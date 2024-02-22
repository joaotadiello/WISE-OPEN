let ip;
let progres =  0;

var bar = new ldBar(".myBar", {
	"stroke": '#A2CF6D',
	"stroke-width": 1,
	"preset": "circle",
	"value": 0
});

const app = {
	close:()=>{
		$("body").fadeOut(500);
        window.location.reload();
        $.post('https://ws-craft/close')
	},

	open:(receitas)=>{
		$("body").fadeIn(500);
		$("crafting").show(500);
		app.updateItensUser()
		gerarReceitasDisponiveis(ip);
	},

	updateItensUser:()=> {
       	$('.right-send').empty();
		$.post('https://ws-craft/updateInventory',JSON.stringify({}),(data)=>{
			let itens = data.itens
			itens.forEach(function(v,k){
				$('.right-send').append(`
					<div class="item" data-key="${v.key}" data-name="${v.name}" data-index="${v.index}">
						<span>${v.name}</span>
						<img src="${ip}/${v.index}.png">
						<small>${v.amount}x</small>
					</div>
				`)
			})
			thiefUpdateOptions()
		})
    },
}

$(document).ready(function() {
	window.addEventListener("message",function(data){
        let action = event.data;
		switch(action.type){
            case "show":
				ip = action.ip;
				app.open(action.receitas);
				//craft = new Slots();
            break

			case "close":
				app.close();
			break

			case "progress":
				bar.set(action.valueBar,true);

				if (action.valueBar >= 100){
					console.log(slots._itemIndex)
					$.post("https://ws-craft/stopCraft", JSON.stringify({item:slots._itemIndex}));
					slots.init();
					gerarReceitasDisponiveis(ip);
				}
			break
        }
		document.onkeyup = function(data){
			if (data.which == 27){
                app.close();
			}
		};
	});
});

function close_modal() {$('.modal').hide();}

function confirmCraft() {
	slots._inCraft = true;
	$('.result-right').hide();
	$.post("https://ws-craft/progress", JSON.stringify({item:slots._itemIndex}));
}


function refresh_craft() {
	bar.set(0,true);
	slots.initUsage(ip);
	$('#table').hide();
	$('#lock-table').show();
}

const thiefUpdateOptions = () => {
	$('.right-send .item').draggable({
        helper: 'clone',
        appendTo: 'main',
        opacity: 0.35,
        zIndex: 99999,
        revert: true,
        revertDuration: 1,
        start: function(event, ui) {
			$(ui.helper).addClass("ui-draggable-helper");
		},
    });

	$('.craft-table .item').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = { key: ui.draggable.data('key'),index:ui.draggable.data('index'),name:ui.draggable.data('name'),slot:$(this).data('slot')};
			openModal(itemData.slot,itemData.name,itemData.key,itemData.index)
        }
    });
}

function confirmarModal(key,index,slot,name){
	let amount = $('#amountModal').val();

	$.post("https://ws-craft/depositCraft", JSON.stringify({item: key,amount: amount}),(data)=>{
		if(data.status){
			slots.insertSlotItem(index,key,amount,slot,ip,name)
		}
		app.updateItensUser();
	});

	$('.modal').hide();
	$('.modal').empty();
}

function openTable(item){
    $.post("https://ws-craft/pegarReceita", JSON.stringify({item:item}),(data)=>{
		let receita = data.receita
		let status = data.status
        if(receita && status){
			slots._itemIndex = data.indexCraft
			slots._itemReceita = data.giveItem
			slots._indexItem = data.index
            slots.receita = receita
            $('#lock-table').hide();
            $('#table').show();
			$('.craft-table').show();
        }
    });
}
