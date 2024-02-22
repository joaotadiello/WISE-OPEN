local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
local config = module('ws-inventario',"config")
vRP = Proxy.getInterface('vRP')

cl = {}
Tunnel.bindInterface('ws-inventario',cl)
srv = Tunnel.getInterface('ws-inventario')

local coldown = 0
local shop = config.coordenadaDepartamento

cache = {}
cache.chest = nil
cache.trunk = nil
cache.shop = nil
cache.shopType = nil
cache.home = nil

local inChest = false

config.keyMappin()

RegisterCommand('inv',function()
    if GetEntityHealth(PlayerPedId()) > 101 then
        if not vRP.isHandcuffed() then
            if coldown == 0 then
                coldown = 1
                local inventory,invWeight,maxInv = srv.getInventory()
                local weapons = cl.getWeapons()
                if inventory  and invWeight and maxInv and weapons then
                    SendNUIMessage({
                        action = "show",
                        playerWeapons = weapons,
                        inventory = inventory,
                        invWeight = invWeight,
                        maxInv = maxInv,
                        slots = config.core.slotNumber,
                        ip = srv.getIP(),
                    })
                    SetNuiFocus(true,true)
                    StartScreenEffect("MenuMGSelectionIn", 0, true)
                end
            end
        else
            TriggerEvent('Notify','negado',"Você não pode abrir o inventario algemado!")
        end
    else
        TriggerEvent('Notify','negado',"Você não pode abrir o inventario morto!")
    end
end)

RegisterCommand('_trunk',function()
    if coldown == 0 then
        coldown = 1
        local inventory,invWeight,maxInv = srv.getInventory()
        local chest,max,atual,status = srv.openTrunk()
        if status then
            if inventory and invWeight and maxInv then
                local vehicle,vnet,placa = config.core.vehInfo(5)
                local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle))
                if distance <= 3 then
                    if placa then
                        if srv.checkTrunk(placa) then
                            cache.trunk = placa
                            SendNUIMessage({
                                action = "show",
                                playerWeapons = cl.getWeapons(),
                                inventory = inventory,
                                invWeight = invWeight,
                                maxInv = maxInv,
                                slots = config.core.slotNumber,
                                secondary = chest,
                                type_secondary = 'trunk',
                                maxPeso = max,
                                pesoAtual = atual,
                                ip = srv.getIP(),
                            })
                            SetNuiFocus(true,true)
                            StartScreenEffect("MenuMGSelectionIn", 0, true)
                        end
                    end
                else
                    TriggerClientEvent('Notify','aviso','Nem um porta malas encontrado.')
                end
            end
        end
    end
end)

----------------------------------------------------------------------------------------------
--- [ CORE - slots ]
----------------------------------------------------------------------------------------------
RegisterNUICallback('updateMochila',function(data,cb)
    local inventory,invWeight,maxInv = srv.getInventory()
    if inventory and invWeight and maxInv then
        cb({inventory = inventory,slotsMax = 24,pesoAtual = invWeight,pesoMax = maxInv})
    end
end)

----------------------------------------------------------------------------------------------
--- [ CORE - Inventory ]
----------------------------------------------------------------------------------------------
RegisterNUICallback('useItem',function(data,cb)
    local item,type,amount = data.item,data.type,parseInt(data.amount)
    if item and type and amount and amount >= 0 then
        srv.useItem(item,amount,type)
    end
end)

RegisterNUICallback('trashItem',function(data,cb)
    local item,amount = data.item,data.amount
    if item then
        srv.deleteItem(item,amount)
    end
end)

RegisterNUICallback('enviarItem',function(data,cb)
    local item,amount = data.item,parseInt(data.amount)
    if item and amount then
        srv.sendItem(item,amount)
    end
end)

RegisterNUICallback('getItemInfo',function(data,cb)
    local item,amount = data.item,parseInt(data.amount)
    if item and amount then
        local desc,peso,name = srv.getItemInfo(item,amount)
        cb({desc = desc,peso = peso,name = name })
    end
end)


RegisterNetEvent('ws:inventory:update')
AddEventHandler('ws:inventory:update',function()
    local inventory,invWeight,maxInv = srv.getInventory()
    SendNUIMessage({
        action = "update",
        playerWeapons = cl.getWeapons(),
        inventory = inventory,
        invWeight = invWeight,
        maxInv = maxInv,
        slots = config.core.slotNumber,
        ip = srv.getIP(),
    })
end)

RegisterNetEvent('ws:inventory:weapon')
AddEventHandler('ws:inventory:weapon',function(weapon,status)
    if status == "WS:INVENTORY" then
        config.core.giveWeaponToPlayer(weapon)
    end
end)

RegisterNetEvent('ws:inventory:weaponAmmo')
AddEventHandler('ws:inventory:weaponAmmo',function(weapon,amount,status)
    if status == "WS:INVENTORY" then
        config.core.giveAmmoToPlayer(weapon,amount)
    end
end)

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
--- [ CORE - BAUS ]
----------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    local chestIndex = nil
    while true do
        local idle = 500
        if chestIndex == nil then
            chestIndex = checkDistanceChest()
        else
            idle = 1
            local distance = #(config.chest[chestIndex].cds - GetEntityCoords(PlayerPedId()))
            if config.chest[chestIndex].exibir and not inChest then
                mBMarker(config.chest[chestIndex].cds, tonumber('0.3'), tonumber('0.3'),tonumber('0.3'), "images", config.chest[chestIndex].icon)
            end
            if distance < 1.2 and IsControlJustPressed(0,38) then
                if srv.checkPerm(chestIndex) then
                    --if srv.registerUserChest(chestIndex) then
                        local inventory,invWeight,maxInv = srv.getInventory()
                        local chest,max,atual = srv.openChest(chestIndex)
                        if inventory and invWeight and maxInv then
                            inChest = true
                            cache.chest = chestIndex
                            SendNUIMessage({
                                action = "show",
                                playerWeapons = cl.getWeapons(),
                                inventory = inventory,
                                invWeight = invWeight,
                                maxInv = maxInv,
                                slots = config.core.slotNumber,
                                secondary = chest,
                                type_secondary = "chest",
                                ip = srv.getIP(),
                                maxPeso = max,
                                pesoAtual = atual
                            })
                            SetNuiFocus(true,true)
                            --StartScreenEffect("MenuMGSelectionIn", 0, true)
                        end
                    --end
                end
            end
            if distance >= 5 then
                inChest = false
                chestIndex = nil
            end
        end
        Wait(idle)
    end
end)

checkDistanceChest = function()
    for k,v in pairs(config.chest) do
        local distance = #(v.cds - GetEntityCoords(PlayerPedId()))
        if distance <= 5 then
            return k
        end
    end
end

RegisterNUICallback('nearToInv',function(data,cb)
    local item,amount,stype = data.item,parseInt(data.amount),data.stype
    if item and amount and amount >= 0 then
        if stype == "chest" then
            srv.takeChest(cache.chest,item,amount)
            local chest,max,atual = srv.openChest(cache.chest)
            cb({chest = chest,max = max,atual = atual})

        elseif stype == "trunk" then            
            srv.takeItemTrunk(item,amount)
            local chest,max,atual = srv.openTrunk()
            cb({chest = chest,max = max,atual = atual})

        elseif stype == "homes" then
            local chest,max,atual = srv.takeItemHome(item,amount,cache.home)
            cb({chest = chest,max = max,atual = atual})

        elseif stype == "shop" then
            srv.buyItenShop(item,amount, cache.shopType)
            cb({chest = cache.shop})
        end
    end
end)


--Precisa refazer
RegisterNUICallback('invToNear',function(data,cb)
    local item,amount,stype = data.item,parseInt(data.amount),data.stype
    if item and amount and amount >= 0 then
        if stype == "chest" then
            srv.storeChest(cache.chest,item,amount,slot)
            local chest,max,atual = srv.openChest(cache.chest)
            cb({chest = chest,max = max,atual = atual})

        elseif stype == "trunk" then
            srv.storeItemTrunk(item,amount,slot)
            local chest,max,atual =  srv.openTrunk()
            cb({chest = chest,max = max,atual = atual})

        elseif stype == "homes" then
            local chest,max,atual = srv.storeHomeChest(item,amount,slot,cache.home)
            cb({chest = chest,max = max,atual = atual})

        elseif stype == "shop" then
            srv.sellItens(item,amount,slot, cache.shopType)
            cb({chest = cache.shop})
        end
    end
end)

cl.openHomeChest = function(chest,maxPeso,atualPeso,select)
    local inventory,invWeight,maxInv = srv.getInventory()
    if inventory  and invWeight and maxInv then
        cache.home = select
        SendNUIMessage({
            action = "show",
            playerWeapons = cl.getWeapons(),
            inventory = inventory,
            invWeight = invWeight,
            maxInv = maxInv,
            slots = config.core.slotNumber,
            secondary = chest,
            type_secondary = "homes",
            maxPeso = maxPeso,
            ip = srv.getIP(),
            pesoAtual = atualPeso
        })
        SetNuiFocus(true,true)
        --StartScreenEffect("MenuMGSelectionIn", 0, true)
    end
end

----------------------------------------------------------------------------------------------
--- [ CORE - Weapons ]
----------------------------------------------------------------------------------------------
RegisterNUICallback('garmas',function(data,cb)
    local weapon = data.weapon
    if weapon then
        srv.garmas(weapon)
        cb({weapon = cl.getWeapons()})
    end
end)

local weapon_types = config.weapons

cl.removeWeapon = function(weapon)
    local ammo = GetAmmoInPedWeapon(PlayerPedId(),weapon)
    RemoveWeaponFromPed(PlayerPedId(),weapon)
    SetPedAmmo(PlayerPedId(),weapon,0)
    return ammo
end 

cl.getWeapons = function()
	local player = PlayerPedId()
	local ammo_types = {}
	local weapons = {}
	for k,v in pairs(weapon_types) do
		local hash = GetHashKey(v)
		if HasPedGotWeapon(player,hash) then
			local atype = GetPedAmmoTypeFromWeapon(player,hash)
			if ammo_types[atype] == nil then
				ammo_types[atype] = true
				weapons[v] = GetAmmoInPedWeapon(player,hash)
			else
				weapons[v] = 0
			end
		end
	end
    local colete = tonumber(GetPedArmour(PlayerPedId()))
    if colete > 0 then
        weapons[config.core.itemColete] = colete
    end
	return weapons
end

cl.verify_colete = function()
    return tonumber(GetPedArmour(PlayerPedId()))
end

cl.removeColete = function()
    config.core.setarColete(0)
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
    SetNuiFocus(false,false)
    StopScreenEffect("MenuMGSelectionIn")
end)

RegisterNUICallback('close',function(data,cb)
    SetNuiFocus(false,false)
    StopScreenEffect("MenuMGSelectionIn")
    local typeClose = data.type
    if typeClose then
        if typeClose == "chest" then
            inChest = false
            TriggerServerEvent('removeChestUser',cache.chest)
            cache.chest = nil
        elseif typeClose == "trunk" then
            TriggerServerEvent('removeTrunk',cache.trunk)
            cache.trunk = nil

        elseif typeClose == "homes" then
            TriggerServerEvent('removeUserHomes',cache.home)
            cache.home = nil
        end
    end
end)

RegisterNUICallback('identity',function(data,cb)
    local player = srv.getIdentity()
    if player then
        cb({nomeCompleto = player.nome.." "..player.sobrenome,idade = player.idade,multas = player.multas,banco = player.banco,carteira = player.money,group = player.groups,user_id = player.id,phone = player.phone,rg = player.rg,adm = player.adm,vip = player.vip})
    end
end)
----------------------------------------------------------------------------------------------
--- [ CORE - Shop ]
----------------------------------------------------------------------------------------------
local shopIndex = nil
CreateThread(function()
    while true do
        local idle = 300
        if shopIndex == nil then
            checkDistance()
        else
            idle = 1
            local distance = #(GetEntityCoords(PlayerPedId()) - shop[shopIndex].coord)
			DrawMarker(23,shop[shopIndex].coord.x,shop[shopIndex].coord.y,shop[shopIndex].coord.z-0.95,0,0,0,0.0,0,0,0.5,0.5,0.4,102, 255, 204,155,0,0,0,1)

            if distance <= 1.2 and IsControlJustPressed(0,38) then
                local inventory,invWeight,maxInv = srv.getInventory()
                if inventory  and invWeight and maxInv then
                    cache.shop = srv.openShop(shop[shopIndex].type)
                    cache.shopType = shop[shopIndex].type
                    if not cache.shop then 
                        TriggerEvent('Notify','aviso','Você não pode acessar este local!')
                    else
                        SendNUIMessage({
                            action = "show",
                            playerWeapons = cl.getWeapons(),
                            inventory = inventory,
                            invWeight = invWeight,
                            maxInv = maxInv,
                            slots = config.core.slotNumber,
                            secondary = cache.shop,
                            ip = srv.getIP(),
                            type_secondary = "shop"
                        })
                        SetNuiFocus(true,true)
                        StartScreenEffect("MenuMGSelectionIn", 0, true)
                    end
                end
            end

            if distance >= 5 then
                shopIndex = nil
            end
        end
        Wait(idle)
    end
end)

checkDistance = function()
    for k,v in pairs(shop) do
        local distance = #(GetEntityCoords(PlayerPedId()) - v.coord)
        if distance <= 5 then
            shopIndex = k
        end
    end
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

----------------------------------------------------------------------------------------------
--- [ CORE - HotBar ]
----------------------------------------------------------------------------------------------
local hotbar = {false,false,false,false}

cl.removeHotBar = function(item)
    for k,v in pairs(hotbar) do
        if v == item then
            hotbar[k] = false
        end
    end
end

RegisterNUICallback('updateHotbar',function(data,cb)
    local item,slot = data.item,parseInt(data.slot)
    if item and slot then
        hotbar[slot] = item 
    end
    cb({hotbar = hotbar})
end)

RegisterNUICallback('removeHot',function(data,cb)
    local slot = parseInt(data.slot)
    if slot then
        for k,v in pairs(hotbar) do
            if k == slot then
                hotbar[k] = false
            end
        end
    end
    cb({hotbar = hotbar})
end)

local hktime = 0
local hk_keys = {
    [157] = {
        action = function()
            if hotbar[1] then
                srv.useItem(hotbar[1],1,nil)
            end
        end
    },
    [158] = {
        action = function()
            if hotbar[2] then
                srv.useItem(hotbar[2],1,nil)
            end
        end
    },
    [160] = {
        action = function()
            if hotbar[3] then
                srv.useItem(hotbar[3],1,nil)
            end
        end
    },
    [164] = {
        action = function()
            if hotbar[4] then
                srv.useItem(hotbar[4],1,nil)
            end
        end
    }
}
local function hkControl()
    if hktime <= 0 then
        hktime = 3
        Citizen.CreateThread(function()
            while hktime > 0 do
                Citizen.Wait(1000)
                hktime = hktime - 1
            end
        end)
        return true
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k, v in pairs(hk_keys) do
            DisableControlAction(0, k, true)
            if IsDisabledControlPressed(0, k) then
                if hkControl() then
                    v.action()
                end
            end
        end
        EnableControlAction(0, 37, true)
    end
end)

Citizen.CreateThread(function()
    while true do
        if not IsDisabledControlPressed(0, 37) then
            HudWeaponWheelIgnoreSelection()
        else
          Citizen.Wait(500)
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('inventory:close')
AddEventHandler('inventory:close',function()
    SendNUIMessage({
        action = "close",
    })
    SetNuiFocus(false,false)
    StopScreenEffect("MenuMGSelectionIn")
end)

local cloneVehicle = nil
function cl.lockVehicleInPlace()
    local ped = PlayerPedId()   
    local playerCoords = GetEntityCoords(ped)
    local pedIsIn = GetVehiclePedIsIn(ped, false)
    if pedIsIn ~= 0 then 
        return
    end
    local nearestVeh = vRP.getNearestVehicle(2)
    if not nearestVeh then 
        return
    end
    local bootCoords = nil
    if nearestVeh then
        bootCoords = GetEntityBonePosition_2(nearestVeh, GetEntityBoneIndexByName(nearestVeh, "boot"))
    end
    if #(playerCoords - bootCoords) < 4.0 then
        cloneVehicle = nearestVeh
        FreezeEntityPosition(nearestVeh,true)
        return true
    end
    return false
end

function cl.clonePlate()
    SetVehicleNumberPlateText(cloneVehicle, "CLONADO")
    FreezeEntityPosition(cloneVehicle,false)
    cloneVehicle = nil
end

function cl.getVehLocked(vNet)
    local vehicle = NetToVeh(vNet)
    local isLocked = GetVehicleDoorLockStatus(vehicle)
    return (isLocked == 1) and true or false
end

function cl.returnfireWorks()
    return fireWorksCreate
end

RegisterNetEvent('open:trunk:ws')
AddEventHandler('open:trunk:ws',function(vehid,trunk)
	if NetworkDoesNetworkIdExist(vehid) then
		local v = NetToVeh(vehid)
		if DoesEntityExist(v) and IsEntityAVehicle(v) then
			if trunk then
				SetVehicleDoorShut(v,5,0)
			else
				SetVehicleDoorOpen(v,5,0,0)
			end
		end
	end
end)
