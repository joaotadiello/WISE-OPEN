fx_version "bodacious"
game {"gta5"}

ui_page "nui/index.html"

server_scripts {
    "@vrp/lib/utils.lua",
    "core.lua",
    'server_config.lua',
	"server.lua",
	"itens.lua",
}

client_scripts  {
	"@vrp/lib/utils.lua",
    "client.lua",
}

files {
	"nui/assets/*.svg",
	"nui/assets/*.png",
	"nui/index.html",
	"nui/js/*.js",
	"nui/css/styles.css"
}