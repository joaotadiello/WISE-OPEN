config = { }

config.desmanche = {
    ['MC'] = {permission = nil,cds = vec3(958.02,-127.89,74.36)},
    ['LC'] = {permission = nil,cds = vec3(998.02,-127.89,0.36)},
}

config.textos = {
    cancelar = "Pressione ~r~F7~w~ para cancelar!",
    seconds = function(seconds) return "Tempo restante para finalizar: ~r~"..seconds.."~w~ segundos!" end,
    moto = "PRESSIONE  ~r~E~w~  PARA DESMONTAR A MOTOCICLETA",
    finalizar = function(time) return "Tempo para finalizar o desmanche  ~r~"..time.."~w~ segundos!" end,
}
-------------------------------------------------------------------
-- [ CONFIG PARA CARROS ] OBS: Informe o numero em segundos
-------------------------------------------------------------------
--Tempo limite para finalizar o desmanche de um
config.tempoLimite = 10 

-- Tempo para remover uma roda
config.tempoParaRemoverRoda = 2

-- Tempo para remover cada parte do veiculo
config.tempoParaRemoverPeca = 2

-- Ativa para receber peças no desmanche
config.ReceberPecas = true

-- Config para receber peças no desmanche
config.pecas = {
    ['motor'] = {'agua',1},
    ['roda'] = {'sanduiche',1},
    ['porta'] = {'maconha',1},
    ['suspencao'] = {'agua',1}
}

-- Caso ativo ira exigir itens para desmanchar o veiculo
config.requiredItens = false

-------------------------------------------------------------------
-- [ CONFIG PARA MATOS ] OBS: Informe o numero em segundos
-------------------------------------------------------------------
-- Tempo para finalizar o desmanche de uma [MOTO]
config.tempoDesmancheDaMoto = 2

-------------------------------------------------------------------
-- [ CONFIG NOTIFY ] OBS: Para quem tem notificação com tempo, todas tem o tempo padrao de 5 segundos
-------------------------------------------------------------------
config.notify = {
    ['NOME_DO_EVENTO'] = 'Notify',
    ['NOTIFY_SUCESSO'] = 'sucesso',
    ['NOTIFY_ERRO'] = 'negado',
    ['NOTIFY_AVISO'] = 'aviso',
}
