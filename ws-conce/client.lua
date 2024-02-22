local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
srv = Tunnel.getInterface('ws-conce')

local veiculos = config.veiculos
local inTestDrive = false
local categorias = {}
local cam = nil
local freeCam = false
local cooldown = 0

local indexConce = nil
local inConce = false

Citizen.CreateThread(function()
    while true do
        local idle = 300
        if not indexConce then
            checkDistance()
        else
            idle = 1
            local distance = #(GetEntityCoords(PlayerPedId()) - config.conce[indexConce].coord)
            if distance <= 3 then
                mBMarker(config.conce[indexConce].coord, tonumber('0.3'), tonumber('0.3'),tonumber('0.3'), "images", "conce")
                if distance <= 2 and IsControlJustPressed(0,38) then
                    inConce = true
                    criar_categorias()
                    TriggerEvent('ws:fadeOut',500)
                    Wait(550)
                    init_cam(config.conce[indexConce].camCoord)
                    TriggerServerEvent('ws:join_dimesion')
                    SetNuiFocus(true,true)
                    SendNUIMessage({
                        show = "show",
                        ip = config.ip,
                        button = config.conce[indexConce].options,
                        tuning = config.conce[indexConce].tuning,
                        sellPayment = config.sellPayment
                    })
                    DisplayRadar(false)
                    TriggerEvent('ws:fadeIn',500)
                end
            else
                if not inConce then
                    indexConce = nil
                end
            end
        end
        Wait(idle)
    end
end)


checkDistance = function()
    for k,v in pairs(config.conce) do
        local distance = #(GetEntityCoords(PlayerPedId()) - v.coord)
        if distance <= 3 then
            indexConce = k
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

criar_categorias = function()
    if not config.conce[indexConce].type then
        for k,v in pairs(veiculos) do
            categorias[k] = true
        end
        return
    end
    for k,v in pairs(config.veiculosCoins) do
        categorias[k] = true
    end
end

-------------------------------------------------------
--- [ CORE - Test Drive ]
-------------------------------------------------------
RegisterNUICallback('spaw_testeDrive',function(data,cb)
    TriggerEvent('fix:conce',true)
    TriggerEvent('ws:fadeOut',1000)
    Wait(1000)
    TriggerEvent('ws:deleteVeh')
    inTestDrive = true
    local model = data.vehicle
    if model then
        local mhash = GetHashKey(model)

        while not HasModelLoaded(mhash) do
            RequestModel(mhash)
            Citizen.Wait(1)
        end

        if HasModelLoaded(mhash) then

	    	tnveh = CreateVehicle(mhash,config.conce[indexConce].testeDrive,config.conce[indexConce].testeDriveHeading,true,true)
            print(tnveh)
            SetPedIntoVehicle(PlayerPedId(),tnveh,-1)
            SetVehicleIsStolen(tnveh,false)
            SetVehicleNeedsToBeHotwired(tnveh,false)
            SetVehicleOnGroundProperly(tnveh)
            SetVehicleNumberPlateText(tnveh,"TESTDRIV")
            TriggerServerEvent('setPlateEveryone',"TESTDRIV")
            SetEntityAsMissionEntity(tnveh,true,true)
            SetVehRadioStation(tnveh,"OFF")
            SetVehicleEngineHealth(tnveh,tonumber('1000.0'))
            SetVehicleBodyHealth(tnveh,tonumber('1000.0'))
            SetVehicleFuelLevel(tnveh,tonumber('100.0'))
            TriggerServerEvent("nyoModule:fuelAddVehicle", VehToNet(tnveh), 60)
            SetModelAsNoLongerNeeded(mhash)
            SetVehicleDoorsLocked(tnveh,4)


            Wait(1500)
            TriggerEvent('ws:fadeIn',1000)
            timer_testDrive()
        end
    end
end)

timer_testDrive = function()
    Citizen.CreateThread(function()
        local time = config.conce[indexConce].testDriveDuracao
        while true do
            if time > 0 then
                time = time - 1
                if time == 0 then
                    inTestDrive = false
                    TriggerEvent('ws:fadeOut',500)
                    Wait(1000)
                    DeleteEntity(tnveh)
                    SetEntityCoords(PlayerPedId(),config.conce[indexConce].coord)
                    Wait(1500)
                    TriggerServerEvent('ws:remove_dimesion')
                    TriggerEvent('fix:conce',false)
                    TriggerEvent('ws:fadeIn',1000)
                    break
                end
            end
            Wait(1000)
        end
    end)
end

-------------------------------------------------------
--- [ NuiCallBacks ]
-------------------------------------------------------

--Retorna as categorias existentes
RegisterNUICallback('get_categorias',function(data,cb)
    cb({categorias = categorias})
end)

RegisterNUICallback('get_menus',function(data,cb)
    local catetoria = data.categoria
    if catetoria then
        cb({categorias = veiculos[catetoria]})
    end
end)

RegisterNUICallback('myVehicles',function(data,cb)
    local myVeh = srv.get_my_veh()
    if myVeh then
        cb({myVeh = myVeh,type = config.conce[indexConce].type})
    end
end)

RegisterNUICallback('bloquearVenda',function()
    TriggerEvent('ws:pNotify','negado','Não é possivel vender veiculos nesta loja!')
end)

RegisterNUICallback('sell_vehicle',function(data,cb)
    local veh = data.vehicle
    if veh then
        srv.sell_vehicle(veh)
    end
end)

RegisterNUICallback('get_stock',function(data,cb)
    local stock = srv.get_vehicle_stock(data.categoria,data.vehicle)
    if stock then
        cb({stock = stock})
    end
end)

local carregando = false
RegisterNUICallback('load_vehicle',function(data)
    local model = data.vehicle
    if not carregando and model then
        carregando = true
        local mhash = GetHashKey(model)

        while not HasModelLoaded(mhash) do
            RequestModel(mhash)
            Citizen.Wait(1)
        end
        
        if HasModelLoaded(mhash) then
            TriggerEvent('ws:deleteVeh')

	    	nveh = CreateVehicle(mhash,config.conce[indexConce].spaw_vehicle,tonumber('138.50'),true,true)
            local plate = "TESTDRIV"
            SetPedIntoVehicle(PlayerPedId(),nveh,-1)
            FreezeEntityPosition(nveh,true)
            SetVehicleIsStolen(nveh,false)
            SetVehicleNeedsToBeHotwired(nveh,false)
            SetVehicleOnGroundProperly(nveh)
            SetVehicleNumberPlateText(nveh,plate)
            TriggerServerEvent('setPlateEveryone',plate)

            SetVehicleDoorsLocked(nveh,4)

            SetEntityAsMissionEntity(nveh,true,true)
            SetVehRadioStation(nveh,"OFF")
            SetVehicleEngineHealth(nveh,tonumber('1000.0'))
            SetVehicleBodyHealth(nveh,tonumber('1000.0'))
            SetVehicleFuelLevel(nveh,tonumber('0.1'))
            SetModelAsNoLongerNeeded(mhash)
            SetVehicleWindowTint(nveh,'1')
            SetVehicleDirtLevel(nveh,tonumber('0.0'))

            init_cam(config.conce[indexConce].camCoord)
        end
        carregando = false
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

-------------------------------------------------------
--- [ Tuning ]
-------------------------------------------------------
RegisterNUICallback('change_color',function(data,cb)
    local rgb = data.color
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh and rgb then
        SetVehicleCustomPrimaryColour(veh,tonumber(rgb[1]),tonumber(rgb[2]),tonumber(rgb[3]))
        SetVehicleExtraColours(veh,1,0)
    end
    init_cam(config.conce[indexConce].camCoord)
end)

RegisterNUICallback('change_window',function(data,cb)
    local index = data.color
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle and index then
        SetVehicleModKit(vehicle,0)
        SetVehicleWindowTint(vehicle,tonumber(index))
    end
    init_cam(config.conce[indexConce].camCoord)
end)

RegisterNUICallback('change_xenon',function(data,cb)
    xenon_cam(config.config[indexConce].xenomCam)
    local index = data.color
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle and index then
        SetVehicleFullbeam(vehicle,true)
        ToggleVehicleMod(vehicle, 22, true)
        SetVehicleHeadlightsColour(vehicle,tonumber(index))
    end
end)

xenon_cam = function(coord)
    if (DoesCamExist(cam)) then
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
        cam = nil
    end
	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA",true,2)
	SetCamCoord(cam,coord.x,coord.y,coord.z-0.5)
    PointCamAtCoord(cam,coord.x,coord.y,coord.z-0.5)
	SetCamActive(cam,true)
    SetCamRot(cam,-16.75,0.02,136.92,1)
	RenderScriptCams(1,0,cam,0,0)
end

getVehicleMods = function(veh)
    local myveh = {}
    if config.infinity then

	    -- myveh.custom.primary = table.pack(GetVehicleCustomPrimaryColour(veh))
	    -- myveh.custom.secondary = table.pack(GetVehicleCustomSecondaryColour(veh))

        -- if GetVehicleWindowTint(veh) == -1 or GetVehicleWindowTint(veh) == 0 then
	    -- 	myveh.janela = false
	    -- else
	    -- 	myveh.janela = GetVehicleWindowTint(veh)
	    -- end

	    -- myveh.farol = GetVehicleHeadlightsColour(veh)
        return config.getTuning(veh)
    else
	    local colors = {
	    	["cromado"] = {120},
	    	["metalico"] = {
	    		0, 147, 1, 11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 27, 28, 29, 150, 30, 31, 32, 33, 34, 
	    		143, 35, 135, 137, 136, 36, 38, 138, 99, 90, 88, 89, 91, 49, 50, 51, 52, 53, 54, 
	    		92, 141, 61, 62, 63, 64, 65, 66, 67, 68, 69, 73, 70, 74, 96, 101, 95, 94, 97,
	    		103, 104, 98, 100, 102, 99, 105, 106, 71, 72, 142, 145, 107, 111, 112
	    	},
	    	["fosco"] = {12,13,14,131,83,82,84,149,148,39,40,41,42,55,128,151,155,152,153,154},
	    	["metal"] = { 117,118,119,158,159 }
	    }
	    myveh.vehicle = veh
	    myveh.model = GetDisplayNameFromVehicleModel(GetEntityModel(veh)):lower()
	    myveh.color =  table.pack(GetVehicleColours(veh))
	    myveh.customPcolor = table.pack(GetVehicleCustomPrimaryColour(veh))
	    myveh.customScolor = table.pack(GetVehicleCustomSecondaryColour(veh))
	    myveh.extracolor = table.pack(GetVehicleExtraColours(veh))
	    myveh.neon = true
	    for i = 0, 3 do 
	    	if not IsVehicleNeonLightEnabled(veh,i) then 
	    		myveh.neon = false
	    		break 
	    	end 
	    end 
	    myveh.neoncolor = table.pack(GetVehicleNeonLightsColour(veh))
	    myveh.xenoncolor = GetVehicleHeadlightsColour(veh)
	    myveh.smokecolor = table.pack(GetVehicleTyreSmokeColor(veh))
	    myveh.plateindex = GetVehicleNumberPlateTextIndex(veh)
	    myveh.pcolortype = false
	    myveh.scolortype = false
	    for k,v in pairs(colors) do
	    	for i,j in pairs(v) do
	    		if myveh.pcolortype and myveh.scolortype then
	    			break
	    		end
	    		if j == myveh.color[1] then
	    			myveh.pcolortype = k
	    		end
	    		if j == myveh.color[2] then
	    			myveh.scolortype = k
	    		end
	    	end
	    end
	    myveh.mods = {}
	    for i = 0, 48 do
	    	myveh.mods[i] = {mod = nil}
	    end
	    for i,t in pairs(myveh.mods) do 
	    	if i == 22 or i == 18 then
	    		if IsToggleModOn(veh,i) then
	    			t.mod = 1
	    		else
	    			t.mod = 0
	    		end
	    	elseif i == 23 or i == 24 then
	    		t.mod = GetVehicleMod(veh,i)
	    		t.variation = GetVehicleModVariation(veh, i)
	    	else
	    		t.mod = GetVehicleMod(veh,i)
	    	end
	    end
	    if GetVehicleWindowTint(veh) == -1 or GetVehicleWindowTint(veh) == 0 then
	    	myveh.windowtint = false
	    else
	    	myveh.windowtint = GetVehicleWindowTint(veh)
	    end
	    if myveh.xenoncolor > 12 or myveh.xenoncolor < -1 then
	    	myveh.xenoncolor = -1
	    end
	    myveh.wheeltype = GetVehicleWheelType(veh)
	    myveh.bulletProofTyres = GetVehicleTyresCanBurst(veh)
	    myveh.damage = (1000 - GetVehicleBodyHealth(vehicle))/100
    end
	return myveh
end

-------------------------------------------------------
--- [ Outros ]
-------------------------------------------------------

RegisterNUICallback('chance_cam',function(data,cb)
    SetNuiFocus(false,false)
    freeCam = true
    if (DoesCamExist(cam)) then
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
        cam = nil
    end
    fix()
end)

RegisterNUICallback('buy_vehicle',function(data,cb)
    local model = data.vehicle
    local categoria = data.categoria
    local vehicle = GetVehiclePedIsIn(PlayerPedId())

    if model and categoria then
        srv.buy_vehicle(categoria,model,getVehicleMods(vehicle))
    end
end)

RegisterNUICallback('rent_vehicle',function(data,cb)
    local model = data.vehicle
    local categoria = data.categoria
    if model and categoria then
        srv.register_rent(categoria,model)
    end
end)

function fix()
    Citizen.CreateThread(function()
        while freeCam do
            if IsControlJustPressed(0,74) then
                init_cam(config.conce[indexConce].camCoord)
                SetNuiFocus(true,true)
                SendNUIMessage({
                    freeCam = false
                })
                freeCam = false
            end
            Wait(1)
        end
    end)
end

init_cam = function(coord)
    if (DoesCamExist(cam)) then
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
        cam = nil
    end
	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA",true,2)
	SetCamCoord(cam,coord.x,coord.y,coord.z+1)
    PointCamAtCoord(cam,coord.x,coord.y,coord.z+1)
	SetCamActive(cam,true)
    SetCamRot(cam,350.0,0.0,0.0,1)
	RenderScriptCams(1,0,cam,0,0)
end

--Retorna os veiculos de uma categoria
RegisterNUICallback('get_vehicles',function(data,cb)
    local cars = {}
    if categorias[data.categoria] then 
        for k,v in pairs(veiculos[data.categoria]) do
            cars[k] = v
        end
    end
    cb({veiculos = cars})
end)

RegisterNUICallback('get_vehInfo',function(data,cb)
    local veh = data.veh
    if veh then
        cb({estoque =  srv.get_vehicle_stock(veh)})
    end
end)

vCLIENT = Proxy.getInterface("vrp_garages")

RegisterNetEvent('ws:deleteVeh')
AddEventHandler('ws:deleteVeh',function()
    if not inTestDrive then
        if config.hi3 then
            local vehicle,vehNet,vehPlate,vehName = vRP.vehList(10)
            vCLIENT.deleteVehicle(vehicle)
        end
        local oldVeh = vRP.getNearestVehicle(7)
        if oldVeh then
            DeleteEntity(oldVeh)
        end
    end
end)

RegisterNUICallback('close',function()
    if nveh then
        DeleteEntity(nveh)
    end
    if (DoesCamExist(cam)) then
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
        cam = nil
    end
    SetNuiFocus(false,false)
    TriggerServerEvent('ws:remove_dimesion')
    SetEntityCoords(PlayerPedId(),config.conce[indexConce].coord)
    StopScreenEffect("MenuMGSelectionIn")
    inConce = false
end)

RegisterNUICallback('close_teste',function()
    if (DoesCamExist(cam)) then
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
        cam = nil
    end
    SetNuiFocus(false,false)
    StopScreenEffect("MenuMGSelectionIn")
end)

RegisterNetEvent('ws:close')
AddEventHandler('ws:close',function()
    SendNUIMessage({
        show="hide",
    })
    StopScreenEffect("MenuMGSelectionIn")
end)

RegisterNetEvent('ws:update')
AddEventHandler('ws:update',function()
    SendNUIMessage({
        show = "updateSell"
    })
end)

RegisterNetEvent('ws:pNotify')
AddEventHandler('ws:pNotify',function(mode,title,message)
    if message == nil then
        message = title
        title = "Loja de carros"
    end
    SendNUIMessage({
        show="notify",
        mode = mode,
        title = title,
        message = message
    })
end)

RegisterNetEvent('ws:fNotify')
AddEventHandler('ws:fNotify',function()
    SendNUIMessage({
        show="notifyfinish",
        mode = mode,
        title = title,
        message = message
    })
end)
