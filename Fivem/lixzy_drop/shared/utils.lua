-- Shared utilities (client & server)

Utils = {}

function Utils.Debug(msg)
    if GetConvarInt('airdrop_debug', 0) == 1 then
        print(('^3[AIRDROP DEBUG]^7 %s'):format(msg))
    end
end

function Utils.RandomFloat(min, max)
    return min + math.random() * (max - min)
end

-- Model loader (client only)
function Utils.LoadModel(model)
    if type(model) == 'string' then model = GetHashKey(model) end
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
        if GetGameTimer() > timeout then return false end
    end
    return true
end

function Utils.UnloadModel(model)
    if type(model) == 'string' then model = GetHashKey(model) end
    SetModelAsNoLongerNeeded(model)
end

-- Animation dict loader (client only)
function Utils.LoadAnimDict(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 8000
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
        if GetGameTimer() > timeout then return false end
    end
    return true
end

function Utils.Notify(msg, type)
    TriggerEvent('ox_lib:notify', {
        title = 'Airdrop',
        description = msg,
        type = type or 'inform'
    })
end

-- Distance helper
function Utils.Distance(a, b)
    return #(a - b)
end