

fx_version 'adamant'
games {'gta5'}

author 'Lixzy'
version '1.0.0'


--RAGEUI
client_scripts {
    "internal/RageUI/RMenu.lua",
    "internal/RageUI/menu/RageUI.lua",
    "internal/RageUI/menu/Menu.lua",
    "internal/RageUI/menu/MenuController.lua",
    "internal/RageUI/components/*.lua",
    "internal/RageUI/menu/elements/*.lua",
    "internal/RageUI/menu/items/*.lua",
    "internal/RageUI/menu/panels/*.lua",
    "internal/RageUI/menu/windows/*.lua",
    "client/client.lua",
    "client/client_report.lua"
}

-- MENU CLIENT
client_scripts { 
    'client/client.lua',
    'client/client_report.lua'
}

shared_scripts {
    'config.lua'
}

--SERVEUR
server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua'
}


dependencies {
    'es_extended'
}

