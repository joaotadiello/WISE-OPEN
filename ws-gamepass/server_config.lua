-------------------------------------------------------------------------------------------------------
--- [ Tunnel / Proxy ]
-------------------------------------------------------------------------------------------------------
local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
local vRP = Proxy.getInterface('vRP')

-------------------------------------------------------------------------------------------------------
--- [ DB ]
-------------------------------------------------------------------------------------------------------
vRP._prepare("checkVehicle/pass","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("pass/giveVehicle","INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,ipva) VALUES(@user_id,@vehicle,@ipva)")
-------------------------------------------------------------------------------------------------------
--- [ SERVER CONFIG ]
-------------------------------------------------------------------------------------------------------
ServerConfig = {}

ServerConfig.RecompensaPorTempoOnline = 50 --Valor recebido por ficar online
ServerConfig.AtivarRecompensaPorTempoOnline = false --Ativa ou nao a recompensa por ficar online


-- OBS: Você precisa criar um novo grupo que contenha a permissao determinada a baixo.
ServerConfig.PermissaoParaAbrirOPasse = 'admin.permissao'

-- LEIA COM ATENÇÃO!
-------------------------------------------------------------------------------------
-- [ Configure aqui as recompensa por cada nivel do passe ]
-- xp = Quantidade de xp para passar de nivel
-- nome = Nome que ira aparecer na NUI
-- img = Imagem do item que deve estar na pasta nui/assets
-- execute = Programe aqui o que o item deve fazer, sempre deve retornar true!!

--[[
    [ INFORMAÇÕES UTEIS PARA COPIAR E COLAR ]

    #FUNÇÃO PARA DAR UM ITEM
    vRP.giveInventoryItem(user_id,'nomedoitem',quantidade)

    #FUNÇÃO PARA DAR DINHEIRO NO BANCO
    vRP.giveBankMoney(user_id,1000)

    #FUNÇÃO PARA DAR DINHEIRO NA MAO
    vRP.giveMoney(user_id,1000)

    #FUNÇÃO PARA ADICIONAR UM CARRO
    AddVehicleToPlayer(user_id,'kuruma')

]]
-------------------------------------------------------------------------------------
ServerConfig.core = {
    getUserId = function(source)
        return vRP.getUserId(source)
    end,

    getSource = function(user_id)
        return vRP.getUserSource(user_id)
    end,

    giveItem = function(user_id,item,quantidade)
        vRP.giveInventoryItem(user_id,item,quantidade)
    end,

    hasPermission = function(user_id,perm)
        return vRP.hasPermission(user_id,perm)
    end,
}


--[[
    NÃO ALTERE NADA AQUI CASO NÃO SAIBA O QUE ESTA FAZENDO!!
    CASO TENHA PROBLEMAS ABRA UM TICKET EM NOSSA LOJA
]]


--Função para adicionar carro na garagem do player 
AddVehicleToPlayer = function(source,user_id,vehicle)
    if user_id and vehicle then
        local row = vRP.query('checkVehicle/pass',{user_id = user_id, vehicle = vehicle})
        if row and row[1] then
            TriggerClientEvent('Notify',source,'aviso','Você já possui este veiculo em sua garagem!')
            return
        end
        vRP.execute('pass/giveVehicle',{user_id = user_id,vehicle = vehicle,ipva = os.time() + 24*30*30})
        TriggerClientEvent('Notify',source,'sucesso','Você resgatou <b>'..vehicle..'</b> com sucesso')
    end
end

RegisterCommand('aab',function()
    local API = Proxy.getInterface('gamepass')
    API.GivePassXP(2,1000)
end)

--[[
    Configure aqui o seu link de webhook
]]
ServerConfig.WebHook = {
    RecebeuXP = '',
    SubiuDeNivel = '',
    ResgatouItem = '',
}

