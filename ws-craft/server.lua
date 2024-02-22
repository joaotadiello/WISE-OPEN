local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
local config = module('ws-craft','config')
vRP = Proxy.getInterface('vRP')

srv = {}
Tunnel.bindInterface('ws-craft',srv)
Proxy.addInterface('ws-craft',srv)

local userCraft = {}
local active  = {}


srv.getInventory = function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local itens = {}
        local inv = cfg.core.getInventory(user_id)
        for k,v in pairs(inv) do
            if cfg.core.itemNameList(k) then
                table.insert(itens,{key = k,index = cfg.core.itemIndexList(k),name = cfg.core.itemNameList(k),amount = v.amount})
            end
        end
        return itens
    end
end

srv.itemIndexList = function(itemName)
    return cfg.core.itemIndexList(itemName)
end

srv.getPlayerWeight = function(floresta)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local item = config.craft[floresta].giveItem
        local amount = config.craft[floresta].quantidade
        local playerMaxInv = cfg.core.getMaxWeight(user_id)
        local weightCurrent = cfg.core.getInventoryWeight(user_id)

        if playerMaxInv and weightCurrent then
            if (weightCurrent + (cfg.core.getItemWeight(item) * amount)) <= playerMaxInv then
                return true
            else
                TriggerClientEvent('Notify',source,'aviso','Espaço insuficiente na mochila!')
                return false
            end
        end
    end
end

srv.hasPermission = function(item)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if config.craft[item] then
            if config.craft[item].permi == nil then
                return true
            else
                if cfg.core.hasPermission(user_id,config.craft[item].permi) then
                    return true
                else
                    TriggerClientEvent('Notify',source,'negado','Você não possui permissão para criar este item!')
                    return false
                end
            end
        end
    end
end

RegisterServerEvent('open:craft')
AddEventHandler('open:craft',function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        userCraft[user_id] = {}
    end
end)

RegisterServerEvent('close:craft')
AddEventHandler('close:craft',function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        for k,v in pairs(userCraft[user_id]) do
            if userCraft[user_id][k] then
                vRP.giveInventoryItem(user_id,k,v.amount)
                userCraft[user_id][k] = nil
            end
        end
        userCraft[user_id] = {}
        TriggerClientEvent('close:craft:fix',source)
    end
end)

srv.getIp = function()
    return cfg.ip
end

---------------------------------------------------------
--- [ Cada item depositado no craft é armazenado aqui ] -
---------------------------------------------------------
srv.depositarItem = function(item,amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if userCraft[user_id] then
            if cfg.core.tryItem(user_id,item,amount) then
                if userCraft[user_id][item] then
                    userCraft[user_id][item].amount = userCraft[user_id][item].amount + amount
                else
                    userCraft[user_id][item] = {amount = amount}
                end
                return true
            else
                TriggerClientEvent('Notify',source,'negado','Você não possui está quantidade!')
                return false
            end
        end
    end
end

srv.reembolsoItens = function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and not active[user_id] then
        active[user_id] = true
        if userCraft[user_id] then
            for k,v in pairs(userCraft[user_id]) do
                if v ~= nil then
                    cfg.core.giveItem(user_id,k,v.amount)
                    userCraft[user_id][k] = nil
                    active[user_id] = false
                end
            end
            TriggerClientEvent('Notify',source,'aviso','Você recebeu seus itens de volta!')
        end
    end
end

---------------------------------------------------------
--- [ Funcao quando finaliza o craft ] ------------------
---------------------------------------------------------
srv.djskjdks = function(floresta)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and config.craft[floresta] then
        if not active[user_id] then
            active[user_id] = true
            local item = config.craft[floresta].giveItem
            local amount = config.craft[floresta].quantidade
            local playerMaxInv = cfg.core.getMaxWeight(user_id)
            local weightCurrent = cfg.core.getInventoryWeight(user_id)

            if playerMaxInv and weightCurrent then
                if (weightCurrent + (cfg.core.getItemWeight(item) * amount)) <= playerMaxInv then
                    userCraft[user_id] = {}
                    cfg.core.giveItem(user_id,item,amount)
                    TriggerClientEvent('Notify',source,'sucesso','Você recebeu '..amount.."x "..cfg.core.itemNameList(item))
                end
            else
                TriggerClientEvent('Notify',source,'aviso','Espaço insuficiente na mochila!')
            end
            active[user_id] = false
        end
    end
end
