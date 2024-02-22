local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
srv = Tunnel.getInterface('ws-player')

cl = {}
Tunnel.bindInterface('ws-player',cl)


local ip = nil
local type = nil

Citizen.CreateThread(function()
    SetNuiFocus(false,false)
    StopScreenEffect("MenuMGSelectionIn")
end)

function cl.getCoord ()
    return GetEntityCoords(PlayerPedId())
end

function cl.inVehicle()
    return IsPedInAnyVehicle(PlayerPedId())
end
---------------------------------------------------------------------
-- [ Evento para abrir a NUI de roubo ]
---------------------------------------------------------------------
cl.openRoubar = function(itens,nitens)
    if not ip then
        ip = srv.getIp()
    end
    type = "roubar"
    SendNUIMessage({
        type = "roubar",
        action = "show",
        itens = itens,
        nitens = nitens,
        ip = ip,
    })
    SetNuiFocus(true,true)
    StartScreenEffect("MenuMGSelectionIn", 0, true)
end

---------------------------------------------------------------------
-- [ Evento para abrir a NUI de saque ]
---------------------------------------------------------------------
RegisterNetEvent('open:saquear')
AddEventHandler('open:saquear',function(itens,nitens,meuPeso,nPeso)
    if not ip then
        ip = srv.getIp()
    end
    type = "saquear"
    SendNUIMessage({
        type = "saquear",
        action = "show",
        ip = ip,
    })
    SetNuiFocus(true,true)
    StartScreenEffect("MenuMGSelectionIn", 0, true)
end)

cl.openSaquear = function(itens,nitens)
    if not ip then
        ip = srv.getIp()
    end
    type = "saquear"
    SendNUIMessage({
        type = "saquear",
        action = "show",
        itens = itens,
        nitens = nitens,
        ip = ip,
    })
    SetNuiFocus(true,true)
    StartScreenEffect("MenuMGSelectionIn", 0, true)
end

---------------------------------------------------------------------
-- [ Evento para abrir a NUI de revistar ]
---------------------------------------------------------------------
RegisterNetEvent('open:revistar')
AddEventHandler('open:revistar',function()
    if not ip then
        ip = srv.getIp()
    end
    type = "revistar"
    SendNUIMessage({
        type = "revistar",
        action = "show",
        itens = itens,
        ip = ip,
    })
    SetNuiFocus(true,true)
    StartScreenEffect("MenuMGSelectionIn", 0, true)
end)
cl.openRevistar = function(itens,nitens)
    if not ip then
        ip = srv.getIp()
    end
    type = "revistar"
    if IsPedInAnyVehicle(PlayerPedId()) then
        TriggerEvent('Notify','negado','Você não pode revistar dentro de um veículo.')
        return 
    end
    SendNUIMessage({
        type = "revistar",
        action = "show",
        itens = itens,
        ip = ip,
    })
    SetNuiFocus(true,true)
    StartScreenEffect("MenuMGSelectionIn", 0, true)
end

---------------------------------------------------------------------
-- [ Evento para abrir a NUI de revistar ]
---------------------------------------------------------------------
cl.openAprender = function(itens)
    if not ip then
        ip = srv.getIp()
    end
    type = "apreender"
    SendNUIMessage({
        type = "apreender",
        action = "show",
        itens= itens,
        ip = ip,
    })
    SetNuiFocus(true,true)
    StartScreenEffect("MenuMGSelectionIn", 0, true)
end

---------------------------------------------------------------------
-- [ Envia para o server para ele apreender os itens ]
---------------------------------------------------------------------
RegisterNUICallback('sendthief',function(data)
    TriggerServerEvent('apreender:itens')
    SetNuiFocus(false,false)
    StopScreenEffect("MenuMGSelectionIn")
end)

---------------------------------------------------------------------
-- [ Atualiza com os itens de quem está sendo revistado ]
---------------------------------------------------------------------
RegisterNUICallback('updateRevistar',function(data,cb)
    local itens = srv.getPlayerInventory("proximo")
    if itens then
        cb({itens = itens})
    end
end)

---------------------------------------------------------------------
-- [ Atualiza os meus itens ]
---------------------------------------------------------------------
RegisterNUICallback('updateMyItens',function(data,cb)
    local itens = srv.getPlayerInventory("meu")
    if itens then
        cb({itens = itens})
    end
end)

---------------------------------------------------------------------
-- [ Atualiza os itens do alvo ]
---------------------------------------------------------------------
RegisterNUICallback('updateNearestItens',function(data,cb)
    local itens = srv.getPlayerInventory("proximo")
    if itens then
        cb({itens = itens})
    end
end)

RegisterNUICallback('leftToRight',function(data,cb)
    local item,amount = data.item,data.amount
    if item  then
        srv.hjhjFG(item,amount,"JkO@3^0koj")
    end
end)

---------------------------------------------------------------------
-- [ Fecha a NUI ]
---------------------------------------------------------------------
RegisterNUICallback('close',function(data)
    if type == "revistar" then
        TriggerServerEvent('revistar:close')
    elseif type == 'saquear' or type == "roubar" then
        TriggerServerEvent('saquear:close')
    end
    SendNUIMessage({
        action = "close",
    })
    SetNuiFocus(false,false)
    StopScreenEffect("MenuMGSelectionIn")
end)

RegisterNUICallback('inpectClick',function(data)
    local item = data.item
    TriggerServerEvent('apreender:itens',item)
end)