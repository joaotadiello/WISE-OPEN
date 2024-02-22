

local core = ServerConfig.core
local webhook = ServerConfig.WebHook
local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
local vRP = Proxy.getInterface('vRP')


local API = {}

Tunnel.bindInterface('gamepass',API)
Proxy.addInterface('gamepass',API)
-------------------------------------------------------------------------------------------------------
--- [ DB API ]
-------------------------------------------------------------------------------------------------------
vRP._prepare("gamepass/GetPlayerReceveid","SELECT received FROM ws_gamepass WHERE user_id = @user_id")
vRP._prepare("gamepass/CreatePlayer","INSERT IGNORE INTO ws_gamepass(user_id,level,xp,received) VALUES(@user_id,@level,@xp,@received)")
vRP._prepare("gamepass/GetLevel","SELECT level FROM ws_gamepass WHERE user_id = @user_id")
vRP._prepare("gamepass/GetXp","SELECT xp FROM ws_gamepass WHERE user_id = @user_id")
vRP._prepare("gamepass/GetAllInfos","SELECT * FROM ws_gamepass WHERE user_id = @user_id")
vRP._prepare('gamepass/SetLevel','UPDATE ws_gamepass SET level = @level WHERE user_id = @user_id')
vRP._prepare('gamepass/UpdateXp','UPDATE ws_gamepass SET xp = xp + @amount WHERE user_id = @user_id')
vRP._prepare('gamepass/UpdateReceveid','UPDATE ws_gamepass SET received = @received WHERE user_id = @user_id')

-------------------------------------------------------------------------------------------------------
--- [ Script start ]
-------------------------------------------------------------------------------------------------------
function webhook(webhook,message)
    if webhook ~= "none" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end

-------------------------------------------------------------------------------------------------------
--- [ DB Core ]
-------------------------------------------------------------------------------------------------------
local GetPlayerXp = function(user_id)
    local row = vRP.query("gamepass/GetXp",{user_id = user_id})
    if not row or not row[1] then return 0 end
    return row[1].xp
end

local GetPlayerLevel = function(user_id)
    local row = vRP.query("gamepass/GetLevel",{user_id = user_id})
    if not row or not row[1] then return 0 end
    return row[1].level
end

local GetPlayerReceveid = function(user_id)
    local row = vRP.query("gamepass/GetPlayerReceveid",{user_id = user_id})
    if not row or not row[1].received then return {} end
    return json.decode(row[1].received)
end

local SetPlayerReceveid = function(user_id,table)
    vRP.execute("gamepass/UpdateReceveid",{user_id = user_id,received = json.encode(table)})
end

local SetPlayerLevel = function(user_id,level)
    vRP.execute('gamepass/SetLevel',{user_id = user_id,level = level})
end

local UpdateXp = function(user_id,amount)
    vRP.execute('gamepass/UpdateXp',{user_id = user_id,amount = amount})
end

local InitPlayer = function(user_id)
    local row = vRP.query("gamepass/GetAllInfos",{user_id = user_id})
    if not row or not row[1] then
        vRP.execute("gamepass/CreatePlayer",{user_id = user_id,level = 1,xp = 0,received = json.encode({})})
    end
end
-------------------------------------------------------------------------------------------------------
--- [ API Utils ]
-------------------------------------------------------------------------------------------------------
local cache = {}
local active = {}
local swebhook = ServerConfig.WebHook
local permissao = ServerConfig.PermissaoParaAbrirOPasse
local rewards = pass

local cooldown = {}
local players = {}
-- Interface para resgatar um item 
API.ClaimReward = function(index)
    local source = source
    local user_id = core.getUserId(source)
    if user_id and not active[user_id] then
        if not cooldown[user_id] or cooldown[user_id] == 0 then 
            active[user_id] = true
            cooldown[user_id] = 3
            local CurrentLevel = GetPlayerLevel(user_id)
            
            if CurrentLevel < index then 
                TriggerClientEvent('Notify',source,'negado','Nivel de passe insuficiente') 
                active[user_id] = false
                return false
            end
            
            if SetClaim(user_id,index) then
                if rewards[index].execute(source,user_id) then
                    webhook(swebhook.ResgatouItem,"```prolog\n[ITEM RESGATADO]\n[NOME DO ITEM]: "..rewards[index].nome.."\n[ID]: "..user_id..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                    return true
                else
                    TriggerClientEvent('Notify',source,'negado','Houve um erro ao reenvedicar sua recompensa!')
                    return false
                end
            else
                TriggerClientEvent('Notify',source,'negado','Você já resgatou essa recompensa')
                return false
            end
        else
            TriggerClientEvent('Notify',source,'negado','Aguarde '..cooldown[user_id]..' segundos para resgatar outra recompensa')
            return false
        end
    end
end

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(cooldown) do
            if v > 0 then
                cooldown[k] = v - 1
            end
        end
        Wait(1000)
    end
end)

-- Salva o item resgatado
SetClaim = function(user_id,index)
    local content = GetPlayerReceveid(user_id)
    for k,v in pairs(content) do
        if index == v then
            return false
        end
    end
    table.insert(content,index)
    SetPlayerReceveid(user_id,content)
    active[user_id] = false
    return true
end

Citizen.CreateThread(function()
    print('[\x1b[32mLOG\x1b[37m]:Tabela de recompensas criada!')
    cache.MaxLevelInGamePass = #pass
end)
-------------------------------------------------------------------------------------------------------
--- [ Level Core ]
-------------------------------------------------------------------------------------------------------
API.GetPlayerLevelPass = function(user_id)
    local current = GetPlayerLevel(user_id)
    if not current then
        InitPlayer(user_id)
    end
    return current
end

function ProcessLevel(source,user_id,oldLevel)
    local xp = GetPlayerXp(user_id)
    local level = 0
    for k,v in pairs(pass) do
        if xp >= v.xp then
            level = k
        end
    end
    if level > oldLevel then
        SetPlayerLevel(user_id,level)
        TriggerClientEvent('Notify',source,'sucesso','Você subiu para o nivel '..level)
        webhook(swebhook.SubiuDeNivel,"```prolog\n[SUBIU DE NIVEL]\n[ID]: "..user_id.."\n[NIVEL ANTIGO]: "..oldLevel.."\n[NIVEL NOVO]: "..level..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
    end
end

API.GivePassXP = function(user_id,amount)
    if user_id and amount then
        UpdateXp(user_id,amount)
        ProcessLevel(source,user_id,GetPlayerLevel(user_id))
        local source = core.getSource(user_id)
        TriggerClientEvent('Notify',source,'sucesso','Você recebeu <b>'..amount..' XP</b>')
        webhook(swebhook.RecebeuXP,"```prolog\n[XP RECEBIDO]\n[ID]: "..user_id.."\n[QUANTIDADE]: "..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
    end
end

API.RewardOnPlayer = function()
    if ServerConfig.AtivarRecompensaPorTempoOnline then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            UpdateXp(user_id,ServerConfig.RecompensaPorTempoOnline)
            TriggerClientEvent('Notify',source,'sucesso','Você recebeu <b>'..ServerConfig.RecompensaPorTempoOnline..' XP</b>')
            webhook(swebhook.RecebeuXP,"```prolog\n[XP RECEBIDO]\n[ID]: "..user_id.."\n[QUANTIDADE]: "..ServerConfig.RecompensaPorTempoOnline..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
            ProcessLevel(source,user_id,GetPlayerLevel(user_id))
        end
    end
end



API.UpdateProgressBar = function()
    local source = source
    local user_id = core.getUserId(source)
    if user_id then
        local xp = GetPlayerXp(user_id)
        local CurrentLevel = GetPlayerLevel(user_id)
        if xp and CurrentLevel then
            if pass[CurrentLevel + 1] then
                local nextXp = pass[CurrentLevel + 1].xp
                return xp, nextXp
            else
                return xp, xp
            end
        end
    end
end


-------------------------------------------------------------------------------------------------------
--- [ Script Core ]
-------------------------------------------------------------------------------------------------------
RegisterCommand('passe',function(source)
    local user_id = core.getUserId(source)
    if user_id then
        if core.hasPermission(user_id,permissao) then
            if not players[user_id] then
                InitPlayer(user_id)
                players[user_id] = true
            end
            local CurrentLevel = GetPlayerLevel(user_id)
            local content = GetPlayerReceveid(user_id)
            
            TriggerClientEvent('ws:openGamePass',source,content,CurrentLevel,cache.MaxLevelInGamePass)
        else
            TriggerClientEvent('Notify',source,'aviso','Você não possui o passe de temporada')
        end
    end
end)
