config = {}

-- cds = local para abrir o farme
-- farme = identificador do farme
-- name = Nome do farme que ira aparecer no front end
-- blip = Nome do blip customizado / blip = nil ira setar um blip padrao
--[[
    OBS:
    PARA USAR blip = 'motoclub' por ex, deve existir uma imagem chamada motoclub dentro
    do arquivo stream/ws_farm.ytd, voce deve usar o openIV para editar este arquvo .ytd.
    Depois de adicionar o blip no arquivo .ytd voce pode colocar em blip = 'nomedoarquivo'
    adicionado no ytd.
]]
config.OpenMenu = {
    {cds = vec3(982.94,-104.52,74.85),farme = 'motoclub',name = 'Moto clube',blip = 'mc'},
}

-- ['motoclub'] = IDENTIFICADOR DO FARME
-- opcoes = botoes que irao aparecer no farme
-- rota_aleatoria = liga ou desliga a rota aleatoria daquele farme
-- cds = local de entrega/coleta
config.script = {
    ['motoclub'] = {
        opcoes = {
            fabricar = true,
            coletar = true,
            entregar = true
        },
        rota_aleatoria = true,
        cds = {
            vec3(60.27,-1347.66,29.24),
            vec3(37.18,-1353.26,29.3),
            vec3(42.57,-1294.98,29.19),
            vec3(45.73,-1103.26,29.1),
            vec3(199.21,-810.91,31.05),
        },
    },
    ['vanilla'] = {
        opcoes = {
            fabricar = true,
            coletar = true,
            entregar = true
        },
        rota_aleatoria = true,
        cds = {
            vec3(60.27,-1347.66,29.24),
            vec3(37.18,-1353.26,29.3),
            vec3(42.57,-1294.98,29.19),
            vec3(45.73,-1103.26,29.1),
            vec3(199.21,-810.91,31.05),
        },
    },
}