local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
local vRP = Proxy.getInterface('vRP')

cfg = {}

cfg.core = {
    -- Pega o inventario
    getInventory = function(user_id)
        return vRP.getInventory(user_id)
    end,

    -- Verifica se tem permissão
    hasPermission = function(user_id,permi)
        return vRP.hasPermission(user_id,permi)
    end,

    -- Index do item
    itemIndexList = function(item)
        return vRP.itemIndexList(item)
    end,

    -- Nome do item
    itemNameList = function(item)
        return vRP.itemNameList(item)
    end,

    -- Remover item do player
    tryItem = function(user_id,item,amount)
        return vRP.tryGetInventoryItem(user_id,item,amount)
    end,

    -- Givar item para o player
    giveItem = function(user_id,item,amount)
        vRP.giveInventoryItem(user_id,item,amount)
    end,

    -- Pegar o peso maximo do inventario
    getMaxWeight = function(user_id)
        return vRP.getInventoryMaxWeight(user_id)
    end,

    -- Pega o peso do inventario
    getInventoryWeight = function(user_id)
        return vRP.getInventoryWeight(user_id)
    end, 

    -- Função para pegar o peso do item
    getItemWeight = function(item)
        return vRP.getItemWeight(item)
    end,
}

cfg.ip = 'http://177.54.149.82/vrp_images'

return cfg