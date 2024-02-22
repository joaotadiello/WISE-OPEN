
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")

vSKILLBAR = Tunnel.getInterface("vulgo-skillbar")
local idgens = Tools.newIDGenerator()

itens = {}

itens.usaveis = {
    ['maconha'] = function(source,user_id,item,amount)
        if srv.tryGetInventoryItem(user_id,"maconha",1) then
            TriggerClientEvent('ws:inventory:update',source)
            vRPclient._playAnim(source,true,{{"mp_player_int_uppersmoke","mp_player_int_smoke"}},true)
            TriggerClientEvent("progress",source,10000,"fumando")
            SetTimeout(10000,function()
                vRPclient._stopAnim(source,false)
                vRPclient.playScreenEffect(source,"RaceTurbo",180)
                vRPclient.playScreenEffect(source,"DrugsTrevorClownsFight",180)
                TriggerClientEvent("Notify",source,"sucesso","Maconha utilizada com sucesso.",8000)
            end)
        else
            cl.removeHotBar(source,item)
        end
    end,

    ['mochila'] = function(source,user_id,item,amount)
        if vRP.tryGetInventoryItem(user_id,"mochila",1) then
            --vRP.varyExp(user_id,"physical","strength",650)
            vRP.varyInventoryMaxWeight(user_id,30)
            TriggerClientEvent("Notify",source,"sucesso","Mochila utilizada com sucesso.",8000)
        end
    end,

    ['repairkit'] = function(source,user_id,item,amount)
        TriggerClientEvent('inventory:close',source)

        if not vRPclient.isInVehicle(source) then
            local vehicle = vRPclient.getNearestVehicle(source,3.5)
            if vehicle then
                if vRP.hasPermission(user_id,"mecanico.permissao") then
                    TriggerClientEvent('cancelando',source,true)
                    vRPclient._playAnim(source,false,{{"mini@repair","fixing_a_player"}},true)
                    if vSKILLBAR.skillbar(source) then
                        TriggerClientEvent('cancelando',source,false)
                        TriggerClientEvent('reparar',source)
                        TriggerClientEvent('repararmotor',source,vehicle)
                        vRPclient._stopAnim(source,false)
                    end
                else
                    if vRP.tryGetInventoryItem(user_id,"repairkit",1) then
                        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
                        TriggerClientEvent('cancelando',source,true)
                        vRPclient._playAnim(source,false,{{"mini@repair","fixing_a_player"}},true)
                        if vSKILLBAR.skillbar(source) then
                            TriggerClientEvent("itensNotify",source,'use',"Usou",""..srv.getItemName(item).."")
                            TriggerClientEvent('cancelando',source,false)
                            TriggerClientEvent('reparar',source)
                            TriggerClientEvent('repararmotor',source,vehicle)
                            vRPclient._stopAnim(source,false)
                        end
                    else
                        cl.removeHotBar(source,item)
                    end
                end
            end
        end
    end,

    ['pneu'] = function(source,user_id,item,amount)
        TriggerClientEvent('inventory:close',source)

        local vehicle,vnetid,placa,vname,lock,banned,work,trunk,model,street = vRPclient.vehList(source,7)
        if vehicle then
            TriggerClientEvent("mike:pneunamao",source)
        else
            TriggerClientEvent("Notify",source,"negado","Você não está próximo à nenhum veículo.",8000)
        end
    end,

    ['paninho'] = function(source,user_id,item,amount)
        TriggerClientEvent('inventory:close',source)
        if not vRPclient.isInVehicle(source) then
            local vehicle = vRPclient.getNearestVehicle(source,3.5)
            if vehicle then
                if vRP.tryGetInventoryItem(user_id,"paninho",1) then
                    TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
                    TriggerClientEvent('cancelando',source,true)

                    TriggerClientEvent("emotes",source,"pano")

                    TriggerClientEvent("progress",source,10000,"limpando")
                    TriggerClientEvent("itensNotify",source,'use',"Usou",""..srv.getItemName(item).."")

                    SetTimeout(10000,function()
                        TriggerClientEvent('cancelando',source,false)
                        TriggerClientEvent('limpar',source)
                        vRPclient._stopAnim(source,false)
                        vRPclient._DeletarObjeto(source)
                    end)
                else
                    cl.removeHotBar(source,item)
                end
            end
        end
    end,

    ['lockpick'] = function(source,user_id,item,amount)
        TriggerClientEvent('inventory:close',source)
        Wait(100)
        local vehicle,vnetid,placa,vname,lock,banned,trunk,model,street = vRPclient.vehList(source,2)
        local policia = vRP.getUsersByPermission("policia.permissao")
        if vehicle then
            if vRP.getInventoryItemAmount(user_id,"lockpick") >= 1 and vRP.tryGetInventoryItem(user_id,"lockpick",1) then
                TriggerClientEvent('cancelando',source,true)
                vRPclient._playAnim(source,false,{{"amb@prop_human_parking_meter@female@idle_a","idle_a_female"}},true)
                TriggerClientEvent("itensNotify",source,'use',"Usou",""..srv.getItemName(item).."")
                if vSKILLBAR.skillbar(source) then
                    TriggerClientEvent('cancelando',source,false)
                    vRPclient._stopAnim(source,false)
                    TriggerEvent("setPlateEveryone",placa)
                    TriggerClientEvent("nation:syncLock",-1,vnetid)
                    TriggerClientEvent("vrp_sound:source",source,'lock',0.5)
                else
                    TriggerClientEvent('cancelando',source,false)
                    vRPclient._stopAnim(source,false)
                    TriggerClientEvent("Notify",source,"negado","Roubo do veículo falhou e as autoridades foram acionadas.",8000)
                    local policia = vRP.getUsersByPermission("policia.permissao")
                    local x,y,z = vRPclient.getPosition(source)
                    for k,v in pairs(policia) do
                        local player = vRP.getUserSource(parseInt(v))
                        if player then
                            async(function()
                                local id = idgens:gen()
                                vRPclient._playSound(player,"CONFIRM_BEEP","HUD_MINI_GAME_SOUNDSET")
                                TriggerClientEvent('chatMessage',player,"911",{64,64,255},"Roubo na ^1"..street.."^0 do veículo ^1"..model.."^0 de placa ^1"..placa.."^0 verifique o ocorrido.")
                                pick[id] = vRPclient.addBlip(player,x,y,z,10,1,"Ocorrência",0.5,false)
                                SetTimeout(20000,function() vRPclient.removeBlip(player,pick[id]) idgens:free(id) end)
                            end)
                        end
                    end
                end
            else
                cl.removeHotBar(source,item)
            end
        else						
            TriggerClientEvent("vrpdoorsystem:forceOpen",source,srv.getItemName(item))
        end
    end,

    ['capuz'] = function(source,user_id,item,amount)
        if vRP.getInventoryItemAmount(user_id,"capuz") >= 1 then
            local nplayer = vRPclient.getNearestPlayer(source,2)
            if nplayer then
                vRPclient.setCapuz(nplayer)
                vRP.closeMenu(nplayer)
                TriggerClientEvent("Notify",source,"sucesso","Capuz utilizado com sucesso.",8000)
            end
        end
    end,

    ['placa'] = function(source,user_id,item,amount)
        if vRPclient.GetVehicleSeat(source) then
            if vRP.tryGetInventoryItem(user_id,"placa",1) then
                local placa = vRP.generatePlate()
                TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
                TriggerClientEvent('cancelando',source,true)
                TriggerClientEvent("vehicleanchor",source)
                TriggerClientEvent("progress",source,59500,"clonando")
                TriggerClientEvent("itensNotify",source,'use',"Usou",""..srv.getItemName(item).."")
                SetTimeout(60000,function()
                    TriggerClientEvent('cancelando',source,false)
                    TriggerClientEvent("cloneplates",source,placa)
                    --TriggerEvent("setPlateEveryone",placa)
                    TriggerClientEvent("Notify",source,"sucesso","Placa clonada com sucesso.",8000)
                end)
            end
        end
    end,

    ['agua'] = function(source,user_id,item,amount)
        local src = source
        if vRP.tryGetInventoryItem(user_id,"agua",1) then

            TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
            vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_ld_flow_bottle",49,28422)
            TriggerClientEvent("progress",source,10000,"tomando")
            TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

            SetTimeout(10000,function()
                vRPclient._stopAnim(source,false)
                vRP.varyThirst(user_id,-40)
                vRP.varyHunger(user_id,0)
                vRP.giveInventoryItem(user_id,"garrafa-vazia",1)
                vRPclient._DeletarObjeto(src)
            end)

        end
    end,

    ['leite'] = function(source,user_id,item,amount)
        local src = source
        if vRP.tryGetInventoryItem(user_id,"leite",1) then

            TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
            vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_energy_drink",49,28422)
            TriggerClientEvent("progress",source,10000,"tomando")
            TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

            SetTimeout(10000,function()
                vRPclient._stopAnim(source,false)
                vRP.varyThirst(user_id,-40)
                vRP.varyHunger(user_id,0)
                vRPclient._DeletarObjeto(src)
            end)

        end
    end,

    ['cafe'] = function(source,user_id,item,amount)
        local src = source
        if vRP.tryGetInventoryItem(user_id,"cafe",1) then

            TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
            vRPclient._CarregarObjeto(src,"amb@world_human_aa_coffee@idle_a","idle_a","prop_fib_coffee",49,28422)
            TriggerClientEvent("progress",source,10000,"tomando")
            TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

            SetTimeout(10000,function()
                vRPclient._stopAnim(source,false)
                vRP.varyThirst(user_id,-40)
                vRP.varyHunger(user_id,0)
                vRPclient._DeletarObjeto(src)
            end)

        end
    end,

    ['cafecleite'] = function(source,user_id,item,amount)
        local src = source
        if vRP.tryGetInventoryItem(user_id,"cafecleite",1) then

            TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
            vRPclient._CarregarObjeto(src,"amb@world_human_aa_coffee@idle_a","idle_a","prop_fib_coffee",49,28422)
            TriggerClientEvent("progress",source,10000,"tomando")
            TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

            SetTimeout(10000,function()
                vRPclient._stopAnim(source,false)
                vRP.varyThirst(user_id,-40)
                vRP.varyHunger(user_id,0)
                vRPclient._DeletarObjeto(src)
            end)

        end
    end,

    ['cafeexpresso'] = function(source,user_id,item,amount)
        local src = source
        if vRP.tryGetInventoryItem(user_id,"cafeexpresso",1) then

            TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
            vRPclient._CarregarObjeto(src,"amb@world_human_aa_coffee@idle_a","idle_a","prop_fib_coffee",49,28422)
            TriggerClientEvent("progress",source,10000,"tomando")
            TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

            SetTimeout(10000,function()
                vRPclient._stopAnim(source,false)
                vRP.varyThirst(user_id,-40)
                vRP.varyHunger(user_id,0)
                vRPclient._DeletarObjeto(src)
            end)

        end
    end,


['capuccino'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"capuccino",1) then

        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_aa_coffee@idle_a","idle_a","prop_fib_coffee",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,-55)
            vRP.varyHunger(user_id,0)
            vRPclient._DeletarObjeto(src)
        end)

    end
end,
['frappuccino'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"frappuccino",1) then

        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_aa_coffee@idle_a","idle_a","prop_fib_coffee",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,-65)
            vRP.varyHunger(user_id,0)
            vRPclient._DeletarObjeto(src)
        end)

    end
end,
['cha'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"cha",1) then

        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_energy_drink",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,-50)
            vRP.varyHunger(user_id,0)
            vRPclient._DeletarObjeto(src)
        end)

    end
end,
['icecha'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"icecha",1) then

        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_energy_drink",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,-50)
            vRP.varyHunger(user_id,0)
            vRPclient._DeletarObjeto(src)
        end)

    end
end,
['sprunk'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"sprunk",1) then

        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","ng_proc_sodacan_01b",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,-65)
            vRP.varyHunger(user_id,0)
            vRPclient._DeletarObjeto(src)
        end)

    end
end,
['cola'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"cola",1) then

        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","ng_proc_sodacan_01a",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,-70)
            vRP.varyHunger(user_id,0)
            vRPclient._DeletarObjeto(src)
        end)

    end
end,
['energetico'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"energetico",1) then

        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_energy_drink",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,-100)
            vRP.varyHunger(user_id,0)
            vRPclient._DeletarObjeto(src)
        end)

    end
end,
['suspensao-ar'] = function(source,user_id)
    TriggerClientEvent("zo_install_suspe_ar", source)
end,
['modulo-neon'] = function(source,user_id)
    TriggerClientEvent("zo_install_mod_neon", source)
end,
['modulo-xenon'] = function(source,user_id)
    TriggerClientEvent("zo_install_mod_xenon", source)
end,
['pibwassen'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"pibwassen",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,-10)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['tequilya'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"tequilya",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_beer_logopen",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,15)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['patriot'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"patriot",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,-10)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['blarneys'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"blarneys",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","p_whiskey_notop",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,15)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['jakeys'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"jakeys",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_beer_logopen",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,15)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['barracho'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"barracho",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_amb_beer_bottle",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,15)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end, 
['ragga'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"ragga",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","p_whiskey_notop",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,15)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['nogo'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"nogo",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_beer_logopen",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,15)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['mount'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"mount",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","p_whiskey_notop",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,20)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['cherenkov'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"cherenkov",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_beer_logopen",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,20)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['bourgeoix'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"bourgeoix",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","p_whiskey_notop",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,20)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['bleuterd'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"bleuterd",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_beer_logopen",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Bebendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,20)
            vRP.varyHunger(user_id,0)
            TriggerClientEvent("inventory:checkDrunk",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['rosquinha'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"rosquinha",1) then
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        TriggerClientEvent("emotes",source,"comer3")
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['sanduiche'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"sanduiche",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        TriggerClientEvent("emotes",source,"comer")
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,

['hotdog'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"hotdog",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        TriggerClientEvent("emotes",source,"comer2")
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['xburguer'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"xburguer",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        TriggerClientEvent("emotes",source,"comer")
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['chips'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"chips",1) then

        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@code_human_wander_eating_donut@male@idle_a","idle_c","ng_proc_food_chips01b",49,28422)
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['batataf'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"batataf",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@code_human_wander_eating_donut@male@idle_a","idle_c","prop_food_bs_chips",49,28422)
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['pizza'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"pizza",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@code_human_wander_eating_donut@male@idle_a","idle_c","v_res_tt_pizzaplate",49,28422)
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['frango'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"frango",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@code_human_wander_eating_donut@male@idle_a","idle_c","prop_food_cb_nugets",49,28422)
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['bcereal'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"bcereal",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@code_human_wander_eating_donut@male@idle_a","idle_c","prop_choc_pq",49,28422)
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['bchocolate'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"bchocolate",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@code_human_wander_eating_donut@male@idle_a","idle_c","prop_choc_meto",49,28422)
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['taco'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"taco",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@code_human_wander_eating_donut@male@idle_a","idle_c","prop_taco_01",49,28422)
        TriggerClientEvent("progress",source,10000,"comendo")
        TriggerClientEvent("itensNotify",source,'use',"Comendo",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            vRP.varyThirst(user_id,0)
            vRP.varyHunger(user_id,-40)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['paracetamil'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"paracetamil",1) then
        
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_cs_pills",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Tomando",""..srv.getItemName(item).."")

        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            TriggerClientEvent("remedios",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['voltarom'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"voltarom",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_cs_pills",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Tomando",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            TriggerClientEvent("remedios",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['trandrylux'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"trandrylux",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_cs_pills",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Tomando",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            TriggerClientEvent("remedios",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['dorfrex'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"dorfrex",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_cs_pills",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Tomando",""..srv.getItemName(item).."")
        
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            TriggerClientEvent("remedios",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,
['buscopom'] = function(source,user_id,item,amount)
    local src = source
    if vRP.tryGetInventoryItem(user_id,"buscopom",1) then
        
        TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
        vRPclient._CarregarObjeto(src,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_cs_pills",49,28422)
        TriggerClientEvent("progress",source,10000,"tomando")
        TriggerClientEvent("itensNotify",source,'use',"Tomando",""..srv.getItemName(item).."")
        SetTimeout(10000,function()
            
            vRPclient._stopAnim(source,false)
            TriggerClientEvent("remedios",source)
            vRPclient._DeletarObjeto(src)
        end)
    end
end,

['mochilap'] = function(source,user_id,item,amount)
    local src = source
    if vRP.getInventoryMaxWeight(user_id) >= 51 then
        TriggerClientEvent("Notify",source,"negado","Você não pode equipar mais mochilas.",8000)
    else
        if vRP.tryGetInventoryItem(user_id,"mochilap",1) then
            TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
            vRP.varyExp(user_id,"physical","strength",650)
            if config.equipBackpack then TriggerClientEvent("inventory:mochilaon",source) end
            TriggerClientEvent("itensNotify",source,'use',"Equipou",""..srv.getItemName(item).."")
        end
    end
end,

['mochilam'] = function(source,user_id,item,amount)
    if vRP.getInventoryMaxWeight(user_id) >= 51 then
        TriggerClientEvent("Notify",source,"negado","Você não pode equipar mais mochilas.",8000)
    else
        if vRP.tryGetInventoryItem(user_id,"mochilam",1) then
            TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
            vRP.varyExp(user_id,"physical","strength",1300)
            if config.equipBackpack then TriggerClientEvent("inventory:mochilaon",source) end
            TriggerClientEvent("itensNotify",source,'use',"Equipou",""..srv.getItemName(item).."")
        end
    end
end,

['mochilag'] = function(source,user_id,item,amount)
    if vRP.getInventoryMaxWeight(user_id) >= 51 then
        TriggerClientEvent("Notify",source,"negado","Você não pode equipar mais mochilas.",8000)
    else
        if vRP.tryGetInventoryItem(user_id,"mochilag",1) then
            TriggerClientEvent('vrp_inventory:Update',source,'updateInventory')
            vRP.varyExp(user_id,"physical","strength",1900)
            if config.equipBackpack then TriggerClientEvent("inventory:mochilaon",source) end
            TriggerClientEvent("itensNotify",source,'use',"Equipou",""..srv.getItemName(item).."")
        end
    end
end,

['colete'] = function(source,user_id,item,amount)
    if vRP.tryGetInventoryItem(user_id,"colete",1) then
        vRPclient.setArmour(source,100)
        TriggerClientEvent("itensNotify",source,'use',"Equipou",""..srv.getItemName(item).."")
    end
end,
}

return itens