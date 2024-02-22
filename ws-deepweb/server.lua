srv = {}
Tunnel.bindInterface('ws-deepweb-core',srv)
Proxy.addInterface('ws-deepweb-core',srv)

local core = config.core
local script = config.script


local active = {}
srv.getIp = function()
    return script.ip
end

-- VERIFICA O TOKEN E A SENHA PARA ACESSAR O SITE
srv.verificarLogin = function(token,senha)
    local source = source
    local user_id = core.getUserId(source)
    if user_id and token and senha then
        local status, name = config.db.verificarLogin(token,senha)
        if status and name then
            webhook(config.webhook.entrouNaLoja,"```prolog\n[DEEPWEB ACESSOU O SITE]\n[TOKEN]:"..token.."\n[USER_ID]:"..user_id.."\n[SENHA]:"..senha..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
            return true,name
        end
    end
end

-- CRIA A LOJA NA DB/CACHE E RETORNA TRUE PARA O CLIENT
srv.criarLoja = function(nome,senha,token,police)
    local source = source
    local user_id = core.getUserId(source)
    if user_id and nome and senha and token then
        if not config.db.checkToken(token) then
            local table = {
                source = source,
                owner = user_id,
                nome = nome,
                senha = senha,
                token = token,
                police = police,
                payment = 0
            }
            local result = GlobalState.openValue
            if police and police == 1 then
                result = result + GlobalState.policeValue
            end
            table.payment = result
            if not _JHOW then
                if core.getItemAmount(user_id,script.item) >= result then
                    if config.db.criarLoja(table) then
                        return true
                    end
                else
                    TriggerClientEvent('Notify',source,'negado','Você não tem dinheiro sujo suficiente para abrir um site!')
                    return false
                end
            else
                if vRP.getBankMoney(user_id) >= result then
                    if config.db.criarLoja(table) then
                        return true
                    end
                else
                    TriggerClientEvent('Notify',source,'negado','Você não tem dinheiro sujo suficiente para abrir um site!')
                    return false
                end
            end
        else
            TriggerClientEvent('Notify',source,'aviso','Este login já esta em uso!')
        end
    end
end

-- PEGA OS ITENS E ARMAZENAMENTO E RETORNA PARA O CLIENT
srv.basicInfoShop = function(token)
    if token then
        if config.db.checkToken(token) then
            return config.pegarProdutos(token)
        end
    end
end

local cacheItens = {}
-- RETORNA O INVENTARIO DO PLAYER COM AS INFORMAÇÕES DOS ITENS
srv.getInventory = function()
    local source = source
    local user_id = core.getUserId(source)
    if user_id then
        local inv = config.core.getInventory(user_id)
        local _ = {}
        for k,v in pairs(inv) do
            if cacheItens[k] then
                table.insert(_,{index = cacheItens[k].index,name = cacheItens[k].name,amount = v.amount,key = k})
            else
                cacheItens[k] = {index = core.itemIndex(k),name = core.itemName(k)}
                table.insert(_,{index = cacheItens[k].index,name = cacheItens[k].name,amount = v.amount,key = k})
            end
        end
        return _
    end
end

-- PEGA A TABELA DE PRODUTOS E FORMATA ELA PARA CONTER O NOME DO PRODUTO USANDO O INDEX DO BANCO DE DADOS
srv.formatarProdutos = function(token)
    local source = source
    local user_id = core.getUserId(source)
    if user_id then
        local produtos = config.pegarProdutos(token)
        if produtos then
            local n = {}
            for k,v in pairs(produtos) do
                if cacheItens[v.item] then
                    table.insert(n,{key = v.item,index = cacheItens[v.item].index,price = v.price, name = cacheItens[v.item].name,estoque = v.estoque})
                else
                    cacheItens[v.item] = {index = core.itemIndex(v.item),name = core.itemName(v.item)}
                    table.insert(n,{key = v.item,index = cacheItens[v.item].index,price = v.price, name = cacheItens[v.item].name,estoque = v.estoque})
                end
            end
            return n,core.hasPermission(user_id,script.policiaPerm),cache.shops[token].police
        end
    end
end

-- CHECA SE O PLAYER POSSUI UM COMPUTADOR
srv.checkItem = function()
    local source = source
    local user_id = core.getUserId(source)
    if user_id then
        if not script.itemComputador then
            return true
        end
        if core.getItemAmount(user_id,script.itemComputador) > 0 then
            return true
        end
    end
end

-- PEGA O DINHEIRO SUJO E RETORNA COMO SALDO
srv.atualizarSaldo = function()
    local source = source
    local user_id = core.getUserId(source)
    if user_id then
        if not _JHOW then
            return core.getItemAmount(user_id,script.item)
        else
            return vRP.getBankMoney(user_id)
        end
    end
end

-- ADICIONA UM ITEM NO SHOP
srv.adicionarItemShop = function(orderInfo)
    local source = source
    local user_id = core.getUserId(source)
    if user_id and orderInfo then
        config.adicionarItemShop(source,user_id,orderInfo)
    end
end

-- ADICIONA O ITEM SELECIONADO DO SHOP
srv.removeItemShop = function(token,item,price,estoque)
    local source = source
    local user_id = core.getUserId(source)
    if user_id then
        local produtos = config.pegarProdutos(token)
        for k,v in pairs(produtos) do
            if v.item == item and v.price == price then
                produtos[k] = nil
            end
        end
        config.db.attProdutos(token,produtos)
        webhook(config.webhook.removerItem,"```prolog\n[DEEPWEB REMOVEU]\n[TOKEN]:"..token.."\n[USER_iD]:"..user_id.."\n[ITEM]:"..core.itemName(item)..'\n[ESTOQUE]:'..estoque..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
    end
end

-- SACA O DINHEIRO DO TOKEN
srv.withdrawShop = function(token,value)
    local source = source
    local user_id = core.getUserId(source)
    if user_id and not active[user_id] then
        active[user_id] = true
        local old = config.getWalletShop(token)
        if value <= old then
            if cache.shops[token].owner == user_id then
                config.setWalletShop(token,parseInt(old - value))
                if not _JHOW then
                    core.giveItem(user_id,script.item,value)
                    TriggerClientEvent('Notify',source,'sucesso','Você sacou R$'..value..' em dinheiro sujo!')
                else
                    vRP.giveBankMoney(user_id,value)
                    TriggerClientEvent('Notify',source,'sucesso','Você sacou R$'..value..'!')
                end
                webhook(config.webhook.sacarShop,"```prolog\n[SACOU DA LOJA]\n[TOKEN]: "..token.."\n[VALUE]: "..value..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")
            else
                TriggerClientEvent('Notify',source,'negado','Você precisa ser dono da loja para efetuar saques!')
            end
        end
        active[user_id] = false
    end
end

-- TRNSFERE PARA OUTRO PLAYER O SHOP
srv.transferShop = function(target,token)
    local source = source
    local user_id = core.getUserId(source)
    if user_id then
        if cache.shops[token].owner == user_id then
            config.db.setOwnerShop(source,target,token)
        else
            TriggerClientEvent('Notify',source,'negado','Você não é dono desse site')
        end
    end
end

-- DELETA O SHOP DA PESSOA
srv.deleteShop = function(token)
    local source = source
    local user_id = core.getUserId(source)
    if user_id then
        if cache.shops[token].owner == user_id then
            config.db.deleteShop(token)
        end
    end
end

-- COMPRA O ITEM SELECIONADO
srv.buyItemShop = function(token,item,price,amount)
    local source = source
    local user_id = core.getUserId(source)
    if user_id and not active[user_id] then
        active[user_id] = true
        local produtos = config.pegarProdutos(token)
        for k,v in pairs(produtos) do
            if v.item == item and tonumber(v.price) == price then
                if v.estoque >= amount then
                    local wallet = core.getItemAmount(user_id,script.item)
                    local total = price*amount
                    if not _JHOW then
                        if wallet >= total and core.tryItem(user_id,script.item,total) then
                            local result = wallet - total
                            if v.estoque - amount == 0 then
                                produtos[k] = nil
                            else
                                produtos[k].estoque = produtos[k].estoque - amount
                            end
                            config.db.attProdutos(token,produtos)
                            local sWallet = config.getWalletShop(token) + total
                            config.setWalletShop(token,sWallet)
                            core.giveItem(user_id,item,amount)
                            TriggerClientEvent('Notify',source,'sucesso','Você recebeu '..cacheItens[item].name.." "..amount.."x")
                            webhook(config.webhook.comprarItem,"```prolog\n[DEEPWEB COMPROU]\n[TOKEN]:"..token.."\n[USER_ID]:"..user_id.."\n[ITEM]:"..core.itemName(item)..'\n[QUANTIDADE]:'..amount.."\n[VALOR] "..total..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")

                        else
                            TriggerClientEvent('Notify',source,'negado',"Você precisa de mais dinheiro sujo!")
                        end
                    else
                        if vRP.tryFullPayment(user_id,total) then
                            local result = wallet - total
                            if v.estoque - amount == 0 then
                                produtos[k] = nil
                            else
                                produtos[k].estoque = produtos[k].estoque - amount
                            end
                            config.db.attProdutos(token,produtos)
                            local sWallet = config.getWalletShop(token) + total
                            config.setWalletShop(token,sWallet)
                            core.giveItem(user_id,item,amount)
                            TriggerClientEvent('Notify',source,'sucesso','Você recebeu '..cacheItens[item].name.." "..amount.."x")
                            webhook(config.webhook.comprarItem,"```prolog\n[DEEPWEB COMPROU]\n[TOKEN]:"..token.."\n[USER_ID]:"..user_id.."\n[ITEM]:"..core.itemName(item)..'\n[QUANTIDADE]:'..amount.."\n[VALOR] "..total..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")

                        else
                            TriggerClientEvent('Notify',source,'negado',"Você precisa de mais dinheiro!")
                        end
                    end
                else
                    TriggerClientEvent('Notify',source,'aviso','Quantidade é maior que o estoque do produto!')
                end
            end
        end
        active[user_id] = false
    end
end

-- PEGA TODOS AS LOJAS QUE O PLAYER É DONO
srv.getMyShops = function()
    local source = source
    local user_id = core.getUserId(source)
    if user_id then
        local t = {}
        local db = config.db.getShopByUser(user_id)
        if db then
            for k,v in ipairs(db) do
                table.insert(t,{nome = v.nome, token = v.token})
            end
            return t
        end
    end
end