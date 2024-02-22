fx_version "bodacious"
game {"gta5"}

ui_page_preload "yes"
ui_page "nui/app.html"

server_scripts {
    "@vrp/lib/utils.lua",
    'server_config.lua',
	"server.lua",
}

client_scripts  {
	"@vrp/lib/utils.lua",
	'config.lua',
    "client.lua",
}

files {
	"nui/app.html",
	"nui/src/img/*.png",
	"nui/src/js/*.js",
	"nui/src/css/app.css"
}