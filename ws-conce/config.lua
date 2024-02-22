config = {}


config.sellPayment = 0.7

config.arkz = true

-- TABELA DE CONFIGURAÇÃO DA CONCESSIONÁRIA
config.conce = {
    [1] = {
        coord = vec3(-30.03,-1105.08,26.43), -- LOCAL PARA ABRIR A CONCE
        spaw_vehicle = vec3(-44.37,-1097.31,26.43+0.5), -- LOCAL ONDE IRA CRIAR O VEICULO PARA SER VISUALIZADO
        camCoord = vec3(-44.43,-1101.8,26.43), -- POSIÇÃO DA CAMERA
        testeDrive = vec3(-17.17,-1079.76,26.68), -- LOCAL ONDE IRA CRIAR O VEICULO DE TEST DRIVE
        testeDriveHeading = 134.07, -- DIREÇÃO QUE O VEICULO DO TESTE DRIVE SERA CRIADO
        testDriveDuracao = 20, -- TEMPO DE DURAÇÃO DO TESTE DRIVE
        xenomCam = vec3(-44.12,-1096.73,27.88-0.1),
        tuning = true, -- HABILITA O TUNING NA CONCE
        options = {comprar = true,alugar = true,test_drive = true}, -- BOTÕES QUE IRÃO APARECER NA CONCE
        type = 'vip'
    },
}

-- CATEGORIAS OBRIGATORIAS NA CONFIG! ['vip'] ['ofertas'] ['destaques']
config.veiculos = {
    ['Esportivos'] = {
        ['nissangtr'] =  {spaw = "nissangtr",nome = "Nissan GTR",valor = 200000, peso = 10, estoque = 0, vip = false},
        ['ferrariitalia'] =  {spaw = "ferrariitalia",nome = "Ferrari Italia", peso = 40, estoque = 0, valor = 300000,vip = false},
        ['adder'] =  {spaw = "adder",nome = "adder", peso = 40, estoque = 0, valor = 300000,vip = false},
        ['audirs6'] =  {spaw = "audirs6",nome = "Audi RS6",valor = 100000, peso = 20, estoque = 0, vip = true},

    },
    ['Moto'] = {
        ['akuma'] =  {spaw = "akuma",nome = "Akuma",valor = 100000, peso = 20, estoque = 0, vip = true},
    },

    ['vip'] = {
        ['bmwm3f80'] =  {spaw = "bmwm3f80",nome = "BMW M3 F80",valor = 100000, peso = 20, estoque = 0, vip = true},
    },

    ['ofertas'] = {
        ['bmwm4gts'] =  {spaw = "bmwm4gts",nome = "BMW M4 GTS",valor = 100000, peso = 20, estoque = 0, vip = true},
    },

    ['destaques'] = {
        ['lamborghinihuracan'] =  {spaw = "lamborghinihuracan",marca = "lamborghini",nome = "huracan",valor = 100000, peso = 20, estoque = 0, vip = true},
        ['bmwm4gts'] =  {spaw = "bmwm4gts",marca = "BMW",nome = "BMW M4 GTS",valor = 100000, peso = 20, estoque = 0, vip = true},
        ['bmwm3f80'] =  {spaw = "bmwm3f80",marca = "BMW",nome = "M3 F80",valor = 100000, peso = 20, estoque = 0, vip = true},
        ['nissangtr'] =  {spaw = "nissangtr",marca = "Nissan",nome = "GTR",valor = 200000, peso = 10, estoque = 0, vip = false},

    },
    ['custom'] = {
        ['bmwm4gts'] =  {spaw = "bmwm4gts",marca = "BMW",nome = "BMW M4 GTS",valor = 100000, peso = 20, estoque = 0, vip = true},
    }
}

config.veiculosCoins = {
    ['vip'] = {
        ['bmwm3f80'] =  {spaw = "bmwm3f80",nome = "BMW M3 F80",valor = 100000, peso = 20, estoque = 0, vip = true},
    },

    ['ofertas'] = {
        ['bmwm4gts'] =  {spaw = "bmwm4gts",nome = "BMW M4 GTS",valor = 100000, peso = 20, estoque = 0, vip = true},
    },

    ['destaques'] = {
        ['lamborghinihuracan'] =  {spaw = "lamborghinihuracan",marca = "lamborghini",nome = "huracan",valor = 100000, peso = 20, estoque = 0, vip = true},
        ['bmwm4gts'] =  {spaw = "bmwm4gts",marca = "BMW",nome = "BMW M4 GTS",valor = 100000, peso = 20, estoque = 0, vip = true},
        ['bmwm3f80'] =  {spaw = "bmwm3f80",marca = "BMW",nome = "M3 F80",valor = 100000, peso = 20, estoque = 0, vip = true},
        ['nissangtr'] =  {spaw = "nissangtr",marca = "Nissan",nome = "GTR",valor = 200000, peso = 10, estoque = 0, vip = false},

    },
}

-- DISTANCIA MAXIMA DO TESTE DRIVE
config.max_distance_test_drive = 100

-- LOCAL ONDE IRA PUXAR AS IMAGENS
config.ip = "localhost"

return config