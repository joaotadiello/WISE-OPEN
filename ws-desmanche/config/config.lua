local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
garage = Proxy.getInterface("vrp_garages")

cfg = { }

cfg.core = {
    playAnim = function(bool,table,bool2)
        vRP.playAnim(bool,{table},bool2)
    end,

    stopAnim = function()
        vRP.stopAnim(false)
    end,
}

return cfg