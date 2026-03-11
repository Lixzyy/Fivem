-- Plane handling: spawn outside map, fly over, drop crate, despawn

Plane = {
    entity = nil,
    pilot = nil,
    blip = nil
}

local function computeSpawnAndRoute(target)
    local angle = math.rad(math.random(0, 359) + 0.0)
    local dir = vector3(math.cos(angle), math.sin(angle), 0.0)
    local start = target + (dir * Config.Plane.spawnDistance)
    local finish = target - (dir * Config.Plane.despawnDistance)
    return start, finish
end

local function cleanup()
    if Plane.pilot and DoesEntityExist(Plane.pilot) then DeleteEntity(Plane.pilot) end
    if Plane.entity and DoesEntityExist(Plane.entity) then DeleteEntity(Plane.entity) end
    if Plane.blip and DoesBlipExist(Plane.blip) then RemoveBlip(Plane.blip) end
    Plane.pilot, Plane.entity, Plane.blip = nil, nil, nil
end

function Plane.StartRunAndDrop(crateId, dropCoords, authoritative)
    authoritative = (authoritative == nil) and true or authoritative

    if not Utils.LoadModel(Config.Plane.model) then
        Utils.Notify("~r~Erreur: modèle d'avion introuvable.")
        return
    end
    if not Utils.LoadModel(Config.Plane.pilotModel) then
        Utils.Notify('~r~Erreur: modèle de pilote introuvable.')
        return
    end

    local start, finish = computeSpawnAndRoute(dropCoords)
    start  = vector3(start.x,  start.y,  Config.Plane.altitude)
    finish = vector3(finish.x, finish.y, Config.Plane.altitude)

    local plane = CreateVehicle(GetHashKey(Config.Plane.model), start.x, start.y, start.z, 0.0, true, true)
    if not plane or plane == 0 then
        Utils.Notify("~r~Erreur: impossible de créer l'avion.")
        return
    end
    print(('[lixzy_drop] plane spawned | handle=%s | pos=%.1f,%.1f,%.1f'):format(tostring(plane), start.x, start.y, start.z))

    SetEntityHeading(plane, GetHeadingFromVector_2d(dropCoords.x - start.x, dropCoords.y - start.y))
    SetEntityInvincible(plane, true)
    SetVehicleDoorsLocked(plane, 4)
    SetVehicleEngineOn(plane, true, true, false)

    local pilot = CreatePedInsideVehicle(plane, 1, GetHashKey(Config.Plane.pilotModel), -1, true, true)
    SetBlockingOfNonTemporaryEvents(pilot, true)
    SetPedKeepTask(pilot, true)

    Plane.entity = plane
    Plane.pilot  = pilot

    -- Blip on plane so players can track it
    Plane.blip = AddBlipForEntity(plane)
    SetBlipSprite(Plane.blip, 16)
    SetBlipColour(Plane.blip, 3)
    SetBlipScale(Plane.blip, 0.8)
    SetBlipAsShortRange(Plane.blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Airdrop Plane')
    EndTextCommandSetBlipName(Plane.blip)

    Effects.PlayPlaneEngine(plane)

    -- Task AI pilot to fly toward finish point
    TaskPlaneMission(pilot, plane, 0, 0, finish.x, finish.y, finish.z, 4, Config.Plane.speed, 0.0, 90.0, 500.0, 50.0)

    -- Monitor approach to drop point
    Citizen.CreateThread(function()
        local dropped = false
        local radius  = Config.Plane.dropRadius or 80.0

        while DoesEntityExist(plane) do
            Citizen.Wait(50)

            local planePos = GetEntityCoords(plane)
            -- Measure horizontal distance only (ignore altitude difference)
            local dist = #(vector3(planePos.x, planePos.y, 0.0) - vector3(dropCoords.x, dropCoords.y, 0.0))

            -- Trigger drop when plane is within radius of the target
            if not dropped and dist <= radius then
                dropped = true
                local dropPos = vector3(dropCoords.x, dropCoords.y, Config.Plane.altitude)
                print(('[lixzy_drop] drop triggered | dist=%.1f | pos=%.1f,%.1f,%.1f'):format(dist, dropPos.x, dropPos.y, dropPos.z))

                if authoritative then
                    Crate.BeginFallFrom(dropPos, crateId)
                    TriggerServerEvent('airdrop:server:crateDropped', crateId, dropPos)
                end
            end

            -- Despawn plane once it passes well beyond the finish point
            local distToFinish = #(vector3(planePos.x, planePos.y, 0.0) - vector3(finish.x, finish.y, 0.0))
            if distToFinish < 150.0 and dropped then
                print('[lixzy_drop] plane reached finish, cleaning up')
                cleanup()
                break
            end
        end
    end)
end