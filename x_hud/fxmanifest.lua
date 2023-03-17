fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
lua54 'yes'

name 'xad-hud'
description 'hud do chuja nie podobny uzywasz na własną odpowiedzialnosc :D'
author 'xad'
version '1.0.0'

shared_script '@es_extended/imports.lua'

server_scripts {
    'server/main.lua'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}

dependencies {
    'es_extended',
}

ui_page {
    'html/index.html'
}

files {
    'html/**', 
}
