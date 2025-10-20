fx_version 'cerulean'
game 'gta5'

author 'donk'
description 'Admin Zones - Remade with ox_lib and dual framework support'
version '2.0.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'bridge.lua',
    'server/main.lua'
}

files {
    'locales/*.json'
}

dependencies {
    'ox_lib'
}
