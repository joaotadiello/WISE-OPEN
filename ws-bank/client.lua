local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local config = module("ws-bank","config")
vRP = Proxy.getInterface("vRP")

cl = {}
Tunnel.bindInterface('ws-bank',cl)
Proxy.addInterface('ws-bank',cl)

srv = Tunnel.getInterface('ws-bank')

local index = nil
local coordenada_bancos = config.coords_bank

local cooldown = 0
local onBank = false

-----------------------------------------------------------
--- [ Sistema de distancia ]
-----------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local idle = 400
        if index == nil then
            checkDistance()
        else
            idle = 1
            local distancia = #(GetEntityCoords(PlayerPedId()) - coordenada_bancos[index].coordenada)
            if not onBank then
                if config.customBlip then
                    mBMarker(coordenada_bancos[index].coordenada, config.customBlip.tamanho, config.customBlip.tamanho,config.customBlip.tamanho, config.customBlip.dic, config.customBlip.img)
                else
                    mBMarker(coordenada_bancos[index].coordenada, tonumber('0.3'), tonumber('0.3'),tonumber('0.3'), "images", "banco")
                end
            end
            if distancia <= 1.2 and IsControlJustPressed(0,38) then
                if config.aberto_24h then
                    cl.open_bank() 
                else
                    if get_timer() >= parseInt(config.horario_abrir) and get_timer() <= parseInt(config.horario_fechar) then
                        cl.open_bank() 
                    else
                        StartScreenEffect("MenuMGSelectionIn", 0, true)
                        SetNuiFocus(true,true)
                        SendNUIMessage({
                            type = "fechado",
                            abertura = config.horario_abrir,
                            fechamento = config.horario_fechar,
                        })
                    end
                end
            end

            if distancia >= 5 then
                index = nil
                onBank = false
            end
        end
        Wait(idle)
    end
end)

cl.open_bank = function()
    onBank = true
    local carteira,banco,nome = srv.get_player_info()
    StartScreenEffect("MenuMGSelectionIn", 0, true)
    SetNuiFocus(true,true)
    SendNUIMessage({
        type = "show",
        nome = nome,
        bank = banco,
        money = carteira,
        logo = config.logo,
        key_pix = srv.get_key_pix(),
        rendimentos = srv.get_rendimento()
    })
end

Citizen.CreateThread(function()
    if config.atm then
        while true do
            if IsControlJustPressed(0,38) then
                if getNearestATM() then
                    cl.open_bank() 
                end
            end
            Wait(1)
        end
    end
end)

getNearestATM = function()
    for k,v in pairs(config.propCaixas) do
        local obj = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()),1.5,GetHashKey(v), false,false,false)
        if obj > 0 then
            local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(obj))
            if distance <= 1.5 then
                return true
            end
        end
    end
end

checkDistance = function()
    for k,v in pairs(coordenada_bancos) do
        local distancia = #(GetEntityCoords(PlayerPedId()) - v.coordenada)
        if distancia <= 5 then
            index = k
        end
    end
end

get_timer = function()
    local n = GetClockHours()
    return n
end

-----------------------------------------------------------
--- [ Callbacks NUI ]
-----------------------------------------------------------
RegisterNUICallback('ws:get_players_trans',function(data,cb)
    local player = srv.get_players_trans()
    if player then
        cb({players = player})
    end
end)

RegisterNUICallback('ws:update_key',function(data,cb)
    local key = srv.get_key_pix()
    if key then
        cb({chave = key})
    end
end)

RegisterNUICallback('register_pix',function(data,cb)
    local key = data.key
    if key then
        srv.create_pix(key)
    end
end)

RegisterNUICallback('edit_pix',function(data,cb)
    local key = data.key
    if key then
        srv.edit_pix(key)
    end
end)

RegisterNUICallback('remove_pix',function(data,cb)
    if cooldown == 0 then
        cooldown = 1
        srv.remove_pix()
    end
end)

RegisterNUICallback('ws:sacar',function(data,cb)
    if cooldown == 0 then
        cooldown = 1
        local value = tonumber(data.value)
        if value ~= nil and value > 0 then
            srv.sacar(value)
        end
    end
end)

RegisterNUICallback('ws:depositar',function(data,cb)
    if cooldown == 0 then
        cooldown = 1
        local value = tonumber(data.value)
        if value ~= nil and value > 0 then
            srv.depositar(value)
        end
    end
end)

RegisterNUICallback('ws:limpar_transferencia',function(data,cb)
    if cooldown == 0 then
        cooldown = 1
        srv.clear_transferencia()
    end
end)

RegisterNUICallback('ws:pagar_multas',function(data,cb)
    if cooldown == 0 then
        cooldown = 1
        local value = tonumber(data.value)
        if value ~= nil and value > 0 then
            srv.pagar_multas(value)
        end
    end
end)

RegisterNUICallback('get_multas',function(data,cb)
    local multas = srv.get_multas()
    if multas then
        cb({multas = multas})
    end
end)


RegisterNUICallback('gerate_grafico',function(data,cb)
    local ganhou,perdeu,multas,total,rendimento = srv.gerenate_data()
    if ganhou and perdeu and multas and total and rendimento then
        cb({ganhou = ganhou,perdeu = perdeu,multas = multas,total = total,rendimento = rendimento})
    end
end)

RegisterNUICallback('pagar_multa',function(data)
    if cooldown == 0 then
        cooldown = 1
        local id = tonumber(data.id_multa)
        if id then
            srv.pagar_multa(id)
        end
    end
end)

RegisterNUICallback('ws:get_trans',function(data,cb)
    local trans = srv.get_historico_bank()
    if trans then
        cb({trans = trans})
    end
end)

RegisterNUICallback('ws:enviar_transferencia',function(data,cb)
    if cooldown == 0 then
        cooldown = 1
        local id,valor = parseInt(data.id),parseInt(data.valor)
        if id and valor then
            if valor > 0 then
                srv.tranferir(id,valor)
            end
        end
    end
end)

RegisterNUICallback('ws:update_money',function(data,cb)
    local wallet,bank = srv.update_money()
    if wallet and bank then
        cb({money = wallet,bank = bank})
    end
end)

--Fechar NUI
RegisterNUICallback('ws:close',function(data,cb)
    StopScreenEffect("MenuMGSelectionIn")
    SetNuiFocus(false,false)
    onBank = false
end)


Citizen.CreateThread(function()
    StopScreenEffect("MenuMGSelectionIn")
    SetNuiFocus(false,false)
end)

cl.notify = function(type,title,message)
    SendNUIMessage({
        type = "notify",
        mode = type,
        title = title,
        message = message,
    })
end

RegisterNetEvent('bank_notify')
AddEventHandler('bank_notify',function(type,title,message)
    SendNUIMessage({
        type = "notify",
        mode = type,
        title = title,
        message = message,
    })
end)

Citizen.CreateThread(function()
    while true do
        if cooldown > 0 then
            cooldown = cooldown - 1
        end
        Wait(1000)
    end
end)

function mBMarker(vector, sizex, sizey, sizez, src, id)
    if not HasStreamedTextureDictLoaded(src) then
        RequestStreamedTextureDict(src, true)
        while not HasStreamedTextureDictLoaded(src) do
            Wait(1)
        end
    else
        local x,y,z = table.unpack(vector)
        DrawMarker(9, x, y, z, 0.0, 0.0, 0.0, tonumber('90.0'), tonumber('90.0'), 0.0, sizex, sizey, sizez, 255, 255, 255, 255,false, true, 2, false, src, id, false)
    end
end

AddEventHandler('playerSpawned',function()
    TriggerServerEvent('register:name')
end)

Citizen.CreateThread(function() 
    Wait(1000)
    TriggerServerEvent(GetCurrentResourceName()..':auth', tostring(GetCurrentServerEndpoint()):gsub('.+:(%d+)','%1'))
end)