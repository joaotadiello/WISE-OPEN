Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")


giveMoney = function(user_id,value)
    if user_id and value then
        vRP.GiveItem(user_id,'dollars',value) --Caso seu dinheiro seja um item
    end
end

getUserSource = function(user_id)
    return vRP.Source(user_id)
end

giveBankMoney = function(user_id,value)
    if user_id and value then
		vRP.GiveBank(user_id,value)
    end
end

getBankMoney = function(user_id)
    return vRP.GetBank(vRP.Source(user_id))
end

getMoney = function(user_id)
    return vRP.ItemAmount(user_id,'dollars')
end

setBankMoney = function(user_id,value)
    if user_id and value then
        vRP.setBankMoney(user_id,value)
    end
end

getIdentity = function(user_id)
    local _ = {}
    local id = vRP.FullName(user_id)
    if id then
        _.name = id
        _.firstname = ''
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
    return vRP.PaymentFull(user_id,value)
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
    vRP.execute(query,table)
end

GetUData = function(user_id,key)
    local entity = vRP.Query("playerdata/GetData",{ Passport = user_id, Name = key })
    return entity and entity[1] and entity[1]['Information'] or json.encode({})
end 

SetUData = function(user_id,key,value)
	vRP.Query("playerdata/SetData",{ Passport = user_id, Name = key, Information = value })
end