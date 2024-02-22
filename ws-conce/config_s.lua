local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

cfg_s = {}

cfg_s.webhook_comprar = ""
cfg_s.webhook_vender = ""
cfg_s.ip = "localhost"

cfg_s.rent_time = 3
cfg_s.price_rent = 0.5

cfg_s.vender_vehicle = 0.5

-- vRP._prepare("get_estoque","SELECT * FROM ws_conce WHERE vehicle = @vehicle")
-- vRP._prepare("att_estoque","UPDATE ws_conce SET estoque = @estoque WHERE vehicle = @vehicle")

-- vRP._prepare("get_rent","SELECT * FROM ws_rent WHERE user_id = @user_id")
-- vRP._prepare("check_rent","SELECT * FROM ws_rent")
-- vRP._prepare("add_rend","INSERT IGNORE INTO ws_rent(user_id,vehicle,time) VALUES(@user_id,@vehicle,@time)")
-- vRP._prepare("veh_add_rend","INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)")
-- vRP._prepare("rem_rent","DELETE FROM ws_rent WHERE user_id = @user_id AND vehicle = @vehicle")

-- vRP._prepare("ws_add_vehicle","INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)")
-- vRP._prepare("ws_rem_vehicle","DELETE FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
-- vRP._prepare("ws_get_vehicle","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")

-- vRP._prepare("ws/get_vehicle","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")

vRP._prepare("get_estoque","SELECT * FROM ws_conce WHERE vehicle = @vehicle")
vRP._prepare("att_estoque","UPDATE ws_conce SET estoque = @estoque WHERE vehicle = @vehicle")

vRP._prepare("get_rent","SELECT * FROM ws_rent WHERE user_id = @user_id")
vRP._prepare("check_rent","SELECT * FROM ws_rent")
vRP._prepare("add_rend","INSERT IGNORE INTO ws_rent(user_id,vehicle,time) VALUES(@user_id,@vehicle,@time)")
vRP._prepare("veh_add_rend","INSERT IGNORE INTO _vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)")
vRP._prepare("rem_rent","DELETE FROM ws_rent WHERE user_id = @user_id AND vehicle = @vehicle")

vRP._prepare("ws_add_vehicle","INSERT IGNORE INTO _vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)")
vRP._prepare("ws_rem_vehicle","DELETE FROM _vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("ws_get_vehicle","SELECT * FROM _vehicles WHERE user_id = @user_id")

vRP._prepare("ws/get_vehicle","SELECT * FROM _vehicles WHERE user_id = @user_id")

cfg_s.rg = function(user_id)
    if user_id then
        return vRP.getUserRegistration(user_id)
    end
end

--------------------------------------------------------------
--- [ Custom commands ]
--------------------------------------------------------------
local veiculos = config.veiculos

getVehicleInfo = function(vehicle)
    for k,v in pairs(veiculos) do
        for a,b  in pairs(v) do
            if vehicle == a then
                return veiculos[k][vehicle]
            end
        end
    end
end

cfg_s.buy_vehicle = function(user_id,category,vehicle,tuning)
    print(user_id,category,vehicle,tuning)
    if user_id and category and vehicle and tuning then
        if veiculos[category][vehicle] then
            if not veiculos[category][vehicle].vip then
                local db = vRP.query('get_estoque',{vehicle = vehicle})
                local estoque = db[1].estoque
                if estoque > 0 then
                    local myVeh = vRP.query('ws_get_vehicle',{user_id=user_id})
                    for k,v in pairs(myVeh) do
                        if v.vehicle == vehicle then
                            if not srv.checkRentSell(user_id,vehicle) then
                                if vRP.tryFullPayment(user_id,veiculos[category][vehicle].valor) then
                                    vRP.execute('rem_rent',{user_id = user_id,vehicle = vehicle})
                                    vRP.execute('ws_add_vehicle',{user_id = user_id,vehicle = vehicle,ipva = os.time() + 24*30*30})
                                    vRP.execute('att_estoque',{estoque = (estoque - 1),vehicle = vehicle })
                                    vRP.setSData('custom:u'..user_id.."veh_"..veiculos[category][vehicle].spaw,json.encode(tuning))
                                    TriggerClientEvent('ws:fNotify',vRP.getUserSource(user_id),"sucesso","Concessinária","Sua compra foi aprovada pelo nossso gerente!")
                                    return
                                end
                            else
                                TriggerClientEvent('ws:pNotify',vRP.getUserSource(user_id),'negado',"Você já possui este veiculo em sua garagem!")
                                return
                            end
                        end
                    end
                    if vRP.tryFullPayment(user_id,veiculos[category][vehicle].valor) then
                        vRP.execute('ws_add_vehicle',{user_id = user_id,vehicle = vehicle,ipva = os.time() + 24*30*30})
                        vRP.execute('att_estoque',{estoque = (estoque - 1),vehicle = vehicle })
                        vRP.setSData('custom:u'..user_id.."veh_"..veiculos[category][vehicle].spaw,json.encode(tuning))
                        TriggerClientEvent('ws:fNotify',vRP.getUserSource(user_id),"sucesso","Concessinária","Sua compra foi aprovada pelo nossso gerente!")
                    end
                end
            else
                TriggerClientEvent('ws:pNotify',vRP.getUserSource(user_id),"negado","Concessinária","Acesso somente para clientes VIP!")
            end
        end
    end
end

cfg_s.rent_vehicle = function(user_id,categoria,vehicle)
    local source = vRP.getUserSource(user_id)
    if not checkVehicle(user_id,vehicle) then
        if veiculos[categoria][vehicle] then
            if not veiculos[categoria][vehicle].vip then
                local rent_price = parseInt(veiculos[categoria][vehicle].valor * config.sellPayment)
                local myVeh = vRP.query('ws_get_vehicle',{user_id=user_id})
                for k,v in pairs(myVeh) do
                    if v.vehicle == vehicle then
                        TriggerClientEvent('Notify',source,'negado',"Você já possui este veiculo em sua garagem!")
                        TriggerClientEvent('ws:pNotify',source,'negado','Aluguel de veiculos',"Você já possui este veiculo em sua garagem!")
                        return
                    end
                end
                local time = parseInt(os.time() + 24*cfg_s.rent_time*60*60)
                if vRP.tryFullPayment(user_id,rent_price) then
                    vRP.execute('add_rend',{user_id = user_id,vehicle = vehicle,time = time})
                    vRP.execute('ws_add_vehicle',{user_id = user_id,vehicle = vehicle,ipva = os.time() + 24*30*30})
                    TriggerClientEvent('ws:pNotify',source,'sucesso','Aluguel de veiculos',"Você alugou "..veiculos[categoria][vehicle].nome.." por R$"..rent_price.." dutante "..cfg_s.rent_time.." dias!")
                    Wait(3000)
                    TriggerClientEvent('ws:close',source)
                end
            else
                TriggerClientEvent('ws:pNotify',source,'negado','Aluguel de veiculos',"Você não pode alugar este tipo de veiculo!")
            end
        end
    else
        TriggerClientEvent('ws:pNotify',source,'negado','Aluguel de veiculos',"Você já possui este veiculo!")
    end
end

return cfg_s