config = { }

config.craft = {

---------------------------------------------------------
--- [ CRAFT GERAL ]
---------------------------------------------------------
    ['placa'] = {
        permi = 'admin.permissao',
        giveItem = 'plastico2',
        quantidade = 5,
        tempoProducao = 10,
        requireLocal = true,
        coord = {
            vec3(58.23,-871.41,30.49),
        },
        receita = {
            ['0'] = {item = 'cocaina',amount = 1},
        }
    },
    ['placadealuminio'] = {
        permi = 'craft.permissao', --permissao que podera craftar
        giveItem = 'placadealuminio', --item que sera recebido
        quantidade = 7, --quantidade que ira produzir
        tempoProducao = 10, --tempo para produzir 7 itens como exemplo
        receita = {
            ['0'] = {item = 'aluminio',amount = 1},
            ['1'] = {item = 'aluminio',amount = 1},
            ['2'] = {item = 'aluminio',amount = 1},
            ['3'] = {item = 'aluminio',amount = 1},
            ['5'] = {item = 'aluminio',amount = 1},
            ['6'] = {item = 'aluminio',amount = 1},
            ['7'] = {item = 'aluminio',amount = 1},
            ['8'] = {item = 'aluminio',amount = 1},
        }
    },
    --- '0' é a posiçao no craft sendo o primeiro quadrado
    --- '8' é a ultima posiçao
    ['0'] = { item = 'aluminio', amount = 1 },
    ['carimbo'] = {
        permi = 'craft.permissao',
        giveItem = 'carimbo',
        quantidade = 4,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'plastico',amount = 1},
            ['1'] = {item = 'plastico',amount = 1},
            ['2'] = {item = 'plastico',amount = 1},
            ['3'] = {item = 'tinta',amount = 1},
            ['4'] = {item = 'tinta',amount = 1},
            ['5'] = {item = 'tinta',amount = 1},
            ['6'] = {item = 'plastico',amount = 1},
            ['7'] = {item = 'plastico',amount = 1},
            ['8'] = {item = 'plastico',amount = 1},
        }
    },

---------------------------------------------------------
--- [ MUNIÇÃO ]
---------------------------------------------------------
    --------------[ FUZIL ]--------------
    ['wammo|WEAPON_SPECIALCARBINE_MK2'] = {
        permi = 'municao.permissao',
        giveItem = 'wammo|WEAPON_SPECIALCARBINE_MK2',
        quantidade = 25,
        tempoProducao = 25,
        receita = {
            ['0'] = {item = 'projetilfuzil', amount = 1 },
            ['1'] = {item = 'projetilfuzil', amount = 1 },
            ['2'] = {item = 'projetilfuzil', amount = 1 },
            ['3'] = {item = 'polvora', amount = 1 },
            ['4'] = {item = 'polvora', amount = 1 },
            ['5'] = {item = 'polvora', amount = 1 },
            ['6'] = {item = 'cartuchofuzil', amount = 1 },
            ['7'] = {item = 'cartuchofuzil', amount = 1 },
            ['8'] = {item = 'cartuchofuzil', amount = 1 },
        }
    },
    ['wammo|WEAPON_ASSAULTRIFLE_MK2'] = {
        permi = 'municao.permissao',
        giveItem = 'wammo|WEAPON_ASSAULTRIFLE_MK2',
        quantidade = 25,
        tempoProducao = 25,
        receita = {
            ['0'] = {item = 'projetilfuzil', amount = 1 },
            ['1'] = {item = 'polvora', amount = 1 },
            ['2'] = {item = 'cartuchofuzil', amount = 1 },
            ['4'] = {item = 'polvora', amount = 1 },
            ['5'] = {item = 'cartuchofuzil', amount = 1 },
            ['6'] = {item = 'projetilfuzil', amount = 1 },
            ['7'] = {item = 'polvora', amount = 1 },
            ['8'] = {item = 'cartuchofuzil', amount = 1 }
        }
    },
    --------------[ SUBMETRALHADORA ]--------------
    ['wammo|WEAPON_ASSAULTSMG'] = {
        permi = 'municao.permissao',
        giveItem = 'wammo|WEAPON_ASSAULTSMG',
        quantidade = 25,
        tempoProducao = 25,
        receita = {
            ['0'] = {item = 'projetilsub', amount = 1 },
            ['3'] = {item = 'projetilsub', amount = 1 },
            ['4'] = {item = 'polvora', amount = 1 },
            ['5'] = {item = 'cartuchosub', amount = 1 },
            ['7'] = {item = 'polvora', amount = 1 },
            ['8'] = {item = 'cartuchosub', amount = 1 },
        }
    },
    ['wammo|WEAPON_GUSENBERG'] = {
        permi = 'municao.permissao',
        giveItem = 'wammo|WEAPON_GUSENBERG',
        quantidade = 25,
        tempoProducao = 25,
        receita = {
            ['1'] = {item = 'polvora', amount = 1 },
            ['3'] = {item = 'projetilsub', amount = 1 },
            ['4'] = {item = 'polvora', amount = 1 },
            ['5'] = {item = 'cartuchosub', amount = 1 },
            ['6'] = {item = 'projetilsub', amount = 1 },
            ['7'] = {item = 'polvora', amount = 1 },
            ['8'] = {item = 'cartuchosub', amount = 1 },
        }
    },
    --------------[ PISTOLA ]--------------
    ['wammo|WEAPON_SNSPISTOL'] = {
        permi = 'municao.permissao',
        giveItem = 'wammo|WEAPON_SNSPISTOL',
        quantidade = 25,
        tempoProducao = 25,
        receita = {
            ['0'] = {item = 'projetilpistola', amount = 1 },
            ['1'] = {item = 'polvora', amount = 1 },
            ['4'] = {item = 'polvora', amount = 1 },
            ['8'] = {item = 'cartuchopistola', amount = 1 },
        }
    },
    ['wammo|WEAPON_PISTOL_MK2'] = {
        permi = 'municao.permissao',
        giveItem = 'wammo|WEAPON_PISTOL_MK2',
        quantidade = 25,
        tempoProducao = 25,
        receita = {
            ['0'] = {item = 'projetilpistola', amount = 1 },
            ['1'] = {item = 'projetilpistola', amount = 1 },
            ['2'] = {item = 'cartuchopistola', amount = 1 },
            ['4'] = {item = 'polvora', amount = 1 },
            ['7'] = {item = 'polvora', amount = 1 },
            ['8'] = {item = 'cartuchopistola', amount = 1 },
        }
    },
    ['wammo|WEAPON_HEAVYPISTOL'] = {
        permi = 'municao.permissao',
        giveItem = 'wammo|WEAPON_HEAVYPISTOL',
        quantidade = 25,
        tempoProducao = 25,
        receita = {
            ['0'] = {item = 'projetilpistola', amount = 1 },
            ['3'] = {item = 'projetilpistola', amount = 1 },
            ['4'] = {item = 'polvora', amount = 1 },
            ['5'] = {item = 'cartuchopistola', amount = 1 },
            ['7'] = {item = 'polvora', amount = 1 },
            ['8'] = {item = 'cartuchopistola', amount = 1 },
        }
    },

---------------------------------------------------------
--- [ LAVAGEM ]
---------------------------------------------------------
    --------------[ PAPEL IMPRESSO ]--------------
    ['papelimpresso'] = {
        permi = 'lavagem.permissao',
        giveItem = 'papelimpresso',
        quantidade = 4,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'carimbo',amount = 1},
            ['1'] = {item = 'papel',amount = 1},
            ['2'] = {item = 'carimbo',amount = 1},
            ['3'] = {item = 'papel',amount = 1},
            ['5'] = {item = 'papel',amount = 1},
            ['6'] = {item = 'carimbo',amount = 1},
            ['7'] = {item = 'papel',amount = 1},
            ['8'] = {item = 'carimbo',amount = 1},
        }
    },
    ['dinheirosujo'] = {
        permi = 'lavagem.permissao',
        giveItem = 'dinheiro',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'papelimpresso',amount = 1},
            ['1'] = {item = 'notafiscal1',amount = 1},
            ['2'] = {item = 'papelimpresso',amount = 1},
            ['3'] = {item = 'notafiscal2',amount = 1},
            ['4'] = {item = 'dinheirosujo',amount = 1},
            ['5'] = {item = 'notafiscal3',amount = 1},
            ['6'] = {item = 'papelimpresso',amount = 1},
            ['7'] = {item = 'notafiscal1',amount = 1},
            ['8'] = {item = 'papelimpresso',amount = 1},
        }
    },

---------------------------------------------------------
--- [ DESMANCHE ]
---------------------------------------------------------
    --------------[ TICKET ]--------------
    ['rticket'] = {
        permi = 'desmanche.permissao',
        giveItem = 'rticket',
        quantidade = 5,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'papel',amount = 1},
            ['1'] = {item = 'papel',amount = 1},
            ['2'] = {item = 'papel',amount = 1},
            ['3'] = {item = 'tinta',amount = 1},
            ['4'] = {item = 'tinta',amount = 1},
            ['5'] = {item = 'tinta',amount = 1},
            ['6'] = {item = 'papel',amount = 1},
            ['7'] = {item = 'papel',amount = 1},
            ['8'] = {item = 'papel',amount = 1},
        }
    },

---------------------------------------------------------
--- [ ARMAS ]
---------------------------------------------------------
    --------------[ G36 ]--------------
    ['wbody|WEAPON_SPECIALCARBINE_MK2'] = {
        permi = 'admin.permissao',
        giveItem = 'wbody|WEAPON_SPECIALCARBINE_MK2',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['1'] = {item = 'cocaina', amount = 1 },
        }
    },
    ['superiorg36'] = {
        permi = 'armas.permissao',
        giveItem = 'superiorg36',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'canodearma', amount = 1 },
            ['1'] = {item = 'molas', amount = 1 },
            ['2'] = {item = 'canodearma', amount = 1 },
            ['3'] = {item = 'bronze', amount = 1 },
            ['4'] = {item = 'ouro', amount = 1 },
            ['5'] = {item = 'bronze', amount = 1 },
            ['7'] = {item = 'prata', amount = 1 },
        }
    },
    ['inferiorg36'] = {
        permi = 'armas.permissao',
        giveItem = 'inferiorg36',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'bronze', amount = 1 },
            ['1'] = {item = 'ouro', amount = 1 },
            ['2'] = {item = 'bronze', amount = 1 },
            ['3'] = {item = 'prata', amount = 1 },
            ['4'] = {item = 'gatilho', amount = 1 },
            ['5'] = {item = 'prata', amount = 1 },
            ['6'] = {item = 'prata', amount = 1 },
        }
    },
    --------------[ AK-MK2 ]--------------
    ['wbody|WEAPON_ASSAULTRIFLE_MK2'] = {
        permi = 'armas.permissao',
        giveItem = 'wbody|WEAPON_ASSAULTRIFLE_MK2',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['1'] = {item = 'superiorak', amount = 1 },
            ['4'] = {item = 'inferiorak', amount = 1 },
        }
    },
    ['superiorak'] = {
        permi = 'armas.permissao',
        giveItem = 'superiorak',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'canodearma', amount = 1 },
            ['1'] = {item = 'molas', amount = 1 },
            ['2'] = {item = 'canodearma', amount = 1 },
            ['3'] = {item = 'bronze', amount = 1 },
            ['4'] = {item = 'ouro', amount = 1 },
            ['5'] = {item = 'bronze', amount = 1 },
            ['7'] = {item = 'prata', amount = 1 },
        }
    },
    ['inferiorak'] = {
        permi = 'armas.permissao',
        giveItem = 'inferiorak',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'bronze', amount = 1 },
            ['1'] = {item = 'ouro', amount = 1 },
            ['2'] = {item = 'bronze', amount = 1 },
            ['3'] = {item = 'prata', amount = 1 },
            ['4'] = {item = 'gatilho', amount = 1 },
            ['5'] = {item = 'prata', amount = 1 },
            ['6'] = {item = 'prata', amount = 1 },
        }
    },
    --------------[ MTAR-21 ]--------------
    ['wbody|WEAPON_ASSAULTSMG'] = {
        permi = 'armas.permissao',
        giveItem = 'wbody|WEAPON_ASSAULTSMG',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['1'] = {item = 'superiormtar', amount = 1 },
            ['4'] = {item = 'inferiormtar', amount = 1 },
        }
    },
    ['superiormtar'] = {
        permi = 'armas.permissao',
        giveItem = 'superiormtar',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'bronze', amount = 1 },
            ['2'] = {item = 'bronze', amount = 1 },
            ['3'] = {item = 'canodearma', amount = 1 },
            ['4'] = {item = 'molas', amount = 1 },
            ['5'] = {item = 'canodearma', amount = 1 },
            ['6'] = {item = 'prata', amount = 1 },
            ['7'] = {item = 'prata', amount = 1 },
            ['8'] = {item = 'prata', amount = 1 },
        }
    },
    ['inferiormtar'] = {
        permi = 'armas.permissao',
        giveItem = 'inferiormtar',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'bronze', amount = 1 },
            ['1'] = {item = 'bronze', amount = 1 },
            ['2'] = {item = 'bronze', amount = 1 },
            ['3'] = {item = 'prata', amount = 1 },
            ['4'] = {item = 'gatilho', amount = 1 },
            ['5'] = {item = 'prata', amount = 1 },
            ['7'] = {item = 'prata', amount = 1 },
            ['8'] = {item = 'prata', amount = 1 },
        }
    },
    --------------[ THOMPSON ]--------------
    ['wbody|WEAPON_GUSENBERG'] = {
        permi = 'armas.permissao',
        giveItem = 'wbody|WEAPON_GUSENBERG',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['1'] = {item = 'superiorthompsom', amount = 1 },
            ['4'] = {item = 'inferiorthompsom', amount = 1 },
        }
    },
    ['superiorthompsom'] = {
        permi = 'armas.permissao',
        giveItem = 'superiorthompsom',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'canodearma', amount = 1 },
            ['1'] = {item = 'molas', amount = 1 },
            ['2'] = {item = 'canodearma', amount = 1 },
            ['3'] = {item = 'prata', amount = 1 },
            ['4'] = {item = 'prata', amount = 1 },
            ['5'] = {item = 'prata', amount = 1 },
            ['7'] = {item = 'bronze', amount = 1 },
        }
    },
    ['inferiorthompsom'] = {
        permi = 'armas.permissao',
        giveItem = 'inferiorthompsom',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'prata', amount = 1 },
            ['1'] = {item = 'prata', amount = 1 },
            ['2'] = {item = 'prata', amount = 1 },
            ['3'] = {item = 'bronze', amount = 1 },
            ['4'] = {item = 'gatilho', amount = 1 },
            ['5'] = {item = 'bronze', amount = 1 },
            ['8'] = {item = 'bronze', amount = 1 },

        }
    },
    --------------[ HK ]--------------
    ['wbody|WEAPON_SNSPISTOL'] = {
        permi = 'armas.permissao',
        giveItem = 'wbody|WEAPON_SNSPISTOL',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['1'] = {item = 'superiorhk', amount = 1 },
            ['4'] = {item = 'inferiorhk', amount = 1 },
        }
    },
    ['superiorhk'] = {
        permi = 'armas.permissao',
        giveItem = 'superiorhk',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'prata', amount = 1 },
            ['1'] = {item = 'prata', amount = 1 },
            ['2'] = {item = 'prata', amount = 1 },
            ['3'] = {item = 'molas', amount = 1 },
            ['5'] = {item = 'canodearma', amount = 1 },
            ['7'] = {item = 'prata', amount = 1 },
        }
    },
    ['inferiorhk'] = {
        permi = 'armas.permissao',
        giveItem = 'inferiorhk',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'prata', amount = 1 },
            ['1'] = {item = 'prata', amount = 1 },
            ['3'] = {item = 'prata', amount = 1 },
            ['4'] = {item = 'gatilho', amount = 1 },
        }
    },
    --------------[ FIVE ]--------------
    ['wbody|WEAPON_PISTOL_MK2'] = {
        permi = 'armas.permissao',
        giveItem = 'wbody|WEAPON_PISTOL_MK2',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['1'] = {item = 'superiorfive', amount = 1 },
            ['4'] = {item = 'inferiorfive', amount = 1 },
        }
    },
    ['superiorfive'] = {
        permi = 'armas.permissao',
        giveItem = 'superiorfive',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'prata', amount = 1 },
            ['1'] = {item = 'prata', amount = 1 },
            ['2'] = {item = 'prata', amount = 1 },
            ['3'] = {item = 'molas', amount = 1 },
            ['4'] = {item = 'canodearma', amount = 1 },
            ['5'] = {item = 'molas', amount = 1 },
            ['6'] = {item = 'prata', amount = 1 },
            ['7'] = {item = 'prata', amount = 1 },
            ['8'] = {item = 'prata', amount = 1 },
        }
    },
    ['inferiorfive'] = {
        permi = 'armas.permissao',
        giveItem = 'inferiorfive',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'prata', amount = 1 },
            ['1'] = {item = 'prata', amount = 1 },
            ['2'] = {item = 'prata', amount = 1 },
            ['4'] = {item = 'gatilho', amount = 1 },
            ['7'] = {item = 'prata', amount = 1 },
        }
    },
    --------------[ HEAVY ]--------------
    ['wbody|WEAPON_HEAVYPISTOL'] = {
        permi = 'armas.permissao',
        giveItem = 'wbody|WEAPON_HEAVYPISTOL',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['1'] = {item = 'superiorheavy', amount = 1 },
            ['4'] = {item = 'inferiorheavy', amount = 1 },
        }
    },
    ['superiorheavy'] = {
        permi = 'armas.permissao',
        giveItem = 'superiorheavy',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'prata', amount = 1 },
            ['1'] = {item = 'prata', amount = 1 },
            ['2'] = {item = 'prata', amount = 1 },
            ['3'] = {item = 'canodearma', amount = 1 },
            ['4'] = {item = 'molas', amount = 1 },
            ['5'] = {item = 'canodearma', amount = 1 },
            ['6'] = {item = 'prata', amount = 1 },
            ['8'] = {item = 'prata', amount = 1 },
        }
    },
    ['inferiorheavy'] = {
        permi = 'armas.permissao',
        giveItem = 'inferiorheavy',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'prata', amount = 1 },
            ['1'] = {item = 'prata', amount = 1 },
            ['2'] = {item = 'prata', amount = 1 },
            ['3'] = {item = 'prata', amount = 1 },
            ['5'] = {item = 'gatilho', amount = 1 },
            ['8'] = {item = 'prata', amount = 1 },
        }
    },

---------------------------------------------------------
--- [ CONTRABANDO ]
---------------------------------------------------------
    --------------[ MASTERPICK ]--------------
    ['masterpick'] = {
        permi = 'contrabando.permissao',
        giveItem = 'masterpick',
        quantidade = 3,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'ouro',amount = 1},
            ['1'] = {item = 'plastico',amount = 1},
            ['2'] = {item = 'plastico',amount = 1},
            ['3'] = {item = 'plastico',amount = 1},
            ['4'] = {item = 'ouro',amount = 1},
            ['5'] = {item = 'plastico',amount = 1},
            ['6'] = {item = 'plastico',amount = 1},
            ['7'] = {item = 'plastico',amount = 1},
            ['8'] = {item = 'ouro',amount = 1},
        }
    },
    --------------[ LOCKPICK ]--------------
    ['lockpick'] = {
        permi = 'contrabando.permissao',
        giveItem = 'lockpick',
        quantidade = 3,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'ferro',amount = 1},
            ['1'] = {item = 'plastico',amount = 1},
            ['2'] = {item = 'plastico',amount = 1},
            ['3'] = {item = 'plastico',amount = 1},
            ['4'] = {item = 'ferro',amount = 1},
            ['5'] = {item = 'plastico',amount = 1},
            ['6'] = {item = 'plastico',amount = 1},
            ['7'] = {item = 'plastico',amount = 1},
            ['8'] = {item = 'ferro',amount = 1},
        }
    },
    --------------[ ENERGETICO ]--------------
    ['energetico'] = {
        permi = 'contrabando.permissao',
        giveItem = 'energetico',
        quantidade = 3,
        tempoProducao = 10,
        receita = {
            ['1'] = {item = 'aluminio',amount = 1},
            ['3'] = {item = 'plastico',amount = 1},
            ['4'] = {item = 'aluminio',amount = 1},
            ['5'] = {item = 'plastico',amount = 1},
            ['7'] = {item = 'aluminio',amount = 1},
        }
    },
    --------------[ CORRENTE ]--------------
    ['corrente'] = {
        permi = 'contrabando.permissao',
        giveItem = 'corrente',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'ferro',amount = 1},
            ['1'] = {item = 'ferro',amount = 1},
            ['2'] = {item = 'ferro',amount = 1},
            ['5'] = {item = 'ferro',amount = 1},
        }
    },
    --------------[ ALGEMAS ]--------------
    ['algemas'] = {
        permi = nil,
        giveItem = 'algemas',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['1'] = {item = 'plastico',amount = 1},
            ['3'] = {item = 'ferro',amount = 1},
            ['4'] = {item = 'corrente',amount = 1},
            ['5'] = {item = 'ferro',amount = 1},
        }
    },
    --------------[ CAPUZ ]--------------
    ['capuz'] = {
        permi = 'contrabando.permissao',
        giveItem = 'capuz',
        quantidade = 1,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'linha',amount = 1},
            ['1'] = {item = 'tecido',amount = 1},
            ['2'] = {item = 'linha',amount = 1},
            ['5'] = {item = 'linha',amount = 1},
            ['6'] = {item = 'linha',amount = 1},
            ['7'] = {item = 'tecido',amount = 1},
            ['8'] = {item = 'linha',amount = 1},
        }
    },
    --------------[ DINAMITE ]--------------
    ['dinamite'] = {
        permi = 'contrabando.permissao',
        giveItem = 'dinamite',
        quantidade = 2,
        tempoProducao = 10,
        receita = {
            ['1'] = {item = 'polvora',amount = 1},
            ['2'] = {item = 'plastico',amount = 1},
            ['3'] = {item = 'polvora',amount = 1},
            ['4'] = {item = 'chipverde',amount = 1},
            ['5'] = {item = 'polvora',amount = 1},
            ['6'] = {item = 'plastico',amount = 1},
            ['8'] = {item = 'plastico',amount = 1},
        }
    },
    --------------[ COLETE ]--------------
    ['colete'] = {
        permi = 'contrabando.permissao',
        giveItem = 'colete',
        quantidade = 2,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'tecido', amount = 1 },
            ['1'] = {item = 'placadealuminio', amount = 1 },
            ['2'] = {item = 'tecido', amount = 1 },
            ['3'] = {item = 'placadealuminio', amount = 1 },
            ['4'] = {item = 'tecido', amount = 1 },
            ['5'] = {item = 'placadealuminio', amount = 1 },
            ['6'] = {item = 'tecido', amount = 1 },
            ['7'] = {item = 'placadealuminio', amount = 1 },
            ['8'] = {item = 'tecido', amount = 1 },
        }
    },

---------------------------------------------------------
--- [ HOSPITAL ]
---------------------------------------------------------
--------------[ ATADURA ]--------------
    ['bandagem'] = {
        permi = 'paramedico.permissao',
        giveItem = 'bandagem',
        quantidade = 5,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'atadura',amount = 1},
            ['2'] = {item = 'atadura',amount = 1},
            ['4'] = {item = 'atadura',amount = 1},
            ['5'] = {item = 'atadura',amount = 1},
        }
    },

---------------------------------------------------------
--- [ DROGAS ]
---------------------------------------------------------
--------------[ MACONHA ]--------------
    ['maconha'] = {
        permi = 'amarelo.permissao',
        giveItem = 'maconha',
        quantidade = 5,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'folhademaconha',amount = 1},
            ['2'] = {item = 'folhademaconha',amount = 1},
            ['4'] = {item = 'folhademaconha',amount = 1},
            ['6'] = {item = 'folhademaconha',amount = 1},
            ['8'] = {item = 'folhademaconha',amount = 1},
        }
    },
    ['maconha2'] = {
        permi = 'amarelo.permissao',
        giveItem = 'maconha2',
        quantidade = 10,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'plastico2',amount = 1},
            ['1'] = {item = 'plastico2',amount = 1},
            ['2'] = {item = 'plastico2',amount = 1},
            ['3'] = {item = 'maconha',amount = 1},
            ['4'] = {item = 'maconha',amount = 1},
            ['5'] = {item = 'maconha',amount = 1},
            ['6'] = {item = 'maconha',amount = 1},
            ['7'] = {item = 'maconha',amount = 1},
            ['8'] = {item = 'maconha',amount = 1},
        }
    },
--------------[ COCAÍNA ]--------------
    ['cocaina'] = {
        permi = 'verde.permissao',
        giveItem = 'cocaina',
        quantidade = 5,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'folhadecoca',amount = 1},
            ['2'] = {item = 'folhadecoca',amount = 1},
            ['3'] = {item = 'folhadecoca',amount = 1},
            ['5'] = {item = 'folhadecoca',amount = 1},
            ['7'] = {item = 'folhadecoca',amount = 1},
        }
    },
    ['cocaina2'] = {
        permi = 'verde.permissao',
        giveItem = 'cocaina2',
        quantidade = 10,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'cocaina2',amount = 1},
            ['1'] = {item = 'cocaina2',amount = 1},
            ['2'] = {item = 'plastico2',amount = 1},
            ['3'] = {item = 'cocaina2',amount = 1},
            ['4'] = {item = 'cocaina2',amount = 1},
            ['5'] = {item = 'plastico2',amount = 1},
            ['6'] = {item = 'cocaina2',amount = 1},
            ['7'] = {item = 'cocaina2',amount = 1},
            ['8'] = {item = 'plastico2',amount = 1},
        }
    },
--------------[ METANFETAMINA ]--------------
    ['metanfetamina'] = {
        permi = 'roxo.permissao',
        giveItem = 'metanfetamina',
        quantidade = 5,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'folhadeopio',amount = 1},
            ['2'] = {item = 'folhadeopio',amount = 1},
            ['3'] = {item = 'folhadeopio',amount = 1},
            ['4'] = {item = 'folhadeopio',amount = 1},
            ['5'] = {item = 'folhadeopio',amount = 1},
            ['7'] = {item = 'folhadeopio',amount = 1},
        }
    },
    ['metanfetamina2'] = {
        permi = 'roxo.permissao',
        giveItem = 'metanfetamina2',
        quantidade = 10,
        tempoProducao = 10,
        receita = {
            ['0'] = {item = 'plastico2',amount = 1},
            ['1'] = {item = 'metanfetamina2',amount = 1},
            ['2'] = {item = 'plastico2',amount = 1},
            ['3'] = {item = 'metanfetamina2',amount = 1},
            ['4'] = {item = 'metanfetamina2',amount = 1},
            ['5'] = {item = 'metanfetamina2',amount = 1},
            ['6'] = {item = 'plastico2',amount = 1},
            ['7'] = {item = 'metanfetamina2',amount = 1},
            ['8'] = {item = 'plastico2',amount = 1},
        }
    },
}

return config