local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP')
garages = Tunnel.getInterface('vrp_garages')
cl = Tunnel.getInterface('ws-desmanche')

local notify = config.notify
local webhookLink = ""
----------------------------------------------------------------------------------------------------------------------------------
-- [ CREATIVE ]
----------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("getVehicleInfoDesmanche","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("mb_setDetido","UPDATE vrp_user_vehicles SET detido = 1, time = @time WHERE user_id = @user_id AND vehicle = @vehicle")
----------------------------------------------------------------------------------------------------------------------------------
-- [ VRPEX ]
----------------------------------------------------------------------------------------------------------------------------------
-- vRP._prepare("getVehicleInfoDesmanche","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
-- vRP._prepare("mb_setDetido","UPDATE vrp_user_vehicles SET detido = @detido, time = @time WHERE user_id = @user_id AND vehicle = @vehicle")

-- Função sempre executada quando inicia o desmanche
verifyVehicle = function(source,user_id,coord,index)
    local vehInfo = {} -- Está tabela e retornada na funcao de finish!!
    local vehicle,vnetid,placa,vname,lock,banned,trunk = vRPclient.vehList(source,2)
    if vehicle and placa and vname then
        if not banned then
            -- local dono = vRP.getUserByRegistration(placa)
            local nation = exports["nation-garages"]
            local dono = nation:getVehicleData(p)
            if dono then
				local veh = vRP.query("getVehicleInfoDesmanche",{ user_id = parseInt(dono), vehicle = vname })
                if veh then
                    -- if #veh <= 0 then
                    --     return false,"Veículo não encontrado na lista do proprietário."
                    -- end
                    -- if parseInt(veh[1].detido) == 1 then
                    --     return false,"Veículo encontra-se apreendido na seguradora."
                    -- end
                    -- if dono == user_id then
                    --     return false,"Você não pode desmanchar seu proprio veiculo!"
                    -- end

                    vehInfo.vnetid = vnetid
                    vehInfo.coord = coord
                    vehInfo.vehicle = vehicle
                    vehInfo.price = vRP.vehiclePrice(vname)
                    vehInfo.model = vname
                    vehInfo.placa = placa
                    vehInfo.dono = dono
                    return true,vehInfo
                end
            end
        else
            return false,"Você não pode desmanchar veiculos proibidos!"
        end
    else
        return false,"Nem um veiculo encontrado!"
    end
end

-- Função sempre executada quando finalza o desmanche
finish = function(source,vehicle,vehInfo,index)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vehInfo and index then
            local pagamento = parseInt(vehInfo.price * 0.5)
            garages.deleteVehicle(source,vehicle) -- Comente caso use a garagem do nation
            -- TriggerEvent("nation:deleteVehicleSync",vehInfo.vnetid) -- Descomente caso use nation_garages
            vRP.execute("mb_setDetido",{ user_id = vehInfo.dono, vehicle = vehInfo.model, time = parseInt(os.time()) })
            vRP.giveMoney(user_id,pagamento)
            TriggerClientEvent('Notify',source,'sucesso','Você recebeu R$'..pagamento..' por desmanchar '..vRP.vehicleName(vehInfo.model))
            webhook(webhookLink,"```prolog\n [DESMANCHE "..index.."]\n[USER ID]:"..user_id.."\n[VEICULO]:"..vehInfo.model.."\n[DONO DO VEICULO]:"..vehInfo.dono.."\n[PLACA]:"..vehInfo.placa..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
        end
    end
end

-- Função executada quando cancela o desmanche do veiculo
cancel = function(source,veh,index,vehicle)
    if veh and veh.dono and veh.vehicle and veh.model and veh.placa then
        garages.deleteVehicle(source,vehicle) -- Comente caso use a garagem do nation
        -- TriggerEvent("nation:deleteVehicleSync",veh.vnetid) -- Descomente caso use nation_garages
        webhook(webhookLink,"```prolog\n [DESMANCHE "..index.." - CANCELADO]\n[USER ID]:"..vRP.getUserId(source).."\n[VEICULO]:"..veh.model.."\n[DONO DO VEICULO]:"..veh.dono.."\n[PLACA]:"..veh.placa..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
        TriggerClientEvent('Notify',source,'aviso','O veiculo foi recuperado pela policia!')
    end
end

-- Função para verificar a permissão
hasPermission = function(user_id,perm)
    return vRP.hasPermission(user_id,perm)
end

GetUserSource = function(user_id)
    return vRP.getUserSource(user_id)
end

ForceDeleteVehicle = function(vehicle,vnetid,prop)
    if vehicle and vnetid and prop then
        local users = vRP.getUsers()
        for k,v in pairs(users) do
            garages.deleteVehicle(v,vehicle)
            --TriggerEvent("nation:deleteVehicleSync",vnetid)
            DeleteEntity(prop)
            break
        end
    end
end

GiveItem = function(source,user_id,item,amount)
    local invWeight = vRP.getInventoryWeight(user_id)
    local maxWeight = vRP.getInventoryMaxWeight(user_id)
    local newWeight = invWeight + vRP.getItemWeight(item)
    if newWeight <= maxWeight then
        vRP.giveInventoryItem(user_id,item,amount)
        TriggerClientEvent(notify['NOME_DO_EVENTO'],source,notify['NOTIFY_SUCESSO'],'Você recebeu '..amount..'x '..vRP.itemNameList(item)..'.')
    else
        TriggerClientEvent(notify['NOME_DO_EVENTO'],source,notify['NOTIFY_ERRO'],'Você não pode carregar mais itens!')
    end
end

TryItem = function(source,user_id)
    local macaricoAmount = vRP.getInventoryItemAmount(user_id,'agua')
    local macacoAmount = vRP.getInventoryItemAmount(user_id,'agua')
    if macacoAmount >= 1 and macaricoAmount >= 4 then
        vRP.tryGetInventoryItem(user_id,'agua',1)
        vRP.tryGetInventoryItem(user_id,'agua',4)
        return true
    end
end

function webhook(webhook,message)
    if webhook ~= "none" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end