let pagina = 0
let totalPage = 5
var audio = new Audio("./assets/click.ogg");

function updatePages() {
    $('#passContent').empty();
    for (var i = pagina * totalPage; i < app.MaxLevelInGamePass && i < (pagina + 1) * totalPage; i++) {
        var AvaibleClaim = app.Itens[i].received
        if (!AvaibleClaim) {
            $('#passContent').append(`
                <div class="item" data-index="${app.Itens[i].index}">
                    <img id="imgItem" src="assets/${app.Itens[i].img}.png">
                    <div class="info-item"> 
                        <p>${app.Itens[i].name}</p>
                        <small>${config.texto_1} ${app.Itens[i].index}</small>
                        <button onclick="ClaimReward('${app.Itens[i].index}',this)">${config.texto_3}</button>
                    </div>
                </div>
            `);
        } else {
            $('#passContent').append(`
                <div class="item received" data-index="${app.Itens[i].index}">
                    <img src="assets/${app.Itens[i].img}.png">
                    <div class="info-item"> 
                        <p>${app.Itens[i].name}</p>
                        <small>${config.texto_1} ${app.Itens[i].index}</small>
                        <button>${config.texto_2}</button>
                    </div>
                </div>
            `);
        }
    }
}

const ClaimReward = (RewardIndex, element) => {
    audio.play();
    $(element).parent().parent().find('#imgItem').attr('src', 'https://c.tenor.com/I6kN-6X7nhAAAAAj/loading-buffering.gif');
    setTimeout(() => {
        $(element).parent().parent().find('#imgItem').attr('src', 'assets/sucess.gif');
        setTimeout(() => {
            updatePages();
        }, 2000)
    }, 2000);
    $.post('https://ws-gamepass/ClaimReward', JSON.stringify({ index: RewardIndex }), (data) => {
        var state = data.status
        if (state == true) {
            app.Itens[RewardIndex - 1].received = state
        }
    })
}

playAudio = () => {
    var sound = new Pizzicato.Sound({
        source: 'file',
        options: { path: './assets/click.ogg', volume: 0.3, }
    }, function () {
        sound.play();
    });
}

const app = {
    open: () => {
        $('body').show();
    },

    UpdateHeader: (current, next) => {
        if (next == "MaxLevel") {
            next = '<b>MAESTRIA</b>'
        }
        $('header').html(`
        <span>${current}</span>
        <div class="bar">
            <span>Carregando</span>
            <div class="fill"></div>
        </div>
        <span>${next}</span>
        `)
        setTimeout(function () {
            UpdateProgressBar();
        }, 100)
    },

    close: () => {
        $('body').hide();
        app.Itens = null;
        $.post('https://ws-gamepass/close')
        window.location.reload();
    },
}

function nextPage() {
    audio.play();
    if (pagina < app.MaxLevelInGamePass / totalPage - 1) {
        pagina++
        updatePages();
    }
}

function prevPage() {
    audio.play();
    if (pagina > 0) {
        pagina--
        updatePages();
    }
}

$(document).ready(function () {

    window.addEventListener("message", function (data) {
        let action = event.data;

        switch (action.action) {
            case "show":
                app.open();
                app.Itens = action.Itens;
                app.MaxLevelInGamePass = action.MaxLevelInGamePass;
                $('#passContent').html('');
                updatePages();
                app.UpdateHeader(action.CurrentLevel, action.NextLevel);
                break

            case "close":
                app.close();
                break
        }

        document.onkeyup = function (data) {
            if (data.which == 27) {
                app.close();
            }
        };
    })
})

const UpdateProgressBar = () => {
    $.post('https://ws-gamepass/UpdateProgressBar', JSON.stringify({}), (data) => {
        var value1 = data.xp
        var value2 = data.next
        let ShowValue = (value1 * 100) / value2
        $('.fill').css('width', ShowValue + '%')
        $('.bar span').html(`${value1}xp/${value2}xp`)
    })
}