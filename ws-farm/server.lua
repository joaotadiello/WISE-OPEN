API = {} 
Tunnel.bindInterface('ws-farm', API)
local IS_WSFARM_ACTIVED = true

local cache = {}
cache.itens = {}

-------------------------------------------------------------------------------------------
-- [ CRAFT ]
-------------------------------------------------------------------------------------------
API.FabricarIndex = function(indexFarme)
    if not IS_WSFARM_ACTIVED then return end
    if config.script and config.script[indexFarme] and config.script[indexFarme].fabricar then
        local itens = {}
        for k,v in ipairs(config.script[indexFarme].fabricar) do
            if config.craft[v] then
                table.insert(itens,{
                    key = config.craft[v].key,
                    targetName = ItemName(config.craft[v].TargetItem),
                    targetIndex = ItemIndex(config.craft[v].TargetItem),
                    craft = config.craft[v].craft
                })
            end
        end
        return itens
    end
end

API.CraftItem = function(indexFarme,item)
    if not IS_WSFARM_ACTIVED then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and not active[user_id] then
        active[user_id] = true
        if config.craft[item] then
            if CheckMyCraftItens(user_id,config.craft[item].craft) then
                if (GetInvWeight(user_id) + (GetItemWeight(config.craft[item].TargetItem) * config.craft[item].ReceveidAmount)) <= GetBackPack(user_id) then
                    SetTimeout(1000*config.craft[item].TimeProduction,function()
                        active[user_id] = false
                        GiveItem(user_id,config.craft[item].TargetItem,config.craft[item].ReceveidAmount)
                        TriggerClientEvent('Notify',source,'sucesso','Você recebeu '..config.craft[item].ReceveidAmount..'x '..ItemName(config.craft[item].TargetItem),3000)
                        webhook(config.webhook.fabricar,"```prolog\n[FABRICAR]\n[ID]:"..user_id.."\n[FARME]:"..indexFarme.."\n[ITEM]:"..config.craft[item].TargetItem.."\n[QUANTIDADE]:"..config.craft[item].ReceveidAmount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                    end)
                    return config.craft[item].TimeProduction,item
                else
                    TriggerClientEvent('Notify',source,'negado','Você não possui espaço suficiente em sua mochila.')
                    for k,v in pairs(config.craft[item].craft) do
                        GiveItem(user_id,v[1],v[3])
                    end
                    active[user_id] = false
                    return false
                end
            else
                TriggerClientEvent('Notify',source,'negado','Você não possui todos os itens da receita!',3000)
            end
        end
        active[user_id] = false
    end
end

CheckMyCraftItens = function(user_id,craft)
    local removedItem = {}
    local i = GetTableSize(craft)
    for k,v in pairs(craft) do
        if TryItem(user_id,v[1],v[3]) then
            removedItem[v[1]] = v[3]
        end
    end
    if i == GetTableSize(removedItem) then
        return true
    else
        for k,v in pairs(removedItem) do
            if GiveItem(user_id,k,v) then
                removedItem[k] = nil
            end
        end
        return false
    end
end

API.ColeteItensIndex = function(indexFarme)
    if config.script and config.script[indexFarme] and config.script[indexFarme].coletar then
        local itens = {}
        for k,v in pairs(config.script[indexFarme].coletar) do
            if cache.itens[k] then
                table.insert(itens,{key = k,index = cache.itens[k].index,name = cache.itens[k].name})
            else
                cache.itens[k] = {
                    key = k,
                    index = ItemIndex(k),
                    name = ItemName(k)
                }
                table.insert(itens,cache.itens[k])
            end
        end
        return itens
    end
end
-------------------------------------------------------------------------------------------
-- [ ENTREGAR ]
-------------------------------------------------------------------------------------------
API.EntregarIndex = function(indexFarme)
    if not IS_WSFARM_ACTIVED then return end
    if config.script and config.script[indexFarme] and config.script[indexFarme].entregar then
        local itens = {}
        for k,v in pairs(config.script[indexFarme].entregar) do
            if cache.itens[k] then
                table.insert(itens,{key = k,index = cache.itens[k].index,name = cache.itens[k].name})
            else
                cache.itens[k] = {
                    key = k,
                    index = ItemIndex(k),
                    name = ItemName(k)
                }
                table.insert(itens,cache.itens[k])
            end
        end
        return itens
    end
end

API.GiveRewardEntrega = function(indexFarme,item)
    if not IS_WSFARM_ACTIVED then return end
    local tbl = {}
    tbl.source = source
    tbl.user_id = vRP.getUserId(source)
    tbl.farme = indexFarme
    tbl.item = item
    if tbl.source and tbl.user_id and tbl.farme and tbl.item then
        config.custom.entregar(tbl)
    end
end 
-------------------------------------------------------------------------------------------
-- [ COLETAR ]
-------------------------------------------------------------------------------------------
API.GiveRewardColeta = function(indexFarme,item)
    local tbl = {}
    tbl.source = source
    tbl.user_id = vRP.getUserId(source)
    tbl.farme = indexFarme
    tbl.item = item
    if tbl.source and tbl.user_id and tbl.farme and tbl.item then
        config.custom.coletar(tbl)
        return true
    end
end

-------------------------------------------------------------------------------------------
-- [ ALL ]
-------------------------------------------------------------------------------------------
API.HasPermission = function(indexFarme)
    if not IS_WSFARM_ACTIVED then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local perms = config.script[indexFarme].AcessPerms
        if perms == true then return true end
        local status = false
        for k,v in pairs(perms) do
            if HasPermission(user_id,v) then 
                return true 
            end 
        end
    end
end

API.GetIP = function()
    return config.ip
end


