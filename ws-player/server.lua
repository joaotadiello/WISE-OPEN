local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
local Tools = module("vrp","lib/Tools")
local idgens = Tools.newIDGenerator()
srv = {}
Tunnel.bindInterface('ws-player',srv)
local active = {}

cl = Tunnel.getInterface('ws-player')

local cache = {}
cache.itens = {}
---------------------------------------------------------------------
-- [ Core ]
---------------------------------------------------------------------
function webhook(webhook,message)
    if webhook ~= "none" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end

srv.getIp = function()
    return cfg.ip
end

srv.getPlayerInventory = function(type)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and type then
        
        if type == "meu" then
            local inv = GetInventory(user_id)
            local itens = { }
            for k,v in pairs(inv) do
                if cache.itens[k] or GetItemName(k) then
                    if cache.itens[k] then
                        table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                    else
                        cache.itens[k] = { 
                            index = GetIndexItem(k),
                            name = GetItemName(k),
                        }
                        table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                    end
                end
            end
            return itens    

        elseif type == "proximo" then
            local nplayer = GetNearestPlayer(source,2)
            if nplayer then
                local nuser_id = vRP.getUserId(nplayer)
                if nuser_id then
                    local inv = GetInventory(nuser_id)
                    local itens = { }
                    for k,v in pairs(inv) do
                        if cache.itens[k] or GetItemName(k) then
                            if cache.itens[k] then
                                table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                            else
                                cache.itens[k] = { 
                                    index = GetIndexItem(k),
                                    name = GetItemName(k),
                                }
                                table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                            end
                        end
                    end
                    return itens
                end
            end
        end
    end
end 

srv.getPlayerWeight = function(type)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if type == "meu" then
            return GetInventoryWeight(user_id)

        elseif type == "proximo" then
            local nplayer = GetNearestPlayer(source,2)
            if nplayer then
                local nuser_id = vRP.getUserId(nplayer)
                if nuser_id then
                    return GetInventoryWeight(nuser_id)
                end
            end
        end
    end
end
local inRevista = {}
---------------------------------------------------------------------
-- [ Revistar ]
---------------------------------------------------------------------
if cfg.ativarFuncao.revistar then
    RegisterCommand('revistar',function(source)
        local source = source
        local user_id = vRP.getUserId(source)
        local nplayer = GetNearestPlayer(source,2)

        if user_id then
            if not nplayer then
                TriggerClientEvent('Notify',source,'aviso','Nenhuma pessoa por perto!')
                return
            end
            if cl.inVehicle(source) then
                TriggerClientEvent('Notify',source,'negado','Você não pode revistar dentro de um veículo.')
                return
            end
            if cfg.paintball then
                if cfg.checkPaintBall(nplayer) then
                    TriggerClientEvent('Notify',source,'negado','Indisponivel!')
                    return
                end
            end
            if cfg.core.revistarPorPermi then
                if not HasPermission(user_id,cfg.core.revistarPermissao) then
                    TriggerClientEvent('Notify',source,'negado','Você não tem permissao para isso!')
                    return
                end
            end
            if cfg.core.requestRevistar then 
                local request = Request(nplayer,'Você aceita ser revistado(a)?',15)
                if not request then
                    TriggerClientEvent('Notify',source,'aviso','A pessoa negou a revista')
                    return
                end
            end
            if user_id and active[user_id] == nil then
                active[user_id] = 3
                inRevista[user_id] = true
                TriggerClientEvent('cancelando',source,true)
                TriggerClientEvent('cancelando',nplayer,true)
                --TriggerClientEvent('carregar',nplayer,source)
                PlayAnim(source,false,{{"misscarsteal4@director_grip","end_loop_grip"}},true)
                PlayAnim(nplayer,false,{{"random@mugging3","handsup_standing_base"}},true)

                local nuser_id = vRP.getUserId(nplayer)
                local weapons = GetPlayerWeapons(nplayer)
                for k,v in pairs(weapons) do
                    if cfg.eros then
                        GiveInventoryItem(nuser_id,"wbody"..k,1)
                        if v.ammo > 0 then
                            GiveInventoryItem(nuser_id,"wammo"..k,v.ammo)
                        end
                    elseif cfg.kush then
                        GiveInventoryItem(nuser_id,k,1)
                        if v.ammo > 0 then
                            GiveInventoryItem(nuser_id,"ammo_"..k,v.ammo)
                        end
                    else
                        GiveInventoryItem(nuser_id,"wbody|"..k,1)
                        if v.ammo > 0 then
                            GiveInventoryItem(nuser_id,"wammo|"..k,v.ammo)
                        end
                    end
                    RemoveWeapon(nuser_id,k)
                end

                local inv = GetInventory(nuser_id)
                local itens = { }
                for k,v in pairs(inv) do
                    if cache.itens[k] or GetItemName(k) then
                        if cache.itens[k] then
                            table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                        else
                            cache.itens[k] = { 
                                index = GetIndexItem(k),
                                name = GetItemName(k),
                            }
                            table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                        end
                    end
                end

                webhook(cfg.webhook.revistar,'```prolog\n[REVISTAR]\n[USER_ID]:'..user_id.."\n[REVISTOU:]"..nuser_id..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                TriggerClientEvent('open:revistar',source)
                cl.openRevistar(source,itens)
            end
        end
    end)
end

RegisterServerEvent('revistar:close')
AddEventHandler('revistar:close',function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local nplayer = GetNearestPlayer(source,2)
        if nplayer then
            inRevista[user_id] = false
            StopAnim(source,false)
            StopAnim(nplayer,false)
            TriggerClientEvent('cancelando',source,false)
            TriggerClientEvent('cancelando',nplayer,false)
            --TriggerClientEvent('carregar',nplayer,source)
        end
    end
end)

AddEventHandler("playerDropped",function(reason)
    if cfg.autoBan then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            if inRevista[user_id] == true then
                vRP.setBanned(user_id,1)
                webhook(cfg.webhook.banimento,'```prolog\n[REVISTAR-CRASH]\n[USER_ID]:'..user_id..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
            end
        end
    end
end)

---------------------------------------------------------------------
-- [ Apreender ]
---------------------------------------------------------------------
if cfg.ativarFuncao.apreender then
    RegisterCommand('apreender',function(source)
        local source = source
        local user_id = vRP.getUserId(source)
        local nplayer = GetNearestPlayer(source,2)
        if not nplayer then
            TriggerClientEvent('Notify',source,'aviso','Nenhuma pessoa por perto!')
            return
        end
        
        if cl.inVehicle(source) then
            TriggerClientEvent('Notify',source,'negado','Você não pode revistar dentro de um veículo.')
            return
        end
        if cfg.paintball then
            if cfg.checkPaintBall(nplayer) then
                TriggerClientEvent('Notify',source,'negado','Indisponivel!')
                return
            end
        end
        if user_id and active[user_id] == nil then
            if HasPermission(user_id,cfg.core.apreenderPermissao) then
                local nuser_id = vRP.getUserId(nplayer)
                local weapons = GetPlayerWeapons(nplayer)
                for k,v in pairs(weapons) do
                    if cfg.eros then
                        GiveInventoryItem(nuser_id,"wbody"..k,1)
                        if v.ammo > 0 then
                            GiveInventoryItem(nuser_id,"wammo"..k,v.ammo)
                        end
                    elseif cfg.kush then
                        GiveInventoryItem(nuser_id,k,1)
                        if v.ammo > 0 then
                            GiveInventoryItem(nuser_id,"ammo_"..k,v.ammo)
                        end
                    else
                        GiveInventoryItem(nuser_id,"wbody|"..k,1)
                        if v.ammo > 0 then
                            GiveInventoryItem(nuser_id,"wammo|"..k,v.ammo)
                        end
                    end
                    RemoveWeapon(nuser_id,k)
                end

                local inv = GetInventory(nuser_id)
                local itens = { }
                for k,v in pairs(inv) do
                    if cache.itens[k] or GetItemName(k) then
                        if cache.itens[k] then
                            table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                        else
                            cache.itens[k] = { 
                                index = GetIndexItem(k),
                                name = GetItemName(k),
                            }
                            table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                        end
                    end
                end
                cl.openAprender(source,itens)
            end 
        end
    end)
end


RegisterServerEvent('apreender:itens')
AddEventHandler('apreender:itens',function(item)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and active[user_id] == nil then
        active[user_id] = 3
        if HasPermission(user_id,cfg.core.apreenderPermissao) then
            local nplayer = GetNearestPlayer(source,2)
            if nplayer then
                local nuser_id = vRP.getUserId(nplayer)
                local ninventory = GetInventory(nuser_id)
                if ninventory then
                    local itens_apreendidos = {}
                    --for k,v in pairs(ninventory) do
                        if item == cfg.itensIlegais[item] then
                            local amount = GetInventoryItemAmount(nuser_id,k)
                            if TryGetInventoryItem(nuser_id,item,amount) then
                                if cfg.core.giveItemPolice then
                                    GiveInventoryItem(user_id,item,amount)
                                end
                                table.insert(itens_apreendidos, "[ITEM]: "..GetItemName(item).." [QUANTIDADE]: "..amount)
                            end
                        end
                    --end
				    local apreendidos = table.concat(itens_apreendidos, "\n")

                    TriggerClientEvent('Notify',source,'sucesso','Você aprendeu '..GetItemName(item)..'!')
                    TriggerClientEvent('Notify',nplayer,'aviso',GetItemName(item)..' apreendido!')
                    webhook(cfg.webhook.apreender,'```prolog\n[APREENDER]\n[USER_ID]:'..user_id.."\n[MELIANTE:]"..nuser_id.."\n"..apreendidos..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                end
            else
                TriggerClientEvent('Notify',source,'aviso',' Nenhuma pessoa por perto')
            end
        end 
    end
end)
-- RegisterServerEvent('apreender:itens')
-- AddEventHandler('apreender:itens',function()
--     local source = source
--     local user_id = vRP.getUserId(source)
--     if user_id and active[user_id] == nil then
--         active[user_id] = 3
--         if HasPermission(user_id,cfg.core.apreenderPermissao) then
--             local nplayer = GetNearestPlayer(source,2)
--             if nplayer then
--                 local nuser_id = vRP.getUserId(nplayer)
--                 local ninventory = GetInventory(nuser_id)
--                 if ninventory then
--                     local itens_apreendidos = {}
--                     for k,v in pairs(ninventory) do
--                         if k == cfg.itensIlegais[k] then
--                             local amount = GetInventoryItemAmount(nuser_id,k)
--                             if TryGetInventoryItem(nuser_id,k,amount) then
--                                 if cfg.core.giveItemPolice then
--                                     GiveInventoryItem(user_id,k,amount)
--                                 end
--                                 table.insert(itens_apreendidos, "[ITEM]: "..GetItemName(k).." [QUANTIDADE]: "..amount)
--                             end
--                         end
--                     end
-- 				    local apreendidos = table.concat(itens_apreendidos, "\n")

--                     TriggerClientEvent('Notify',source,'sucesso','Você aprendeu os itens ilegais!')
--                     TriggerClientEvent('Notify',nplayer,'aviso','Seus itens foram apreendidos!')
--                     webhook(cfg.webhook.apreender,'```prolog\n[APREENDER]\n[USER_ID]:'..user_id.."\n[MELIANTE:]"..nuser_id.."\n"..apreendidos..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
--                 end
--             else
--                 TriggerClientEvent('Notify',source,'aviso',' Nenhuma pessoa por perto')
--             end
--         end 
--     end
-- end)


---------------------------------------------------------------------
-- [ Roubar ]
---------------------------------------------------------------------
if cfg.ativarFuncao.roubar then
    RegisterCommand('roubar',function(source)
        local source = source
        local user_id = vRP.getUserId(source)
        local nplayer = GetNearestPlayer(source,2)
        local policia = GetUsersByPermission(cfg.permiPolicia)
        if #policia >= cfg.core.roubarMinPolicia then
            if not nplayer then
                TriggerClientEvent('Notify',source,'aviso','Nenhuma pessoa por perto!')
                return
            end
            if cfg.paintball then
                if cfg.checkPaintBall(nplayer) then
                    TriggerClientEvent('Notify',source,'negado','Indisponivel!')
                    return
                end
            end
            if cl.inVehicle(source) then
                TriggerClientEvent('Notify',source,'negado','Você não pode revistar dentro de um veículo.')
                return
            end
            if user_id and active[user_id] == nil then
                active[user_id] = 2
                local nuser_id = vRP.getUserId(nplayer)
                local request = Request(nplayer,'Você está sendo roubado!Deseja aceitar o roubo?',15)
                if request then
                    TriggerClientEvent('cancelando',source,true)
                    TriggerClientEvent('cancelando',nplayer,true)
                    --TriggerClientEvent('carregar',nplayer,source)
                    PlayAnim(source,false,{{"misscarsteal4@director_grip","end_loop_grip"}},true)
                    PlayAnim(nplayer,false,{{"random@mugging3","handsup_standing_base"}},true)
                    if cfg.core.roubarChamarPolicia then
                        srv.callPolice(source)
                    end
    
                    local weapons = GetPlayerWeapons(nplayer)
                    for k,v in pairs(weapons) do
                        if vRP.check_weapon(nuser_id,k) then
                            RemoveWeapon(nuser_id,k)
                            if cfg.eros then
                                GiveInventoryItem(nuser_id,"wbody"..k,1)

                                if v.ammo > 0 then
                                    GiveInventoryItem(nuser_id,"wammo"..k,v.ammo)
                                end
                            elseif cfg.kush then
                                GiveInventoryItem(nuser_id,k,1)
                                if v.ammo > 0 then
                                    GiveInventoryItem(nuser_id,"ammo_"..k,v.ammo)
                                end
                            else
                                GiveInventoryItem(nuser_id,"wbody|"..k,1)
                                if v.ammo > 0 then
                                    GiveInventoryItem(nuser_id,"wammo|"..k,v.ammo)
                                end
                            end
                            RemoveWeapon(nuser_id,k)
                        end
                    end
    
                    local inv = GetInventory(user_id)
                    local itens = { }
                    for k,v in pairs(inv) do
                        if cache.itens[k] or GetItemName(k) then
                            if cache.itens[k] then
                                table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                            else
                                cache.itens[k] = { 
                                    index = GetIndexItem(k),
                                    name = GetItemName(k),
                                }
                                table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                            end
                        end
                    end
    
                    local ninv = GetInventory(nuser_id)
                    local nitens = { }
                    for k,v in pairs(ninv) do
                        if cache.itens[k] or GetItemName(k) then
                            if cache.itens[k] then
                                table.insert(nitens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                            else
                                cache.itens[k] = { 
                                    index = GetIndexItem(k),
                                    name = GetItemName(k),
                                }
                                table.insert(nitens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                            end
                        end
                    end
    
                    cl.openRoubar(source,itens,nitens)
                else
                    TriggerClientEvent('Notify',source,'aviso','A pessoa negou o roubo!')
                end  
            end
        else
            TriggerClientEvent('Notify',source,'aviso','Numero de policiais insuficiente!')
        end
    end)
end

local blips = {}
function srv.callPolice(source)
    CallPolice(source)
end

-- Funcao para roubar o player
srv.hjhjFG = function(item,amount,pass)
    if item then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id and active[user_id] == nil then
            active[user_id] = 1
            if pass == "JkO@3^0koj" then
                local nplayer = GetNearestPlayer(source,2)
                if nplayer then
                    local nuser_id = vRP.getUserId(nplayer)
                    if nuser_id then
                        local playerMaxInv = GetMaxWeight(user_id)
                        local weightCurrent = GetInventoryWeight(user_id)
                        if not amount then
                            amount = GetInventoryItemAmount(nuser_id,item)
                        end
                        if playerMaxInv and weightCurrent then
                            if (weightCurrent + (GetItemWeight(item) * amount)) <= playerMaxInv then
                                local fix = GetNearestPlayer(source,2)
                                if nplayer == fix then
                                    if TryGetInventoryItem(nuser_id,item,amount) then
                                        GiveInventoryItem(user_id,item,amount)
                                        TriggerClientEvent('Notify',nplayer,'aviso'," "..amount.."x "..GetItemName(item).." roubada(a)")
                                        TriggerClientEvent('Notify',source,'sucesso','Você recebeu '..amount.."x "..GetItemName(item))
                                        webhook(cfg.webhook.roubar,'```prolog\n[ROUBAR]\n[USER_ID]:'..user_id.."\n[ROUBOU:]"..nuser_id..'\n[ITEM]'..GetItemName(item).."\n[QUANTIDADE]"..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                                    else
                                        TriggerClientEvent('Notify',source,'negado','Quantidade invalida!')
                                    end
                                end
                            else
                                TriggerClientEvent('Notify',source,'aviso','Espaço insuficiente')
                            end
                        end
                    end
                end
            end
        end
    end
end
---------------------------------------------------------------------
-- [ Saquear ]
---------------------------------------------------------------------
if cfg.ativarFuncao.saquear then
    RegisterCommand('saquear',function(source)
        local source = source
        local user_id = vRP.getUserId(source)
        local policia = GetUsersByPermission(cfg.permiPolicia)
        local nplayer = GetNearestPlayer(source,2)
        
        if #policia >= cfg.core.saquearMinPolicia then
            if not nplayer then
                TriggerClientEvent('Notify',source,'aviso','Nenhuma pessoa por perto!')
                return
            end
        
            if cfg.paintball then
                if cfg.checkPaintBall(nplayer) then
                    TriggerClientEvent('Notify',source,'negado','Indisponivel!')
                    return
                end
            end

            if cl.inVehicle(source) then
                TriggerClientEvent('Notify',source,'negado','Você não pode revistar dentro de um veículo.')
                return
            end
            if user_id and active[user_id] == nil then
                active[user_id] = 2
                local nuser_id = vRP.getUserId(nplayer)
                if nuser_id then
                    if GetPlayerHealth(nplayer) <= cfg.core.vidaMinima then
                        TriggerClientEvent('cancelando',source,true)
 	    		        PlayAnim(source,false,{{"amb@medic@standing@tendtodead@idle_a","idle_a"}},true)
                        local weapons = GetPlayerWeapons(nplayer)
                        for k,v in pairs(weapons) do

                            if cfg.eros then
                                GiveInventoryItem(nuser_id,"wbody"..k,1)
                                if v.ammo > 0 then
                                    GiveInventoryItem(nuser_id,"wammo"..k,v.ammo)
                                end
                            elseif cfg.kush then
                                GiveInventoryItem(nuser_id,k,1)
                                if v.ammo > 0 then
                                    GiveInventoryItem(nuser_id,"ammo_"..k,v.ammo)
                                end
                            else
                                GiveInventoryItem(nuser_id,"wbody|"..k,1)
                                if v.ammo > 0 then
                                    GiveInventoryItem(nuser_id,"wammo|"..k,v.ammo)
                                end
                            end
                            RemoveWeapon(nuser_id,k)
                        end

                        local inv = GetInventory(user_id)
                        local itens = { }
                        for k,v in pairs(inv) do
                            if cache.itens[k] or GetItemName(k) then
                                if cache.itens[k] then
                                    table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                                else
                                    cache.itens[k] = { 
                                        index = GetIndexItem(k),
                                        name = GetItemName(k),
                                    }
                                    table.insert(itens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                                end
                            end
                        end
    
                        local ninv = GetInventory(nuser_id)
                        local nitens = { }
                        for k,v in pairs(ninv) do
                            if cache.itens[k] or GetItemName(k) then
                                if cache.itens[k] then
                                    table.insert(nitens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                                else
                                    cache.itens[k] = { 
                                        index = GetIndexItem(k),
                                        name = GetItemName(k),
                                    }
                                    table.insert(nitens,{key = k,index = cache.itens[k].index,amount = v.amount,name = cache.itens[k].name})
                                end
                            end
                        end
                        cl.openSaquear(source,itens,nitens)
                    else
                        TriggerClientEvent('Notify',source,'negado','A pessoa não está em coma!')
                    end
                end
            end
        else
            TriggerClientEvent('Notify',source,'aviso','Numero de policiais insuficiente!')
        end
    end)
end

RegisterServerEvent('saquear:close')
AddEventHandler('saquear:close',function()
    local source = source
    local nplayer = GetNearestPlayer(source,2)
    StopAnim(source,false)
	TriggerClientEvent('cancelando',source,false)
    if nplayer then
        StopAnim(nplayer,false)
        TriggerClientEvent('cancelando',nplayer,false)
    end
end)

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

