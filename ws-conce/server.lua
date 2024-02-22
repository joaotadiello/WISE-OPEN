local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local config = module("ws-conce","config")
local cfg_s = module("ws-conce","config_s")


vRP = Proxy.getInterface("vRP")

srv = {}
Tunnel.bindInterface("ws-conce",srv)
Proxy.addInterface('ws-conce',srv)

local srv_slots = parseInt(GetConvar("sv_maxclients"))
local veiculos = config.veiculos
local active = {}


function webhook(webhook,message)
    if webhook ~= "none" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end

srv.getRegistration = function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        return cfg_s.rg(user_id)
    end
end


----------------------------------------------------------------
--- [ Core functions ]
----------------------------------------------------------------
srv.get_vehicle_stock = function(vehicle)
    local db = vRP.query('get_estoque',{vehicle = vehicle})
    local estoque = db[1].estoque
    return estoque
end

srv.buy_vehicle = function(category,vehicle,tuning,index)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and category and vehicle and tuning then
        cfg_s.buy_vehicle(user_id,category,vehicle,tuning,index)
    end
end

srv.get_my_veh = function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local db = vRP.query('ws/get_vehicle',{user_id = user_id})
        local myVeh = {}
        for k,v in pairs(db) do
            if getVehicleInfo(v.vehicle) then
                myVeh[v.vehicle] = {nome = vRP.vehicleName(v.vehicle),price = getVehiclePrice(v.vehicle)}
            elseif getVehicleInfo(v.veiculo) then
                myVeh[v.veiculo] = {nome = vRP.vehicleName(v.veiculo),price = getVehiclePrice(v.veiculo)}
            end
        end
        return myVeh
    end
end

getVehiclePrice = function(vehicle)
    for k,v in pairs(veiculos) do
        for a,b  in pairs(v) do
            if vehicle == a then
                return parseInt(b.valor)
            end
        end
    end
end
----------------------------------------------------------------
--- [ Core sell vehicle ]
----------------------------------------------------------------
srv.sell_vehicle = function(vehicle)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if active[user_id] == nil then
            active[user_id] = 3
            if srv.checkRentSell(user_id,vehicle) then
                if cfg_s.summerBase then
                    cfg_s.summerBaseSell(source,user_id,vehicle)
                else
                    local vehInfo = getVehicleInfo(vehicle)
                    if type(vehInfo) == "table" and vehInfo.spaw == vehicle then
                        if not vehInfo.vip then
                            local payment = cfg_s.vender_vehicle * vehInfo.valor
                            if checkVehicle(user_id,vehicle) then
                                TriggerClientEvent('ws:update',source)
                                vRP.execute('ws_rem_vehicle',{user_id = user_id, vehicle = vehicle})
                                vRP.giveBankMoney(user_id,payment)
                                if cfg_s.webhook_sell then
                                    webhook(cfg_s.webhook_sell,'```[Concessionaria venda]\n[ID]:'..user_id.."\n[VALOR]:"..payment.."[VEICULO]:"..vehicle..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                                end
                                TriggerClientEvent('ws:pNotify',source,'sucesso',"Você vendeu "..vehInfo.nome.." por "..vRP.format(payment))
                            end
                        else
                            TriggerClientEvent('ws:pNotify',source,'sucesso',"Você não pode vender "..vehInfo.nome..".")
                        end
                    else
                        TriggerClientEvent('ws:pNotify',source,'negado',"Veiculo não encontrado!")
    
                    end
                end
            else
                TriggerClientEvent('ws:update',source)
                TriggerClientEvent('ws:pNotify',source,'negado',"Você não pode vender um veiculo alugado!")
            end
        end
    end
end

checkVehicle = function(user_id,vehicle)
    local db = vRP.query('ws_get_vehicle',{user_id = user_id})
    for k,v in pairs(db) do
        if v.vehicle == vehicle then
            return true
        end
    end
    return false
end

srv.checkRentSell = function(user_id,vehicle)
    local db = vRP.query('get_rent',{user_id = user_id})
    for k,v in pairs(db) do
        if vehicle == v.vehicle then
            return false
        end 
    end
    return true
end

getVehicleInfo = function(vehicle)
    for k,v in pairs(veiculos) do
        for a,b  in pairs(v) do
            if vehicle == a then
                return veiculos[k][vehicle]
            end
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


----------------------------------------------------------------
--- [ Core dimesion ]
----------------------------------------------------------------
local dimesion = {}

RegisterServerEvent('ws:join_dimesion')
AddEventHandler('ws:join_dimesion',function()
    local source = source
    local i = dimesion_available()
    if i then
        dimesion[i] = source
        SetPlayerRoutingBucket(source,i)
    end
end)



RegisterServerEvent('ws:remove_dimesion')
AddEventHandler('ws:remove_dimesion',function()
    local source = source
    if source then
        local n = GetPlayerRoutingBucket(source)
        if n ~= nil and n ~= 0 then
            dimesion[n] = 0
            SetPlayerRoutingBucket(source,0)
        end
    end
end)

dimesion_available = function()
    for k,v in pairs(dimesion) do
        if v == 0 then
            return k
        end
    end
end

gerate_dimesions = function()
    if srv_slots == 1 then
        for i = 1,2 do
            dimesion[i] = 0
        end
    else
        for i = 1,(srv_slots / 2) do
            dimesion[i] = 0
        end
    end
end

Citizen.CreateThread(function()
    gerate_dimesions()
    remove_rent_vehicles()
end)

----------------------------------------------------------------
--- [ CORE - Alugar ]
----------------------------------------------------------------
srv.register_rent = function(categoria,vehicle)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        cfg_s.rent_vehicle(user_id,categoria,vehicle)
    end
end

remove_rent_vehicles = function()
    local db = vRP.query('check_rent')
    local time = os.time()
    for k,v in pairs(db) do
        if tonumber(v.time) <= time then
            vRP.execute('rem_rent',{user_id = v.user_id,vehicle = v.vehicle})
            vRP.execute('ws_rem_vehicle',{user_id = v.user_id,vehicle = v.vehicle})
        end
    end
end