fx_version 'bodacious'
game 'gta5'

client_scripts {
    '@vrp/lib/utils.lua',
    'config/config.lua',
    'client-side/client.lua',
}

server_scripts {
    '@vrp/lib/utils.lua',
    'server-side/core.lua',
    'server-side/server.lua',
} 

shared_script {
	'config/shared-config.lua'
}