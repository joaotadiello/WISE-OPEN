Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

exports("license", function()
    return 'c1b4bfcd21a7d1a803ea55e75744e0ba909ca1ec5d2de1440a2b890934390fa31824041aefeb6cb2382d72c0f71af46a35a0'
end)

giveMoney = function(user_id,value)
    if user_id and value then
        vRP.giveMoney(user_id,value)
        --vRP.giveInventoryItem(user_id,'dinheiro',value) --Caso seu dinheiro seja um item
    end
end

getUserSource = function(user_id)
    return vRP.getUserSource(user_id)
end

giveBankMoney = function(user_id,value)
    if user_id and value then
        vRP.giveBankMoney(user_id,value)
    end
end

getBankMoney = function(user_id)
    --return vRP.getBankMoney(user_id) --vrpex
    return 0
end

getMoney = function(user_id)
    --return vRP.getMoney(user_id)
    return 0

    --return vRP.getInventoryItemAmount(user_id,'dollars') -- DINHEIRO POR ITEM / COMENTE O DE CIMA
end

setBankMoney = function(user_id,value)
    if user_id and value then
        vRP.setBankMoney(user_id,value)
    end
end

getIdentity = function(user_id)
    local _ = {}
    local id = vRP.getUserIdentity(user_id)
    if id and id.name and id.firstname then
        _.name = id.name
        _.firstname = id.firstname
        return _
    else
        print('[\x1b[1;31mERRO\x1b[37m]:Voce precisa arrumar sua funcao de identidade, \x1b[1;31mabra um chamado de suporte \x1b[1;36m[ Wise - Resources ]')
    end
end

Format = function(value)
    return value
end

TryPayment = function(user_id,value)
    return vRP.tryPayment(user_id,value)
end

TryFullPayment = function(user_id,value)
    return vRP.PaymentFull(user_id, value)
end

Prepare = function(key,sql)
    vRP.Prepare(key,sql)
end

GetUsers = function()
    return vRP.Players()
end

Query = function(query,table)
    return vRP.Query(query,table)
end

Execute = function(query,table)
    vRP.Query(query, table)
end

GetUData = function(user_id,key)
    return vRP.UserData(user_id, key) --creative
end

SetUData = function(user_id,key,value)
    vRP.setUData(user_id,key,value)
end