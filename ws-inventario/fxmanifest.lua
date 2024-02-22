fx_version "bodacious"
game {"gta5"}

ui_page "html/index.html"


server_scripts {
    "@vrp/lib/utils.lua",
	"server.lua",
    'server_config.lua',
	"itens.lua",
}

client_scripts  {
	"@vrp/lib/utils.lua",
    "client.lua",
	'config.lua',

}

files {
	"html/assets/*.svg",
	"html/assets/*.png",

	"html/index.html",
	"html/js/*.js",
	"html/css/styles.css"
}