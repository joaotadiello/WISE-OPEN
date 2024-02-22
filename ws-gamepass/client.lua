local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
API = Tunnel.getInterface('gamepass')

local cooldown = 0
local rewards = {}

Citizen.CreateThread(function()
    for k,v in pairs(pass) do
        rewards[k] = {
            index = k,
            img = v.img,
            xp = v.xp,
            name = v.nome,
            received = false
        }
    end
end)



RegisterNetEvent('ws:openGamePass')
AddEventHandler('ws:openGamePass',function(Itens,CurrentLevel,MaxLevelInGamePass)
    for k,v in pairs(Itens) do
        if rewards[v] then
            rewards[v].received = true
        end
    end

    SetNuiFocus(true,true)
    SendNUIMessage({
        action = 'show',
        Itens = rewards,
        CurrentLevel = CurrentLevel,
        NextLevel = NextLevel(CurrentLevel,MaxLevelInGamePass),
        MaxLevelInGamePass = MaxLevelInGamePass
    })
    StartScreenEffect("MenuMGSelectionIn", 0, true)
end)

RegisterNUICallback('ClaimReward',function(data,cb)
    if cooldown == 0 then
        cooldown = 2
        local status = API.ClaimReward(tonumber(data.index))
        cb({status = status})
    else
        TriggerEvent('Notify','aviso','Estamos processando outra reenvidicação de recompensa, tente novamente em alguns segundos.')
    end
end)


RegisterNUICallback('close',function(data,cb)
    close()
end)

RegisterNUICallback('UpdateProgressBar',function(data,cb)
    local current,next = API.UpdateProgressBar()
    if current and next then
        cb({xp = current,next = next})
    end
end)

close = function()
    SetNuiFocus(false,false)
    StopScreenEffect("MenuMGSelectionIn")
end

Citizen.CreateThread(function()
    while true do
        if cooldown > 0 then
            cooldown = cooldown - 1
        end
        Wait(1000)
    end
end)


NextLevel = function(current,max)
    if (current + 1) < max then
        return current + 1
    else
        return 'MaxLevel'
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(1000*ClientConfig.TempoParaReceberRecompensa)
        API.RewardOnPlayer()
    end
end)
