-- Client entry: receives start, orchestrates plane & crate

-- track which crate IDs have been initialized to avoid duplicate plane spawns
local initializedCrates = {}

RegisterNetEvent('airdrop:client:start', function(data)
    local crateId = data.id
    local drop = data.drop
    local announce = data.announce
    local ownerServerId = data.owner

    -- determine if this client is the owner
    local isOwner = ownerServerId and ownerServerId == GetPlayerServerId(PlayerId())

    print(('[lixzy_drop] client start event received, owner=%s, announce=%s, drop=%.1f,%.1f,%.1f'):format(
        tostring(isOwner), tostring(announce), drop.x, drop.y, drop.z))

    if announce then
        Utils.Notify('~y~Un airdrop militaire est en approche !')
    end

    -- create blip for everyone (shows drop area)
    TriggerEvent('airdrop:client:spawnCrate', crateId, drop)

    -- draw temporary ground indicator so players know where plane will go
    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + 15000
        while GetGameTimer() < endTime do
            DrawMarker(1, drop.x, drop.y, drop.z + 1.0, 0,0,0, 0,0,0, 3.0,3.0,3.0, 0,255,0,150, false, true, 2, false, nil, nil, false)
            Citizen.Wait(0)
        end
    end)

    -- inform owner
    if isOwner then
        Utils.Notify('~g~Vous êtes responsable du drop, l’avion va apparaître.')
    end

    -- only start plane once per crateId
    if not initializedCrates[crateId] then
        initializedCrates[crateId] = true
        Plane.StartRunAndDrop(crateId, drop, isOwner)
    else
        print('[lixzy_drop] ignored duplicate start event for crate', crateId)
    end
end)

-- Allow server to clear entities if needed
RegisterNetEvent('airdrop:client:clear', function()
    Crate.Delete()
end)