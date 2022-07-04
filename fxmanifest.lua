fx_version 'bodacious'
game 'gta5'

name 'vCAD UI - QBCore Version'
author 'Ffrankys, Flixxx, Tallerik, Mîhó & divide29'
version '2.0.0'

client_scripts {
    '@menuv/menuv.lua',
	'config/config.lua',
    'config/config_zones.lua',
    'config/config_katalog.lua',
    'config/config_sonstiges.lua',

	'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',

    'config/config.lua',
    'config/config_zones.lua',
    'config/config_katalog.lua',
    'config/config_sonstiges.lua',

    'server/server.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/functions.js',
    'nui/main.css',
    'nui/new.css',
    'nui/tablet.png'
}
