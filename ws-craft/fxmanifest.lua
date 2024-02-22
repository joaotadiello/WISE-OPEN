fx_version "bodacious"
game {"gta5"}

ui_page "html/index.html"


server_scripts {
    "@vrp/lib/utils.lua",
    'server_config.lua',
	'config.lua',
	"server.lua",
}

client_scripts  {
	"@vrp/lib/utils.lua",
	'config.lua',
    "client.lua",

}

files {
	"html/assets/*.svg",
	"html/assets/*.png",

	"html/index.html",
	"html/js/*.js",
	"html/css/styles.css"
}