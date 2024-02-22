local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
local config = module('ws-craft','config')
vRP = Proxy.getInterface('vRP')

srv = Tunnel.getInterface('ws-craft')

local cooldown = 0

Citizen.CreateThread(function()
    while true do
        if cooldown > 0 then
            cooldown = cooldown - 1
        end
        Wait(1000)
    end
end)

RegisterCommand('craft',function()
    StartScreenEffect("MenuMGSelectionIn", 0, true)
    TriggerServerEvent('open:craft')
    SetNuiFocus(true,true)
    SendNUIMessage({
        type = 'show',
        ip = srv.getIp(),  
        receitas = pegarReceitasDisponiveis()
    })
end)


function pegarReceitasDisponiveis()
    local receitas = {}
    for k,v in pairs(config.craft) do
        table.insert(receitas,k)
    end
    return receitas
end

Citizen.CreateThread(function()
    SetNuiFocus(false,false)
end)

RegisterNUICallback('pegarReceita',function(data,cb)
    local item = data.item
    if item and cooldown == 0 then
        cooldown = 2
        if config.craft[item] then
            if config.craft[item].requireLocal then
                if type(config.craft[item].coord) == "function" then
                    local distance = #(GetEntityCoords(PlayerPedId()) - config.craft[item].coord)
                    if distance <= 4 then
                        if srv.getPlayerWeight(item) then
                            cb({
                                receita = config.craft[item].receita,
                                giveItem = config.craft[item].giveItem,
                                status = srv.hasPermission(item),
                                index = srv.itemIndexList(config.craft[item].giveItem),
                                indexCraft = item
                            })
                        else
                            SendNUIMessage({
                                type = "close",
                            })
                            SetNuiFocus(false,false)
                            TriggerServerEvent('close:craft')
                        end
                    else
                        TriggerEvent('Notify','aviso','Você precisa estar no local correto!')
                    end
                elseif type(config.craft[item].coord) == "table" then
                    for k,v in pairs(config.craft[item].coord) do
                        local distance = #(GetEntityCoords(PlayerPedId()) - v)
                        if distance <= 4 then
                            if srv.getPlayerWeight(item) then
                                cb({
                                    receita = config.craft[item].receita,
                                    giveItem = config.craft[item].giveItem,
                                    status = srv.hasPermission(item),
                                    index = srv.itemIndexList(config.craft[item].giveItem),
                                    indexCraft = item
                                })
                            else
                                SendNUIMessage({
                                    type = "close",
                                })
                                SetNuiFocus(false,false)
                                TriggerServerEvent('close:craft')
                            end
                        end
                    end
                end
            else
                if srv.getPlayerWeight(item) then
                    cb({
                        receita = config.craft[item].receita,
                        giveItem = config.craft[item].giveItem,
                        status = srv.hasPermission(item),
                        index = srv.itemIndexList(config.craft[item].giveItem),
                        indexCraft = item
                    })
                else
                    SendNUIMessage({
                        type = "close",
                    })
                    SetNuiFocus(false,false)
                    TriggerServerEvent('close:craft')
                end
            end
        end
    end
end)

RegisterNUICallback('updateReceitas',function(data,cb)
    cb({receitas = pegarReceitasDisponiveis()})
end)

-- Atualiza o inventario da pessoa
RegisterNUICallback('updateInventory',function(data,cb)
    local inv = srv.getInventory()
    if inv then
        cb({itens = inv})
    end
end)

RegisterNUICallback('depositCraft',function(data,cb)
    local item,amount = data.item,parseInt(data.amount)
    if item and amount > 0 then
        local status = srv.depositarItem(item,amount)
        cb({status=status})
    end
end)

RegisterNUICallback('refound',function(data,cb)
    srv.reembolsoItens()
end)

local progres = false
local table = {}
RegisterNUICallback('progress',function(data,cb)
    local item = data.item
    if item then
        table.item = data.item
        table.producao = config.craft[item].tempoProducao
        table.porce = parseInt(100 / config.craft[item].tempoProducao)
        table.porceAtual = 0
        progres = true
    end
end)

Citizen.CreateThread(function()
    while true do
        if progres then
            table.porceAtual = table.porceAtual + table.porce
            if table.porceAtual >= 100 then
                progres = false
            end
            SendNUIMessage({
                type = "progress",
                valueBar = table.porceAtual
            })
        end
        Wait(1000)
    end
end)

RegisterNUICallback('stopCraft',function(data,cb)
    local item = data.item
    if item then
        if table.item == item then
            srv.djskjdks(table.item)
            table = {}
        end
    end
end)


RegisterNUICallback('close',function(data,cb)
    SetNuiFocus(false,false)
    TriggerServerEvent('close:craft')
    StopScreenEffect("MenuMGSelectionIn")
end)

RegisterNetEvent('close:craft:fix')
AddEventHandler('close:craft:fix',function()
    table = {}
    progres = false
end)