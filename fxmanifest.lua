fx_version 'bodacious'
game 'gta5'

name 'vCAD UI - ESX Version'
author 'Ffrankys, Flixxx, Tallerik & Mîhó'
version '1.5.0'

client_scripts {
	'config.lua',
    'config/config_zones.lua',
    'config/config_katalog.lua',

	'client/client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',

    'config/config.lua',
    'config/config_zones.lua',
    'config/config_katalog.lua',

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

/*
dependencies {
	'mysql-async'
}
*/
