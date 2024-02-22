local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')
local groups = module("vrp","cfg/groups")
local trunkSize = module("vrp","cfg/inventory")


vRP = Proxy.getInterface('vRP')
vRPcliente = Tunnel.getInterface('vRP')

bank = Proxy.getInterface('ws-bank')
home = Proxy.getInterface('vrp_homes')

cfg = {}

cfg.ip = "localhost/itens"
cfg.homes_summer = false

local groups = groups.groups
Citizen.CreateThread(function()
    if cfg.homes_summer then
        return
    else
        homesTable = home.getHomeChsestSize()
    end
end)

cfg.paintball = false
----------------------------------------------------------------------
--- [ CORE - Config]
----------------------------------------------------------------------
cfg.core = {

    -- Libera dar RR com a base ligada sem precisa de um RR geral!
    enableRestart = true,

    --Numero de slots do inventario
    slotNumber = 24, 

    -- Moeda da sua base
    monetary = 'R$',

    -- Estrutura (table[user_id] = source)
    getUsersBase = function()
        return vRP.getUsers()
    end,    

    -- Retorna o tamanho do porta-malas
    getTrunkSize = function(vname)
        return trunkSize.chestweight[vname] or 50
    end,

    -- Função para cobrar o dinheiro da mao do player
    tryPayment = function(user_id,value)
        return vRP.tryPayment(user_id,parseInt(value))
    end,

    -- Funcao para pegar o ID do player
    getUserId = function(source)
        return vRP.getUserId(source)
    end,

    -- Função para pegar a permissao do player
    hasPermission = function(user_id,perm)
        return vRP.hasPermission(user_id,perm)
    end,


    -- Função para pegar server_data
    getSData = function(dkey)
        return json.decode(vRP.getSData(dkey)) or {}
    end,

    -- Função para pegar user_data
    getUData = function(user_id,dkey)
        return json.decode(vRP.getUData(user_id,dkey)) or {}
    end,

    -- Função para salvar em server_users
    setSData = function(dkey,value)
        vRP.setSData(dkey,value)
    end,

    -- Função para salvar no user_data
    setUData = function(user_id,dkey,value)
        vRP.setUData(user_id,dkey,value)
    end,

    -- Função para dar dinheiro ao player
    giveMoney = function(user_id,value)
        vRP.giveMoney(user_id,parseInt(value))
    end,

    -- Retorna o bau da casa
    getHomeChest = function(houseIndex)
        return json.decode(vRP.getSData('chest:'..houseIndex)) or {},'chest:'..houseIndex
    end,
    
    -- Retorna a tabela de homes syntax(table[houseName] = tamanho)
    gerateSizeHome = function()
        local size = { }
        if homesTable then
            for k,v in pairs(homesTable) do
                size[k] = v[3]
            end
            return size
        end
    end,

    -- Retorna dados para identidade
    getIdentity = function(user_id)
        local player = {}
        local i = vRP.getUserIdentity(user_id)
    
        player.id = user_id
        player.nome = i.name
        player.sobrenome = i.firstname
        player.idade = i.age
        player.money = vRP.getMoney(user_id)
        player.banco = vRP.getBankMoney(user_id)
        player.groups = cfg.core.getUserGroupByType(user_id,"job")
        player.multas = bank.verify_multas(user_id)
        player.phone = i.phone
        player.rg = i.registration
        player.vip = cfg.core.getUserGroupByType(user_id,"job")
    
        return player
    end,

    -- Função para pegar o nome do grupo do player
    getUserGroupByType = function(user_id,gtype)
        local user_groups = vRP.getUserGroups(user_id)
        for k,v in pairs(user_groups) do
            local kgroup = groups[k]
            if kgroup then
                if kgroup._config and kgroup._config.gtype and kgroup._config.gtype == gtype then
                    return kgroup._config.title
                end
            end
        end
        return ""
    end,

    dropItem = function(user_id,item,amout)
        if vRP.tryGetInventoryItem(user_id,item,amount) then
            local x,y,z = vRPclient.getPosition(vRP.getUserSource(user_id))
		    TriggerEvent("DropSystem:create",item,amout,x,y,z,3600)
        end
    end,

    giveItem = function(user_id,item,amount)
        vRP.giveInventoryItem(user_id,item,amount)
    end,

    tryItem = function(user_id,item,amount)
        return vRP.tryGetInventoryItem(user_id,item,amount)
    end,

    getItemAmount = function(user_id,item)
        return vRP.getInventoryItemAmount(user_id,item)
    end,

    getInventoryWeight = function(user_id)
        return vRP.getInventoryWeight(user_id)
    end,

    getInventory = function(user_id)
        return vRP.getInventory(user_id)
    end,

    playAnim = function(source,bool,table,bool2)
        vRPclient.playAnim(source,bool,table,bool2)
    end,

}

cfg.webhook = {
    trunkStore = "",
    trunkTake = "",

    homesTake = "",
    homesStore = "",

    usarItem = "",
    deleteItem = "",

    enviarItem = "",
    garmas = "",
    equipar = "",

    limparInventario = "",
    commandItem = "",

    shopComprar = "",
    shopVender = "",

    policiaArsenal = '',
}
----------------------------------------------------------------------
--- [ CORE - Primarias]
----------------------------------------------------------------------
cfg.dropItem = false
cfg.adminPermi  = 'admin.permissao'
cfg.policiapermissao = "policia.permissao"
cfg.medicopermissao = 'paramedico.permissao'

cfg.itens = {
    ['agua'] = { index = 'agua',nome = 'Agua',type = 'usar',peso = 1,desc = "Liquido incolor"},
    ['maconha'] = { index = 'maconha',nome = 'Maconha',type = 'usar',peso = 1, desc = "Planta amplamente utilizada em todo o mundo, tanto para uso medicinal como para uso recreativo."},
    ['cocaina'] = { index = 'cocaina',nome = 'Cocaina',type = 'usar',peso = 1, desc = "Estimulante, com efeitos anestésicos utilizada fundamentalmente como uma droga recreativa"},
    ['energetico'] = { index = 'energetico',nome = 'Energetico',type = 'usar',peso = 1, desc = "bebida não-alcóolicas que estimulam o metabolismo humano fornecendo a energia a quem bebe através da ingestão de taurina"},
    ['mochila'] = { index = 'mochila',nome = 'Mochila',type = 'usar',peso = 1, desc = "Um saco de lona ou tecido sintético resistente que é carregado nas costas de uma pessoa, e apoiada através de duas alças que passam por cima dos ombros"},
    ['metanfetamina'] = { index = 'metanfetamina',nome = 'Metanfetamina',type = 'usar',peso = 1, desc = "Uma substância psicoativa de ação estimulante do sistema nervoso central"},
    ------------------------
    --- [ ITENS DE FARM ILEGAL ]
    ------------------------
    ["bala"] = { index =  "bala",nome = 'Bala',type = 'usar',peso = 1,desc = "Projétil, e um componente da munição que é expelido do cano da arma durante o disparo"},
    ["corrente"] = { index =  "corrente",nome = 'Corrente',type = 'usar',peso = 1,desc = "A corrente é constituída por elos metálicos que se acoplam"},
    ["c4"] = { index =  "c4",nome = 'c4',type = 'usar',peso = 1,desc = "Composto formado por explosivos, ligantes, plastificantes e, geralmente marcado por detetores taggant, tal como este produto químico."},
    ["dinamite"] = { index =  "dinamite",nome = 'Dinamite',type = 'usar',peso = 1,desc = "É composta por nitroglicerina misturada a um material absorvente"},
    ["keyred"] = { index =  "keyRed",nome = 'Key Red',type = 'usar',peso = 1,desc = "Chave vermelha"},
    ["keyyellow"] = { index =  "keyyellow",nome = 'Key Yellow',type = 'usar',peso = 1,desc = "Chave amarela!"},
    ["keyblue"] = { index =  "keyblue",nome = 'Key Blue',type = 'usar',peso = 1,desc = "Chave azul"},
    ["keycard"] = { index =  "keycard",nome = 'Key Card',type = 'usar',peso = 1,desc = "Chave chave comum"},
    ["keypremium"] = { index =  "keypremium",nome = 'Key Premium',type = 'usar',peso = 1,desc = "Chave Premium"},
    ["cimakeypink"] = { index =  "cimakeypink",nome = 'Parte de cima da Key Pink',type = 'usar',peso = 1,desc = "Parte superior Key Pink"},
    ["baixokeypink"] = { index =  "baixokeypink",nome = 'Parte de baixo da Key Pink',type = 'usar',peso = 1,desc = "Parte inferior Key Pink"},
    ["keypink"] = { index =  "keypink",nome = 'Key Pink',type = 'usar',peso = 1,desc = "Chave rosa pronta para uso"},
    ["algemas"] = { index =  "algemas",nome = 'Algemas',type = 'usar',peso = 1,desc = "São dispositivos mecânicos destinados a manter presos os pulsos de uma pessoa"},
    ["serra"] = { index =  "serra",nome = 'Serra',type = 'usar',peso = 1,desc = "É uma ferramenta utilizada para cortar madeira, plásticos, metais ou outros materiais e consiste numa folha de aço com uma série de recortes num dos seus rebordos"},
    ["furadeira"] = { index =  "furadeira",nome = 'Furadeira',type = 'usar',peso = 1,desc = "É uma máquina que tem como função principal a execução de furos"},
    ["colete"] = { index =  "colete",nome = 'Colete',type = 'usar',peso = 1,desc = "São vestimentas especiais que protegem os utilizadores contra projéteis ou destroços de artefatos militares"},
    ["fogos"] = { index =  "fogos",nome = 'Fogos',type = 'usar',peso = 1,desc = "São explosivos de efeito pirotécnico ou sonoro feitos para fins de entretenimento, efeitos estéticos ou visuais"},
    ["skate"] = { index =  "skate",nome = 'Skate',type = 'usar',peso = 1,desc = "Shape, com quatro rodas pequenas e dois eixos chamados de “trucks”."},
    ["risebox"] = { index =  "risebox",nome = 'Rise Box',type = 'usar',peso = 1,desc = "Mate sua curriosidade e me abra !!!"},
    ["binoculos"] = { index =  "binoculos",nome = 'Binóculos',type = 'usar',peso = 1,desc = "É um instrumento óptico composto por lentes que possibilitam o alcance de visão"},
    ["capuz"] = { index =  "capuz",nome = 'Capuz',type = 'usar',peso = 1,desc = "Tecido para interferir na visão"},
    ["energetico"] = { index =  "energetico",nome = 'Energético',type = 'usar',peso = 1,desc = "bebida não-alcóolicas que estimulam o metabolismo humano fornecendo a energia a quem bebe através da ingestão de taurina"},
    ["masterpick"] = { index =  "masterpick",nome = 'Masterpick',type = 'usar',peso = 1,desc = "ferramenta profissonal para destracar carros"},
    ["lockpick"] = { index =  "lockpick",nome = 'Lockpick',type = 'usar',peso = 1,desc = "ferramenta para destracar carros"},
    ["mochila"] = { index =  "mochila",nome = 'Mochila',type = 'usar',peso = 1,desc = "Um saco de lona ou tecido sintético resistente que é carregado nas costas de uma pessoa, e apoiada através de duas alças que passam por cima dos ombros"},
    ["vaper"] = { index =  "vaper",nome = 'Vaper',type = 'usar',peso = 1,desc = "Cigarro eletronico, eleva a pressão sanguínea e causa picos de adrenalina"},
    ["radio"] = { index =  "radio",nome = 'Rádio',type = 'usar',peso = 1,desc = "É um aparelho de comunicações através de ondas eletromagnéticas propagadas no espaço"},
    ["radio2"] = { index =  "radio2",nome = 'Rádio',type = 'usar',peso = 1,desc = "É um aparelho de comunicações através de ondas eletromagnéticas propagadas no espaço"},
    ["celular"] = { index =  "celular",nome = 'Celular',type = 'usar',peso = 1,desc = "É um aparelho de comunicação por ondas eletromagnéticas que permite a transmissão bidirecional de voz"},
    ["celular2"] = { index =  "celular2",nome = 'Celular',type = 'usar',peso = 1,desc = "É um aparelho de comunicação por ondas eletromagnéticas que permite a transmissão bidirecional de voz"},
    ["laco"] = { index =  "laco",nome = 'Laço',type = 'usar',peso = 1,desc = "liga flexivel"},
    ["mascara"] = { index =  "mascara",nome = 'Máscara',type = 'usar',peso = 1,desc = "Estrutura plana, flexível e porosa, composto por grânulos de resina de Polipropileno"},
    ["mascara2"] = { index =  "mascara2",nome = 'Máscara',type = 'usar',peso = 1,desc = "Estrutura plana, flexível e porosa, composto por grânulos de resina de Polipropileno"},
    ["fios"] = { index =  "fios",nome = 'Fios',type = 'usar',peso = 1,desc = "Ligas de cobre"},
    ["plastico2"] = { index =  "plastico2",nome = 'Plásticos para Embalagem',type = 'usar',peso = 1,desc = "são materiais orgânicos poliméricos sintéticos, de constituição macromolecular, dotada de grande maleabilidade"},
    ["roupas"] = { index =  "roupas",nome = 'Roupas',type = 'usar',peso = 1,desc = "São objeto usado para cobrir partes do corpo"},
    ["roupas2"] = { index =  "roupas2",nome = 'Roupas',type = 'usar',peso = 1,desc = "São objeto usado para cobrir partes do corpo"},
    ["tecido"] = { index =  "tecido",nome = 'Tecido',type = 'usar',peso = 1,desc = "É um material à base de fios de fibra natural ou sintética"},
    ["placa"] = { index =  "placa",nome = 'Placa',type = 'usar',peso = 1,desc = "placa de aluminio de identifica veiculos"},
    ["raceticket"] = { index =  "raceticket",nome = 'Race Ticket',type = 'usar',peso = 1,desc = "Bilhete para correr"},
    ["anel"] = { index =  "anel",nome = 'Anel',type = 'usar',peso = 1,desc = "Objeto circular de ouro que pode ser colocado no dedo"},
    ["colar"] = { index =  "colar",nome = 'Colar',type = 'usar',peso = 1,desc = "objeto circular que pode ser colocado no pescoço"},
    ["tornozeleira"] = { index =  "tornozeleira",nome = 'Tornozeleira',type = 'usar',peso = 1,desc = "Cinto de rastreio"},
    ["anelb"] = { index =  "anelb",nome = 'Anel de Brilhante',type = 'usar',peso = 1,desc = "Objeto circular de ouro com pedra preciosa no meio que pode ser colocado no dedo "},
    ["pulseira"] = { index =  "pulseira",nome = 'Pulseira de Brilhante',type = 'usar',peso = 1,desc = "Conjunto de ligas de ouro em circulo com pedras preciosas"},
    ["relogio"] = { index =  "relogio",nome = 'Relógios',type = 'usar',peso = 1,desc = "Aparelhos que mostra as horas"},
    ["varadepesca"] = { index =  "varadepesca",nome = 'Vara de Pesca',type = 'usar',peso = 1,desc = "Vara para pescar peixes"},
    ["cartaodecredito"] = { index =  "cartaodecredito",nome = 'Cartao de Crédito',type = 'usar',peso = 1,desc = "Chip para fazer Transações"},
    ["casavip"] = { index =  "casavip",nome = 'Casa Vip',type = 'usar',peso = 1,desc = "Sua chave para sua casa VIP"},
    ["ticket"] = { index =  "ticket",nome = 'Ticket de Corrida de Carros',type = 'usar',peso = 1,desc = "Bilhete para fazer corrida explosiva de carro"},
    ["ticket2"] = { index =  "ticket2",nome = 'Ticket de Corrida de Motos',type = 'usar',peso = 1,desc = "Bilhete para fazer corrida explosiva de moto"},
    ["cimaticket"] = { index =  "cimaticket",nome = 'Parte de Cima do Ticket',type = 'usar',peso = 1,desc = "parte de cima do bilhete de corrida"},
    ["baixoticket"] = { index =  "baixoticket",nome = 'Parte de Baixo do Ticket',type = 'usar',peso = 1,desc = "parte de baixo do bilhete de corrida"},
    ["plastico"] = { index =  "plastico",nome = 'Plástico',type = 'usar',peso = 1,desc = "são materiais orgânicos poliméricos sintéticos, de constituição macromolecular, dotada de grande maleabilidade"},
    ["solvente"] = { index =  "solvente",nome = 'Solvente',type = 'usar',peso = 1,desc = "É um líquido incolor, de odor pouco acentuado, semelhante ao odor de querosene"},
    ["chip"] = { index =  "chip",nome = 'Chip Eletrônico',type = 'usar',peso = 1,desc = "Placa de armazenamento de informações"},
    ["polvora"] = { index =  "polvora",nome = 'Pólvora',type = 'usar',peso = 1,desc = "Pó que explosivo"},
    ["dinheiro"] = { index =  "dinheiro",nome = 'Dinheiro',type = 'usar',peso = 1,desc = "Papel de auto valor"},
    ["dinheirosujo"] = { index =  "dinheirosujo",nome = 'Dinheiro Marcado',type = 'usar',peso = 0.00001,desc = "Papel de auto valor manchado"},
    ["secador"] = { index =  "secador",nome = 'Secador',type = 'usar',peso = 1,desc = "ferramenta para secar"},
    ["radioqueimado"] = { index =  "radioqueimado",nome = 'Radio Queimado',type = 'usar',peso = 1,desc = "É um aparelho de comunicações com defeito"},
    ["celularqueimado"] = { index =  "celularqueimado",nome = 'Celular Queimado',type = 'usar',peso = 1,desc = "É um aparelho de comunicação com defeito"},
    ["mascaramolhada"] = { index =  "mascaramolhada",nome = 'Mascara Molhada',type = 'usar',peso = 1,desc = "Mascara impossivel de usar pois esta esopada"},
    ["roupamolhada"] = { index =  "roupamolhada",nome = 'Roupa Molhada',type = 'usar',peso = 1,desc = "Tecido para trocar de roupa molhada"},
    ["dinheiromolhado"] = { index =  "dinheiromolhado",nome = 'Dinheiro Molhado',type = 'usar',peso = 1,desc = "Papel de auto valor molhado"},
    ["aliancacasamento"] = { index =  "aliancacasamento",nome = 'Aliança de Casamento',type = 'usar',peso = 1,desc = "Objeto auto valor que faz união, ligação pelo matrimônio"},
    ------------------------
    --- [ ITENS ARMAS ]
    ------------------------
    ["molas"] = { index =  "molas",nome = 'Molas',type = 'usar',peso = 1,desc = "É um objeto elástico flexível usado para armazenar a energia mecânica."},  
    ["gatilho"] = { index =  "gatilho",nome = 'Gatilho',type = 'usar',peso = 1,desc = "É uma peça da arma de fogo que ao ser acionada"},
    ["canodearma"] = { index =  "canodearma",nome = 'Cano de Arma',type = 'usar',peso = 1,desc = "A alma é a parte oca do interior do cano de uma arma de fogo"},
    ["cartucho1"] = { index =  "cartucho1",nome = 'Cartucho de Pistola',type = 'usar',peso = 1,desc = "É a unidade de munição das armas de percussão e de retrocarga"},
    ["cartucho2"] = { index =  "cartucho2",nome = 'Cartucho de Submetralhadoras',type = 'usar',peso = 1,desc = "É a unidade de munição das armas de percussão e de retrocarga"},
    ["cartucho3"] = { index =  "cartucho3",nome = 'Cartucho de Fuzil',type = 'usar',peso = 1,desc = "É a unidade de munição das armas de percussão e de retrocarga"},
    ["projetil1"] = { index =  "projetil1",nome = 'Projetil de Pistola',type = 'usar',peso = 1,desc = "E um componente da munição que é expelido do cano da arma durante o disparo"},
    ["projetil2"] = { index =  "projetil2",nome = 'Projetil de Submetralhadoras',type = 'usar',peso = 1,desc = "E um componente da munição que é expelido do cano da arma durante o disparo"},
    ["projetil3"] = { index =  "projetil3",nome = 'Projetil de Fuzil',type = 'usar',peso = 1,desc = "E um componente da munição que é expelido do cano da arma durante o disparo"},
    ["aluminio"] = { index =  "aluminio",nome = 'Aluminio',type = 'usar',peso = 1,desc = "É um metal leve, macio, porém resistente, de aspecto metálico branco, que tem um revestimento fino de um óxido"},
    ["bronze2"] = { index =  "bronze2",nome = 'Placa de Bronze',type = 'usar',peso = 1,desc = "É uma série de ligas metálicas que tem como base o cobre e o estanho"},
    ["ferrolho"] = { index =  "ferrolho",nome = 'Ferrolho',type = 'usar',peso = 1,desc = "Designação da parte de uma arma de repetição"},
    ["cano"] = { index =  "cano",nome = 'Cano',type = 'usar',peso = 1,desc = " É o tubo reto por onde o tiro é efetuado e o projétil arremessado"},
    ["cobre"] = { index =  "cobre",nome = 'Fio de Cobre',type = 'usar',peso = 1,desc = "Liga de cobre"},
    ["mola2"] = { index =  "mola2",nome = 'Mola de Armas',type = 'usar',peso = 1,desc = "Liga flexivel de aço em forma espiral"},
    
    ["superiorhk"] = { index =  "superiorhk",nome = 'Parte Superior de HK',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiorhk"] = { index =  "inferiorhk",nome = 'Parte Inferior de HK',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["superiorfive"] = { index =  "superiorfive",nome = 'Parte Superior de Five',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiorfive"] = { index =  "inferiorfive",nome = 'Parte Inferior de five',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["superiorheavy"] = { index =  "superiorheavy",nome = 'Parte Superior de Heavy',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiorheavy"] = { index =  "inferiorheavy",nome = 'Parte Inferior de Heavy',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["superiorthompsom"] = { index =  "superiorthompsom",nome = 'Parte Superior de Thompsom',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiorthompsom"] = { index =  "inferiorthompsom",nome = 'Parte Inferior de Thompsom',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["superiormtar"] = { index =  "superiormtar",nome = 'Parte Superior de MTAR',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiormtar"] = { index =  "inferiormtar",nome = 'Parte Inferior de MTAR',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["superiorm4"] = { index =  "superiorm4",nome = 'Parte Superior de M4',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiorm4"] = { index =  "inferiorm4",nome = 'Parte Inferior de M4',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["superiorg36"] = { index =  "superiorg36",nome = 'Parte Superior de G36',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiorg36"] = { index =  "inferiorg36",nome = 'Parte Inferior de G36',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["superiorak"] = { index =  "superiorak",nome = 'Parte Superior de AK',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiorak"] = { index =  "inferiorak",nome = 'Parte Inferior de AK',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiorceramic"] = { index =  "inferiorceramic",nome = 'Parte Inferior de Ceramic Pistol',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["superiorceramic"] = { index =  "superiorceramic",nome = 'Parte Superior de Ceramic Pistol',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiortec"] = { index =  "inferiortec",nome = 'Parte Inferior de Tec',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["superiortec"] = { index =  "superiortec",nome = 'Parte Superior de Tec',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["superiormk2"] = { index =  "superiormk2",nome = 'Parte Superior de SMG MK2',type = 'usar',peso = 1,desc = "Componente de arma"},
    ["inferiormk2"] = { index =  "inferiormk2",nome = 'Parte Inferior de SMG MK2',type = 'usar',peso = 1,desc = "Componente de arma"},
    ------------------------
    --- [ DROGAS ]
    ------------------------
    ["folhadeopio"] = { index = "folhadeopio",nome = 'Folha de Opio',type = 'usar',peso = 1,desc = "É encontrado em forma de pó que é obtido do látex que é retirado da cápsula da papoula, ainda verde"},
    ["metanfetamina"] = { index = "metanfetamina",nome = 'Metanfetamina',type = 'usar',peso = 1,desc = "Substância psicoativa de ação estimulante do sistema nervoso central"},
    ["metanfetamina2"] = { index = "metanfetamina2",nome = 'Metanfetamina para Venda',type = 'usar',peso = 1,desc = "Substância psicoativa de ação estimulante do sistema nervoso central"},
    ["folhademaconha"] = { index =  "folhademaconha",nome = 'Folha de Maconha',type = 'usar',peso = 1,desc = "Eles são imparipinados com margens serrilhadas"},
    ["maconha"] = { index =  "maconha",nome = 'Maconha',type = 'usar',peso = 1,desc = "É uma planta que apresenta componentes que podem ser usados para fins medicinais, mas também apresenta substâncias que afetam o sistema nervoso"},
    ["maconha2"] = { index =  "maconha2",nome = 'Maconha Embalada',type = 'usar',peso = 1,desc = "É uma planta que apresenta componentes que podem ser usados para fins medicinais, mas também apresenta substâncias que afetam o sistema nervoso"},
    ["folhadecoca"] = { index =  "folhadecoca",nome = 'Folha de Coca',type = 'usar',peso = 1,desc = "É uma planta da família Erythroxylaceae"},
    ["cocaina"] = { index =  "cocaina",nome = 'Cocaina',type = 'usar',peso = 1,desc = "É uma substância natural, extraída das folhas de uma planta"},
    ["cocaina2"] = { index =  "cocaina2",nome = 'Cocaina para Venda',type = 'usar',peso = 1,desc = "Cocaina embalada"},
   ------------------------
    --- [ LOJAS ]
    ------------------------
    ["alianca"] = { index =  "alianca",nome = 'Alianca',type = 'usar',peso = 1,desc = "Representação de amor"},
    ["buque"] = { index =  "buque",nome = 'Buque',type = 'usar',peso = 1,desc = "Conjunto de flores"},
    ["rosa"] = { index =  "rosa",nome = 'Rosa',type = 'usar',peso = 1,desc = "flor com petolas vermelhas"},
    ["ursinho"] = { index =  "ursinho",nome = 'Ursinho',type = 'usar',peso = 1,desc = "Urso de pelúcia"},
    ["isca"] = { index =  "isca",nome = 'Isca',type = 'usar',peso = 1,desc = "Isca para pesca"},
    ["repairkit"] = { index =  "repairkit",nome = 'Kit de Reparo',type = 'usar',peso = 1,desc = "Reparo para o seu veículo"},
    ["militec"] = { index =  "militec",nome = 'Militec',type = 'usar',peso = 1,desc = "Reparo no motor do veículo"},
    ------------------------
    --- [ COMIDAS / BEBIDAS ]
    ------------------------
    ['sanduiche'] = { index = 'sanduiche',nome = 'Sanduiche',type = 'usar',peso = 1,desc = "É um tipo de alimento que consiste em duas fatias de um pão inteiro, entre as quais é colocada carne, queijo ou outro tipo de alimento"},
    ['donuts'] = { index = 'donuts',nome = 'Donuts',type = 'usar',peso = 1,desc = "Rosca ou rosquinha é um pequeno bolo em forma de rosca"},
    ['hotdog'] = { index = 'hotdog',nome = 'Hotdog',type = 'usar',peso = 1,desc = "Alimento em que se coloca salsicha dentro de um pão sovado."},
    ['refrigerante'] = { index = 'refrigerante',nome = 'Refrigerante',type = 'usar',peso = 1,desc = "bebida que mistura corantes, conservantes, açúcar, aroma sintético de fruta e gás carbônico."},
    ['cafe'] = { index = 'cafe',nome = 'Café',type = 'usar',peso = 1,desc = "grãos torrados do fruto do cafeeiro"},
    ['sucolaranja'] = { index = 'sucolaranja',nome = 'Suco de Laranja',type = 'usar',peso = 1,desc = "Suco natural de Laranja"},
    ['absolut'] = { index = 'absolut',nome = 'Absolut',type = 'usar',peso = 1,desc = "Bebidas alcoólicas"},
    ['chandon'] = { index = 'chandon',nome = 'Chandon',type = 'usar',peso = 1,desc = "Bebidas alcoólicas"},
    ['garrafavazia'] = { index = 'garrafavazia',nome = 'Garrafa Vazia',type = 'usar',peso = 1,desc = "Bebidas alcoólicas"},
    ['xtudo'] = { index = 'xtudo',nome = 'X-tudo',type = 'usar',peso = 1,desc = "É um tipo de alimento que consiste em duas fatias de um pão inteiro, entre as quais é colocada carne, queijo ou outro tipo de alimento!"},
    ['pizza'] = { index = 'pizza',nome = 'Pizza',type = 'usar',peso = 1,desc = "Massa reachado com queijo, juntamente com molho de tomate"},
    ['pao'] = { index = 'pao',nome = 'Pão',type = 'usar',peso = 1,desc = "Alimento elaborado com farinha de trigo"},
    ['miojo'] = { index = 'miojo',nome = 'Miojo',type = 'usar',peso = 1,desc = "Macarrão instantâneo"},
    ['skolbeats'] = { index = 'skolbeats',nome = 'Skol beats',type = 'usar',peso = 1,desc = "Bebidas alcoólicas!"},
    ['gin'] = { index = 'gin',nome = 'Gin',type = 'usar',peso = 1,desc = "Bebida alcoólica!"},
    ['cerveja'] = { index = 'cerveja',nome = 'Cerveja',type = 'usar',peso = 1,desc = "bebidas alcoólicas"},
    ['aguadecoco'] = { index = 'aguadecoco',nome = 'Agua de coco',type = 'usar',peso = 1,desc = "Água extraída do coco"},
    ['vitamina'] = { index = 'vitamina',nome = 'Vitamina',type = 'usar',peso = 1,desc = "Bebida que ajuda seu metabolismo"},
    ['h2o'] = { index = 'h2o',nome = 'H2o',type = 'usar',peso = 1,desc = "Refrigerante"},
    ['itubaina'] = { index = 'itubaina',nome = 'Itubaina',type = 'usar',peso = 1,desc = "Refrigente"},
    ['taco'] = { index = 'taco',nome = 'Taco',type = 'usar',peso = 1,desc = "Comida típica do México"},
    ["whisky"] = { index =  "whisky",nome = 'whisky',type = 'usar',peso = 1,desc = "Bebidas alcoólicas"},
    ["vodka"] = { index =  "vodka",nome = 'vodka',type = 'usar',peso = 1,desc = "Bebidas alcoólicas"},
    ["tequila"] = { index =  "tequila",nome = 'tequila',type = 'usar',peso = 1,desc = "Bebidas alcoólicas"},
    ["conhaque"] = { index =  "conhaque",nome = 'conhaque',type = 'usar',peso = 1,desc = "Bebidas alcoólicas"},
    ["absinto"] = { index =  "absinto",nome = 'absinto',type = 'usar',peso = 1,desc = "Bebidas alcoólicas"},
    ["chocolate"] = { index =  "chocolate",nome = 'chocolate',type = 'usar',peso = 1,desc = "Doce extraído do cacau"},
    ["hamburguer"] = { index =  "hamburguer",nome = 'hamburguer',type = 'usar',peso = 1,desc = "É um tipo de alimento que consiste em duas fatias de um pão inteiro, entre as quais é colocada carne, queijo ou outro tipo de alimento!"},
    ["papinha"] = { index =  "papinha",nome = 'papinha',type = 'usar',peso = 1,desc = "Alimento destinado a bebes"},
    ["agua"] = { index =  "agua",nome = 'agua',type = 'usar',peso = 1,desc = "Melhor liquido para matar sua sede"},
    ------------------------
    --- [ ITENS EMPREGOS ]
    ------------------------
    ["peixe"] = { index =  "peixe",nome = 'peixe',type = 'usar',peso = 1,desc = "Salmão"},
    ["peixe2"] = { index =  "peixe2",nome = 'peixe2',type = 'usar',peso = 1,desc = "Tilápia!"},
    ["peixe3"] = { index =  "peixe3",nome = 'peixe3',type = 'usar',peso = 1,desc = "Sardinha"},
    ["peixe4"] = { index =  "peixe4",nome = 'peixe4',type = 'usar',peso = 1,desc = "Atum"},
    ["peixe5"] = { index =  "peixe5",nome = 'peixe5',type = 'usar',peso = 1,desc = "Merluza"},
    ["peixe6"] = { index =  "peixe6",nome = 'peixe6',type = 'usar',peso = 1,desc = "Corvina"},
    ["peixe7"] = { index =  "peixe7",nome = 'peixe7',type = 'usar',peso = 1,desc = "Bacalhau!"},
    
    ["bronze"] = { index =  "bronze",nome = 'bronze',type = 'usar',peso = 1,desc = "É uma série de ligas metálicas que tem como base o cobre e o estanho"},
    ["prata"] = { index =  "prata",nome = 'prata',type = 'usar',peso = 1,desc = "É um subproduto da mineração de chumbo e está frequentemente associada ao cobre"},
    ["ouro"] = { index =  "ouro",nome = 'ouro',type = 'usar',peso = 1,desc = "É um metal de transição brilhante"},
    ["topazio"] = { index =  "topazio",nome = 'topazio',type = 'usar',peso = 1,desc = "seu propósito é trazer uma nova vida com cargas positivas"},
    ["quartzo"] = { index =  "quartzo",nome = 'quartzo',type = 'usar',peso = 1,desc = "Tem muitas propriedades energéticas para limpeza e cura do corpo como um todo"},
    ["turmalina"] = { index =  "turmalina",nome = 'turmalina',type = 'usar',peso = 1,desc = "complexos grupos de silicato quanto à sua composição química"},
    ["laranja"] = { index =  "laranja",nome = 'laranja',type = 'usar',peso = 1,desc = "Fruta"},
    
    ["caixadeferramenta"] = { index =  "caixadeferramenta",nome = 'Caixa de ferramenta',type = 'usar',peso = 1,desc = "Kit de ferramentas, reparo de veiculo"},
    ["chavederoda"] = { index =  "chavederoda",nome = 'Chave de roda',type = 'usar',peso = 1,desc = "Retirar e recolocar os parafusos"},
    ["graxa"] = { index =  "graxa",nome = 'graxa',type = 'usar',peso = 1,desc = "Função de lubrificar máquinas e equipamentos"},
    ["oleo"] = { index =  "oleo",nome = 'oleo',type = 'usar',peso = 1,desc = "Pertencem ao grupo dos lipídios"},
    ["parafusos"] = { index =  "parafusos",nome = 'parafusos',type = 'usar',peso = 1,desc = "Prego de cabeça chata e sulcado em forma de rosca que fixa com maior segurança"},
    ["spray"] = { index =  "spray",nome = 'spray',type = 'usar',peso = 1,desc = "Jato de gás ou líquido em mínimas gotículas"},
    ["pneu"] = { index =  "pneu",nome = 'pneu',type = 'usar',peso = 1,desc = "Elástico que se prende à jante das rodas de certos veículos"},
    ------------------------
    --- [ HOSPITAL ]
    ------------------------
    ["azitromicina"] = { index =  "azitromicina",nome = 'azitromicina',type = 'usar',peso = 1,desc = "Antibiótico de amplo espectro que pertence ao grupo dos macrólidos"},
    ["bandagem"] = { index =  "bandagem",nome = 'bandagem',type = 'usar',peso = 1,desc = "Elástica garante conforto e adaptação"},
    ["buscopam"] = { index =  "buscopam",nome = 'buscopam',type = 'usar',peso = 1,desc = "Para o tratamento dos sintomas de cólicas intestinais"},
    ["camisinha"] = { index =  "camisinha",nome = 'camisinha',type = 'usar',peso = 1,desc = "Prevenir contra doenças sexualmente transmissíveis"},
    ["dipiroca"] = { index =  "dipiroca",nome = 'dipiroca',type = 'usar',peso = 1,desc = "Monoidratada é analgésico para dor e antitérmico para febre."},
    ["dorflex"] = { index =  "dorflex",nome = 'dorflex',type = 'usar',peso = 1,desc = "Alívio da dor associada a contraturas musculares"},
    ["glucanal"] = { index =  "glucanal",nome = 'glucanal',type = 'usar',peso = 1,desc = "Aumentar a imunidade"},
    ["ibuprofeno"] = { index =  "ibuprofeno",nome = 'ibuprofeno',type = 'usar',peso = 1,desc = "Em casos dores discretas e moderadas"},
    ["novalgina"] = { index =  "novalgina",nome = 'novalgina',type = 'usar',peso = 1,desc = "Medicamento de ação analgésica, indicado para o tratamento de dores em geral"},
    ["paracetamol"] = { index =  "paracetamol",nome = 'paracetamol',type = 'usar',peso = 1,desc = "dor de cabeça, dor no corpo, dor de dente, dor nas costas, dores musculares"},
    ["xerelto"] = { index =  "xerelto",nome = 'xerelto',type = 'usar',peso = 1,desc = "Medícamento para doenças graves e sangramentos"},
    ["medkit"] = { index =  "medkit",nome = 'medkit',type = 'usar',peso = 1,desc = "Primeiros socorros"},
    ["psicotropico"] = { index =  "psicotropico",nome = 'psicotropico',type = 'usar',peso = 1,desc = "Altera a função cerebral e temporariamente muda a percepção"},
    ["antialergico"] = { index =  "antialergico",nome = 'antialergico',type = 'usar',peso = 1,desc = "Tratar reações alérgicas"},
    ["merthiolate"] = { index =  "merthiolate",nome = 'merthiolate',type = 'usar',peso = 1,desc = "Desinfecção e limpeza"},
    ["analgesico"] = { index =  "analgesico",nome = 'analgesico',type = 'usar',peso = 1,desc = "Anti-inflamatório"},
    ["anador"] = { index =  "anador",nome = 'anador',type = 'usar',peso = 1,desc = "tratamento da dor e febre"},
    ["oxidodeferro"] = { index =  "oxidodeferro",nome = 'oxidodeferro',type = 'usar',peso = 1,desc = " utilizados como pigmentos baratos e duráveis em tintas"},
    ["lactosemonoidratada"] = { index =  "lactosemonoidratada",nome = 'lactosemonoidratada',type = 'usar',peso = 1,desc = " substância usada em diversos medicamentos homeopáticos"},
    ["capsulagelatinosa"] = { index =  "capsulagelatinosa",nome = 'Capsula gelatinosa',type = 'usar',peso = 1,desc = " veiculação de fármacos por via oral"},
    ["diazepam"] = { index =  "diazepam",nome = 'diazepam',type = 'usar',peso = 1,desc = "Medicamento ansiolítico da classe dos benzodiazepínicos"},
    ["rivotril"] = { index =  "rivotril",nome = 'rivotril',type = 'usar',peso = 1,desc = "Medicamento ansiolítico"},
    ["fluoxetina"] = { index =  "fluoxetina",nome = 'fluoxetina',type = 'usar',peso = 1,desc = "Tratar a ansiedade e a depressão"},
    ["bandaid"] = { index =  "bandaid",nome = 'bandaid',type = 'usar',peso = 1,desc = "Proteger pequenos ferimentos"},
    ["bandaidbob"] = { index =  "bandaidbob",nome = 'bandaidbob',type = 'usar',peso = 1,desc = "Proteger pequenos ferimentos"},
    ["bandaidmagicos"] = { index =  "bandaidmagicos",nome = 'bandaid dos padrinhos magicos',type = 'usar',peso = 1,desc = "Proteger pequenos ferimentos"},
    ["bandaidnaruto"] = { index =  "bandaidnaruto",nome = 'bandaid do naruto',type = 'usar',peso = 1,desc = "Proteger pequenos ferimentos"},
    ["bandaidpoly"] = { index =  "bandaidpoly",nome = 'bandaid da poly',type = 'usar',peso = 1,desc = "Proteger pequenos ferimentos"},
    ["bisturi"] = { index =  "bisturi",nome = 'bisturi',type = 'usar',peso = 1,desc = "Instrumento cirúrgico"},
    ["seringa2"] = { index =  "seringa2",nome = 'seringa2',type = 'usar',peso = 1,desc = "Equipamento de bombeamento"},
    ["piluladodiaseguinte"] = { index =  "piluladodiaseguinte",nome = 'pilula do dia seguinte',type = 'usar',peso = 1,desc = "Pode evitar a gravidez após a relação sexual"},
    ["piluladoesquecimento"] = { index =  "piluladoesquecimento",nome = 'pilula do esquecimento',type = 'usar',peso = 1,desc = "Pessoas que passaram por situação traumática"},
    ------------------------
    --- [ PISTOLAS ]
    ------------------------
    ['wbody|WEAPON_SNSPISTOL'] =  {index = 'WEAPON_SNSPISTOL',nome = 'HK',type = 'equipar',peso = 6, desc = "Hk."},
    ['wammo|WEAPON_SNSPISTOL'] =  {index = 'm-snspistol',nome = 'Municao de HK',type = 'recarregar',peso = 0.01, desc = "Munição de Hk."},

    ['wbody|WEAPON_VINTAGEPISTOL'] =  {index = 'WEAPON_VINTAGEPISTOL',nome = 'Vintage Pistol',type = 'equipar',peso = 6.5, desc = "Vintage Pistol."},
    ['wammo|WEAPON_VINTAGEPISTOL'] =  {index = 'm-vintagepistol',nome = 'Municao de Vintage Pistol',type = 'recarregar',peso = 0.02, desc = "Munição de Vintage Pistol."},

    ['wbody|WEAPON_PISTOL'] =  {index = 'WEAPON_PISTOL',nome = 'M1911',type = 'equipar',peso = 6.5, desc = "M1911."},
    ['wammo|WEAPON_PISTOL'] =  {index = 'm-pistol',nome = 'Municao de M1911',type = 'recarregar',peso = 0.03, desc = "Munição de M1911."},

    ['wbody|WEAPON_PISTOL_MK2'] =  {index = 'WEAPON_PISTOL_MK2',nome = 'Five Seven',type = 'equipar',peso = 7.5, desc = "Five Seven."},
    ['wammo|WEAPON_PISTOL_MK2'] =  {index = 'm-pistolmk2',nome = 'Municao de Five Seven',type = 'recarregar',peso = 0.05, desc = "Munição de Five Seven."},

    ['wbody|WEAPON_CERAMICPISTOL'] =  {index = 'WEAPON_CERAMICPISTOL',nome = 'Ceramic Pistol',type = 'equipar',peso = 5, desc = "Ceramic Pistol."},
    ['wammo|WEAPON_CERAMICPISTOL'] =  {index = 'm-ceramicpistol',nome = 'Municao de Ceramic Pistol',type = 'recarregar',peso = 0.05, desc = "Munição de Ceramic Pistol."},

    ['wbody|WEAPON_HEAVYPISTOL'] =  {index = 'WEAPON_HEAVYPISTOL',nome = 'HEAVY PISTOL',type = 'equipar',peso = 7.5, desc = "HEAVY PISTOL."},
    ['wammo|WEAPON_HEAVYPISTOL'] =  {index = 'm-heavypistol',nome = 'Municao de HEAVY',type = 'recarregar',peso = 0.05, desc = "Munição de HEAVY PISTOL."},

    ['wbody|WEAPON_COMBATPISTOL'] =  {index = 'WEAPON_COMBATPISTOL',nome = 'Glock',type = 'equipar',peso = 5, desc = "Glock 18."},
    ['wammo|WEAPON_COMBATPISTOL'] =  {index = 'm-glock',nome = 'Municao de Glock',type = 'recarregar',peso = 0.05, desc = "Glock 18."},

    ['wbody|WEAPON_REVOLVER'] =  {index = 'WEAPON_REVOLVER',nome = 'Revolver',type = 'equipar',peso = 10, desc = "Revolver."},
    ['wammo|WEAPON_REVOLVER'] =  {index = 'm-revolver',nome = 'Municao de Revolver',type = 'recarregar',peso = 0.25, desc = "Munição de Revolver."},

    ['wbody|WEAPON_REVOLVER_MK2'] =  {index = 'WEAPON_REVOLVER_MK2',nome = 'Revolver Mk2',type = 'equipar',peso = 10.5, desc = "Revolver Mk2."},
    ['wammo|WEAPON_REVOLVER_MK2'] =  {index = 'm-revolvermk2',nome = 'Municao de Revolver Mk2',type = 'recarregar',peso = 0.35, desc = "Munição de Revolver Mk2."},

    ------------------------
    --- [ SUBMETRALHADORAS ]
    ------------------------
    ['wbody|WEAPON_SMG'] =  {index = 'WEAPON_SMG',nome = 'MP5',type = 'equipar',peso = 8, desc = "MP5."},
    ['wammo|WEAPON_SMG'] =  {index = 'm-smg',nome = 'Municao de MP5',type = 'recarregar',peso = 0.08, desc = "Munição de MP5."},

    ['wbody|WEAPON_SMG_MK2'] =  {index = 'WEAPON_SMG_MK2',nome = 'Smg Mk2',type = 'equipar',peso = 8, desc = "Smg Mk2."},
    ['wammo|WEAPON_SMG_MK2'] =  {index = 'm-smgmk2',nome = 'Municao de Smg Mk2',type = 'recarregar',peso = 0.08, desc = "Munição de Smg Mk2."},

    ['wbody|WEAPON_MINISMG'] =  {index = 'WEAPON_MINISMG',nome = 'Skorpion',type = 'equipar',peso = 9, desc = "Skorpion."},
    ['wammo|WEAPON_MINISMG'] =  {index = 'm-minismg',nome = 'Municao de Skorpion',type = 'recarregar',peso = 0.08, desc = "Munição de Skorpion."},

    ['wbody|WEAPON_MICROSMG'] =  {index = 'WEAPON_MICROSMG',nome = 'Uzi',type = 'equipar',peso = 9.5, desc = "Uzi."},
    ['wammo|WEAPON_MICROSMG'] =  {index = 'm-microsmg',nome = 'Municao de Uzi',type = 'recarregar',peso = 0.08, desc = "Munição de Uzi."},

    ['wbody|WEAPON_COMBATPDW'] =  {index = 'WEAPON_COMBATPDW',nome = 'Sig Sauer',type = 'equipar',peso = 9.5, desc = "Sig Sauer."},
    ['wammo|WEAPON_COMBATPDW'] =  {index = 'm-sigsauer',nome = 'Municao de Sig Sauer',type = 'recarregar',peso = 0.08, desc = "Munição de Sig Sauer."},

    ['wbody|WEAPON_ASSAULTSMG'] =  {index = 'WEAPON_ASSAULTSMG',nome = 'MTAR',type = 'equipar',peso = 9.5, desc = "MTAR."},
    ['wammo|WEAPON_ASSAULTSMG'] =  {index = 'm-assaultsmg',nome = 'Municao de MTAR',type = 'recarregar',peso = 0.08, desc = "Municao de MTAR."},

    ['wbody|WEAPON_COMBATMG'] =  {index = 'WEAPON_COMBATMG',nome = 'M60',type = 'equipar',peso = 15.5, desc = "M60."},
    ['wammo|WEAPON_COMBATMG'] =  {index = 'm-combatmg',nome = 'Municao de M60',type = 'recarregar',peso = 0.50, desc = "Munição de M60."},

    ['wbody|WEAPON_GUSENBERG'] =  {index = 'WEAPON_GUSENBERG',nome = 'Thompsom',type = 'equipar',peso = 10.5, desc = "Thompsom."},
    ['wammo|WEAPON_GUSENBERG'] =  {index = 'm-thompson',nome = 'Municao de Thompsom',type = 'recarregar',peso = 0.08, desc = "Munição de Thompsom."},
    
    ------------------------
    --- [ FUZIS ]
    ------------------------
    ['wbody|WEAPON_ASSAULTRIFLE'] =  {index = 'WEAPON_ASSAULTRIFLE',nome = 'AK47',type = 'equipar',peso = 10, desc = "AK-47."},
    ['wammo|WEAPON_ASSAULTRIFLE'] =  {index = 'm-ak47',nome = 'Municao de AK47',type = 'recarregar',peso = 0.10, desc = "Munição de Ak-47."},

    ['wbody|WEAPON_ASSAULTRIFLE_MK2'] =  {index = 'WEAPON_ASSAULTRIFLE_MK2',nome = 'AK47 Mk2',type = 'equipar',peso = 12, desc = "AK-47 Mk2."},
    ['wammo|WEAPON_ASSAULTRIFLE_MK2'] =  {index = 'm-ak47mk2',nome = 'Municao de AK47 Mk2',type = 'recarregar',peso = 0.15, desc = "Munição de Ak-47 MK2."},

    ['wbody|WEAPON_CARBINERIFLE'] = {index = 'WEAPON_CARBINERIFLE',nome = "M4A1",type = 'equipar',peso = 12, desc = "M4A1."},
    ['wammo|WEAPON_CARBINERIFLE'] = {index = 'm-m4a1',nome = "Munição de M4A1",type = 'recarregar',peso = 0.15, desc = "Munição de M4A1."},

    ['wbody|WEAPON_CARBINERIFLE_MK2'] = {index = 'WEAPON_CARBINERIFLE_MK2',nome = "M4A1 Mk2",type = 'equipar',peso = 15, desc = "M4A1."},
    ['wammo|WEAPON_CARBINERIFLE_MK2'] = {index = 'm-m4a1mk2',nome = "Munição de M4A1 Mk2",type = 'recarregar',peso = 0.15, desc = "Munição de M4A1 Mk2."},

    ['wbody|WEAPON_ADVANCEDRIFLE'] = {index = 'WEAPON_ADVANCEDRIFLE',nome = "Rifle Avançado",type = 'equipar',peso = 15, desc = "Rifle Avançado."},
    ['wammo|WEAPON_ADVANCEDRIFLE'] = {index = 'm-advancedrifle',nome = "Munição de Rifle Avançado",type = 'recarregar',peso = 0.15, desc = "Munição de Rifle Avançado."},

    ['wbody|WEAPON_MILITARYRIFLE'] = {index = 'WEAPON_MILITARYRIFLE',nome = "Fuzil Militar",type = 'equipar',peso = 10, desc = "Fuzil Militar."},
    ['wammo|WEAPON_MILITARYRIFLE'] = {index = 'm-militaryrifle',nome = "Munição de Fuzil Militar",type = 'recarregar',peso = 0.15, desc = "Munição de Fuzil Militar."},

    ['wbody|WEAPON_COMPACTRIFLE'] = {index = 'WEAPON_COMPACTRIFLE',nome = "Mini Draco",type = 'equipar',peso = 7.5, desc = "Mini Draco."},
    ['wammo|WEAPON_COMPACTRIFLE'] = {index = 'm-compactrifle',nome = "Munição de Mini Draco",type = 'recarregar',peso = 0.15, desc = "Munição de Mini Draco."},

    ['wbody|WEAPON_SPECIALCARBINE'] = {index = 'WEAPON_SPECIALCARBINE',nome = "G36",type = 'equipar',peso = 10, desc = "G36."},
    ['wammo|WEAPON_SPECIALCARBINE'] = {index = 'm-g36',nome = "Munição de G36",type = 'recarregar',peso = 0.15, desc = "Munição de G36."},

    ['wbody|WEAPON_SPECIALCARBINE_MK2'] = {index = 'WEAPON_SPECIALCARBINE_MK2',nome = "G36 Mk2",type = 'equipar',peso = 10, desc = "G36 Mk2."},
    ['wammo|WEAPON_SPECIALCARBINE_MK2'] = {index = 'm-g36mk2',nome = "Munição de G36 Mk2",type = 'recarregar',peso = 0.15, desc = "Munição de G36 Mk2."},

    ------------------------
    --- [ SHOTGUNS ]
    ------------------------
    ['wbody|WEAPON_PUMPSHOTGUN'] = {index = 'WEAPON_PUMPSHOTGUN',nome = "Shotgun",type = 'equipar',peso = 7.5, desc = "Shotgun."},
    ['wammo|WEAPON_PUMPSHOTGUN'] = {index = 'm-pumpshotgun',nome = "Munição de Shotgun",type = 'recarregar',peso = 0.25, desc = "Munição de Shotgun."},
    
    ['wbody|WEAPON_PUMPSHOTGUN_MK2'] = {index = 'WEAPON_PUMPSHOTGUN_MK2',nome = "Shotgun Mk2",type = 'equipar',peso = 7.5, desc = "Shotgun Mk2."},
    ['wammo|WEAPON_PUMPSHOTGUN_MK2'] = {index = 'm-pumpshotgunmk2',nome = "Munição de Shotgun Mk2",type = 'recarregar',peso = 0.25, desc = "Munição de Shotgun Mk2."},

    ['wbody|WEAPON_BULLPUPSHOTGUN'] = {index = 'WEAPON_BULLPUPSHOTGUN',nome = "Bullshotgun",type = 'equipar',peso = 7.5, desc = "Bullshotgun."},
    ['wammo|WEAPON_BULLPUPSHOTGUN'] = {index = 'm-bullshotgun',nome = "Munição de Bullshotgun",type = 'recarregar',peso = 0.25, desc = "Munição de Bullshotgun."},

    ------------------------
    --- [ ARMAS BRANCAS ]
    ------------------------
    ['wbody|WEAPON_STUNGUN'] = {index = 'WEAPON_STUNGUN',nome = "Taser",type = 'equipar',peso = 5, desc = "Taser."},
    ['wammo|WEAPON_STUNGUN'] = {index = 'm-stungun',nome = "Munição de Taser",type = 'recarregar',peso = 0.01, desc = "Munição de Taser."},

    ['wbody|GADGET_PARACHUTE'] = {index = 'GADGET_PARACHUTE',nome = "Paraquedas",type = 'equipar',peso = 5, desc = "Paraquedas."},
    ['wammo|GADGET_PARACHUTE'] = {index = 'm-paraquedas',nome = "Munição de Paraquedas",type = 'recarregar',peso = 0.01, desc = "Munição de Paraquedas."},

    ['wbody|WEAPON_FIREEXTINGUISHER'] = {index = 'WEAPON_FIREEXTINGUISHER',nome = "Extintor",type = 'equipar',peso = 5, desc = "Extintor."},
    ['wammo|WEAPON_FIREEXTINGUISHER'] = {index = 'm-extintor',nome = "Munição de Extintor",type = 'recarregar',peso = 0.01, desc = "Munição de Extintor."},

    ['wbody|WEAPON_DAGGER'] = {index = 'WEAPON_DAGGER',nome = "Adaga",type = 'equipar',peso = 7, desc = "Adaga."},
    ['wbody|WEAPON_BAT']    = {index = 'WEAPON_DAGGER',nome = "Bastão",type = 'equipar',peso = 7, desc = "Bastão."},
    ['wbody|WEAPON_BOTTLE'] = {index = 'WEAPON_DAGGER',nome = "Garrafa Quebrada",type = 'equipar',peso = 7, desc = "Garrafa Quebrada."},
    ['wbody|WEAPON_FLASHLIGHT'] = {index = 'WEAPON_DAGGER',nome = "Lanterna",type = 'equipar',peso = 7, desc = "Lanterna."},
    ['wbody|WEAPON_GOLFCLUB'] = {index = 'WEAPON_DAGGER',nome = "Taco de Golf",type = 'equipar',peso = 7, desc = "Taco de Golf."},
    ['wbody|WEAPON_CROWBAR'] = {index = 'WEAPON_CROWBAR',nome = "Pé de Cabra",type = 'equipar',peso = 7, desc = "Pé de Cabra."},
    ['wbody|WEAPON_HAMMER'] = {index = 'WEAPON_DAGGER',nome = "Martelo",type = 'equipar',peso = 7, desc = "Martelo."},
    ['wbody|WEAPON_HATCHET'] = {index = 'WEAPON_DAGGER',nome = "Machadinha",type = 'equipar',peso = 7, desc = "Machadinha."},
    ['wbody|WEAPON_KNUCKLE'] = {index = 'WEAPON_DAGGER',nome = "Soco Inglês",type = 'equipar',peso = 7, desc = "Soco Inglês."},
    ['wbody|WEAPON_KNIFE'] = {index = 'WEAPON_DAGGER',nome = "Faca",type = 'equipar',peso = 7, desc = "Faca."},
    ['wbody|WEAPON_MACHETE'] = {index = 'WEAPON_DAGGER',nome = "Machete",type = 'equipar',peso = 7, desc = "Machete."},
    ['wbody|WEAPON_SWITCHBLADE'] = {index = 'WEAPON_DAGGER',nome = "Canivete",type = 'equipar',peso = 7, desc = "Canivete."},
    ['wbody|WEAPON_NIGHTSTICK'] = {index = 'WEAPON_DAGGER',nome = "Cacetete",type = 'equipar',peso = 7, desc = "Cacetete."},
    ['wbody|WEAPON_WRENCH'] = {index = 'WEAPON_DAGGER',nome = "Chave Inglesa",type = 'equipar',peso = 7, desc = "Chave Inglesa."},
    ['wbody|WEAPON_BATTLEAXE'] = {index = 'WEAPON_DAGGER',nome = "Machado de Batalha",type = 'equipar',peso = 7, desc = "Machado de Batalha."},
    ['wbody|WEAPON_POOLCUE'] = {index = 'WEAPON_DAGGER',nome = "Taco de Sinuca",type = 'equipar',peso = 7, desc = "Taco de Sinuca."},
    ['wbody|WEAPON_STONE_HATCHET'] = {index = 'WEAPON_DAGGER',nome = "Machado de Pedra",type = 'equipar',peso = 7, desc = "Machado de Pedra."},
}
----------------------------------------------------------------------
--- [ Confiuração para shop ]
----------------------------------------------------------------------
cfg.departamento = {
    ['lojas'] = {
        permissao = nil, -- nil é para todos poderem acessar
        itens = {
            ['maconha'] = {comprar = 5000,vender = 2000},
            ['agua'] = {comprar = 1000,vender = 500},   
        }
    },

    ['ammo'] = {
        permissao = nil,
        itens = {
            ['maconha'] = {comprar = 5000,vender = 2000},
            ['agua'] = {comprar = 1000,vender = 500},   
        }
    },

    ['arsenal'] = {
        permissao = 'admin.permissao',
        itens = {
            ['WEAPON_COMBATPISTOL'] = {comprar = 0,vender = 0,municao = 200},
        }
    }
}

cfg.arsenalTypes = {
    ['arsenal'] = true
}

----------------------------------------------------------------------
--- [ Blacklist de itens que nao podem ser guardados]
----------------------------------------------------------------------
cfg.blacklist = {
    ['homes'] = {
        ['identidade'] = 'identidade',
    },
    ['chest'] = {
        ['identidade'] = 'identidade',
    },
    ['trunk'] = {
        ['dinheirosujo'] = 'dinheirosujo',
    },
    ['enviar'] = {
        ['dinheirosujo'] = 'dinheirosujo',
    }
}

cfg.antifload = true


----------------------------------------------------------------------
--- [ Confiuração para trunk chest ]
----------------------------------------------------------------------
cfg.vehInfo = function(source,radius)
	local vehicle,vnetid,placa,vname,lock,banned,trunk = vRPclient.vehList(source,radius)
	return vehicle,vnetid,placa,vname,lock,banned,trunk
end

-- [ Sempre que chamada retorna data.                                ]
-- [ user_id = ID do dono do carro | vname = Nome do spaw do veiculo.]
cfg.getTrunkChest = function(user_id,vname)
    local chest = "chest:u"..user_id.."veh_"..vname
    local data = json.decode(vRP.getSData(chest)) or {}
    return data
end

------------------------------------------------------------------------------------
-- [ Salva na db o porta malas do veiculo.                                         ]
-- [ user_id = ID do dono do carro | vname = Nome do spaw do veiculo | data = data ]
------------------------------------------------------------------------------------
cfg.setDataTrunk = function(user_id,vname,data)
    local chest = "chest:u"..user_id.."veh_"..vname
    vRP.setSData(chest,json.encode(data))
end

return cfg
