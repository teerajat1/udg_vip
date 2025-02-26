fx_version 'cerulean'
game 'gta5'

name "udg_vip"
description "udg_vip"
author "udg_vip"
version "1.0.0"

shared_scripts {
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Import the MySQL library
    'server/*.lua'
}
