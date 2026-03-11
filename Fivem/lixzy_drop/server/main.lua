-- Server scheduler and orchestration

local running = false
local lastRunAt = 0
local activeCrates = {}
local idCounter = 0

local function nextId()
    idCounter = idCounter + 1
    return ('CRATE-%d-%d'):format(idCounter, os.time())
end

local function getPlayers()
    local list = {}
    for _,src in ipairs(GetPlayers()) do
        list[#list+1] = tonumber(src)
    end
    return list
end

local function pickOwner(drop)
    local players = getPlayers()
    if #players == 0 then return nil end
    local best, bestDist
    for _,src in ipairs(players) do
        local ped = GetPlayerPed(src)
        if ped ~= 0 then
            local coords = GetEntityCoords(ped)
            local dist = #(coords - drop)
            if not bestDist or dist < bestDist then
                best, bestDist = src, dist
            end
        end
    end
    return best or players[math.random(1, #players)]
end

local function broadcast(msg, coords)
    TriggerClientEvent('airdrop:client:announce', -1, msg, coords)
end

local function startAirdrop(ownerOverride, coordsOverride)
    if running then
        print("[lixzy_drop] startAirdrop called but another drop is already active")
        return
    end
    running = true

    local drop = coordsOverride or Locations[math.random(1, #Locations)]
    local owner = ownerOverride or pickOwner(drop)
    if not owner then
        print("[lixzy_drop] startAirdrop aborted: no players online")
        running = false
        return
    end

    print(('[lixzy_drop] spawning airdrop at %.1f, %.1f, %.1f (owner %s)%s'):format(
        drop.x, drop.y, drop.z, owner, ownerOverride and " (forced)" or ""))

    local id = nextId()
    activeCrates[id] = {
        owner = owner,
        coords = drop,
        landed = false,
        busy = false,
        looted = false,
        createdAt = os.time()
    }

    if Config.Event.announceIncoming then
        broadcast('~y~Un airdrop militaire est en approche !', drop)
    end

    TriggerClientEvent('airdrop:client:start', -1, {
        id = id,
        drop = drop,
        announce = Config.Event.announceIncoming,
        owner = owner
    })

    lastRunAt = os.time()
end

-- Scheduler
CreateThread(function()
    while true do
        local waitMs = math.floor((Config.Event.intervalMinutes or 20) * 60 * 1000)
        Wait(waitMs)
        if not Config.Event.enabled then goto continue end

        local players = getPlayers()
        if #players < (Config.Event.minPlayers or 0) then goto continue end
        if math.random(1, 100) > (Config.Event.chance or 100) then goto continue end

        startAirdrop()
        ::continue::
    end
end)

-- ─── Server Events ────────────────────────────────────────────────────────────

RegisterNetEvent('airdrop:server:crateNetId', function(crateId, netId, chuteNetId)
    local crate = activeCrates[crateId]
    if not crate then
        print(('[lixzy_drop] crateNetId: crate %s not found in activeCrates'):format(tostring(crateId)))
        return
    end
    crate.netId = netId
    crate.chuteNetId = chuteNetId
    TriggerClientEvent('airdrop:client:crateNetId', -1, crateId, netId, chuteNetId)
    print(('[lixzy_drop] crate %s | netId=%s | chuteNetId=%s'):format(crateId, tostring(netId), tostring(chuteNetId)))
end)

RegisterNetEvent('airdrop:server:crateDropped', function(crateId, coords)
    if coords then
        TriggerClientEvent('airdrop:client:crateDropped', -1, crateId, coords)
    end
end)

RegisterNetEvent('airdrop:server:crateLanded', function(crateId, coords)
    local crate = activeCrates[crateId]
    if not crate then
        print(('[lixzy_drop] crateLanded: crate %s not found'):format(tostring(crateId)))
        return
    end
    crate.landed = true
    crate.coords = coords

    print(('[lixzy_drop] crate %s landed at %.1f, %.1f, %.1f'):format(crateId, coords.x, coords.y, coords.z))
    broadcast('~g~La caisse a atterri ! Allez la récupérer.', coords)
    TriggerClientEvent('airdrop:client:crateLanded', -1, crateId, coords)
end)

RegisterNetEvent('airdrop:server:tryOpen', function(crateId)
    local src = source
    local crate = activeCrates[crateId]
    print(('[lixzy_drop] tryOpen | src=%s | crateId=%s | found=%s'):format(
        tostring(src), tostring(crateId), tostring(crate ~= nil)))
    if not crate then
        TriggerClientEvent('airdrop:client:denyOpen', src, "Ce colis n'existe plus.")
        return
    end
    if not crate.landed then
        TriggerClientEvent('airdrop:client:denyOpen', src, "La caisse n'a pas encore atterri.")
        return
    end
    if crate.busy then
        TriggerClientEvent('airdrop:client:denyOpen', src, "Quelqu'un ouvre déjà ce colis.")
        return
    end
    if crate.looted then
        TriggerClientEvent('airdrop:client:denyOpen', src, 'Ce colis est vide.')
        return
    end

    crate.busy = true
    crate.busyBy = src
    TriggerClientEvent('airdrop:client:allowOpen', src, crateId)
end)

RegisterNetEvent('airdrop:server:finalizeOpen', function(crateId)
    local src = source
    local crate = activeCrates[crateId]
    if not crate then return end
    if crate.busyBy ~= src then return end
    if crate.looted then return end

    local rewards = Loot.RollRewards()
    Loot.GiveRewards(src, rewards)

    crate.looted = true
    crate.busy = false

    if Config.Event.announceOpened then
        broadcast("~y~Un joueur a ouvert l'airdrop !", crate.coords)
    end

    -- Notifier l'ouvreur
    TriggerClientEvent('airdrop:client:opened', src, crateId, Config.Crate.deleteAfterLootSeconds)
    -- Forcer la suppression chez tous les autres clients
    TriggerClientEvent('airdrop:client:clear', -1)

    SetTimeout((Config.Crate.deleteAfterLootSeconds + 2) * 1000, function()
        activeCrates[crateId] = nil
        running = false  -- toujours reset, même si d'autres crates actifs
        print(('[lixzy_drop] crate %s cleared, running=false'):format(crateId))
    end)

    if Config.Webhook and Config.Webhook.url and Config.Webhook.url ~= '' then
        PerformHttpRequest(Config.Webhook.url, function() end, 'POST', json.encode({
            username = Config.Webhook.username or 'Airdrop System',
            avatar_url = Config.Webhook.avatar or '',
            embeds = { {
                title = 'Airdrop ouvert',
                description = ('Player **%s** opened crate **%s**'):format(GetPlayerName(src), crateId),
                color = 16711680,
                fields = {
                    { name = 'Coords', value = ('%.2f, %.2f, %.2f'):format(
                        crate.coords.x, crate.coords.y, crate.coords.z), inline = true },
                },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
            } }
        }), { ['Content-Type'] = 'application/json' })
    end
end)

RegisterCommand('airdropspawn', function(source, args, rawCommand)
    if running then
        if source ~= 0 then
            TriggerClientEvent('chat:addMessage', source, { args = { '^1[lixzy_drop]', 'Airdrop already active.' } })
        end
        return
    end

    local coords = nil
    if #args >= 3 then
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if x and y and z then coords = vector3(x, y, z) end
    elseif source ~= 0 then
        local ped = GetPlayerPed(source)
        if ped and ped ~= 0 then coords = GetEntityCoords(ped) end
    end

    local overrideOwner = source ~= 0 and source or nil

    if source == 0 then
        print('[lixzy_drop] manual spawn from console')
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^2[lixzy_drop]', 'Manual airdrop requested.' } })
    end

    broadcast('~y~Un airdrop a été lancé manuellement par un administrateur.')
    startAirdrop(overrideOwner, coords)
end, false)

AddEventHandler('playerDropped', function()
    local src = source
    for id, crate in pairs(activeCrates) do
        if crate.busyBy == src and not crate.looted then
            crate.busy = false
            crate.busyBy = nil
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
end)