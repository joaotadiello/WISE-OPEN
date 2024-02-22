local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
local vRP = Proxy.getInterface('vRP')

pass = {
    [1] = {
        xp = 200,
        nome = '10x energetico',
        img = 'energetico',

        execute = function(source,user_id)
            vRP.giveInventoryItem(user_id,'energetico',10)
            TriggerClientEvent('Notify',source,'sucesso','Você recebeu 10x energeticos')
            return true
        end,
    },

    [2] = {
        xp = 350,
        nome = '5x celulares',
        img = 'celular',

        execute = function(source,user_id)
            vRP.giveInventoryItem(user_id,'celular',5)
            TriggerClientEvent('Notify',source,'sucesso','Você recebeu 5x celulares')
            return true
        end,
    },

    [3] = {
        xp = 550,
        nome = '1x Glock-18',
        img = 'glock',

        execute = function(source,user_id)
            vRP.giveInventoryItem(user_id,'wbody|WEAPON_COMBATPISTOL',1)
            TriggerClientEvent('Notify',source,'sucesso','Você recebeu 1x glock')
            return true
        end,
    },

    [4] = {
        xp = 750,
        nome = 'Munição Glock',
        img = 'm-glock',

        execute = function(source,user_id)
            vRP.giveInventoryItem(user_id,'wammo|WEAPON_COMBATPISTOL',200)
            TriggerClientEvent('Notify',source,'sucesso','Você recebeu 200x munições de glock')
            return true
        end,
    },

    [5] = {
        xp = 1000,
        nome = 'Kuruma',
        img = 'kuruma',

        execute = function(source,user_id)
            AddVehicleToPlayer(source,user_id,'kuruma')
            return true
        end,
    },

    [6] = {
        xp = 1500,
        nome = 'pacote de armas',
        img = 'maconha',

        execute = function(source,user_id)
            print('recebeu')
            return true
        end,
    },

    [7] = {
        xp = 2000,
        nome = 'pacote de armas',
        img = 'maconha',

        execute = function(source,user_id)
            print('recebeu')
            return true
        end,
    },

    [8] = {
        xp = 2500,
        nome = 'pacote de armas',
        img = 'maconha',

        execute = function(source,user_id)
            print('recebeu')
            return true
        end,
    },

    [9] = {
        xp = 3000,
        nome = 'pacote de armas',
        img = 'maconha',

        execute = function(source,user_id)
            print('recebeu')
            return true
        end,
    },

    [10] = {
        xp = 4000,
        nome = 'pacote de armas',
        img = 'maconha',

        execute = function(source,user_id)
            AddVehicleToPlayer(source,user_id,'kuruma')
            return true
        end,
    },

    [11] = {
        xp = 5000,
        nome = 'pacote de armas',
        img = 'maconha',

        execute = function(source,user_id)
            print('recebeu')
            return true
        end,
    },
}