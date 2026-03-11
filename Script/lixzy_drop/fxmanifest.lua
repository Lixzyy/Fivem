fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Advanced Airdrop System'
author 'lixzy'
description 'Premium-grade Advanced Airdrop System for FiveM with plane flyover, parachute crate, loot, blips, effects, and notifications.'
version '1.0.0'

dependencies {
    'ox_lib',
    'ox_inventory'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/utils.lua',
    'config/config.lua',
    'config/loot.lua',
    'config/locations.lua'
}

client_scripts {
    'client/ui.lua',
    'client/effects.lua',
    'client/crate.lua',
    'client/plane.lua',
    'client/main.lua'
}

server_scripts {
    'server/loot.lua',
    'server/events.lua',
    'server/main.lua'
}

files {
}

escrow_ignore {
    'config/*.lua',
    'shared/*.lua',
    'server/loot.lua'
}