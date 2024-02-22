Tunnel = module('vrp','lib/Tunnel')
Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')

active = {}

GiveItem = function(user_id,item,amount)
    return vRP.giveInventoryItem(user_id,item,amount,true)
end

TryItem = function(user_id,item,amount)
    return vRP.tryGetInventoryItem(user_id,item,amount,true)
end

ItemIndex = function(item)
    return vRP.itemIndexList(item)
end

ItemName = function(item)
    return vRP.itemNameList(item)
end

GetTableSize = function(table)
    local n = 0
    for k,v in pairs(table) do n = n + 1 end
    return n
end

GetBackPack = function(user_id)
    return vRP.getBackpack(user_id)
end

GetInvWeight = function(user_id)
    return vRP.computeInvWeight(user_id)
end

GetItemWeight = function(item)
    return vRP.itemWeightList(item)
end

HasPermission = function(user_id,perm)
    return vRP.hasPermission(user_id,perm)
end

webhook = function(webhook,message)
    if webhook ~= "none" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end