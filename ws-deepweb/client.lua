local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')

srv = Tunnel.getInterface('ws-deepweb-core')
config = Tunnel.getInterface('ws-deepweb')

local mission = {}

local script = cfg.script
local blackList = cfg.script.blackList
local itemMinValue = cfg.script.minValue

local inMenu = false
local ip = nil
local cooldown = 0
-------------------------------------------------------------------------
--- [ COMMONS ]
-------------------------------------------------------------------------
local cdsindex = nil
local wifi = cfg.wifi
local inside = false
RegisterNUICallback('getInventory',function(data,cb)
    local inventory = srv.getInventory()
    if inventory then
        cb({inventory = inventory})
    end
end)

Citizen.CreateThread(function()
    StopScreenEffect("MenuMGSelectionIn")
    SetNuiFocus(false,false)
end)

if cfg.wifi.active then
    Citizen.CreateThread(function()
        creteBlips()
        while true do
            if not cdsindex then
                getDistance()
            else
                inside = true
                local distance = #(GetEntityCoords(PlayerPedId()) - wifi.areas[cdsindex])
                if distance > wifi.distance then
                    cdsindex = nil
                    inside = false
                    inMenu = false
                end
            end
            Wait(1000)
        end
    end)
else
    inside = true
end

RegisterCommand(script.commandName,function()
    if GetEntityHealth(PlayerPedId()) > 101 then
        if inside and not inMenu then
            if srv.checkItem() then
                if not ip then
                    ip = srv.getIp()
                end
                inMenu = true
                StartScreenEffect("MenuMGSelectionIn", 0, true)
                SendNUIMessage({
                    display = "show",
                    policeValue = GlobalState.policeValue,
                    privateValue = GlobalState.privateValue,
                    openValue = GlobalState.openValue,
                    ip = ip,
                    registro = script.registro,
                })
                SetNuiFocus(true,true)
            else
                TriggerEvent('Notify','aviso','Você precisa de um computador!')
            end
        else
            TriggerEvent('Notify','aviso','Você precisa estar em uma zona de wifi!')
        end
    else
        TriggerEvent('Notify','negado','Você não pode fazer isso estando morto!')
    end
end)

creteBlips = function()
    for _,v in pairs(wifi.areas) do
		local blip = AddBlipForCoord(v.x,v.y,v.z)
		SetBlipSprite(blip,459)
		SetBlipAsShortRange(blip,true)
		SetBlipColour(blip,55)
		SetBlipScale(blip,0.6)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Zona wifi')
		EndTextCommandSetBlipName(blip)
	end
end

getDistance = function()
    local ped = PlayerPedId()
    for k,v in pairs(wifi.areas) do
        local distance = #(GetEntityCoords(ped) - v)
        if distance <= wifi.distance then
            cdsindex = k
        end
    end
end

-------------------------------------------------------------------------
--- [ MERCADO ILEGAL ]
-------------------------------------------------------------------------
RegisterNUICallback('getAllShops',function(data,cb)
    local shops = config.getAllShops()
    if shops then
        cb({shops = shops})
    end
end)

RegisterNUICallback('getItensShops',function(data,cb)
    local token = data.token
    if token then
        local itens,isPolice,activeProtec = srv.formatarProdutos(token)
        cb({itens=itens,isPolice = isPolice,active = activeProtec})
    end
end)


RegisterNUICallback('buyItem',function(data,cb)
    if cooldown == 0 then
        local token, item, price, amount = data.token,data.item,parseInt(data.price),parseInt(data.amount)
        local itemOrder = {}
        itemOrder.price = price
        itemOrder.item = item
        itemOrder.amount = amount
        itemOrder.token = token
        if cfg.missao.active then
            createMission(itemOrder,'give')
        else
            srv.buyItemShop(token, item, price, amount)
        end
    end
end)

-------------------------------------------------------------------------
--- [ MINHAS LOJAS ]
-------------------------------------------------------------------------
-- Verifica o usuario e senha
RegisterNUICallback('checkToken',function(data,cb)
    local token,senha = data.token,data.password
    if token and senha then
        local status,name = srv.verificarLogin(token,senha)
        if status and name then
            cb({autenticado = true,name = name})
        else
            TriggerEvent('Notify','aviso','Token não encontrado ou a senha está incorreta!')
        end
    end
end)

RegisterNUICallback('criarLoja',function(data,cb)
    local nome,login,senha,police = data.name,data.login,data.password,data.police
    if nome and login and senha then
        if police then
            police = 1
        else
            police = 0 
        end

        if srv.criarLoja(nome,senha,login,police) then
            cb({autenticado = true})
        else
            cb({autenticado = false})
        end
    end
end)
   
-- GERA OS ITENS NA NUI DO MEU SHOP
RegisterNUICallback('gerarItensMeuShop',function(data,cb)
    local token = data.token
    if token then
        local itens = srv.formatarProdutos(token)
        for k,v in pairs(itens) do
            print(k,v)
        end
        cb({itens=itens})
    end
end)   

-- ADICIONA O ITEM A LOJA
RegisterNUICallback('addItemShop',function(data,cb)
    if cooldown == 0 then
        cooldown = 1
        local item,price,amount,token = data.item,parseInt(data.price),tonumber(data.amount),data.token
        if item and price and amount > 0 and token then
            if blackList[item] then
                TriggerEvent('Notify','aviso','Este item não pode ser vendido na deepweb!')
                return
            end
            if itemMinValue[item] and price < itemMinValue[item] then
                TriggerEvent('Notify','aviso','Este item não pode ser vendido por menos de R$<b>'..itemMinValue[item]..'</b>.')
                return
            end
            local itemOrder = {}
            itemOrder.price = price
            itemOrder.item = item
            itemOrder.amount = amount
            itemOrder.token = token

            if cfg.missao.active then
                createMission(itemOrder,'try')
            else
                srv.adicionarItemShop(itemOrder)
            end
        end
    end
end)

RegisterNUICallback('removeItemShop',function(data)
    if cooldown == 0 then
        cooldown = 1
        local token,item,price,estoque = data.token,data.item,parseInt(data.price),data.estoque
        srv.removeItemShop(token,item,price,estoque)
    end
end)

RegisterNUICallback('refreshSaldoShop',function(data,cb)
    local value = config.getWalletShop(data.token)
    if value then
        cb({value = value})
    end
end)

RegisterNUICallback('withdraw',function(data,cb)
    if cooldown == 0 then
        cooldown = 1
        local token,valor = data.token,parseInt(data.value)
        if token and valor and valor > 0  then
            srv.withdrawShop(token,valor)
        end
    end
end)

-------------------------------------------------------------------------
--- [ MISSION SYSTEM ]
-------------------------------------------------------------------------
createMission = function(params,type)
    local index = math.random(1,#cfg.missao.locais)
    mission.cds = cfg.missao.locais[index]
    mission.order = params
    mission.type = type
    if mission.type == 'try' then
        CriandoBlip(mission.cds,'Entregar produto')
    elseif mission.type == 'give' then
        CriandoBlip(mission.cds,'Buscar encomenda')
    end
    TriggerEvent('Notify','sucesso','Vá até o local marcado em seu mapa para buscar a encomenda.')
end

Citizen.CreateThread(function()
    while true do
        local idle = 1000
        if mission.cds then
            local distance = #(GetEntityCoords(PlayerPedId()) - mission.cds)
            if distance <= 15 then
                idle = 1
				mBMarker(mission.cds, tonumber('0.3'), tonumber('0.3'),tonumber('0.3'), "ilegal_draws", 'ilegal')
                if distance <= 1.2 and IsControlJustPressed(0,38) then
                    if mission.cds then
                        RemoveBlip(blips)
                        if mission.type == 'try' then
                            srv.adicionarItemShop(mission.order)
                        elseif mission.type == 'give' then
                            srv.buyItemShop(mission.order.token, mission.order.item, mission.order.price, mission.order.amount)
                        end
                        mission = {}
                    end
                end
            end
        end
        Wait(idle)
    end
end)

function CriandoBlip(vector,text)
	blips = AddBlipForCoord(vector)
    SetBlipSprite(blip,459)
    SetBlipAsShortRange(blip,true)
    SetBlipColour(blip,55)
    SetBlipScale(blip,0.8)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blips)
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

-------------------------------------------------------------------------
--- [ WALLET ]
-------------------------------------------------------------------------
-- ATUALIZA OS SALDO DA CARTEIRA
RegisterNUICallback('atualizarSaldoCarteira',function(data,cb)
    local saldo = srv.atualizarSaldo()
    cb({saldo=tostring(saldo)})
end) 

RegisterNUICallback('getMyShops',function(data,cb)
    local shops = srv.getMyShops()
    if shops then
        cb({shops = shops})
    end
end)

RegisterNUICallback('transferirShop',function(data,cb)
    if cooldown == 0 then
        cooldown = 1
        local target,token = tonumber(data.target),data.token
        if target and token then
            srv.transferShop(target,token)
        end
    end
end)

RegisterNUICallback('deleteShop',function(data,cb)
    local token = data.token
    if token then
        srv.deleteShop(token)
    end
end)

RegisterNUICallback('infoShop',function(data,cb)
    local login,senha = config.getShopInfo(data.token)
    if login and senha then
        cb({login = login,senha = senha})
    end
end)

Citizen.CreateThread(function()
    while true do
        if cooldown > 0 then
            cooldown = cooldown - 1
        end
        Wait(1000)
    end
end)



-------------------------------------------------------------------------
--- [ FECHAR A NUI ]
-------------------------------------------------------------------------
close = function()
    inMenu = false
    StopScreenEffect("MenuMGSelectionIn")
    SetNuiFocus(false,false)
    SendNUIMessage({
        display = "hide",
    })
end
RegisterNUICallback('close',close)