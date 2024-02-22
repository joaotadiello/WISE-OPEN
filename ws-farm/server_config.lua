
config = {}

config.ip = 'localhost/itens'

config.webhook = {
    entregar = '',
    coletar = '',
    fabricar = ''
}


--[[
    [ CONFIG CRAFT ]
    Deve ser configurado somente as receitas do itens

    ['weed'] = Chave para identificar, nao precisa ser necessariamente o nome do item ['qualquercoisa']
    key = ['weed'] deve ser SEMPRE igual ao nome que fica entre ['']
    TargetItem = Item que ira ser recebido no final
    ReceveidAmount = Quantidade que ira ser recebida
    TimeProduction = Tempo para produzir o item
    AvaliableGroups = Em quais GRUPOS DO SCRIPT o item estara disponivel para ser fabricado
    craft = Receita para criar o item. Maximo de 3 itens, começando em 0 até 2.{item,index,quantidade}
]]
config.craft = {
    ['motoclub_arma'] = {
        key = 'motoclub_arma',
        TargetItem = 'glock',
        ReceveidAmount = 1,
        TimeProduction = 10,
        craft = {
            ['0'] = {'pecasdearma','pecasdearma',1},
        },
    },
    ['vanilla_arma'] = {
        key = 'vanilla_arma',
        TargetItem = 'glock',
        ReceveidAmount = 1,
        TimeProduction = 10,
        craft = {
            ['0'] = {'pecasdearma','pecasdearma',1},
        },
    },    
}

--[[
    [ CONFIG SCRIPT ]
    fabricar = Itens que poderão ser criados no ['motoclub'].Os itens devem existir no config.craft!!
    AcessPerms = Permissoes de acesso ao farm
    coletar = itens que poderao ser coletados no farm
    entregar = itens que poderao ser entregues no farm
]]
config.script = {
    ['motoclub'] = {
        AcessPerms = {
            'admin',
            'Admin',
        },
        fabricar = {
            'weed',
            'qualquercoisa',
        },
        coletar = {
            ['weed'] = 2,
            ['joint'] = 5,
        },
        entregar = {
            ['weed'] = 2,
            ['cocaine'] = 5,
        }
    },
    ['vanilla'] = {
        AcessPerms = {
            'admin',
        },
        fabricar = {
            'weed',
            'qualquercoisa',
        },
        coletar = {
            ['weed'] = 2,
            ['joint'] = 5,
        },
        entregar = {
            ['weed'] = 2,
            ['cocaine'] = 5,
        }
    },
}

config.custom = {
    coletar = function(tbl)
        local source,user_id,farme,item = tbl.source,tbl.user_id,tbl.farme,tbl.item
        if config.script[farme].coletar[item] then
            local amount = config.script[farme].coletar[item]
            local max_inv = GetBackPack(user_id)
            local inv_weight = GetInvWeight(user_id)
            if (inv_weight + (GetItemWeight(item) * amount)) <= max_inv then
                GiveItem(user_id,item,amount)
                TriggerClientEvent('Notify',source,'sucesso','Você recebeu '..amount..'x '..ItemName(item)..'.')
                webhook(config.webhook.coletar,"```prolog\n[COLETAR]\n[ID]:"..user_id.."\n[FARME]:"..farme.."\n[ITEM]:"..item.."\n[QUANTIDADE]:"..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")

            else
                TriggerClientEvent('Notify',source,'negado','Você não possui mais espaço em sua mochila!')
                TriggerClientEvent('ws-farm:endFarm',source) --Encerra a rota de coleta ou entrega
            end
        end
    end,

    entregar = function(tbl)
        local source,user_id,farme,item = tbl.source,tbl.user_id,tbl.farme,tbl.item
        if config.script[farme].entregar[item] then
            local amount = config.script[farme].entregar[item]
            local max_inv = GetBackPack(user_id)
            local inv_weight = GetInvWeight(user_id)
            if (inv_weight + (GetItemWeight(item) * amount)) <= max_inv then
                TryItem(user_id,item,amount)
                GiveItem(user_id,'dollars',parseInt(amount * 100))
                TriggerClientEvent('Notify',source,'sucesso','Você recebeu '..parseInt(amount * 100)..'x dinheiro pela entrega!.')
                webhook(config.webhook.coletar,"```prolog\n[ENTREGAR]\n[ID]:"..user_id.."\n[FARME]:"..farme.."\n[ITEM ENTREGUE]:"..item.."\n[QUANTIDADE]:"..amount..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").."\n```")

            else
                TriggerClientEvent('Notify',source,'negado','Você não possui mais espaço em sua mochila!')
                TriggerClientEvent('ws-farm:endFarm',source) --Encerra a rota de coleta ou entrega
            end
        end
    end
}

config.craft = {
    ['motoclub_arma'] = {
        key = 'motoclub_arma',
        TargetItem = 'glock',
        ReceveidAmount = 1,
        TimeProduction = 10,
        craft = {
            ['0'] = {'pecasdearma','pecasdearma',1},
        },
    },
    ['vanilla_arma'] = {
        key = 'vanilla_arma',
        TargetItem = 'glock',
        ReceveidAmount = 1,
        TimeProduction = 10,
        craft = {
            ['0'] = {'pecasdearma','pecasdearma',1},
        },
    },    
}


```lua
config.script = {
    ['motoclub'] = {
        AcessPerms = {
            'admin',
            'Admin',
        },
        fabricar = {
            'motoclub_arma',
        },
        coletar = {
            ['weed'] = 2,
            ['joint'] = 5,
        },
        entregar = {
            ['weed'] = 2,
            ['cocaine'] = 5,
        }
    },
    ['vanilla'] = {
        AcessPerms = {
            'admin',
        },
        fabricar = {
            'vanilla_arma',
        },
        coletar = {
            ['weed'] = 2,
            ['joint'] = 5,
        },
        entregar = {
            ['weed'] = 2,
            ['cocaine'] = 5,
        }
    },
}
```