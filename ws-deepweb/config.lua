--[[
    [------------------------------------------------------------------------------------------------------------------------------------------------]
    [blacklist]
        - Configure os itens que não poderão ser adicionados na loja.
        - Exemplo --> ['spawdoitem'] = true
    [------------------------------------------------------------------------------------------------------------------------------------------------]        
    [minValue]
        - Define o valor minimo de um item, caso o item não seja configurado ele ira vendido pelo valor que o player quiser.
    [------------------------------------------------------------------------------------------------------------------------------------------------]        
    [wifi]
        - Você ira configurar as areas onde sera disponivel acessar a deepweb.
    [------------------------------------------------------------------------------------------------------------------------------------------------]        
        [active]
        - Liga o sistema de wifi onde precisa estar naquele local para abrir a deepweb.
        [distance]
        - Distance que a wifi ira ter sinal.
        [areas]
        - Locais onde o wifi ira funcionar.
    [------------------------------------------------------------------------------------------------------------------------------------------------]        
    [registro]
        - Desabilita o registro de novas lojas, deixando somente via banco de dados, assim você poderá deixar somente para
        organizações que você criar.
    [------------------------------------------------------------------------------------------------------------------------------------------------]
    [sistemaDeMissao]
        - Caso esteja ativo, quando um player adicionar um produto na loja ou comprar um produto, ele ira precisar
        ir ate uma coordenada buscar/guardar o item, isso corrige para que o player nao abre a deep web em meio
        a uma ação e compre algum item para tirar vantagem.
    [------------------------------------------------------------------------------------------------------------------------------------------------]

]]

cfg = {}

cfg.missao = {
    -- DEFINE SE IRA CRIAR A ROTA PRA IR ENTREGAR OU RECEBER O ITEM
    active = false,
    locais = {
        vec3(156.74,-787.66,31.27),
        vec3(162.14,-791.31,31.2),
    }
}

cfg.wifi = {
    active = true,
    distance = 50,
    areas = {
        vec3(168.54,-992.81,30.1),
    }
}

cfg.script = {
    commandName = 'deep',
    sistemaDeMissao = false,
    blackList = {
        ['dinheirosujo'] = true,
        ['identidade'] = true,
    },
    minValue = {
        ['serra'] = 2500,
    },
    registro = true,
}


