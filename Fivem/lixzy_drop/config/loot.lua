


LootConfig = {}

-- Top-level weights for each category
LootConfig.Weights = {
    Money = 55,        -- % of pulls
    Weapons = 35,
    RareItems = 10
}

-- Money rewards (one roll)
LootConfig.Money = {
    min = 5000,
    max = 20000
}

-- Weapons list 
LootConfig.Weapons = {
    'weapon_assaultrifle',
    'weapon_carbinerifle',
    'weapon_smg'
}

LootConfig.RareItems = {
    { name = 'armor', label = 'Body Armor', count = 1, weight = 60 },
    { name = 'medkit', label = 'Medkit', count = {min=1,max=2}, weight = 35 },
    { name = 'special_item', label = 'Special Item', count = 1, weight = 5 }
}


LootConfig.Compose = function()
    return {
        rolls = 1
    }
end
