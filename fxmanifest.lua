fx_version 'bodacious'
game 'gta5'

name 'vCAD UI'
author 'Ffrankys, Flixxx, Tallerik & Mîhó'
version '1.4.1'

client_scripts {
	'config/config.lua',
    'config/config_zones.lua',
    'config/config_katalog.lua',
    'config/config_sonstiges.lua',
	'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',

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
