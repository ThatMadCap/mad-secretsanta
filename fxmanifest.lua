fx_version 'cerulean'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
game 'gta5'

name 'mad-secretsanta'
version '1.0.0'
description 'Multiplayer Secret Santa'
author 'MadCap'

dependencies {
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'bridge/notify/client.lua',
    'bridge/target/client.lua',
    'bridge/menu/client.lua',
    'modules/client/*.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/framework/server.lua',
    'bridge/notify/server.lua',
    'modules/server/*.lua',
    'server/*.lua'
}

files {
    'locales/*.json',
    'config/*.lua',
    'bridge/**/*.lua'
}
