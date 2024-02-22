local webhook = config.webhook
local script = config.script
local _Is_autenticated = true

Citizen.CreateThread(function()
    print('[\x1b[32mCORE\x1b[37m]:CARREGADO')
    if webhook then
        print('[\x1b[32mWEBHOOK\x1b[37m]:CARREGADO')
    end
    if script then
        print('[\x1b[32mCONFIG\x1b[37m]:CARREGADO')
    end
    _Is_autenticated = true
end)

local srv = {}
Tunnel.bindInterface('ws-bank', srv)
Proxy.addInterface('ws-bank', srv)

cl = Tunnel.getInterface('ws-bank')
notify = function(source, type, title, message)
    cl.notify(source, type, title, message)
end

function SendWebhook(webhook, message)
    if webhook ~= "none" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({ content = message }),
            { ['Content-Type'] = 'application/json' })
    end
end

local active = {}
local chachePlayer = {}
-----------------------------------------------------------
--- [ Banco de dados]
-----------------------------------------------------------
Prepare("get_multas", "SELECT * FROM wise_multas WHERE user_id = @user_id")
Prepare("payment_multa", "DELETE FROM wise_multas WHERE user_id = @user_id AND multa_id = @multa_id")
Prepare("create_cache_pix", "SELECT * FROM wise_pix")
Prepare("get_pix", "SELECT * FROM wise_pix WHERE user_id = @user_id")
Prepare("update_pix", "UPDATE wise_pix SET chave = @chave WHERE user_id = @user_id")
Prepare("rem_pix", "DELETE FROM wise_pix WHERE user_id = @user_id")
Prepare("add_pix", "INSERT IGNORE INTO wise_pix (user_id,chave) VALUES(@user_id,@chave)")
-----------------------------------------------------------
--- [ Misc]
-----------------------------------------------------------
srv.get_player_info = function()
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local identidade = getIdentity(user_id)
        if identidade then
            local name = identidade.name .. " " .. identidade.firstname
            return getMoney(user_id), getBankMoney(user_id), name
        end
        return 0, 0, ""
    end
end

srv.register_player_cache = function(user_id)
    if not _Is_autenticated then return end
    if user_id then
        local identidade = getIdentity(user_id)
        if identidade then
            chachePlayer[user_id] = { user_id = user_id, nome = identidade.name, sobrenome = identidade.firstname }
        end
    end
end

srv.get_players_trans = function()
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local name = {}
        for k, v in pairs(chachePlayer) do
            if v then
                table.insert(name, v)
            end
        end
        return name
    end
end

srv.update_money = function()
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local money = getMoney(user_id)
        local bank = getBankMoney(user_id)
        return money, bank
    end
end
-----------------------------------------------------------
--- [ Grafico ]
-----------------------------------------------------------
srv.gerenate_data = function()
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    local ganhou = 0
    local perdeu = 0
    local multas = 0
    local rendimento = 0
    if user_id then
        local historico = json.decode(GetUData(user_id, "ws-bank:historico")) or {}
        local db_multas = Query("get_multas", { user_id = user_id })
        local rendimento_db = json.decode(GetUData(user_id, "ws:rendimento")) or {}

        for k, v in pairs(historico) do
            if v.value then
                local sinal = split(v.value, "R")[1]
                if sinal == "+" then
                    local db_valor = parseInt(split(v.value, "$")[2])
                    if db_valor then
                        ganhou = ganhou + (db_valor * 1000)
                    end
                elseif sinal == "-" then
                    local db_valor = parseInt(split(v.value, "$")[2])
                    if db_valor then
                        perdeu = perdeu + (db_valor * 1000)
                    end
                end
            end
        end

        if rendimento_db then
            for k, v in pairs(rendimento_db) do
                rendimento = rendimento + v
            end
        end



        for k, v in ipairs(db_multas) do
            multas = multas + v.valor
        end
        local total = ganhou + perdeu + multas + rendimento
        return ganhou, perdeu, multas, total, rendimento
    end
end
-----------------------------------------------------------
--- [ Sistema do banco]
-----------------------------------------------------------
srv.depositar = function(value)
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and not active[user_id] then
        active[user_id] = true
        if TryPayment(user_id, parseInt(value)) then
            giveBankMoney(user_id, parseInt(value))
            srv.register_trans(user_id, "Deposito", parseInt(value))
            SendWebhook(webhook.depositar,
                "```prolog\n[WISE BANK]\n[DEPOSITOU]\n[VALOR]:" ..
                Format(value) .. "\n[USER_ID]:" .. user_id .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. "\n```")
            --notify(source,"sucesso","Banco","Você depositou R$"..Format(value)..".")
            TriggerClientEvent('bank_notify', source, "sucesso", "Banco", "Você depositou R$" .. Format(value) .. ".")
        else
            --notify(source,"negado","Banco","Você não possui essa quantidade em sua carteira!")
            TriggerClientEvent('bank_notify', source, "negado", "Banco",
                "Você não possui essa quantidade em sua carteira!")
        end
        active[user_id] = false
    end
end

srv.sacar = function(value)
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and not active[user_id] then
        active[user_id] = true
        local bank = getBankMoney(user_id)
        if bank >= parseInt(value) and value > 0 then
            setBankMoney(user_id, parseInt(bank - value))
            giveMoney(user_id, parseInt(value))
            srv.register_trans(user_id, "Saque", -parseInt(value))
            SendWebhook(webhook.sacar,
                "```prolog\n[WISE BANK]\n[SACOU]\n[VALOR]:" ..
                Format(value) .. "\n[USER_ID]:" .. user_id .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. "\n```")
            --notify(source,"sucesso","Banco","Você sacou R$"..Format(value)..".")
            TriggerClientEvent('bank_notify', source, "sucesso", "Banco", "Você sacou R$" .. Format(value) .. ".")
        end
        active[user_id] = false
    end
end

srv.tranferir = function(target, value)
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    local nplayer = getUserSource(target)
    if user_id and target and nplayer and not active[user_id] then
        active[user_id] = true
        local bank = getBankMoney(user_id)
        if bank >= parseInt(value) then
            setBankMoney(user_id, parseInt(bank - value))
            giveBankMoney(target, parseInt(value))
            srv.register_trans(user_id, "Transferencia", -parseInt(value))
            srv.register_trans(target, "Transferencia", parseInt(value))
            SendWebhook(webhook.transferir,
                "```prolog\n[WISE BANK]\n[TRASFERIU]\n[VALOR]:" ..
                Format(value) ..
                "\n[USER_ID]:" .. user_id .. "\n[PARA]:" ..
                target .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. "\n```")

            TriggerClientEvent('bank_notify', source, "sucesso", "Banco", "Você transferiu R$" .. Format(value))
            TriggerClientEvent('bank_notify', nplayer, "sucesso", "Banco", "Você recebeu R$" .. Format(value))
            active[user_id] = false
            return true
        end
    end
end

-----------------------------------------------------------
--- [ Sistema de rendimentos ]
-----------------------------------------------------------
srv.djklsdklsjdkls = function(quantiade, item, password)
    if script.desabilitarRendimento then
        return
    end
    local users = GetUsers()
    for k, v in pairs(users) do
        local bank = getBankMoney(k)
        local rendimento = parseInt(bank * script.rendimento)
        if rendimento > 0 then
            giveBankMoney(k, rendimento)
            srv.register_trans(k, "Rendimento", rendimento)
            srv.register_rendimento(k, rendimento)
            SendWebhook(webhook.rendimento,
                "```prolog\n[WISE BANK]\n[RENDIMENTO]\n[VALOR]:" ..
                Format(rendimento) .. "\n[USER_ID]:" .. k .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. "\n```")

            TriggerClientEvent('bank_notify', v, "sucesso", "Poupança",
                "Você recebeu R$" .. Format(rendimento) .. " pelos seus investimentos.")
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(1000 * script.tempoRendimento)
        srv.djklsdklsjdkls()
    end
end)

srv.register_rendimento = function(user_id, value)
    if not _Is_autenticated then return end
    if user_id then
        local __ = GetUData(user_id, "ws:rendimento")
        local data = json.decode(__) or {}
        if data then
            if #data >= 20 then
                data = {}
            end
            table.insert(data, value)
            SetUData(user_id, "ws:rendimento", json.encode(data))
        end
    end
end

srv.get_rendimento = function()
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local __ = GetUData(user_id, "ws:rendimento")
        local data = json.decode(__) or {}
        if data then
            return data
        end
    end
end
-----------------------------------------------------------
--- [ Sistema de historico de compras ]
-----------------------------------------------------------
srv.register_trans = function(user_id, type, value)
    if not _Is_autenticated then return end
    local data = json.decode(GetUData(user_id, "ws-bank:historico")) or {}
    if data then
        if value < 0 then
            value = value * -1
            value = "-R$" .. value
            table.insert(data, { type = type, value = Format(value) })
        else
            local value = "+R$" .. value
            table.insert(data, { type = type, value = Format(value) })
        end
        SetUData(user_id, 'ws-bank:historico', json.encode(data))
    end
end

srv.get_historico_bank = function(nsource)
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local data = json.decode(GetUData(user_id, "ws-bank:historico")) or {}
        if #data >= 20 then
            srv.clear_transferencia(source)
        end

        if data then
            return data
        end
    end
end

srv.clear_transferencia = function(nsource)
    if not _Is_autenticated then return end
    local source = source
    if nsource then
        source = nsource
    end
    local user_id = vRP.getUserId(source)
    if user_id then
        local data = {}
        SetUData(user_id, 'ws-bank:historico', json.encode(data))
    end
end

-----------------------------------------------------------
--- [ Sistema de multas ]
-----------------------------------------------------------
srv.get_multas = function()
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    local multas = {}
    local total_multas = 0
    if user_id then
        local db = Query("get_multas", { user_id = user_id })
        if db then
            for k, v in ipairs(db) do
                local temp = os.date("*t", tonumber(v.time))
                local date = temp.day .. "/" .. temp.month .. "/2021"
                total_multas = total_multas + v.valor
                table.insert(multas,
                    { id_multa = v.multa_id, motivo = v.motivo, valor = v.valor, time = date, desc = v.descricao })
            end
        end
        return multas
    end
end

srv.pagar_multa = function(id)
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and not active[user_id] then
        active[user_id] = true
        local db = Query("get_multas", { user_id = user_id })
        if db then
            for k, v in ipairs(db) do
                if v.multa_id == id then
                    if TryFullPayment(user_id, v.valor) then
                        Execute("payment_multa", { user_id = user_id, multa_id = id })
                        srv.register_trans(user_id, "Pagamento de multa", parseInt(v.valor * -1))
                        SendWebhook(webhook.multa,
                            "```prolog\n[WISE BANK]\n[PAGAMENTO MULTA]\n[VALOR]:" ..
                            Format(v.valor) ..
                            "\n[USER_ID]:" .. user_id .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. "\n```")
                        TriggerClientEvent('bank_notify', source, "sucesso", "Prefeitura",
                            "Multa Nº" .. v.multa_id .. " paga com sucesso!")
                    else
                        TriggerClientEvent('bank_notify', source, "negado", "Prefeitura",
                            "Você não possui R$" .. v.valor .. " para pagar a multa Nº" .. v.multa_id .. " !")
                    end
                    active[user_id] = false
                end
            end
        end
    end
end

RegisterCommand('rmulta', function(source, args)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and args and args[1] then
        if vRP.hasPermission(user_id, config.permi_multar) then
            cl.open_nui(source, "multar")
        end
    end
end)

srv.verify_multas = function(user_id)
    if not _Is_autenticated then return end
    if user_id then
        local db = Query('get_multas', { user_id = user_id })
        local value = 0
        if #db > 0 then
            for k, v in ipairs(db) do
                value = value + v.valor
            end
        end
        return value
    end
end

----------------------------------------------------------
--- [ Pix ]
-----------------------------------------------------------
local cache_pix = {}

Citizen.CreateThread(function()
    local all_keys = Query('create_cache_pix')
    if all_keys then
        for k, v in ipairs(all_keys) do
            cache_pix[tostring(v.chave)] = v.user_id
        end
    end
end)

srv.get_key_pix = function()
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local data = Query('get_pix', { user_id = user_id })
        if #data > 0 then
            return data[1].chave
        end
    end
end

srv.create_pix = function(key)
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local data = Query('get_pix', { user_id = user_id })
        if #data > 0 then
            TriggerClientEvent('bank_notify', source, "negado", "Pix", "Você já possui uma chave pix")
        else
            if cache_pix[tostring(key)] == nil then
                cache_pix[tostring(key)] = user_id
                Execute('add_pix', { user_id = user_id, chave = key })
                SendWebhook(webhook.criarPix,
                    "```prolog\n[WISE BANK]\n[CRIAR PIX]\n[CHAVE]" ..
                    key .. "\n[USER_ID]:" .. user_id .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. "\n```")
                TriggerClientEvent('bank_notify', source, "sucesso", "Pix", "Você criou sua chave pix!")
            else
                TriggerClientEvent('bank_notify', source, "negado", "Pix", "Está chave já esta em uso!")
            end
        end
    end
end

srv.edit_pix = function(key)
    if not _Is_autenticated then return end
    if key then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            local data = Query('get_pix', { user_id = user_id })
            if #data > 0 then
                if cache_pix[tostring(key)] == nil then
                    cache_pix[tostring(data[1].chave)] = nil
                    cache_pix[tostring(key)] = user_id
                    Execute("update_pix", { user_id = user_id, chave = key })
                    SendWebhook(webhook.editar_pix,
                        "```prolog\n[WISE BANK]\n[EDITOU PIX]\n[CHAVE ANTIGA]" ..
                        data[1].chave ..
                        "\n[NOVA CHAVE]:" ..
                        key .. "\n[USER_ID]:" .. user_id .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. "\n```")
                    TriggerClientEvent('bank_notify', source, "sucesso", "Pix", "Você editou sua chave pix!")
                else
                    TriggerClientEvent('bank_notify', source, "negado", "Pix", "Está chave já esta em uso!")
                end
            else
                TriggerClientEvent('bank_notify', source, "negado", "Pix",
                    "Você precisa criar uma chave antes de edita-la!")
            end
        end
    end
end

srv.remove_pix = function()
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local data = Query('get_pix', { user_id = user_id })
        if #data > 0 then
            Execute('rem_pix', { user_id = user_id })
            cache_pix[tostring(data[1].chave)] = nil
            SendWebhook(webhook.deletarPix,
                "```prolog\n[WISE BANK]\n[DELETOU PIX]\n[CHAVE]:" ..
                data[1].chave .. "\n[USER_ID]:" .. user_id .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. "\n```")
            --notify(source,"sucesso","Pix","Você deletou sua chave pix!")
            TriggerClientEvent('bank_notify', source, "sucesso", "Pix", "Você deletou sua chave pix!")
        end
    end
end

srv.trans_pix = function(key, value)
    if not _Is_autenticated then return end
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and value > 0 and not active[user_id] then
        active[user_id] = true
        if cache_pix[tostring(key)] then
            local nplayer = getUserSource(cache_pix[tostring(key)])
            if nplayer then
                local bank = getBankMoney(user_id)
                if value <= bank then
                    setBankMoney(user_id, parseInt(bank - value))
                    srv.register_trans(user_id, "Pagamento via PIX", -parseInt(value))
                    srv.register_trans(cache_pix[tostring(key)], "Recebimento via PIX", parseInt(value))
                    giveBankMoney(cache_pix[tostring(key)], value)

                    --notify(source,"sucesso","Transferência via PIX","Você enviou R$"..Format(value).." para a chave "..key..".")
                    --notify(nplayer,"sucesso","Recebimento via PIX","Você recebeu R$"..Format(value).." via PIX.")

                    TriggerClientEvent('bank_notify', source, "sucesso", "Transferência via PIX",
                        "Você enviou R$" .. Format(value) .. " para a chave " .. key .. ".")
                    TriggerClientEvent('bank_notify', nplayer, "sucesso", "Recebimento via PIX",
                        "Você recebeu R$" .. Format(value) .. " via PIX.")

                    SendWebhook(webhook.transferir_pix,
                        "```prolog\n[WISE BANK]\n[TRASFERIU PIX]:" ..
                        Format(value) ..
                        "\n[USER_ID]:" ..
                        user_id ..
                        "\n[PARA]:" .. cache_pix[tostring(key)] ..
                        os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") .. "\n```")
                end
            else
                --notify(source,"negado","Aviso","Número pix indisponivel,tente mais tarde!")
                TriggerClientEvent('bank_notify', source, "negado", "Aviso", "Número pix indisponivel,tente mais tarde!")
            end
        else
            --notify(source,"negado","Sistema PIX","Chave não encontrada!")
            TriggerClientEvent('bank_notify', source, "negado", "Sistema PIX", "Chave não encontrada!")
        end
        active[user_id] = false
    end
end
----------------------------------------------------------
--- [ Utils ]
-----------------------------------------------------------
split = function(str, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    local i = 1
    for str in string.gmatch(str, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if user_id then
        local bank = getBankMoney(user_id)
        local money = getMoney(user_id)
        if bank and money then
            srv.register_player_cache(user_id)
            SendWebhook(webhook.dinheiroAoConectar,
                "```prolog\n[WISE BANK]\n[PLAYER JOIN]\n[USER_ID]" ..
                user_id ..
                "\n[CARTEIRA]:" ..
                Format(money) .. "\n[BANCO]:" .. Format(bank) .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") ..
                "\n```")
        end
    end
end)


AddEventHandler('playerDropped', function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local bank = getBankMoney(user_id)
        local money = getMoney(user_id)
        if bank and money then
            SendWebhook(webhook.dinheiroAoSair,
                "```prolog\n[WISE BANK]\n[PLAYER DROP]\n[USER_ID]" ..
                user_id ..
                "\n[CARTEIRA]:" ..
                Format(money) .. "\n[BANCO]:" .. Format(bank) .. os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S") ..
                "\n```")
        end
        if chachePlayer[user_id] then
            chachePlayer[user_id] = nil
        end
    end
end)

RegisterCommand('rmulta', function(source, args)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id and args and args[1] and args[2] then
        if vRP.hasPermission(user_id, rmulta) then
            Execute("payment_multa", { user_id = tonumber(args[1]), multa_id = tonumber(args[2]) })
        end
    end
end)
