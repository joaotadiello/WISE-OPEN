Tunnel = module('vrp','lib/Tunnel')
Proxy = module('vrp','lib/Proxy')
vRP = Proxy.getInterface('vRP')

config = {}
cache = {}

Tunnel.bindInterface('ws-deepweb',config)
Proxy.addInterface('ws-deepweb',config)

function webhook(webhook,message)
    if webhook ~= "none" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end

-- ['STRING'] = TABLE
cache.shops = {}

vRP._prepare("check_token","SELECT * FROM ws_deepweb_shops WHERE token = @token")
vRP._prepare("getAllShop","SELECT * FROM ws_deepweb_shops")
vRP._prepare("get_eth","SELECT eth FROM vrp_users WHERE id = @id")
vRP._prepare('set_eth','UPDATE vrp_users SET eth = @eth WHERE id = @id')
vRP._prepare("get_produtos","SELECT produtos FROM ws_deepweb_shops WHERE token = @token")
vRP._prepare("get_myShops","SELECT * FROM ws_deepweb_shops WHERE owner = @owner")
vRP._prepare("get_walletShop","SELECT wallet FROM ws_deepweb_shops WHERE token = @token")
vRP._prepare('set_walletShop','UPDATE ws_deepweb_shops SET wallet = @wallet WHERE token = @token')
vRP._prepare('updateOwnerShop','UPDATE ws_deepweb_shops SET owner = @owner WHERE token = @token')
vRP._prepare("deleteShop","DELETE FROM ws_deepweb_shops WHERE token = @token")
vRP._prepare("add_shop","INSERT IGNORE INTO ws_deepweb_shops(token,owner,senha,wallet,produtos,nome,police) VALUES(@token,@owner,@senha,@wallet,@produtos,@nome,@police)")
vRP._prepare('att_estoque','UPDATE ws_deepweb_shops SET produtos = @produtos WHERE token = @token')

config.db = {
    getShopByUser = function(user_id)
        local tbl = vRP.query('get_myShops',{owner = user_id})
        return tbl
    end,

    -- VERIFICA SE O TOKEN EXISTE, CASO NÃO, TENTA REGISTRAR O TOKEN NO CACHE
    checkToken = function(token)
        if cache.shops[token] then
            return true
        else
            local rows = vRP.query('check_token',{token = token})
            if rows then 
                local i = rows[1]
                if i then
                    cache.shops[token] = {
                        police = i.police,
                        private = i.private,
                        owner = i.owner,
                        estoque = i.estoque,
                        nome = i.nome,
                        senha = i.senha,
                        token = i.token
                    }
                    return true
                end
            end
        end
    end,

    -- VERIFICA AS INFORMACOES DE LOGIN
    verificarLogin = function(token,senha)
        if config.db.checkToken(token) then
            if cache.shops[token].senha == senha then
                return true,cache.shops[token].nome
            else
                return false
            end
        end
    end,

    -- CRIA A LOJA E REGISTRA NO CACHE
    criarLoja = function(info)
        if not _JHOW then
            if config.core.tryItem(info.owner,config.script.item,info.payment) then
                vRP.execute('add_shop',{
                    token = info.token,
                    owner = info.owner,
                    senha = info.senha,
                    wallet = 0.0,
                    produtos = json.encode({}),
                    nome = info.nome,
                    police = info.police,
                })
                cache.shops[info.token] = {
                    token = info.token,
                    owner = info.owner,
                    senha = info.senha,
                    wallet = 0.0,
                    nome = info.nome,
                    police = info.police,
                }
                TriggerClientEvent('Notify',info.source,'sucesso','Você criou seu site na deep web!')
                webhook(config.webhook.criarLoja,"```prolog\n[LOJA CRIADA]\n[TOKEN]: "..info.token.."\n[OWNER]: "..info.owner.."\n[SENHA]: "..info.senha..'\n[NOME]: '..info.nome..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                return true
            end
            return false
        else
            if vRP.tryFullPayment(info.owner,info.payment) then
                vRP.execute('add_shop',{
                    token = info.token,
                    owner = info.owner,
                    senha = info.senha,
                    wallet = 0.0,
                    produtos = json.encode({}),
                    nome = info.nome,
                    police = info.police,
                })
                cache.shops[info.token] = {
                    token = info.token,
                    owner = info.owner,
                    senha = info.senha,
                    wallet = 0.0,
                    nome = info.nome,
                    police = info.police,
                }
                TriggerClientEvent('Notify',info.source,'sucesso','Você criou seu site na deep web!')
                webhook(config.webhook.criarLoja,"```prolog\n[LOJA CRIADA]\n[TOKEN]: "..info.token.."\n[OWNER]: "..info.owner.."\n[SENHA]: "..info.senha..'\n[NOME]: '..info.nome..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                return true
            end
            return false
        end
    end,

    -- PEGA TODAS AS INFOS NA DB E REGISTRA NO CACHE
    createCache = function()
        local tbl = vRP.query("getAllShop")
        if tbl then
            for k,v in pairs(tbl) do
                cache.shops[v.token] = v
            end
            print('[\x1b[32mSUCESSO\x1b[37m]:CACHE DE LOJAS GERADO!')
        end
    end,

    -- ATUALIZA O CONTEUDO DO SHOP DO TOKEN INDICADO
    attProdutos = function(token,table)
        vRP.execute('att_estoque',{produtos = json.encode(table),token = token})
    end,

    setOwnerShop = function(source,target,token)
        cache.shops[token].owner = target
        vRP.execute('updateOwnerShop',{owner = target,token = token})
        local nplayer = config.core.getSource(target)
        if nplayer then
            TriggerClientEvent('Notify',nplayer,'sucesso','Você recebeu '..cache.shops[token].nome..' do passaporte <b>'..config.core.getUserId(source)..'</b>.')
        end
        TriggerClientEvent('Notify',source,'sucesso','Você transferiu '..cache.shops[token].nome..' para o passaporte <b>'..target..'</b>.') 
        webhook(config.webhook.transferirShop,"```prolog\n[LOJA TRANSFERIDA]\n[TOKEN]: "..token.."\n[NEW OWNER]: "..target.."\n[OLD OWNER]: "..config.core.getUserId(source)..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
    end,

    deleteShop = function(token)
        vRP.execute('deleteShop',{token = token})
        cache.shops[token] = nil
        webhook(config.webhook.deleteShop,"```prolog\n[LOJA DELETADA]\n[TOKEN]: "..token..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
    end,
}

_JHOW = true

Citizen.CreateThread(function()
    config.db.createCache()
    GlobalState.policeValue = 3000000 -- Valor para ativar a proteção contra policia
    GlobalState.openValue = 2000000 -- Valor para abrir um site
end)

config.getShopInfo = function(token)
    if cache.shops[token] then
        return cache.shops[token].token,cache.shops[token].senha
    end
end

config.script = {
    -- Item do dinheiro sujo
    item = 'dinheirosujo',

    -- Permissao geral da policia, para bloquear o acesso a lojas com proteção
    policiaPerm = 'policia.permissao',

    -- Item para usar acessar a deepweb | (-->itemComputador = 'nomedoitem'<--) caso queira que precise de item
    itemComputador = nil,

    -- IP para buscar as imagens
    ip = 'localhost',

    -- Numero maximo de itens em um shop
    maxItemInShop = 10,  
}

config.webhook = {
    criarLoja = "https://discord.com/api/webhooks/913769101896335380/chNh90GnvfwaWa5PAWVoMOa722MAoRwmLaY5cUe6YQkGua_B0kSuKlVB7UdiVQCgSmpY",
    transferirShop = "https://discord.com/api/webhooks/913769101896335380/chNh90GnvfwaWa5PAWVoMOa722MAoRwmLaY5cUe6YQkGua_B0kSuKlVB7UdiVQCgSmpY",
    deleteShop = "https://discord.com/api/webhooks/913769101896335380/chNh90GnvfwaWa5PAWVoMOa722MAoRwmLaY5cUe6YQkGua_B0kSuKlVB7UdiVQCgSmpY",
    sacarShop = "https://discord.com/api/webhooks/913769101896335380/chNh90GnvfwaWa5PAWVoMOa722MAoRwmLaY5cUe6YQkGua_B0kSuKlVB7UdiVQCgSmpY",
    removerItem = "https://discord.com/api/webhooks/913769101896335380/chNh90GnvfwaWa5PAWVoMOa722MAoRwmLaY5cUe6YQkGua_B0kSuKlVB7UdiVQCgSmpY",
    depositarShop = "https://discord.com/api/webhooks/913769101896335380/chNh90GnvfwaWa5PAWVoMOa722MAoRwmLaY5cUe6YQkGua_B0kSuKlVB7UdiVQCgSmpY",
    entrouNaLoja = "https://discord.com/api/webhooks/913769101896335380/chNh90GnvfwaWa5PAWVoMOa722MAoRwmLaY5cUe6YQkGua_B0kSuKlVB7UdiVQCgSmpY",
    comprarItem = "https://discord.com/api/webhooks/913769101896335380/chNh90GnvfwaWa5PAWVoMOa722MAoRwmLaY5cUe6YQkGua_B0kSuKlVB7UdiVQCgSmpY",
}

config.core = {
    -- RETORNA O ID DO PLAYER
    getUserId = function(source) return vRP.getUserId(source) end,

    -- PEGA A SOURCE DO ID
    getSource = function(user_id)
        return vRP.getUserSource(user_id)
    end,

    -- FUNCAO PARA DAR ITEM AO JOGADOR
    giveItem = function(user_id,item,amount) vRP.giveInventoryItem(user_id,item,amount) end,

    -- FUNCAO PARA REMOVER ITEM AO JOGADOR
    tryItem = function(user_id,item,amount) return vRP.tryGetInventoryItem(user_id,item,amount) end,

    -- FUNCAO PARA PEGAR A QUANTIDADE DE UM ITEM
    getItemAmount = function(user_id,item) return vRP.getInventoryItemAmount(user_id,item) end,

    -- FUNÇÃO PARA RETORNAR O INVENTARIO DO JOGADOR
    getInventory = function(user_id) return vRP.getInventory(user_id) end,

    -- FUNÇÃO PARA VERIFICAR A PERMISSAO
    hasPermission = function(user_id,perm) return vRP.hasPermission(user_id,perm) end,

    itemIndex = function(item) return vRP.itemIndexList(item) end,

    itemName = function(item) return vRP.itemNameList(item) end,

}

-- RETORNA O TOKEN DE TODAS AS LOJAS CRIADAS
config.getAllShops = function()
    local n = {}
    for k,v in pairs(cache.shops) do
        table.insert(n,{token = v.token,nome = v.nome})
    end
    return n
end

-- RETORNA OS PRODUTOS DO TOKEN INFORMADO
config.pegarProdutos = function(token)
    if token then
        local value = json.decode(vRP.query('get_produtos',{token = token})[1].produtos)
        if value then
            return value
        end
    end
end

-- ADICIONA O PRODUTO NO TOKEN INFORMADO
config.adicionarItemShop = function(source,user_id,orderInfo)
    if source and user_id and orderInfo then
        local produtos = config.pegarProdutos(orderInfo.token)
        if produtos then
            if #produtos < config.script.maxItemInShop then
                for k,v in pairs(produtos) do
                    if v.item == orderInfo.item then
                        if v.price == orderInfo.price then
                            if config.core.tryItem(user_id,orderInfo.item,orderInfo.amount) then
                                produtos[k].estoque = produtos[k].estoque + orderInfo.amount
                                config.db.attProdutos(orderInfo.token,produtos)
                                TriggerClientEvent('Notify',source,'sucesso','Você adicionou <b>'..orderInfo.amount..'x<b> '..orderInfo.item)
                                webhook(config.webhook.depositarShop,"```prolog\n[DEEPWEB ADICIONAR]\n[TOKEN]:"..orderInfo.token.."\n[USER_iD]:"..user_id.."\n[ITEM]:"..config.core.itemName(orderInfo.item)..'\n[QUANTIDADE]:'..orderInfo.amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                                return
                            end
                        end
                    end
                end
                if config.core.tryItem(user_id,orderInfo.item,orderInfo.amount) then
                    table.insert(produtos,{item = orderInfo.item,price = orderInfo.price,estoque = orderInfo.amount})
                    config.db.attProdutos(orderInfo.token,produtos)
                    TriggerClientEvent('Notify',source,'sucesso','Você adicionou <b>'..orderInfo.amount..'x<b> '..orderInfo.item)
                    webhook(config.webhook.depositarShop,"```prolog\n[DEEPWEB ADICIONAR]\n[TOKEN]:"..orderInfo.token.."\n[USER_iD]:"..user_id.."\n[ITEM]:"..config.core.itemName(orderInfo.item)..'\n[QUANTIDADE]:'..orderInfo.amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
                end
            else
                TriggerClientEvent('Notify',source,'aviso','Seu site atingiu o numero maximo de ')
            end
        end
    end
end

-- PEGA O VALOR DA WALLET DA LOJA
config.getWalletShop = function(token)
    if token then
        local row = vRP.query('get_walletShop',{token = token})
        return row[1].wallet
    end
end

-- SETA O VALOR DA WALLET DA LOJA
config.setWalletShop = function(token,value)
    vRP.execute('set_walletShop',{token = token,wallet = value})
end