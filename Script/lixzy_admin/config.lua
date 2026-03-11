
                                         

-------- EXEMPLE ------------------------------
-- ↓ LA LOGS (pas toucher!!)↓      ↓WEEBOK↓
--        Staffmodeon    =      "CHANGER",
------------------------------------------------

--------- LOGS ---------
Config = {
    webhook = {
        Staffmodeon = "https://discord.com/api/webhooks/",      -- MODE STAFF ON
        Staffmodeoff = "https://discord.com/api/webhooks/",     -- MODE STAFF OFF
        Jail = "https://discord.com/api/webhooks/",
        UnJail = "https://discord.com/api/webhooks/",
        teleport = "https://discord.com/api/webhooks/",
        teleportTo = "https://discord.com/api/webhooks/",
        revive = "https://discord.com/api/webhooks/",
        teleportcoords = "https://discord.com/api/webhooks/",
        teleporttoit = "https://discord.com/api/webhooks/",
        message = "https://discord.com/api/webhooks/",
        annonce = "https://discord.com/api/webhooks/",
        SavellPlayerAuto = "https://discord.com/api/webhooks/",-- SAVE TOUT LES JOUEURS
        clearInv = "https://discord.com/api/webhooks/",        -- CLEAR INVENTAIRE
        clearLoadout = "https://discord.com/api/webhooks/",    -- CLEAR ARME
        WipePlayer = "https://discord.com/api/webhooks/",
        kick = "https://discord.com/api/webhooks/",
        SendLogs = "https://discord.com/api/webhooks/",        -- GENERAL LOGS
        report = "https://discord.com/api/webhooks/"
    }
}

------- JAIL ------
Config.JailBlip     = {x = 256.83, y = -784.37, z = 30.45}  -- coordonnées de la UNJAIL
Config.JailLocation = {x = 1641.64, y = 2571.08, z = 45.50} -- coordonnées de la JAIL 

------- LICENSES -------
Config.Licenses = {
    superadmin = {},
    owner = {},
    manager = {"license:1474ccffb977b13c8fabfb4705d3dda51e219727"},
    admin = {},
    mod = {},
    support = {}
}

Config.GroupOutfits = {
    support = {
        bags_1 = 0, bags_2 = 0,
        tshirt_1 = 15, tshirt_2 = 0,
        torso_1 = 178, torso_2 = 1,
        arms = 130,
        pants_1 = 77, pants_2 = 1,
        shoes_1 = 55, shoes_2 = 1,
        mask_1 = 0, mask_2 = 0,
        bproof_1 = 0,
        chain_1 = 0,
        helmet_1 = 91, helmet_2 = 1,
    },
    mod = {
        bags_1 = 0, bags_2 = 0,
        tshirt_1 = 15, tshirt_2 = 0,
        torso_1 = 291, torso_2 = 0,
        arms = 130,
        pants_1 = 178, pants_2 = 0,
        shoes_1 = 47, shoes_2 = 4,
        mask_1 = 0, mask_2 = 0,
        bproof_1 = 0,
        chain_1 = 0,
        helmet_1 = 91, helmet_2 = 10,
    },
    admin = {
        bags_1 = 0, bags_2 = 0,
        tshirt_1 = 15, tshirt_2 = 2,
        torso_1 = 286, torso_2 = 0,
        arms = 168,
        pants_1 = 50, pants_2 = 0,
        shoes_1 = 24, shoes_2 = 0,
        mask_1 = 0, mask_2 = 0,
        bproof_1 = 0,
        chain_1 = 0,
        helmet_1 = 91, helmet_2 = 10,
    },
    manager = {
        bags_1 = 0, bags_2 = 0,
        tshirt_1 = 15, tshirt_2 = 0,
        torso_1 = 178, torso_2 = 6,
        arms = 168,
        pants_1 = 77, pants_2 = 6,
        shoes_1 = 55, shoes_2 = 6,
        mask_1 = 0, mask_2 = 0,
        bproof_1 = 0,
        chain_1 = 0,
        helmet_1 = 91, helmet_2 = 6,
    },
    owner = {
        bags_1 = 0, bags_2 = 0,
        tshirt_1 = 15, tshirt_2 = 2,
        torso_1 = 311, torso_2 = 0,
        arms = 168,
        pants_1 = 76, pants_2 = 0,
        shoes_1 = 10, shoes_2 = 0,
        mask_1 = 0, mask_2 = 0,
        bproof_1 = 0,
        chain_1 = 0,
        helmet_1 = 91, helmet_2 = 10,
    },
    default = {
        bags_1 = 0, bags_2 = 0,
        tshirt_1 = 15, tshirt_2 = 2,
        torso_1 = 291, torso_2 = 0,
        arms = 168,
        pants_1 = 115, pants_2 = 0,
        shoes_1 = 47, shoes_2 = 4,
        mask_1 = 0, mask_2 = 0,
        bproof_1 = 0,
        chain_1 = 0,
        helmet_1 = 91, helmet_2 = 10,
    }
}


