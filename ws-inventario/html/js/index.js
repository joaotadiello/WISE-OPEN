let weightLeft = 0;
let cont = 0; 
let type_secondary;
let currentSlot = 0;
let slotNumber;
let ip;

const app = {
    open:()=>{
        $("body").fadeIn(500)
        updateOptions();
    },
    close:()=>{
        $("body").hide();
        $.post('https://ws-inventario/close',JSON.stringify({type:type_secondary}))
        window.location.reload();
    }
}

const inv = {
	useItem:(item,type)=>{
		let amount = parseInt($('.amount').val())
		if(item && type){
			$.post('https://ws-inventario/useItem',JSON.stringify({item:item,amount:amount,type:type}))
			app.close();
		}
	},

	sendItem:(item)=>{
		let amount = parseInt($('.amount').val())
		if(item){
			$.post('https://ws-inventario/enviarItem',JSON.stringify({item:item,amount:amount}))
			app.close();
		}
	}
}

$(document).ready(function() {
   
	window.addEventListener("message",function(data){
        let action = event.data;

		switch(action.action){
            case "show":
                ip = action.ip
                app.open();
            break

			case "update":
				updateMochila();
				updatePlayerWeapons(action.playerWeapons);
			break

			case "close":
				app.close();
			break
        }
		if (action.secondary != null){
			$('.inventory-near').fadeIn(500)
			type_secondary = action.type_secondary
			updateChest(action.secondary,action.maxPeso,action.pesoAtual)
		}

		slotNumber = action.slots
        updateMochila();
		updatePlayerWeapons(action.playerWeapons);
		hotBarInit();
		updateHotBar();

        $('#kg-inventory').html(`<b>${action.invWeight} <small>kg</small></b> ${action.maxInv} <small>kg</small>`);
        
      	document.onkeyup = function(data){
			if (data.which == 27){
                app.close();
			}
		};

		$("#search-near").on("keyup", function() {
			var value = $(this).val().toLowerCase();
			$(".near-content .item").filter(function() {
			  $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
			});
		});
	})
    
})

function plus() { 
    while(cont < 10000){
        cont = cont+1
        let $target = $('.equipped-slots');
        $target.scrollLeft(cont);
    }

}
function minus() { 
    if (cont >= 0 ) {
        while(cont > 0){
            cont = cont-1
            let $target = $('.equipped-slots');
            $target.scrollLeft(cont);
        }

    }
}

const updateOptions = () => {
    $('.item').draggable({
        helper: 'clone',
        appendTo: '.allnui',
        opacity: 0.35,
        zIndex: 99999,
        revert: true,
        revertDuration: 1,
        start: function(event, ui) {
			$(ui.helper).addClass("ui-draggable-helper");
		},
    });

	$('.slot').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {

            if (ui.draggable.parent()[0] == undefined) return;

            const origin = ui.draggable.parent()[0].className;
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

            if (origin === "near-content" && tInv === "near-content") return;

            itemData = { key: ui.draggable.data('key'),stype:ui.draggable.data('stype')};

            if (itemData.key === undefined) return;

            if (origin === "inventory-content" && tInv === "inventory-content") {
				return
			} else if (origin === "near-content" && tInv === "inventory-content") {
				$.post("https://ws-inventario/nearToInv", JSON.stringify({
					item: itemData.key,
					amount: $("#amount-near").val(),
					stype: itemData.stype
				}),(data)=>{
					updateChest(data.chest, data.max, data.atual);
					updateMochila();
				});
			} else if (origin === "near-content" && tInv === "near-content") {
				console.log("not");
			}

			updateOptions();
			$('#amount-near').val();
			$('.amount').val();
		}
	});

    $('.populated').droppable({
		hoverClass: 'hoverControl',
		drop: function (event, ui) {
			if (ui.draggable.parent()[0] == undefined) return;

			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined) return;
			const tInv = $(this).parent()[0].className;

			if (origin === "near-content" && tInv === "near-content") return;

			itemData = { key: ui.draggable.data('key'),stype:ui.draggable.data('stype') };
			const targetname = $(this).data('key');
			const targetamount = $(this).data('amount');

			let amount = 0;
			let itemAmount = parseInt(ui.draggable.data('amount'));

			if ($(".amount").val() == "" | parseInt($(".amount").val()) == 0)
				amount = itemAmount;
			else
				amount = parseInt($(".amount").val());

			if (amount > itemAmount)
				amount = itemAmount;

			$('.populated, .empty, .use').off("draggable droppable");

			let futureWeightLeft = weightLeft;

			// if (ui.draggable.data('key') == $(this).data('key')) {
			// 	let newSlotAmount = amount + parseInt($(this).data('amount'));
			// 	let newSlotWeight = parseFloat(ui.draggable.data("peso")) + parseFloat($(this).data("peso"));

			// 	$(this).data('amount', newSlotAmount);
			// 	$(this).data("peso", newSlotWeight.toFixed(2));

			// 	if (origin === "inventory-content" && tInv === "near-content") {
			// 		futureWeightLeft = futureWeightLeft - (parseFloat(ui.draggable.data('peso')) * amount);
			// 	} else if (origin === "near-content" && tInv === "inventory-content") {
			// 		futureWeightLeft = futureWeightLeft + (parseFloat(ui.draggable.data('peso')) * amount);
			// 	}
			// } else {
			// 	if (origin === "near-content" && tInv === "inventory-content") return;

			// 	if (origin === "inventory-content" && tInv === "near-content") {
			// 		futureWeightLeft = futureWeightLeft - parseFloat(ui.draggable.data('amount')) + parseFloat($(this).data('amount'));
			// 	}
			// }
			
			if (origin === "inventory-content" && tInv === "inventory-content") {
				return
			} else if (origin === "near-content" && tInv === "inventory-content") {
				$.post("https://ws-inventario/nearToInv", JSON.stringify({
					item: itemData.key,
					amount: $("#amount-near").val(),
					stype:itemData.stype
				}),(data)=>{
					updateChest(data.chest, data.max, data.atual);
					updateMochila();
				});
			}

			updateOptions();
			$('#amount-near').val(0);
			$('.amount').val();
		}
	});

	$('.hotbar-slot').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = { key: ui.draggable.data('key'), slot: $(this).data('slot'), type:ui.draggable.data('type') };

			const origin = ui.draggable.parent()[0].className;
			if (origin === undefined) return;

			if (itemData.type == "equipar" || itemData.type == "recarregar" ) {
				return
			}

			if (origin === "inventory-content") {
				updateHotBar(itemData.slot,itemData.key,itemData.type);
			}
        }
    });

	$('aside').droppable({
		hoverClass: 'hoverControl',
        drop: function (event, ui) {
			const origin = ui.draggable.parent()[0].className;
			const tInv = $(this).parent()[0].className;

			itemData = { key: ui.draggable.data('key'), amount: parseInt($(".amount").val()),stype:ui.draggable.data('stype')};
			if (origin === undefined) return;
			if (origin === "near-content" && tInv === "inventory-near") {
				return;
			}else {
				$.post("https://ws-inventario/invToNear", JSON.stringify({
					item: itemData.key,
					amount: parseInt(itemData.amount),
					stype: itemData.stype,
				}),(data)=>{
					updateChest(data.chest, data.max, data.atual);
					updateMochila();
				});
			}
        }
    });
}

const updateMochila = () =>{
    $.post('https://ws-inventario/updateMochila',JSON.stringify({}),(data)=>{
        $('.inventory-content').empty()
        let count = 0;
		data.inventory.forEach(function(v,k){
			count++       
			$('.inventory-content').append(`
			<div class="item populated" onclick="openInfoItem(this)" 
				data-key="${v.key}" data-type="${v.type}" data-stype="${type_secondary}"
				
				data-amount="${v.amount}" data-index="${v.index}">
				<img src="http://${ip}/${v.index}.png">
				<small>${v.amount}x</small>
			</div>
			`)
        })
		while(count <= slotNumber){
			count++
			$('.inventory-content').append(`<div class="slot"></div>`)
		}

        $('#kg-inventory').html(`<b>${data.pesoAtual} <small>kg</small></b> ${data.pesoMax} <small>kg</small>`);

        updateOptions();
    })
}

function closeModal() {
	$('.inventory-desc').empty();
}

function trash_item(item,slot) {
	let amount = parseInt($('.amount').val())
	$.post('https://ws-inventario/trashItem',JSON.stringify({item:item,amount:amount}))
	updateMochila();
}

function openInfoItem(i){
	$.post('https://ws-inventario/getItemInfo',JSON.stringify({item:i.dataset.key,amount:i.dataset.amount}),(data)=>{
		$('.item').css('opacity', '1');
		$('.item').css('background-color', 'rgba(255, 255, 255, 0.09)');
		$(i).css('opacity', '.6');
		$(i).css('background-color', '#a1cf6d1e');
	
		$('.inventory-desc').html(`
			<div class="warning"  onclick = "closeModal()"><i class="far fa-window-close"></i> esc para fechar</div>
			<div class="desc-title">
				<p>${data.name}</p>
				<span>${data.peso}<small> kg</small></span>
				<span>${i.dataset.amount}<small> qtd</small></span>
				<div class="trash-item-desc" onclick="trash_item('${i.dataset.key}')">
                    <i class="fad fa-trash"></i>
                </div>
			</div>
			<div class="desc-item">
				<p>${data.desc}</p>
			</div>
	
			<div class="desc-action">
				<button class="btn-action" onclick="inv.useItem('${i.dataset.key}','${i.dataset.type}')">Usar item</button>
				<button class="btn-action" onclick="inv.sendItem('${i.dataset.key}')">Enviar item</button>
			</div>
	
			<div class="desc-input">
				<small id="valRange">1</small>
				<input class="amount" type="number" placeholder="Quantidade">
				<input class="rangeInput" type="range" value="0" min="0" max="${i.dataset.amount}">
			</div>
	
			<script>
				$( ".rangeInput" ).change(function() {
					$( ".amount" ).val( $( this ).val() );
					$( "#valRange" ).html( $( this ).val() );
				});
				
				$( ".btn-action" ).hover(
					function() {
					$( this ).addClass( "hover-btn" );
					}, function() {
					$( this ).removeClass( "hover-btn" );
					}
				);
	
				$( ".amount" ).keyup(function() {
					$( "#valRange" ).html( $( this ).val() );
					$( ".rangeInput" ).val( $(this).val() );
				});
			</script>
		`)
	})
}

const updatePlayerWeapons = (weapons) =>{
	if (weapons){
		$('.equipped-scroll').empty();
		Object.entries(weapons).forEach(function(v,k){
			console.log(k,v)
			if (v[1] != 0) {
				$('.equipped-scroll').append(`
				<div class="equipped-item">
					<img src="http://${ip}/${v[0]}.png">
					<div class="equipped-info">
						<span>munição: ${v[1]}</span>
						<button onclick="garmas(this,'${v[0]}')">desequipar</button>
					</div>
				</div>
				`)
			} else {
				$('.equipped-scroll').append(`
				<div class="equipped-item">
					<img src="http://${ip}/${v[0]}.png">
					<div class="equipped-info">
						<button onclick="garmas(this,'${v[0]}')">desequipar</button>
					</div>
				</div>
				`)
			}
		});
	}
}

const updateHotBar = (slot,item,type) => {
	$.post('https://ws-inventario/updateHotbar',JSON.stringify({slot:slot,item:item,type:type}),(data) => {
		let count = 1;
		let hotbar = data.hotbar
		$('.hotbar').empty();
		hotbar.forEach(function(v,k){
			if(v != false){
				$('.hotbar').append(`
				<div class="hotbar-slot" data-slot="${count}" data-type="">
					<label>${count}</label>
					<div class="inner"></div>
					<img src="http://${ip}/${v}.png"></img>
					<div class="remove">
                        <span>${v}</span>
                        <button onclick="removeHotbat(this)" data-slot="${count}" >remover</button>
                    </div>
				</div>
				`)
			} else {
				$('.hotbar').append(`
				<div class="hotbar-slot" data-slot="${count}" data-type="">
					<label>${count}</label>
				</div>
				`)
			}
			count++;
			updateOptions();
		})
	})
}

function garmas(el,hash) {
	$(el).parent().parent().remove()
	$.post('https://ws-inventario/garmas',JSON.stringify({weapon:hash}),(data)=>{
		updatePlayerWeapons(data.weapon)
		updateMochila();
	})
}

function removeHotbat(i){
	$.post('https://ws-inventario/removeHot',JSON.stringify({
		slot:i.dataset.slot
	}),(data)=>{
		let count = 1;
		let hotbar = data.hotbar
		$('.hotbar').empty();
		hotbar.forEach(function(v,k){
			if(v != false){
				$('.hotbar').append(`
				<div class="hotbar-slot" data-slot="${count}" data-type="">
					<label>${count}</label>
					<div class="inner"></div>
					<img src="http://${ip}/${v}.png"></img>
					<div class="remove">
                        <span>${v}</span>
                        <button onclick="removeHotbat(this)" data-slot="${count}">remover</button>
                    </div>
				</div>
				`)
			} else {
				$('.hotbar').append(`
				<div class="hotbar-slot" data-slot="${count}" data-type="">
					<label>${count}</label>
				</div>
				`)
			}
			count++;
			updateOptions();
		})
	})
}

function openInfoChestItem(i){
	$('.item').css('opacity', '1');
    $('.item').css('background-color', 'rgba(255, 255, 255, 0.09)');
    $(i).css('opacity', '.6');
    $(i).css('background-color', '#a1cf6d1e');

	$('#near-desc').text(i.dataset.desc)
	$('.near-img img').empty();
	$('.near-img img').attr('src',`http://${ip}/${i.dataset.index}.png`)
}

const updateChest = (chest,max,atual) =>{
	$('.near-content').empty();
	if (type_secondary == "chest" || type_secondary == "homes" || type_secondary == "trunk"){
		chest.forEach(function(v,k){
			$('.near-content').append(`
			<div class="item" data-stype="${type_secondary}" data-key="${v.key}" data-index="${v.index}" data-desc="${v.name}" onclick="openInfoChestItem(this)">
				<img src = "http://${ip}/${v.index}.png"></img>
				<small>${v.amount}x</small>
				<span style="position:absolute;opacity:0">${v.name}</span>
			 </div>
			`)
		});
	} else {
		chest.forEach(function(v,k){
			$('.near-content').append(`
			<div class="item" data-stype="${type_secondary}" data-key="${v.key}" data-index="${v.index}" data-desc="${v.name}" onclick="openInfoChestItem(this)">
				<img src = "http://${ip}/${v.index}.png"></img>
				<small>R$${v.valor}</small>
				<span style="position:absolute;opacity:0">${v.name}</span>
			 </div>
			`)
		});
	}

	if (type_secondary == "chest" || type_secondary == "homes" || type_secondary == "trunk"){
		$('#kg-near').html(`<b>${atual}<small>kg</small></b> / ${max}kg</span>`)
	}
	setImagemNear(type_secondary)
}

const setImagemNear = () =>{
	switch(type_secondary){
		case "chest":
			$('.near-img img').attr('src',`assets/cofre22.png`)
			break

		case "trunk":
			$('.near-img img').attr('src',`assets/trunk.png`)
			break

		case "homes":
			$('.near-img img').attr('src',`assets/casa.png`)
			break

		case "shop":
			$('.near-img img').attr('src',`assets/shop.png`)
			break
	}
}

function close() {
    app.close();
}

function abrirIdentidade(){
	$('identity').fadeIn(500)
	$.post('https://ws-inventario/identity',JSON.stringify({}),(data)=>{
		$('identity').html(`
		<div class="photo">
			<div class="job"><p>${data.group}</p></div>
		</div>
		<div class="info-identity">
			<div class="box">
				<label>Passaporte</label><br>
				<small>ID: ${data.user_id}</small>
			</div>
			<div class="box">
				<label>Nome Completo</label><br>
				<small>${data.nomeCompleto}</small>
			</div>
			<div class="box">
				<label>Idade</label><br>
				<small>${data.idade} anos</small>
			</div>
			<div class="box">
				<label>Banco</label><br>
				<small>R$ ${data.banco}</small>
			</div>
			<div class="box">
				<label>Carteira</label><br>
				<small>R$ ${data.carteira}</small>
			</div>

			<div class="box">
				<label>Multas</label><br>
				<small>${data.multas}</small>
			</div>

			<div class="box">
				<label>Celular</label><br>
				<small>${data.phone}</small>
			</div>

			<div class="box">
				<label>RG</label><br>
				<small>${data.rg}</small>
			</div>

			<div class="box">
				<label>VIP</label><br>
				<small>${data.vip}</small>
			</div>
		</div>
		<div class="close-identity" onclick="fecharIdentidade()"><i class="fal fa-times"></i></div>
		`)
	})
}



function fecharIdentidade(){
	$('identity').fadeOut(500)
}

const hotBarInit = () =>{
	$('.hotbar').html(`
	<div class="hotbar-slot" data-slot="1">
	<label>1</label>
	</div>
	<div class="hotbar-slot" data-slot="2">
		<label>2</label>
	</div>
	<div class="hotbar-slot" data-slot="3">
		<label>3</label>
	</div>
	<div class="hotbar-slot" data-slot="4">
		<label>4</label>
	</div>
	`)
}
