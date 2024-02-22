local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP')
local nation = Tunnel.getInterface("nation_paintball")

cfg = {}

-- Configure aqui seus itens ilegais
cfg.itensIlegais = {
    ["colete"] = "colete",
    ["maconha"] = "maconha",
    ["cocaina"] = "cocaina",
    ["metanfetamina"] = "metanfetamina",
}

-- AutoBan para quem revistar e quitar
cfg.autoBan = true

-- Config para caso tenha o paitball
cfg.paintball = false
cfg.checkPaintBall = function(source)
    return nation.isInPaintball(source)
end

-- Config para ativar ou desativar um menu
cfg.ativarFuncao = {revistar = true, saquear = true,roubar = true, apreender = true}

-- Permissão geral da policia
cfg.permiPolicia = 'mindmaster.permissao'

cfg.ip = 'mengazo.com/itens'

cfg.adminpermissao = 'mindmaster.permissao'

cfg.core = {
------------------------------------------------------
    -- [ CONFIG PARA O REVISTAR ]
    ------------------------------------------------------,
    --Revistar somente por permissao
    revistarPorPermi = false,

    -- Permissao para revistar
    revistarPermissao = 'policia.permissao',

    -- Pede para a pessoa se ela quer ser revistada
    requestRevistar = true,

    ------------------------------------------------------
    -- [ CONFIG PARA O ROUBAR ]
    ------------------------------------------------------,
    --Minimo de policiais online para roubar
    roubarMinPolicia = 0,

    roubarChamarPolicia = false,

    ------------------------------------------------------
    -- [ CONFIG PARA O APREENDER ]
    ------------------------------------------------------
    -- Permissao para apreender
    apreenderPermissao = 'policia.permissao',

    -- Dar itens apreendidos para o policial
    giveItemPolice = false,

    -- Spaw do item colete
    itemColete = "colete",

    ------------------------------------------------------
    -- [ CONFIG PARA O SAQUEAR ]
    ------------------------------------------------------
    saquearMinPolicia = 0,

    -- Vida minima para poder saquear jogados
    vidaMinima = 101,
}

cfg.webhook = {
    saquear = "",
    roubar = "",
    revistar = "",
    apreender = "",
    banimento = "seuwebhook",
}

return cfg