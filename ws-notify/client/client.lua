local SendNUIMessage = function(data)
    Citizen.InvokeNative(0x78608ACB, json.encode(data))
end

function SendReactMessage(action, data)
    SendNUIMessage({ action = action, data = data })
end

--- @param image string
---@param name string
---@param amount number
---@param action 'recebeu' | 'enviou'
local function NotifyItens(image,name,amount,action)
    SendReactMessage("0x771F3335", {
        image = image,
        name = name,
        amount = amount,
        action = action
    })
end
exports('NotifyItens', NotifyItens)
RegisterNetEvent('NotifyItens', NotifyItens)

--- @vararg 0xA524CA30 notify:config
--- @vararg 0x47827583 Config
--- @vararg 0x1C31B317 auth
RegisterNuiCallback("0xA524CA30",function(_,cb)
    cb({["0x47827583"] = Config,["0x1C31B317"] = true})
end)

RegisterCommand("itens",function()
    SendReactMessage("0x771F3335",{
        image = "minismg",
        name = "Mini smg",
        amount = 1,
        action = "recebeu"
    })
    Wait(3000)
    SendReactMessage("0x771F3335",{
        image = "minismg",
        name = "Mini smg",
        amount = 1,
        action = "enviou"
    })
end,false)
