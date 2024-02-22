local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP')

-- Retorna a vida do jogador
GetPlayerHealth = function(source)
    return vRPclient.getHealth(source)
end

-- Retorna a tabela de armas do jogador
GetPlayerWeapons = function(source)
    return vRPclient.replaceWeapons(source,{})
end

-- Verifica a permissao do jogador
HasPermission = function(user_id,perm)
    return vRP.hasPermission(user_id,perm)
end

-- Retorna a source do jogador mais proximo
GetNearestPlayer = function(source,radius)
    return vRPclient.getNearestPlayer(source,radius)
end

-- Pega o inventario do jogador
GetInventory = function(user_id)
    return vRP.getInventory(user_id)
end

-- Pegar o peso maximo do inventario
GetMaxWeight = function(user_id)
    return vRP.getInventoryMaxWeight(user_id)
end

-- Pega o peso do inventario
GetInventoryWeight = function(user_id)
    return vRP.getInventoryWeight(user_id)
end

-- Funcao para pegar peso do item
GetItemWeight = function(item)
    return vRP.getItemWeight(item)
end

-- Procurar index do item
GetIndexItem = function(item)
    return vRP.itemIndexList(item)
end

-- Pega o nome do item
GetItemName = function(item)
    return vRP.itemNameList(item)
end

-- Verifica se a pessoa tem esta com colete equipado!
VerifyArmor = function(source)
    return vRPclient.getArmour(source)
end

-- Remove a arma do player
RemoveWeapon = function(user_id,weapon)
    vRP.removeWeaponDataTable(user_id,weapon)
end

-- Função para dar item
GiveInventoryItem = function(user_id,item,quantidade)
    vRP.giveInventoryItem(user_id,item,quantidade)
end

-- Função para remover item
TryGetInventoryItem = function(user_id,item,amount)
    return vRP.tryGetInventoryItem(user_id,item,amount)
end

-- Função para pegar a quantidade de um item
GetInventoryItemAmount = function(user_id,item)
    return vRP.getInventoryItemAmount(user_id,item)
end

Request = function(source,text,time)
    return vRP.request(source,text,time)
end

PlayAnim = function(source,status,table,bool)
    vRPclient.playAnim(source,status,table,bool)
end

StopAnim = function(source)
    vRPclient.stopAnim(source,false)
end

GetUsersByPermission = function(permi)
    return vRP.getUsersByPermission(permi) or {}
end

CallPolice = function(source)
    print('Chamar policia ws-player')
end

