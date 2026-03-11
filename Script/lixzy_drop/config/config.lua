Config = {}

-- Event schedule / logic
Config.Event = {
    enabled = true,                 -- Master switch
    intervalMinutes = 60,           -- How often to attempt an airdrop
    minPlayers = 20,                 -- Minimum players required online
    chance = 70,                    -- % chance to actually trigger when the timer hits
    announceIncoming = true,        -- Sends incoming notification + blips
    announceLanded = true,          -- Sends landed notification
    announceOpened = true           -- Sends notification when someone opens it
}

-- Plane settings
Config.Plane = {
    model = 'bombushka',           -- Plane model (e.g., 'titan', 'cargoplane')
    pilotModel = 's_m_m_pilot_02',  -- Pilot ped
    speed = 120.0,                  -- Target speed in m/s for mission tasking
    altitude = 500.0,               -- Flight altitude above sea level (lower for visibility)
    spawnDistance = 500.0,         -- How far outside the drop zone to spawn the plane (closer for tests)
    dropOffset = 0.0,               -- How many meters before the target to release crate (positive releases early)
    despawnDistance = 500.0,       -- Distance beyond drop to despawn
    dropRadius = 80.0  -- Augmenté à 80m pour compenser la vitesse de l'avion
}

-- Crate settings
Config.Crate = {
    model = 'prop_box_wood05a',  -- Crate model; replace with a custom model in stream if desired
    parachuteModel = 'p_cargo_chute_s',
    groundDuration = 15 * 60,       -- Seconds the crate remains if not looted
    deleteAfterLootSeconds = 60,    -- Seconds to delete after loot
    marker = {
        enabled = true,
        type = 2,                    -- Marker type
        scale = {x = 0.5, y = 0.5, z = 0.5},
        color = {r = 255, g = 0, b = 0, a = 160}
    }
}

-- Map blip and radius
Config.Blip = {
    enabled = true,
    sprite = 408,        -- Parachute icon
    color = 1,           -- Red
    scale = 1.0,
    radius = 250.0,      -- Meters radius shown on the map circle
    alpha = 120,         -- Transparency of radius area
    shortRange = false
}

-- Keybinds & interaction
Config.Interaction = {
    key = 38,                   -- E default (INPUT_PICKUP). (Alternative: 51 for INPUT_CONTEXT)
    holdSeconds = 6,            -- How long to hold to open
    distance = 2.0              -- Max distance to interact
}

-- Visual & audio effects
Config.Effects = {
    planeEngineSound = true,  -- Attempt to play plane engine sound (may vary by game build)
    crateLandingSound = true,
    redSmoke = true
}

-- Optional Discord webhook for logging (leave empty to disable)
Config.Webhook = {
    url = '', -- 'https://discord.com/api/webhooks/...'
    username = 'Airdrop System',
    avatar = ''
}

-- Framework bridge preferences (auto-detects if left to 'auto')
Config.Framework = {
    type = 'auto',           -- 'auto' | 'esx' | 'qbcore' | 'standalone'
    moneyAccount = 'cash'    -- for ESX choose 'money' or 'cash' depending on your build
}