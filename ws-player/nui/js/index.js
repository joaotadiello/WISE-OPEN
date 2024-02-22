let ip = null;
const handleClickInspect = (item) => {
    console.log(item)
    $.post("https://ws-player/inpectClick", JSON.stringify({ item: item}));
    setTimeout(function () {
        app.updateMyItens();
        app.updateNearestPlayer();
    }, 500)
}

const app = {
    close: () => {
        $("body").fadeOut(500);
        window.location.reload();
        $.post('https://ws-player/close')
    },

    open: (mode, itens, nitens) => {
        $("body").fadeIn(500);
        switch (mode) {
            case "revistar":
                $('inspect').html(revistar())
                $("inspect").fadeIn(500);

                app.updateItensInspect(itens);
                break

            case "apreender":
                $("inspect").html(apreender());
                $("inspect").fadeIn(500);

                app.updateItensInspect(itens);
                break

            case "roubar":
                $("thief").html(roubar());
                $("thief").fadeIn(500);

                app.updateMyItens(itens);
                app.updateNearestPlayer(nitens);
                break

            case "saquear":
                $("thief").html(saquear());
                $("thief").fadeIn(500);

                app.updateMyItens(itens);
                app.updateNearestPlayer(nitens);
                break
        }
    },

    sendthief: () => {
        $.post('https://ws-player/sendthief')
        app.close();
    },

    updateItensInspect: (itens) => {
        itens.forEach(function (v, k) {
            $('inspect .right-send').append(`
				<div class="item" onClick="handleClickInspect('${v.key}')">
					<span>${v.name}</span>
					<img src="http://${ip}/${v.index}.png">
					<small>${v.amount}x</small>
				 </div>
			`)
        });
        thiefUpdateOptions();
    },

    updateMyItens: (itens) => {
        if (itens) {
            $('thief .left-send').empty();
            itens.forEach(function (v, k) {
                $('thief .left-send').append(`
                    <div class="item" data-key="${v.key}">
                        <span>${v.name}</span>
                        <img src="http://${ip}/${v.index}.png">
                        <small>${v.amount}x</small>
                    </div>
                `)
            });
            thiefUpdateOptions();
        } else {
            $.post('https://ws-player/updateMyItens', JSON.stringify({}), (data) => {
                $('thief .left-send').empty();
                let itens = data.itens
                itens.forEach(function (v, k) {
                    $('thief .left-send').append(`
                        <div class="item" data-key="${v.key}">
                            <span>${v.name}</span>
                            <img src="http://${ip}/${v.index}.png">
                            <small>${v.amount}x</small>
                        </div>
                    `)
                });
                thiefUpdateOptions();
            })
        }
    },

    updateNearestPlayer: (itens) => {
        if (itens) {
            $('thief .right-send').empty();
            itens.forEach(function (v, k) {
                $('thief .right-send').append(`
                    <div class="item" data-key="${v.key}">
                        <span>${v.name}</span>
                        <img src="http://${ip}/${v.index}.png">
                        <small>${v.amount}x</small>
                    </div>
                `)
            });
            thiefUpdateOptions();
        } else {
            $.post('https://ws-player/updateNearestItens', JSON.stringify({}), (data) => {
                $('thief .right-send').empty();
                let itens = data.itens
                itens.forEach(function (v, k) {
                    $('thief .right-send').append(`
                        <div class="item" data-key="${v.key}">
                            <span>${v.name}</span>
                            <img src="http://${ip}/${v.index}.png">
                            <small>${v.amount}x</small>
                        </div>
                    `)
                });
                thiefUpdateOptions();
            })
        }

    },
}


$(document).ready(function () {
    window.addEventListener("message", function (data) {
        let action = event.data;
        switch (action.action) {
            case "show":
                ip = action.ip
                app.open(action.type, action.itens, action.nitens);
                break
        }
        document.onkeyup = function (data) {
            if (data.which == 27) {
                app.close();
            }
        };
    });
});

const thiefUpdateOptions = () => {
    $('thief .item').draggable({
        helper: 'clone',
        appendTo: 'main',
        opacity: 0.35,
        zIndex: 99999,
        revert: true,
        revertDuration: 1,
        start: function (event, ui) {
            $(ui.helper).addClass("ui-draggable-helper");
        },
    });

    $('.inventory-thief').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = { key: ui.draggable.data('key') };
            const origin = ui.draggable.parent()[0].className;
            if (origin === undefined) return;
            console.log(origin)
            if (origin === "thief-content right-send") {
                $.post("https://ws-player/leftToRight", JSON.stringify({ item: itemData.key, amount: parseInt($('#quantidadeNearest').val()) }));
                setTimeout(function () {
                    app.updateMyItens();
                    app.updateNearestPlayer();
                }, 500)
            }
        }
    });
}
