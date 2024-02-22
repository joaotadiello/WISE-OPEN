local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')

API = Tunnel.getInterface('ws-farm')

local cache = {}
local inColeta = false
local inEntrega = false
local coldown = 0
cache.indexFarme = nil
cache.coletar = {}
cache.fabricar = {}
cache.entregar = {}
cache.index = 1 -- index da rota

----------------------------------------------------------------------------------
-- [ OPEN MENU ]
----------------------------------------------------------------------------------
Citizen.CreateThread(function()
    StopScreenEffect("MenuMGSelectionIn")

    while true do
        local idle = 400
        if not cache.indexFarme then
            GetIndexFarm()
        else
            idle = 1
            if config.OpenMenu[cache.indexFarme].blip then
                mBMarker(config.OpenMenu[cache.indexFarme].cds, tonumber('0.3'), tonumber('0.3'),tonumber('0.3'), 'ws_farm', config.OpenMenu[cache.indexFarme].blip)
            else
                DrawMarker(3,config.OpenMenu[cache.indexFarme].cds.x,config.OpenMenu[cache.indexFarme].cds.y,config.OpenMenu[cache.indexFarme].cds.z-0.65,0,0,0,0.0,0,0,0.3,0.3,0.3,5, 161, 242,100,0,0,0,1)
            end
            local distance = #(GetEntityCoords(PlayerPedId()) - config.OpenMenu[cache.indexFarme].cds)
            if distance <= 2 and IsControlJustPressed(0,38) then
                if API.HasPermission(config.OpenMenu[cache.indexFarme].farme) then
                    if inColeta or inEntrega then
                        TriggerEvent('Notify','negado','Você não pode acessar o farme em quanto está com algum serviço ativo!')
                    else
                        -- cache.indexFarme = 1 -- int
                        -- config.OpenMenu[cache.indexFarme].farme = nome do farme
                        SetNuiFocus(true,true)
                        StartScreenEffect("MenuMGSelectionIn", 0, true)
                        SendNUIMessage({
                            ip = API.GetIP(),
                            action = "show",
                            buttons = config.script[config.OpenMenu[cache.indexFarme].farme].opcoes,
                            indexFarme = config.OpenMenu[cache.indexFarme].farme,
                            farmeName = config.OpenMenu[cache.indexFarme].name
                        })
                    end
                end
            end
            if distance >= 10 then
                cache.indexFarme = nil
            end
        end
        Wait(idle)
    end
end)

GetIndexFarm = function()
    for k,v in pairs(config.OpenMenu) do
        local distance = #(GetEntityCoords(PlayerPedId()) - v.cds)
        if distance <= 10 then
            cache.indexFarme = k
        end
    end
end

RegisterNetEvent('ws-farm:endFarm')
AddEventHandler('ws-farm:endFarm',function()
    SetTimeout(500,function()
        inEntrega = false
        inColeta = false
        RemoveBlip(cache.blips)
        cache.blips = false
    end)
end)
----------------------------------------------------------------------------------
-- [ NUI CALLBACK ]
----------------------------------------------------------------------------------
close = function()
    StopScreenEffect("MenuMGSelectionIn")
    SetNuiFocus(false,false)
end

RegisterNUICallback('close',function(data)
    close()
end)
-------------------------------------------------------------------------------------------
-- [ Entregar ]
-------------------------------------------------------------------------------------------
RegisterNUICallback('GetEntregarCache',function(data,cb)
    local index = data.indexFarme
    cb({itens = GetCacheEntregar(index)})
end)

GetCacheEntregar = function(indexFarme)
    if not cache.entregar[indexFarme] then
        cache.entregar[indexFarme] = API.EntregarIndex(indexFarme)
    end
    return cache.entregar[indexFarme]
end

RegisterNUICallback('EntregarItem',function(data,cb)
    local farmeIndex,item = data.indexFarme,data.item
    cache.farmeIndex = farmeIndex
    cache.item = item
    inEntrega = true
    CreateRouteEntrega()
end)

CreateRouteEntrega = function()
    if config.script[cache.farmeIndex].rota_aleatoria then
        cache.index = math.random(1,#config.script[cache.farmeIndex].cds)
    else
        if cache.index < #config.script[cache.farmeIndex].cds then
            cache.index = cache.index + 1
        else
            cache.index = 1
        end
    end
    if cache.index then
        CriandoBlip(config.script[cache.farmeIndex].cds[cache.index])
        GetDistanceEntrega()
    end
end
local cooldown = 0
GetDistanceEntrega = function()
    Citizen.CreateThread(function()
        local cds = config.script[cache.farmeIndex].cds[cache.index]
        local oldIndex = cache.index
        local ped = PlayerPedId()
        while cache.index == oldIndex and cache.blips and inEntrega do
            local idle = 300
            local distance = #(GetEntityCoords(ped) - cds)
            if distance <= 10 then
                idle = 1
			    DrawMarker(3,config.script[cache.farmeIndex].cds[cache.index].x,config.script[cache.farmeIndex].cds[cache.index].y,config.script[cache.farmeIndex].cds[cache.index].z-0.65,0,0,0,0.0,0,0,0.3,0.3,0.3,5, 255, 0,150,0,0,0,1)

                if distance <= 2 and IsControlJustPressed(0,38) and cooldown == 0 then
                    cooldown = 2
                    RemoveBlip(cache.blips)
                    API.GiveRewardEntrega(cache.farmeIndex,cache.item)
                    CreateRouteEntrega()
                end
            end
            Wait(idle)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        local idle = 1000
        if inEntrega then
            idle = 1
            dwText("Pressione ~r~F7~w~ para cancelar o serviço",0.95)
            if IsControlJustPressed(0,168) then
                inEntrega = false
                RemoveBlip(cache.blips)
                cache.blips = false
                TriggerEvent('Notify','negado','Você saiu do serviço atual!')
            end
        end 
        Wait(idle)
    end
end)


-------------------------------------------------------------------------------------------
-- [ CRAFT ]
-------------------------------------------------------------------------------------------
local craftTimers = false
RegisterNUICallback('CraftItem',function(data,cb)
    if coldown == 0 then
        coldown = 2 
        local farmeIndex,item = data.indexFarme,data.item
        local seconds,item = API.CraftItem(farmeIndex,item)
        if seconds and item and not craftTimers and type(craftTimers) == 'boolean' then
            craftTimers = {seconds,item,farmeIndex}
            cb({true})
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if type(craftTimers) == 'table' then
            if craftTimers[1] > 0 then
                craftTimers[1] = craftTimers[1] - 1
                SendNUIMessage({action='timer',value = craftTimers[1],craftItem = craftTimers[2]})
                if craftTimers[1] == 0 then
                    craftTimers = false
                end
            end
        end
        if cooldown > 0 then
            cooldown = cooldown - 1
        end
        Wait(1000)
    end
end)

RegisterNUICallback('GetCacheFabricar',function(data,cb)
    local index = data.indexFarme
    cb({itens = GetCacheFabricar(index)})
end)

GetCacheFabricar = function(indexFarme)
    if not cache.fabricar[indexFarme] then
        cache.fabricar[indexFarme] = API.FabricarIndex(indexFarme)
    end
    return cache.fabricar[indexFarme]
end
-------------------------------------------------------------------------------------------
-- [ COLETAR ]
-------------------------------------------------------------------------------------------
RegisterNUICallback('GetColetarItens',function(data,cb)
    local index = data.indexFarme
    cb({itens = GetCacheColetarIndex(index)})
end)

GetCacheColetarIndex = function(indexFarme)
    if not cache.coletar[indexFarme] then
        cache.coletar[indexFarme] = API.ColeteItensIndex(indexFarme)
    end
    return cache.coletar[indexFarme]
end

RegisterNUICallback('ColeteItem',function(data,cb)
    local farmeIndex,item = data.indexFarme,data.item
    cache.farmeIndex = farmeIndex
    cache.item = item
    inColeta = true
    CreateRoute()
end)

Citizen.CreateThread(function()
    while true do
        local idle = 1000
        if inColeta then
            idle = 1
            dwText("Pressione ~r~F7~w~ para cancelar o serviço",0.95)
            if IsControlJustPressed(0,168) then
                inColeta = false
                RemoveBlip(cache.blips)
                cache.blips = false
                TriggerEvent('Notify','negado','Você saiu do serviço atual!')
            end
        end 
        Wait(idle)
    end
end)

function dwText(text,height)
	SetTextFont(4)
	SetTextScale(0.50,0.50)
	SetTextColour(255,255,255,180)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.5,height)
end

CreateRoute = function()
    if config.script[cache.farmeIndex].rota_aleatoria then
        cache.index = math.random(1,#config.script[cache.farmeIndex].cds)
    else
        if cache.index < #config.script[cache.farmeIndex].cds then
            cache.index = cache.index + 1
        else
            cache.index = 1
        end
    end
    if cache.index then
        CriandoBlip(config.script[cache.farmeIndex].cds[cache.index])
        GetDistanceColeta()
    end
end

local coletando = false
GetDistanceColeta = function()
    Citizen.CreateThread(function()
        local cds = config.script[cache.farmeIndex].cds[cache.index]
        local oldIndex = cache.index
        local ped = PlayerPedId()
        while cache.index == oldIndex and cache.blips and inColeta do
            local idle = 300
            local distance = #(GetEntityCoords(ped) - cds)
            if distance <= 10 then
                idle = 1
			    DrawMarker(3,config.script[cache.farmeIndex].cds[cache.index].x,config.script[cache.farmeIndex].cds[cache.index].y,config.script[cache.farmeIndex].cds[cache.index].z-0.65,0,0,0,0.0,0,0,0.3,0.3,0.3,5, 255, 0,150,0,0,0,1)

                if distance <= 2 and IsControlJustPressed(0,38) then
                    if API.GiveRewardColeta(cache.farmeIndex,cache.item) then
                        RemoveBlip(cache.blips)
                        CreateRoute()
                    end
                end
            end
            Wait(idle)
        end
    end)
end

CriandoBlip = function(vector,text)
	cache.blips = AddBlipForCoord(vector)
    SetNewWaypoint(vector.x,vector.y)
	SetBlipSprite(cache.blips,1)
	SetBlipColour(cache.blips,3)
	SetBlipScale(cache.blips,0.4)
	SetBlipAsShortRange(cache.blips,false)
	SetBlipRoute(cache.blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Nova entrega solicitada")
	EndTextCommandSetBlipName(cache.blips)
    TriggerEvent('Notify','sucesso','A rota foi adicionada em seu GPS')
end

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

Citizen.CreateThread(function()
    while true do
        if coldown > 0 then
            coldown = coldown - 1
        end
        Wait(1000)
    end
end)

Citizen.CreateThread(function() 
    Wait(1000)
    TriggerServerEvent(GetCurrentResourceName()..':auth', tostring(GetCurrentServerEndpoint()):gsub('.+:(%d+)','%1'))
end)