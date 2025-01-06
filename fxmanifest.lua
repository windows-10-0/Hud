fx_version 'cerulean'
game 'gta5'
author 'windows_10_'
description 'HUD'

client_scripts {
   'client/**'
}

server_scripts {
   'server/**'
}

shared_script 'config.lua'

ui_page 'web/dist/index.html'

files {
   'web/dist/index.html',
   'web/dist/assets/*.js',
   'web/dist/assets/*.css',
   'web/dist/assets/*.ttf',
   'web/dist/assets/*.png',
}