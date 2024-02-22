let ip = 0;

const setProgress = (percentage, fillClass,item) => {
    if(percentage == '0'){
        $('.circleProgress').parent().html(`
            <button onclick="CraftItem(this,'${item}')">fabricar</button>
        `);
    } else {
        $('.act small').html(`${percentage}s`)
        let circle = document.querySelector(`.${fillClass}`)
        let calc = (113 * (100 - percentage)) / 100
        circle.style.strokeDashoffset = calc
    }
}

const CreateItensColetar = (indexFarme) => {
    $.post('https://ws-farm/GetColetarItens', JSON.stringify({ indexFarme: indexFarme }), (data) => {
        $('#coletar').empty();
        data.itens.forEach(function (v, k) {
            $('#coletar').append(`
            <div class="item-collect">
                <div class="name">${v.name}</div>
                <img src="http://${ip}/${v.index}.png">
                <button onclick="ColeteItem('${v.key}')">coletar</button>
            </div>
            `)
        })
    })
}

const CreateItensEntregas = (indexFarme) => {
    $.post('https://ws-farm/GetEntregarCache', JSON.stringify({ indexFarme: indexFarme }), (data) => {
        $('#entregar').empty();
        data.itens.forEach(function (v, k) {
            $('#entregar').append(`
            <div class="item-collect">
                <div class="name">${v.name}</div>
                <img src="http://${ip}/${v.index}.png">
                <button onclick="EntregarItem('${v.key}')">Entregar</button>
            </div>
            `)
        })
    })
}

const CreateItensFabricar = (indexFarme) => {
    $.post('https://ws-farm/GetCacheFabricar', JSON.stringify({ indexFarme: indexFarme }), (data) => {
        $('#fabricar').empty();
        data.itens.forEach(function (v, k) {
            console.log(v.targetIndex)
            if (v.craft['0'] && v.craft['1'] && v.craft['2']) {
                $('#fabricar').append(`
                    <div class="item-craft">
                        <div class="craft-item">
                          <span>${v.targetName}</span>
                          <img src="http://${ip}/${v.targetIndex}.png">
                        </div>
                        <div class="recipe">
                          <div class="recipe-item">
                            <div class="name">${v.craft['0'][0]}</div>
                            <img src="http://${ip}/${v.craft['0'][1]}.png"">
                            <small>${v.craft['0'][2]}x</small>
                          </div>
                          <div class="recipe-item">
                            <div class="name">${v.craft['1'][0]}</div>
                            <img src="http://${ip}/${v.craft['1'][1]}.png"">
                            <small>${v.craft['1'][2]}x</small>
                          </div>
                          <div class="recipe-item">
                            <div class="name">${v.craft['2'][0]}</div>
                            <img src="http://${ip}/${v.craft['2'][1]}.png"">
                            <small>${v.craft['2'][2]}x</small>
                          </div>
                        </div>
                        <div class="act">
                          <button onclick="CraftItem(this,'${v.key}')">fabricar</button>
                        </div>
                    </div>
                `)
            } else if (v.craft['0'] && v.craft['1']) {
                $('#fabricar').append(`
                    <div class="item-craft">
                        <div class="craft-item">
                          <span>${v.targetName}</span>
                          <img src="http://${ip}/${v.targetIndex}.png">
                        </div>
                        <div class="recipe">
                          <div class="recipe-item">
                            <div class="name">${v.craft['0'][0]}</div>
                            <img src="http://${ip}/${v.craft['0'][1]}.png"">
                            <small>${v.craft['0'][2]}x</small>
                          </div>
                          <div class="recipe-item">
                            <div class="name">${v.craft['1'][0]}</div>
                            <img src="http://${ip}/${v.craft['1'][1]}.png"">
                            <small>${v.craft['1'][2]}x</small>
                          </div>
                        </div>
                        <div class="act">
                          <button onclick="CraftItem(this,'${v.key}')">fabricar</button>
                        </div>
                    </div>
                `)
            } else if (v.craft['0']) {
                $('#fabricar').append(`
                <div class="item-craft">
                    <div class="craft-item">
                      <span>${v.targetName}</span>
                      <img src="http://${ip}/${v.targetIndex}.png">
                    </div>
                    <div class="recipe">
                      <div class="recipe-item">
                        <div class="name">${v.craft['0'][0]}</div>
                        <img src="http://${ip}/${v.craft['0'][1]}.png"">
                        <small>${v.craft['0'][2]}x</small>
                      </div>
                    </div>
                    <div class="act">
                      <button onclick="CraftItem(this,'${v.key}')">fabricar</button>
                    </div>
                </div>
            `)
            }

        })
    })
}

const CreateButtons = (list) => {
    let active = false
    Object.entries(list).forEach(function (v, k) {
        if (v[1]) {
            if (!active && v[0] === 'coletar') {
                active = true;
                $('header ul').append(`
                    <li onclick="app.changeCategory(this)" id="active">${v[0]}</li>
                `)
            } else {
                $('header ul').append(`
                    <li onclick="app.changeCategory(this)">${v[0]}</li>
                `)
            }
        }
    })
}

const CraftItem = (el,item) => {
    $.post('https://ws-farm/CraftItem', JSON.stringify({
        indexFarme: app.indexFarme,
        item: item,
    }),(data) =>{
        if(data){
            $(el).parent().html(`
                <svg class="circleProgress">
                    <circle class='circleBack' r='18' cx="50%" cy="50%"></circle>
                    <circle class='shieldFill circleFill' r='18' cx="50%" cy="50%"></circle>
                </svg>
                <small></small>
                <button style="display: none;">fabricar</button>
            `);
        }
    })
}

const EntregarItem = (item) => {
    $.post('https://ws-farm/EntregarItem', JSON.stringify({
        indexFarme: app.indexFarme,
        item: item,
    }))
    app.closeNUI();
}

const ColeteItem = (item) => {
    $.post('https://ws-farm/ColeteItem', JSON.stringify({
        indexFarme: app.indexFarme,
        item: item,
    }))
    app.closeNUI();
}

const app = {
    indexFarme: null,
    openNUI: () => {
        $('body').show();
        CreateItensColetar(app.indexFarme);
        CreateItensFabricar(app.indexFarme);
        CreateItensEntregas(app.indexFarme);
    },
    closeNUI: () => {
        $('body').hide();
        window.location.reload();
        $.post('https://ws-farm/close')
    },
    changeCategory: (e) => {
        $('header li').attr('id', '');
        $(e).attr('id', 'active');

        let category = $(e).html().toLowerCase();
        $('.container').hide();
        $('#' + category).show('slow');
    },
}

$(document).ready(function () {
    window.addEventListener("message", function (data) {
        let action = event.data
        switch (action.action) {
            case 'show':
                ip = action.ip;
                CreateButtons(action.buttons)
                $('header h1').text(action.farmeName)
                app.indexFarme = action.indexFarme;
                app.openNUI();
                break

            case 'timer':
                setProgress(action.value,'circleFill',action.craftItem)
            break
        }

        document.onkeyup = function (data) {
            if (data.which == 27) {
                app.closeNUI()
            }
        };
    })
})





