local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
local cfg = module('ws-inventario','server_config')
local config = module('ws-inventario','config')
local itens = module('ws-inventario','itens')

vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP')

cl = Tunnel.getInterface('ws-inventario')

srv = { }
Tunnel.bindInterface('ws-inventario',srv)
Proxy.addInterface('ws-inventario',srv)
local use = { }
local activeUser = { }
local actived = {}
item_list = cfg.itens


Citizen.CreateThread(function()
    vRP.defInventoryItem()
end)

local isAuthorized = true

srv.getInventory = function()
    if isAuthorized then
        local source = source
        local user_id = cfg.core.getUserId(source)
        if user_id then
            local inventory = {}
            local inv = cfg.core.getInventory(user_id)
            if inv then
                for k,v in pairs(inv) do
                    if srv.getIndexItem(k) then
                        table.insert(inventory,{index = srv.getIndexItem(k), amount = parseInt(v.amount), key = k, type = srv.getItemType(k) })
                    end
                end
                return inventory,parseInt(cfg.core.getInventoryWeight(user_id)),vRP.getInventoryMaxWeight(user_id)
            end
        end
    end
end

srv.defInventoryItem = function()
    local itens = { }
    for k,v in pairs(item_list) do
        if v.peso == nil then
            item_list[k].peso = 0
        end
        local item = { name = item_list[k].nome, weight = item_list[k].peso }
        itens[k] = item
    end
    return itens
end

srv.getIP = function()
    return cfg.ip
end

RegisterCommand('item',function(source,args)
    local source = source
    local user_id = cfg.core.getUserId(source)
    if user_id and args[1] and args[2] then
        if cfg.core.hasPermission(user_id,cfg.adminPermi) then
            if item_list then
                if item_list[args[1]] then
                    cfg.core.giveItem(user_id,args[1],parseInt(args[2]))
                    TriggerClientEvent('Notify',source,'sucesso','Você pegou <b>'..args[2]..'x </b> '..srv.getItemName(args[1]),10000)
                    webhook(cfg.webhook.commandItem,"```prolog\n[/ITEM]\n[ITEM]:"..args[1].."\n[QUANTIDADE]:"..args[2].."\n[USER_iD]:"..user_id..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                end
            end
        end
    end
end)

----------------------------------------------------------------------------------------------
--- [ CORE - Inventory ]
----------------------------------------------------------------------------------------------
srv.useItem = function(item,amount,type)
    if isAuthorized then
        local source = source
        local user_id = cfg.core.getUserId(source)
        if user_id then
            TriggerClientEvent('inventory:close',source)
            if type == nil then
                type = srv.getItemType(item)
            end
            if amount == 0 or amount == nil then
                amount = 1
            end
            if type == "equipar" or type == "recarregar" then
                if type == "equipar" then
                    if cfg.core.tryItem(user_id,item,1) then
                        TriggerClientEvent('ws:inventory:weapon',source,item,"WS:INVENTORY")
                        TriggerClientEvent('ws:inventory:update',source)
                        webhook(cfg.webhook.equipar,"```prolog\n[EQUIPOU]\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:1'..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                    end
                else
                    if checkWeaponEquiped(source,item) then
                        if cfg.core.tryItem(user_id,item,amount) then
                            TriggerClientEvent('ws:inventory:weaponAmmo',source,item,amount,"WS:INVENTORY")
                            TriggerClientEvent('ws:inventory:update',source)
                            webhook(cfg.webhook.equipar,"```prolog\n[EQUIPOU]\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:1'..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                        end
                    else
                        TriggerClientEvent('Notify',source,"aviso","Você precisa estar com a arma equipada para recarrega-la!",10000)
                    end
                end
            else
                if itens.usaveis[item] then
                    if amount > 1 then
                        amount =  1
                        TriggerClientEvent('Notify',source,'aviso','Você pode usar apenas um item de cada vez.',10000)
                    end
                    local maxAmount = cfg.core.getItemAmount(user_id,item)
                    if amount <= maxAmount then
                        itens.usaveis[item](source,user_id,item,amount)
                        webhook(cfg.webhook.usarItem,"```prolog\n[USOU]\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                    else
                        TriggerClientEvent('Notify',source,'negado','Quantidade invalida!',10000)
                    end
                else
                    TriggerClientEvent('Notify',source,"aviso","Item não usavel!",10000)
                end
            end
        end
    end
end

srv.deleteItem = function (item,amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if not amount or amount == 0 then
            amount = cfg.core.getItemAmount(user_id,item)
        end
        if cfg.dropItem then
            cfg.core.dropItem(user_id,item,amount)
            webhook(cfg.webhook.deleteItem,"```prolog\n[DROPOU]\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
            return
        end
        if cfg.core.tryItem(user_id,item,amount) then
            cfg.core.dropItem(user_id,item,amount)
            webhook(cfg.webhook.deleteItem,"```prolog\n[DROPOU]\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
        end
    end
end

checkWeaponEquiped = function(source,key)
    local slit = split(key,"|")[2]
    for k,v in pairs(vRPclient.getWeapons(source))do
        if k == slit then
            return true
        end
    end
end

split = function(str, sep)
    if sep == nil then sep = "%s" end
    local t={}
    local i=1
    for str in string.gmatch(str, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

----------------------------------------------------------------------------------------------
--- [ CORE - Extras ]
----------------------------------------------------------------------------------------------
srv.sendItem = function(item,amount)
    if isAuthorized then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            if amount == 0 then
                amount = cfg.core.getItemAmount(user_id,item)
            end
            local nplayer = vRPclient.getNearestPlayer(source,1.5)
            if nplayer and amount >= 0 then
                local nuser_id = cfg.core.getUserId(nplayer)
                local nMax = vRP.getInventoryMaxWeight(nuser_id)
                local nCurrent = cfg.core.getInventoryWeight(nuser_id)
                local pesoItem = srv.getItemWeight(item) * amount

                if (nCurrent + pesoItem) <= nMax then
                    if verify_item(item,'enviar') then
                        if cfg.core.tryItem(user_id,item,amount) then
                            cfg.core.playAnim(source,true,{{"mp_common","givetake1_a"}},false)
                            cfg.core.playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)

                            cfg.core.giveItem(nuser_id,item,amount)
                            TriggerClientEvent('Notify',source,'sucesso','Você enviou '..amount.."x "..srv.getItemName(item)..".",10000)
                            TriggerClientEvent('Notify',nplayer,'sucesso','Você recebeu '..amount.."x "..srv.getItemName(item)..".",10000)
                            webhook(cfg.webhook.enviarItem,"```prolog\n[ENVIOU]\n[USER_iD]:"..user_id.."\n[TARGET]:"..nuser_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                        else
                            TriggerClientEvent('Notify',source,'negado',"Quantidade invalida!",10000)
                        end
                    end
                else
                    TriggerClientEvent('Notify',source,'negado',"Sem espaço na mochila!",10000)
                end
            else
                TriggerClientEvent('Notify',source,'aviso',"Nem uma pessoa encontrada!",10000)
            end
        end
    end
end

local paintball = nil --Tunnel.getInterface("nation_paintball")

srv.garmas = function(weapon)
    if isAuthorized then
        local source = source
        local user_id = cfg.core.getUserId(source)
        if user_id and use[user_id] == nil then
            use[user_id] = 5
            if cfg.paintball then
                if paintball == nil then
                    paintball = Tunnel.getInterface("nation_paintball")
                    return
                else
                    if paintball.isInPaintball(source) then
                        TriggerClientEvent('Notify',source,'aviso','Indisponivel!')
                        return
                    end
                end
            end
            if cfg.tavarb then
                porte = Proxy.getInterface("zo_porte")
                if porte.getInsPorte()[tostring(user_id)] then
                    TriggerClientEvent("Notify", source, "erro", "Você não pode guardar agora.")
                    return
                end
            end
            if cfg.core.hasPermission(user_id,cfg.policiapermissao) or cfg.core.hasPermission(user_id,cfg.medicopermissao) then
                TriggerClientEvent('Notify',source,'negado','Você não pode guardar equipamentos em serviço!',10000)
            else
                if weapon == config.core.itemColete then
                    local condicao = cl.verify_colete(source)
                    if condicao >= 90 then
                        cl.removeColete(source)
                        cfg.core.giveItem(user_id,config.core.itemColete,1)
                        TriggerClientEvent('Notify',source,'sucesso','Você guardou 1x colete')
                    end
                else
                    if vRP.removeWeaponDataTable(user_id,weapon) then 
                        cfg.core.giveItem(user_id,"wbody|"..weapon,1)
                        local ammo = cl.removeWeapon(source,weapon)
                        if ammo > 0 then
                            cfg.core.giveItem(user_id,"wammo|"..weapon,ammo)
                        end
                        TriggerClientEvent('Notify',source,"sucesso","Você guardou 1x <b>"..srv.getItemName("wbody|"..weapon).."</b>",10000)
                        webhook(cfg.webhook.garmas,"```prolog\n[GUARDOU]\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName("wbody|"..weapon)..'\n[QUANTIDADE]:1'..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                    end
                end
            end
        else
            TriggerClientEvent('Notify',source,'aviso','Indisponivel, aguarde '..use[user_id].." segundos para retirar novamente!",10000)
        end
    end
end

srv.getIdentity = function()
    local source = source
    local user_id = cfg.core.getUserId(source)
    if user_id then
        local player = cfg.core.getIdentity(user_id)
        return player
    end
end

----------------------------------------------------------------------------------------------
--- [ CORE ]
----------------------------------------------------------------------------------------------

srv.tryGetInventoryItem = function(user_id,item,amount,slot)
    if user_id and item and amount then
        return cfg.core.tryItem(user_id,item,amount)
    end
end

srv.getInventoryItemAmount = function(user_id,item)
    if user_id and item then 
        return cfg.core.getItemAmount(user_id,item)
    end
end

srv.giveInventoryItem  = function(user_id,item,amount,slot)
    if user_id and item and amount then
        cfg.core.giveItem(user_id,item,amount)
    end
end

srv.basic_itens_create = function()
    local itens_create = {}
    for k,v in pairs(item_list) do
        itens_create[k] = {v.nome,v.peso}
    end
    return itens_create
end

srv.getItemName = function(index)
    if item_list[index] ~= nil then
        return item_list[index].nome
    end
end

srv.getIndexItem = function(index)
    if item_list[index] ~= nil then
        return item_list[index].index
    end
end

srv.getItemType = function(index)
    if item_list[index] ~= nil then
        return item_list[index].type
    end
end

srv.getInfoItem = function(index)
    if item_list[index] ~= nil then
        return item_list[index]
    end
end

srv.getItemWeight = function(item)
    if item_list[item] ~= nil then
        if item_list[item].peso ~= nil then
            return item_list[item].peso
        else
            return 0
        end
    else
        return 0
    end
end

srv.getBasicItemInfo = function(item)
    if item_list[item] ~= nil then
        return item_list[item].name, item_list[item].peso
    end
end

srv.getItemDesc = function(item)
    if item_list[item] ~= nil then
        return item_list[item].desc
    end
end

srv.getItemDefinition = function(item)
    if item_list[item] ~= nil then
        return item,srv.getItemWeight(item)
    end
end

srv.getItemInfo = function(item,amount)
    local desc = srv.getItemDesc(item)
    local peso = parseInt(srv.getItemWeight(item) * amount)
    local name = srv.getItemName(item)
    return desc,peso,name
end
----------------------------------------------------------------------------------------------
--- [ CORE - Trunk  ]
----------------------------------------------------------------------------------------------
local user_trunk = {}
local cacheTrunk = {}
local active = {}

srv.openTrunk = function()
    if isAuthorized then
        local source = source
        local user_id = cfg.core.getUserId(source)
        if user_id then
            local vehicle,vnetid,placa,vname,lock,banned,trunk = cfg.vehInfo(source,7)
            if vname and placa then
                if lock == 1 or lock == false then
                    local dono = nil
                    if cfg.gleice then
                        dono = vRP.getVehiclePlate(placa)
                    else
                        dono = vRP.getUserByRegistration(placa)
                    end
                    if dono then
                        local data = cfg.getTrunkChest(dono,vname)
                        if data then
                            local itens = {}
                            for k,v in pairs(data) do
                                if v.amount > 0 then
                                    table.insert(itens,{index = srv.getIndexItem(k), amount = parseInt(v.amount), name = srv.getItemName(k),  key = k, type = srv.getItemType(k), peso = parseInt(srv.getItemWeight(k)*v.amount),desc = srv.getItemDesc(k) })
                                end
                            end
                            user_trunk[placa] = user_id
                            TriggerClientEvent('open:trunk:ws',-1,vnetid,false)
                            return itens,cfg.core.getTrunkSize(vname),getWeightItemTrunk(data),true
                        end
                    end
                else
                    TriggerClientEvent('Notify',source,'aviso','Porta malas trancado!',5000)
                    return false
                end
            end
        end
    end
end

srv.storeItemTrunk = function(item,amount,slot)
    local source = source
    local user_id = cfg.core.getUserId(source)
    if user_id and item and amount >= 0 and active[user_id] == nil then
        active[user_id] = 4
        local vehicle,vnetid,placa,vname,lock,banned,trunk = cfg.vehInfo(source,7)
        if placa and vname then
            if verify_item(item,'trunk') then
                local dono = nil
                if cfg.gleice then
                    dono = vRP.getVehiclePlate(placa)
                else
                    dono = vRP.getUserByRegistration(placa)
                end
                local data = cfg.getTrunkChest(dono,vname)
                local trunk_peso = getWeightItemTrunk(data)

                if amount == 0 then
                    amount = cfg.core.getItemAmount(user_id,item)
                end

                if trunk_peso + srv.getItemWeight(item) * amount <= cfg.core.getTrunkSize(vname) then
                    if cfg.core.tryItem(user_id,item,amount,slot) then
                        if data[item] then
                            data[item].amount = data[item].amount + amount
                        else
                            data[item] = {amount = parseInt(amount)}
                        end
                        cfg.setDataTrunk(dono,vname,data)
                        webhook(cfg.webhook.trunkStore,"```prolog\n[TRUNK CHEST - GUARDAR]\n[DONO ID]:"..dono.."\n[VEICULO]:"..vname.."\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")

                    else
                        TriggerClientEvent(source,'Notify','negado','Quantidade invalida!',10000)
                    end
                else
                    TriggerClientEvent('Notify',source,'negado','Porta malas sem espaço!',10000)
                end
            else
                TriggerClientEvent('Notify',source,'negado','Você não pode guardar este item.',10000)
            end
        end
    end
end

srv.takeItemTrunk = function(item,amount)
    local source = source
    local user_id = cfg.core.getUserId(source)
    if user_id and activeUser[user_id] == nil then
        activeUser[user_id] = true
        local vehicle,vnetid,placa,vname,lock,banned,trunk = cfg.vehInfo(source,7)
        if placa and vname then
            local dono = nil
            if cfg.gleice then
                dono = vRP.getVehiclePlate(placa)
            else
                dono = vRP.getUserByRegistration(placa)
            end
            local data = cfg.getTrunkChest(dono,vname)

            if data[item] and data[item].amount >= amount then
                if amount == 0 then
                    amount = data[item].amount
                end

                local inv_peso = cfg.core.getInventoryWeight(user_id)
                if inv_peso + srv.getItemWeight(item) * amount <= vRP.getInventoryMaxWeight(user_id) then
                    if data[item].amount - amount == 0 then
                        data[item] = nil
                    else
                        data[item].amount = data[item].amount - amount
                    end
                    cfg.setDataTrunk(dono,vname,data)
                    cfg.core.giveItem(user_id,item,amount)
                    webhook(cfg.webhook.trunkTake,"```prolog\n[TRUNK CHEST - PEGAR]\n[DONO ID]:\n"..dono.."\n[VEICULO]:"..vname.."\n[USER_ID]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")

                else
                    TriggerClientEvent('Notify',source,'negado','Sem espaço na mochila!',10000)
                end
            else
                TriggerClientEvent('Notify',source,'negado','Quantidade invalida!',10000)
            end
        end
        activeUser[user_id] = nil
    end 
end

getWeightItemTrunk = function(data)
    local peso = 0
    for k,v in pairs(data) do
        peso = parseInt(peso  + (srv.getItemWeight(k) * v.amount))
    end
    return peso
end

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(active) do
            if v > 0 then
                active[k] = active[k] - 1
                if active[k] == 0 then
                    active[k] = nil
                end
            end
        end
        Wait(1000)
    end
end)

srv.checkTrunk = function(placa)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if placa then
            if use[placa] == nil then
                use[placa] = user_id
                cacheTrunk[user_id] = placa
                return true
            else
                TriggerClientEvent('Notify',source,'negado','Porta malas em uso!',10000)
                return false
            end
        end
    end
end

AddEventHandler("playerDropped",function(reason)
	local source = source
	local user_id = cfg.core.getUserId(source)
    if user_id then
        if cacheTrunk[user_id] then
            use[cacheTrunk[user_id]] = nil
            cacheTrunk[user_id] = nil
        end
    end
end)


RegisterServerEvent('removeTrunk')
AddEventHandler('removeTrunk',function(placa)
    local vehicle,vnetid,_,vname,lock,banned,trunk = cfg.vehInfo(source,7)
    if vnetid and placa then
        TriggerClientEvent('open:trunk:ws',-1,vnetid,true)

        if use[placa] then
            cacheTrunk[use[placa]] = nil
            use[placa] = nil
        end
    end
end)

----------------------------------------------------------------------------------------------
--- [ CORE - Shop  ]
----------------------------------------------------------------------------------------------
local active = {}
local cacheItens = {}

CreateThread(function()
    for k,v in pairs(cfg.departamento) do
        cacheItens[k] = {}
    end

    for k,v in pairs(cfg.departamento) do
        for _,p in pairs(cfg.departamento[k].itens) do
            if cfg.arsenalTypes[k] then
                table.insert(cacheItens[k],{index = srv.getIndexItem('wbody|'.._), valor = p.comprar, name = srv.getItemName('wbody|'.._), key = _})
            else
                table.insert(cacheItens[k],{index = srv.getIndexItem(_), valor = p.comprar, name = srv.getItemName(_),  key = _})
            end
        end
    end
end)

srv.openShop = function(type)
    if isAuthorized then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            if cfg.departamento[type].permissao == nil then
                return cacheItens[type]
            else
                if vRP.hasPermission(user_id,cfg.departamento[type].permissao) then
                    return cacheItens[type]
                else
                    return false
                end
            end
        end
    end
end

srv.sellItens = function(item,amount,slot,type)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and active[user_id] == nil then
        active[user_id] = 2
        for k,v in pairs(cacheItens[type]) do
            if v.key == item then
                if amount == 0 or amount == nil then
                    amount = cfg.core.getItemAmount(user_id,item)
                end
                if cfg.core.tryItem(user_id,item,amount) then
                    local value = amount * cfg.departamento[type].itens[item].vender
                    if value > 0 then
                        cfg.core.giveMoney(user_id,value)
                        TriggerClientEvent('Notify',source,'sucesso','Você vendeu '..srv.getItemName(item).." por "..cfg.core.monetary..value,10000)
                        webhook(cfg.webhook.shopVender,"```prolog\n[RECEBIDO]:"..value.."\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                        return
                    end
                end
            end
        end
        TriggerClientEvent('Notify',source,'negado',"Este item não esta disponivel para venda!",10000)
    end
end

srv.buyItenShop = function(item,amount,type)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then 
        if amount > 0 then
            if cfg.departamento[type] and cfg.departamento[type].itens[item] then
                local value = cfg.departamento[type].itens[item].comprar * amount
                local inv_peso = cfg.core.getInventoryWeight(user_id)
                -- Verifica se o type é para arsenal
                if cfg.arsenalTypes[type] then
                        TriggerClientEvent('ws:inventory:weapon',source,'wbody|'..item,"WS:INVENTORY")
                        TriggerClientEvent('ws:inventory:weaponAmmo',source,'wammo|'..item,cfg.departamento[type].itens[item].municao,"WS:INVENTORY")
                        TriggerClientEvent('ws:inventory:update',source)

                        webhook(cfg.webhook.policiaArsenal,"```prolog\n[RETIROU]:\n[USER_ID]:"..user_id.."\n[ITEM]:"..srv.getItemName('wbody|'..item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                        TriggerClientEvent('Notify',source,'sucesso','Você pegou 1x '..srv.getItemName('wbody|'..item),10000)
                else
                    if inv_peso + srv.getItemWeight(item) * amount <= vRP.getInventoryMaxWeight(user_id) then
                        if cfg.core.tryPayment(user_id,value) then
                            cfg.core.giveItem(user_id,item,amount)
                            webhook(cfg.webhook.shopComprar,"```prolog\n[PAGO]:"..value.."\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")

                            TriggerClientEvent('Notify',source,'sucesso','Você comprou '..srv.getItemName(item).." por "..cfg.core.monetary..value,10000)
                        else
                            TriggerClientEvent('Notify',source,"negado",'Pagamento recusado!',10000)
                        end
                    else
                        TriggerClientEvent('Notify',source,'negado','Sem espaço no inventario!',10000)
                    end
                end
            end
        else
            TriggerClientEvent('Notify',source,'aviso','Digite uma quantidade valida!',10000)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(active) do
            if v > 0 then
                active[k] = active[k] - 1
                if active[k] == 0 then
                    active[k] = nil
                end
            end
        end
        Wait(1000)
    end
end)

----------------------------------------------------------------------------------------------
--- [ CORE - Homes  ]
----------------------------------------------------------------------------------------------
local user_homes = { }
local chestSize = { }
local cacheHomes = { }

local smHouse = { }

Citizen.CreateThread(function()
    if cfg.homes_summer then
        return
    else
        local table = cfg.core.gerateSizeHome()
        if type(table) == "table" then
            chestSize = table
            print('[INVENTORY] Tabela de casas criada!')
        else
            print('[INVENTORY] Tabela de casas nao encotrada!')
        end
    end
end)

srv.openHomeChest = function(source,user_id,hname,vault)
    if isAuthorized then
        if user_id and source then
            if hname then
                if cacheHomes[hname] == nil then
                    cacheHomes[hname] = user_id
                    local chest,dkey = cfg.core.getHomeChest(hname)
                    local itens = {}
                    for k,v in pairs(chest) do
                        if v.amount > 0 then
                            table.insert(itens,{index = srv.getIndexItem(k), amount = parseInt(v.amount), name = srv.getItemName(k),  key = k, type = srv.getItemType(k), peso = parseInt(srv.getItemWeight(k)*v.amount),desc = srv.getItemDesc(k) })
                        end
                    end
                    user_homes[user_id] = dkey
                    if vault then
                        smHouse[user_id] = vault
                        cl.openHomeChest(source,itens,vault,getWeightItemHomes(chest),hname)
                    else
                        cl.openHomeChest(source,itens,chestSize[hname],getWeightItemHomes(chest),hname)
                    end
                else
                    TriggerClientEvent('Notify',source,'sucesso','Báu em uso!',10000)
                end
            else
                print('[INVENTORY ERROR] Nome da casa nao informado!')
            end
        end
    end
end

getWeightItemHomes = function(data)
    local peso = 0
    for k,v in pairs(data) do
        peso = parseInt(peso  + (srv.getItemWeight(k) * v.amount))
    end
    return peso
end

srv.storeHomeChest = function(item,amount,slot,index)
    local itens = {}
    local source = source
    local user_id = cfg.core.getUserId(source)
    if user_id and use[user_id] == nil then
        use[user_id] = 2
        local data = cfg.core.getHomeChest(index)
        if amount == 0 then
            amount = cfg.core.getItemAmount(user_id,item)
        end
        local weightHomes = getWeightItemHomes(data)
        local maxChest = 0
        if smHouse[user_id] then
            maxChest = smHouse[user_id]
        else
            maxChest = chestSize[index]
        end
        if verify_item(item,'homes') then
            if (weightHomes + (srv.getItemWeight(item)*amount)) <= maxChest then
                if cfg.core.tryItem(user_id,item,amount,slot) then
                    if data[item] then
                        data[item].amount = data[item].amount + amount
                    else
                        data[item] = {amount = parseInt(amount)}
                    end
                    webhook(cfg.webhook.homesStore,"```prolog\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")

                    cfg.core.setSData(user_homes[user_id],json.encode(data))
                end
            
                for k,v in pairs(data) do
                    if v.amount > 0 then
                        table.insert(itens,{index = srv.getIndexItem(k), amount = parseInt(v.amount), name = srv.getItemName(k),  key = k, type = srv.getItemType(k), peso = parseInt(srv.getItemWeight(k)*v.amount),desc = srv.getItemDesc(k) })
                    end
                end
                if smHouse[user_id] then
                    return itens,smHouse[user_id],getWeightItemHomes(data)
                else
                    return itens,chestSize[index],getWeightItemHomes(data)
                end
            else
                TriggerClientEvent('Notify',source,'negado','Espaço insuficiente!')
            end
        else
            TriggerClientEvent('Notify',source,'negado','Você não pode guardar este item.',10000)
        end
    end
end

srv.takeItemHome = function(item,amount,index)
    local source = source
    local user_id = cfg.core.getUserId(source)
    if user_id and use[user_id] == nil then
        use[user_id] = 5
        local data = cfg.core.getHomeChest(index)
        if data[item] and data[item].amount >= amount then
            if amount == 0 then
                amount = data[item].amount
            end
            local inv_peso = cfg.core.getInventoryWeight(user_id)
            if inv_peso + srv.getItemWeight(item) * amount <= vRP.getInventoryMaxWeight(user_id) then
                if data[item].amount - amount == 0 then
                    data[item] = nil
                else
                    data[item].amount = data[item].amount - amount
                end
                cfg.core.giveItem(user_id,item,amount)
                cfg.core.setSData(user_homes[user_id],json.encode(data))
                TriggerClientEvent('Notify',source,'sucesso','Você retirou '..amount.."x "..srv.getItemName(item),10000)
                webhook(cfg.webhook.homesTake,"```prolog\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")

                local itens = {}
                for k,v in pairs(data) do
                    if v.amount > 0 then
                        table.insert(itens,{index = srv.getIndexItem(k), amount = parseInt(v.amount), name = srv.getItemName(k),  key = k, type = srv.getItemType(k), peso = parseInt(srv.getItemWeight(k)*v.amount),desc = srv.getItemDesc(k) })
                    end
                end
                if smHouse[user_id] then
                    return itens,smHouse[user_id],getWeightItemHomes(data)
                else
                    return itens,chestSize[index],getWeightItemHomes(data)
                end
            end
        end
    else
        TriggerClientEvent('Notify',source,'aviso','Indisponivel, aguarde '..use[user_id].." segundos para retirar novamente!",10000)
    end
end 

RegisterServerEvent('removeUserHomes')
AddEventHandler('removeUserHomes',function(index)
    if cacheHomes[index] then
        cacheHomes[index] = nil
        if smHouse[user_id] then
            smHouse[user_id] = nil
        end
    end
end)

AddEventHandler("playerDropped",function(reason)
	local source = source
	local user_id = cfg.core.getUserId(source)
    if user_id then
        for k,v in pairs(cacheHomes) do
            if user_id == v then
                cacheHomes[k] = nil
                if smHouse[user_id] then
                    smHouse[user_id] = nil
                end
            end
        end
    end
end)

----------------------------------------------------------------------------------------------
--- [ CORE - Chest  ]
----------------------------------------------------------------------------------------------
local chest = config.chest
local inUse = {}

RegisterServerEvent('removeChestUser')
AddEventHandler('removeChestUser',function(chestName)
    inUse[chestName] = nil
end)

AddEventHandler("playerDropped",function(reason)
	local source = source
    for k,v in pairs(inUse) do
        if v == source then
            inUse[k] = nil
        end
    end
end)

srv.checkPerm = function(chestName)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and chest[chestName] then
        if not inUse[chestName] then
            if cfg.core.hasPermission(user_id,chest[chestName].permi)
                inUse[chestName] = source
                return true
            end 
        end
    end
end

srv.openChest = function(chestName)
    if isAuthorized then
        local source = source
        local user_id = cfg.core.getUserId(source)
        if user_id then
            local data = cfg.core.getSData('chest:'..chestName)
            if data then
                local itens = {}
                for k,v in pairs(data) do
                    if v.amount > 0 then
                        table.insert(itens,{index = srv.getIndexItem(k), amount = parseInt(v.amount), name = srv.getItemName(k),  key = k })
                    end
                end
                return itens,chest[chestName].tamanho,getChestWeight(data)
            end
        end
    end
end

srv.takeChest = function(index,item,amount)
    local source = source
    local user_id = cfg.core.getUserId(source)
    if user_id and chest[index] and item and amount >= 0 and not actived[user_id] then
        actived[user_id] = true
        local data = cfg.core.getSData('chest:'..index)
        if data[item] and data[item].amount >= amount then
            if amount == 0 then
                amount = data[item].amount
            end
            local inv_peso = cfg.core.getInventoryWeight(user_id)
            if inv_peso + srv.getItemWeight(item) * amount <= vRP.getInventoryMaxWeight(user_id) then
                if data[item].amount - amount == 0 then
                    data[item] = nil
                else
                    data[item].amount = data[item].amount - amount
                end
                cfg.core.setSData('chest:'..index,json.encode(data))
                cfg.core.giveItem(user_id,item,amount)
                TriggerClientEvent('Notify',source,'sucesso','Você retirou '..amount..'x '..srv.getItemName(item),10000)
                webhook(chest[index].log,"```prolog\n[CHEST RETIROU]\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")

            else
                TriggerClientEvent('Notify',source,'negado','Espaço insuficiente!',10000)
            end
        else
            TriggerClientEvent('Notify',source,'negado','Quantidade invalida!',10000)
        end
        actived[user_id] = nil
    end
end

srv.storeChest = function(index,item,amount,slot)
    local source = source
    local user_id = cfg.core.getUserId(source)
    if user_id and not actived[user_id] then
        actived[user_id] = true
        if index and item and amount >= 0 then 
            if verify_item(item,'chest') then
                local data = cfg.core.getSData('chest:'..index)
                if data then
                    if amount == 0 then
                        amount = cfg.core.getItemAmount(user_id,item)
                    end
                    local currentWeight = getChestWeight(data)
                    local newWeight = parseInt(srv.getItemWeight(item) * amount)
                    if (currentWeight + newWeight) <= chest[index].tamanho then
                        if cfg.core.tryItem(user_id,item,amount,slot) then
                            if data[item] then
                                data[item].amount = data[item].amount + amount
                            else
                                data[item] = {amount = parseInt(amount)}
                            end
                            TriggerClientEvent('Notify',source,'sucesso','Você guardou '..amount..'x '..srv.getItemName(item),10000)
                            cfg.core.setSData('chest:'..index,json.encode(data))
                            webhook(chest[index].log,"```prolog\n[CHEST GUARDAR]\n[USER_iD]:"..user_id.."\n[ITEM]:"..srv.getItemName(item)..'\n[QUANTIDADE]:'..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                        end
                    else
                        TriggerClientEvent('Notify',source,'negado','Espaço insuficiente!',10000)
                    end
                end
            else
                TriggerClientEvent('Notify',source,'negado','Você não pode guardar este item.',10000)
            end
        end
        actived[user_id] = nil
    end
end

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(use) do
            if v > 0 then
                use[k] = use[k] - 1
                if use[k] == 0 then
                    use[k] = nil
                end
            end
        end
        Wait(1000)
    end
end)

getChestWeight = function(table)
    local peso = 0
    for k,v in pairs(table) do
        peso = peso + (srv.getItemWeight(k) * v.amount)
    end
    return parseInt(peso)
end



function webhook(webhook,message)
    if webhook ~= "none" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end

verify_item = function(item,type)
    if cfg.blacklist[type] then
        if cfg.blacklist[type][item] then
            return false
        else
            return true
        end
    end
    return true
end