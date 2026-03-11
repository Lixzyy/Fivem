-- Loot selection & ox_inventory bridge

Loot = {}

local function weightPick(list)
    local total = 0
    for _,it in ipairs(list) do total = total + (it.weight or 0) end
    local r = math.random() * total
    local acc = 0
    for _,it in ipairs(list) do
        acc = acc + (it.weight or 0)
        if r <= acc then return it end
    end
    return list[#list]
end

function Loot.RollRewards()
    local rewards = {}
    local rolls = 1
    if LootConfig.Compose and type(LootConfig.Compose) == 'function' then
        local c = LootConfig.Compose()
        if c and c.rolls then rolls = c.rolls end
    end

    for i = 1, rolls do
        local roll = math.random(1, 100)
        local choice
        if roll <= LootConfig.Weights.Money then
            choice = 'Money'
        elseif roll <= LootConfig.Weights.Money + LootConfig.Weights.Weapons then
            choice = 'Weapons'
        else
            choice = 'RareItems'
        end

        if choice == 'Money' then
            local amt = math.random(LootConfig.Money.min, LootConfig.Money.max)
            table.insert(rewards, { type = 'money', amount = amt })
        elseif choice == 'Weapons' then
            local w = LootConfig.Weapons[math.random(1, #LootConfig.Weapons)]
            table.insert(rewards, { type = 'weapon', name = w, ammo = math.random(60, 180) })
        elseif choice == 'RareItems' then
            local item = weightPick(LootConfig.RareItems)
            local count = item.count
            if type(count) == 'table' then count = math.random(count.min or 1, count.max or 1) end
            table.insert(rewards, { type = 'item', name = item.name, label = item.label or item.name, count = count })
        end
    end

    return rewards
end

function Loot.GiveRewards(src, rewards)
    for _, r in ipairs(rewards) do
        if r.type == 'money' then
            -- ox_inventory: donner de l'argent cash comme item 'money'
            exports.ox_inventory:AddItem(src, 'money', r.amount)
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Airdrop',
                description = ('Vous recevez $%d'):format(r.amount),
                type = 'success'
            })

        elseif r.type == 'weapon' then
            -- ox_inventory: donner l'arme + munitions
            exports.ox_inventory:AddItem(src, r.name, 1, { ammo = r.ammo or 0 })
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Airdrop',
                description = ('Arme reçue : %s'):format(r.name),
                type = 'success'
            })

        elseif r.type == 'item' then
            exports.ox_inventory:AddItem(src, r.name, r.count)
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Airdrop',
                description = ('Objet reçu : %s x%d'):format(r.label or r.name, r.count),
                type = 'success'
            })
        end

        print(('[lixzy_drop] gave %s to player %s'):format(json.encode(r), GetPlayerName(src)))
    end
end