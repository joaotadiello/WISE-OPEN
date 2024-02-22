fx_version 'bodacious'
game 'gta5'

ui_page "nui/index.html"

client_scripts {
    '@vrp/lib/utils.lua',
    'client.lua',
    'config.lua'
}

server_scripts {
    '@vrp/lib/utils.lua',
    'server_config.lua',
    'server.lua',
} 

files {
	"nui/assets/*.ogg",
	"nui/assets/*.png",
	"nui/assets/*.gif",
	"nui/index.html",
	"nui/style/*.css",
	"nui/js/config.js",
	"nui/js/font.js",
	"nui/js/ui.js",
}

shared_script {
	'@vrp/lib/utils.lua',
	'shared-config.lua'
}