config = {}

-- Locais para acessar o banco
config.coords_bank = {
    [1] = {coordenada = vec3(150.26,-1039.99,29.37)},
    [2] = {coordenada = vec3(246.80,222.75,106.28)},
    [3] = {coordenada = vec3(-350.81,-49.42,49.04)},
    [4] = {coordenada = vec3(314.38,-278.72,54.17)},
    [7] = {coordenada = vec3(1174.90,2706.57,38.09)},
    [8] = {coordenada = vec3(237.42,217.71,106.29)},
    [9] = {coordenada = vec3(-2962.58,482.83,15.71)},
    [10] = {coordenada = vec3(-112.91,6469.72,31.63)},
}


-- CONTROLA A BUSCA POR CAIXA ELETRONICO USANDO OS PROPS A BAIXO
config.atm = true
config.propCaixas = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm"
}

config.customBlip = {
    tamanho = 0.3,
    dic = 'images',
    img = 'banco'
}

--Configurar horario de abertura e fechamento do banco
config.aberto_24h = true
config.horario_abrir = 7
config.horario_fechar = 17

--Configurar link da logo do banco
config.logo = ""


return config