-- Crate entity management & interaction

Crate = {
    current = nil,
    id = nil,
    coords = nil,
    landed = false,
    blip = nil,
    radius = nil,
    parachute = nil,
    owner = false,
    busy = false
}

-- Announce blips (shown before crate lands)
local announceBlips = {}

local function createBlipsAt(coords)
    if not Config.Blip.enabled then return end
    Crate.blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(Crate.blip, Config.Blip.sprite)
    SetBlipColour(Crate.blip, Config.Blip.color)
    SetBlipScale(Crate.blip, Config.Blip.scale)
    SetBlipAsShortRange(Crate.blip, Config.Blip.shortRange)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Airdrop')
    EndTextCommandSetBlipName(Crate.blip)

    Crate.radius = AddBlipForRadius(coords.x, coords.y, coords.z, Config.Blip.radius)
    SetBlipColour(Crate.radius, Config.Blip.color)
    SetBlipAlpha(Crate.radius, Config.Blip.alpha)
end

local function clearBlips()
    if Crate.blip and DoesBlipExist(Crate.blip) then RemoveBlip(Crate.blip) end
    if Crate.radius and DoesBlipExist(Crate.radius) then RemoveBlip(Crate.radius) end
    Crate.blip, Crate.radius = nil, nil
end

function Crate.Spawn(owner, id, dropCoords)
    Crate.owner = owner
    Crate.id = id
    Crate.coords = dropCoords
    Crate.landed = false
    Crate.busy = false
    createBlipsAt(dropCoords)
end

function Crate.Delete()
    if Crate.parachute and DoesEntityExist(Crate.parachute) then
        DetachEntity(Crate.parachute, true, true)
        DeleteEntity(Crate.parachute)
    end
    if Crate.current and DoesEntityExist(Crate.current) then
        DeleteEntity(Crate.current)
    end
    Effects.StopRedSmoke()
    clearBlips()
    -- Nettoyer les announce blips restants
    for _, b in ipairs(announceBlips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end
    announceBlips = {}
    Crate.current, Crate.parachute, Crate.id = nil, nil, nil
    Crate.coords = nil
    Crate.landed = false
    Crate.owner = false
    Crate.busy = false
    print('[lixzy_drop] Crate.Delete() called, state reset')
end

function Crate.BeginFallFrom(startCoords, crateId)
    -- Assigner ET capturer localement pour usage sûr dans les threads
    if crateId then Crate.id = crateId end
    local localCrateId = Crate.id  -- capture locale immuable
    print(('[lixzy_drop] BeginFallFrom | crate=%s | pos=%.1f,%.1f,%.1f'):format(
        tostring(localCrateId), startCoords.x, startCoords.y, startCoords.z))

    Effects.StartRedSmokeAt(startCoords)

    -- Load crate model
    local crateModel = Config.Crate.model
    if not Utils.LoadModel(crateModel) then
        print('[lixzy_drop] primary crate model failed, trying fallback')
        crateModel = 'prop_box_wood02a'
        if not Utils.LoadModel(crateModel) then
            Utils.Notify('~r~Erreur: aucun modèle de caisse valide.')
            return
        end
    end

    -- Load parachute model
    local chuteModel = Config.Crate.parachuteModel or 'p_cargo_chute_s'
    print(('[lixzy_drop] loading chute model: %s | inCdimage: %s'):format(
        chuteModel, tostring(IsModelInCdimage(GetHashKey(chuteModel)))))
    if not Utils.LoadModel(chuteModel) then
        print('[lixzy_drop] parachute model failed to load, continuing without')
        chuteModel = nil
    end

    -- Spawn crate as a networked object (OneSync will sync to all clients)
    local crate = CreateObject(GetHashKey(crateModel), startCoords.x, startCoords.y, startCoords.z, true, true, false)
    if not crate or crate == 0 then
        Utils.Notify('~r~Erreur: impossible de créer la caisse.')
        return
    end

    SetEntityHeading(crate, math.random(0, 360) + 0.0)
    SetEntityInvincible(crate, false)
    SetEntityRecordsCollisions(crate, true)
    -- Make sure physics are active so velocity works
    ActivatePhysics(crate)

    -- Spawn and attach parachute
    local parachute = nil
    if chuteModel then
        parachute = CreateObject(GetHashKey(chuteModel), startCoords.x, startCoords.y, startCoords.z + 0.5, true, true, false)
        if parachute and parachute ~= 0 then
            AttachEntityToEntity(
                parachute, crate,
                0,
                0.0, 0.0, 0.5,  -- Z offset: parachute floats above crate
                0.0, 0.0, 0.0,
                false, false, false, false, 2, true
            )
            Crate.parachute = parachute
            print(('[lixzy_drop] parachute attached | handle=%s'):format(parachute))
        else
            parachute = nil
            print('[lixzy_drop] parachute entity failed to create')
        end
    end

    Crate.current = crate

    -- Broadcast networkIds à tous les autres clients via serveur
    local netId = NetworkGetNetworkIdFromEntity(crate)
    local chuteNetId = parachute and NetworkGetNetworkIdFromEntity(parachute) or nil
    TriggerServerEvent('airdrop:server:crateNetId', localCrateId, netId, chuteNetId)
    print(('[lixzy_drop] netId=%s | chuteNetId=%s'):format(tostring(netId), tostring(chuteNetId)))

    -- Controlled fall loop
    Citizen.CreateThread(function()
        local landed = false
        while DoesEntityExist(crate) and not landed do
            Citizen.Wait(50)

            local coords = GetEntityCoords(crate)
            Crate.coords = coords

            -- Always apply controlled downward velocity (parachute effect)
            SetEntityVelocity(crate, 0.0, 0.0, -4.0)

            -- Try ground detection (only reliable when terrain is loaded nearby)
            local groundFound, gz = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)

            local touchedGround = false
            if groundFound and gz and gz ~= 0 then
                -- Ground is loaded: check if close enough
                if (coords.z - gz) <= 1.8 then
                    touchedGround = true
                end
            else
                -- Ground not loaded yet: fallback to IsEntityInAir
                if not IsEntityInAir(crate) then
                    touchedGround = true
                end
            end

            if touchedGround then
                landed = true

                SetEntityVelocity(crate, 0.0, 0.0, 0.0)
                FreezeEntityPosition(crate, true)

                -- Snap to ground if we have gz, otherwise leave where it is
                if gz and gz ~= 0 then
                    SetEntityCoords(crate, coords.x, coords.y, gz + 0.3, false, false, false, false)
                end

                -- Detach and remove parachute
                if parachute and DoesEntityExist(parachute) then
                    DetachEntity(parachute, true, true)
                    DeleteEntity(parachute)
                    Crate.parachute = nil
                    print('[lixzy_drop] parachute removed on landing')
                end

                local landCoords = GetEntityCoords(crate)
                Crate.landed = true
                print(('[lixzy_drop] crate landed at %.1f, %.1f, %.1f'):format(landCoords.x, landCoords.y, landCoords.z))

                TriggerServerEvent('airdrop:server:crateLanded', localCrateId, landCoords)
                Effects.PlayCrateLandSound(crate)
                Effects.StartRedSmokeAt(landCoords)
            end
        end
    end)

    -- Auto-delete if nobody loots within groundDuration
    Citizen.CreateThread(function()
        local ttl = Config.Crate.groundDuration
        while ttl > 0 and localCrateId do
            Citizen.Wait(1000)
            ttl = ttl - 1
        end
        if localCrateId and Crate.current and DoesEntityExist(Crate.current) then
            print('[lixzy_drop] crate expired, deleting')
            Crate.Delete()
        end
    end)
end

-- ─── Proximity loop: marker + interaction hint ───────────────────────────────
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        -- Crate.current peut être nil pour les non-owners, on utilise Crate.coords directement
        if Crate.id and Crate.landed and Crate.coords then
            local ply = PlayerPedId()
            local pcoords = GetEntityCoords(ply)
            local ccoords = Crate.coords
            local dist = #(pcoords - ccoords)

            if dist < 25.0 then
                UI_DrawMarker(ccoords)
            end

            if dist < Config.Interaction.distance then
                UI_Draw3DText(ccoords + vector3(0.0, 0.0, 0.75), '~y~Appuyez sur ~b~E ~y~pour ouvrir')
                if IsControlJustPressed(0, Config.Interaction.key) and not Crate.busy then
                    print(('[lixzy_drop] trying to open crate %s'):format(tostring(Crate.id)))
                    TriggerServerEvent('airdrop:server:tryOpen', Crate.id)
                end
            else
                Citizen.Wait(250)
            end
        else
            Citizen.Wait(500)
        end
    end
end)

-- ─── Net Events ──────────────────────────────────────────────────────────────

RegisterNetEvent('airdrop:client:allowOpen', function(crateId)
    if not Crate.id or crateId ~= Crate.id then return end
    local ply = PlayerPedId()
    local dict = 'amb@prop_human_bum_bin@base'
    if Utils.LoadAnimDict(dict) then
        TaskPlayAnim(ply, dict, 'base', 8.0, -8.0, Config.Interaction.holdSeconds * 1000, 1, 0.0, false, false, false)
    end
    UI_ShowProgress(Config.Interaction.holdSeconds, 'Ouverture du colis...')
    Crate.busy = true

    Citizen.SetTimeout(Config.Interaction.holdSeconds * 1000, function()
        UI_HideProgress()
        ClearPedTasks(ply)
        TriggerServerEvent('airdrop:server:finalizeOpen', Crate.id)
    end)
end)

RegisterNetEvent('airdrop:client:denyOpen', function(msg)
    if msg then Utils.Notify(msg) end
    Crate.busy = false
end)

RegisterNetEvent('airdrop:client:opened', function(crateId, deleteDelay)
    if not Crate.id or crateId ~= Crate.id then return end
    Utils.Notify('Vous avez récupéré le contenu de l\'airdrop !', 'success')
    Crate.busy = false
    -- L'ouvreur supprime après le délai, le clear server s'occupera des autres
    Citizen.SetTimeout((deleteDelay or Config.Crate.deleteAfterLootSeconds) * 1000, function()
        Crate.Delete()
    end)
end)

RegisterNetEvent('airdrop:client:clear', function(crateId)
    -- Si l'ouvreur reçoit clear, il ignore car opened s'en charge déjà avec délai
    if Crate.busy then return end
    -- Petit délai pour laisser l'animation se terminer chez les spectateurs
    Citizen.SetTimeout(2000, function()
        Crate.Delete()
    end)
end)

RegisterNetEvent('airdrop:client:announce', function(msg, dropCoords)
    if msg then Utils.Notify(msg) end
    if dropCoords then
        local tmpBlip = AddBlipForRadius(dropCoords.x, dropCoords.y, dropCoords.z, Config.Blip.radius)
        SetBlipColour(tmpBlip, Config.Blip.color)
        SetBlipAlpha(tmpBlip, Config.Blip.alpha)
        announceBlips[#announceBlips + 1] = tmpBlip
        Citizen.SetTimeout(120000, function()
            if DoesBlipExist(tmpBlip) then RemoveBlip(tmpBlip) end
            for i, v in ipairs(announceBlips) do
                if v == tmpBlip then table.remove(announceBlips, i); break end
            end
        end)
    end
end)

RegisterNetEvent('airdrop:client:crateLanded', function(id, coords)
    -- Pour les non-owners, Crate.id peut être nil ou pas encore set, on force l'assignation
    if Crate.id and Crate.id ~= id then return end
    Crate.id = id
    Crate.coords = coords
    Crate.landed = true

    -- Move blips to actual landing spot
    clearBlips()
    createBlipsAt(coords)

    -- Brief ground marker
    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + 15000
        while GetGameTimer() < endTime do
            DrawMarker(1, coords.x, coords.y, coords.z + 1.0, 0,0,0, 0,0,0, 2.0,2.0,2.0, 255,0,0,150, false, true, 2, false, nil, nil, false)
            Citizen.Wait(0)
        end
    end)

    -- Clear announce radii
    for _, b in ipairs(announceBlips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end
    announceBlips = {}
end)