let isAnimating = true;
let activeFooter = false;
let freeCam = false;
let modelSelect = null;
let ip = null;
let sellPayment;

let windowsTuning = [0,1,2,3,4,5,6]
let lightTuning = [0,1,2,3,4,5,6,7,8,9,10,11,12]


const app = {
    open_nui: () => {
        $('body').fadeIn();
        app.generate_destaques();
        $.post('https://ws-conce/startBlur');
    },

    close_nui: () => {
        $('body').fadeOut(1000);
        $.post('https://ws-conce/close')
        window.location.reload();
    },

    close_teste: () =>{
        $('body').fadeOut(1000);
        $.post('https://ws-conce/close_teste')
        window.location.reload();
    },

    close_footer: () => {
        $('footer').animate({
            bottom: -160,
        }, 1000, function() {
            $('.close-footer').css('color', '#000');
            $('.close-footer').css('background-color', '#fff');
            $('.close-footer').css('transform', 'rotate(-180deg)');
        });
    },

    generate_destaques: () => {
        $.post('https://ws-conce/get_menus',JSON.stringify({categoria:'destaques'}),(data)=>{
            let categoria = data.categorias
            let count = 0

            $("#slider").html(`
                <div class="slider-inner">
                    <div id="slider-content"></div>
                </div>
                <img id="slide-image" src="http://${ip}/vehicles/${categoria['nissangtr'].spaw}.png" />
                <div class="slide-content-img"></div>
                <div id="pagination"></div>
            `)

            $("#slider-content").append(`
                <div class="meta">Destaques</div>
                <h2 id="slide-title">Nissan <br>GTR</h2>
                <div class="slide-content-name"></div>
                <div class="meta">Preço</div>
                <div id="slide-status">R$ ${formatarNumero(categoria['nissangtr'].valor)}</div>
                <div class="slide-content-price"></div>
            `)

            Object.entries(categoria).forEach(([k, v]) => {


                $(".slide-content-name").append(`
                    <span data-slide-title="${count}">${v.marca}<br>${v.nome}</span>
                `);

                $(".slide-content-price").append(`
                    <span data-slide-status="${count}">R$ ${formatarNumero(v.valor)}</span>
                `);

                $(".slide-content-img").append(`
                    <img data-slide-img="${count}" src="http://${ip}/vehicles/${v.spaw}.png" />
                `);

                $("#pagination").append(`
                    <button data-slide="${count}" onclick="change_slide(this)"></button>
                `);
                count++
            });
            
        })
    },

    close_extra: () => {
        $('.extra-vehicles').fadeOut();
        $('#slider').fadeIn();
    },

    close_modal: () => {
        $('.sell-modal').hide();
        $('.extra-vehicles').show()
    },

    confirm_sell: (vehicle) => {
        $('.sell-modal').hide();
        $('.extra-vehicles').show()
        $('.extra-content').empty()
        $.post('https://ws-conce/sell_vehicle',JSON.stringify({vehicle:vehicle}))

    },

    cancel_sell: () => {
        $('.sell-modal').fadeOut();
        $('.extra-vehicles').show()
    },

    vehicle_menu: (category) => {
        $('.extra-vehicles').fadeIn();
        $('#slider').fadeOut();
        $('.extra-content').empty();
        $('.extra-title .meta').html('Veiculos Para ' + category)
        switch(category){

            case "vip":
                $.post('https://ws-conce/get_menus',JSON.stringify({categoria:category}),(data)=>{
                    let cat = data.categorias
                    Object.entries(cat).forEach(([k, v]) => {
                        $('.extra-content').append(`
                            <div class="extra-item"              
                            data-name="${v.nome}"
                            data-spaw="${v.spaw}"
                            data-estoque="${v.estoque}"
                            data-category="${category}"
                            data-weight="${v.peso}"
                            data-price="${formatarNumero(v.valor)}"
                            
                            onclick="cb.load_vehicle('${v.spaw}');app_action.comprar_carros2(this)">
                                <span>${v.nome}</span>
                                <img src="http://${ip}/vehicles/${v.spaw}.png">
                            </div>
                        `)
                    });
                })
            break

            case "vender":
                $.post('https://ws-conce/myVehicles',JSON.stringify({}),(data)=>{
                    if (data.type){
                        $.post('https://ws-conce/bloquearVenda',JSON.stringify({}))
                    } else {
                        let cat = data.myVeh
                        Object.entries(cat).forEach(([k, v]) => {
                            $('.extra-content').append(`
                                <div class="extra-item" onclick="cb.sell_vehicle('${k}','${v.nome}',${v.price})">
                                    <span>${v.nome}</span>
                                    <img src="http://${ip}/vehicles/${k}.png">
                                </div>
                            `)
                        });
                    }
                })
            break

            case "ofertas":
                $.post('https://ws-conce/get_menus',JSON.stringify({categoria:category}),(data)=>{
                    let cat = data.categorias
                    Object.entries(cat).forEach(([k, v]) => {
                        $('.extra-content').append(`
                            <div class="extra-item"                     
                            data-name="${v.nome}"
                            data-spaw="${v.spaw}"
                            data-estoque="${v.estoque}"
                            data-category="${category}"
                            data-weight="${v.peso}"
                            data-price="${formatarNumero(v.valor)}"
                            onclick="cb.load_vehicle('${v.spaw}');app_action.comprar_carros2(this)">
                                <span>${v.nome}</span>
                                <img src="http://${ip}/vehicles/${v.spaw}.png">
                            </div>
                        `)
                    });
                })
            break
        }

    },

    action_buy: (element) => {
        if (element.dataset.action === 'buy') {
            $.post('https://ws-conce/buy_vehicle',JSON.stringify({categoria:$('#vehicle-type').text(),vehicle:modelSelect}))
        } else if (element.dataset.action === 'rent') {
            $.post('https://ws-conce/rent_vehicle',JSON.stringify({categoria:$('#vehicle-type').text(),vehicle:modelSelect}))
        } else {
            $.post('https://ws-conce/spaw_testeDrive',JSON.stringify({vehicle:modelSelect}))
            app.close_teste()
        }
    },

    open_footer: () => {
        $('footer').animate({
            bottom: 40,
        }, 1000, function() {
            $('.close-footer').css('color', '#fff');
            $('.close-footer').css('background-color', 'transparent');
            $('.close-footer').css('transform', 'rotate(0deg)');
        });
    },

    change_tuning: (element) => {
        $('.content-header li').removeClass('active-tuning');
        $(element).addClass('active-tuning');
        $('.scroll').hide();
        $('#'+element.dataset.tuning).fadeIn();
        app.generate_tuning(element.dataset.tuning)
    },

    generate_tuning: (type) => {
        if (type === 'color') {
            $('#content-tuning').hide()

            $('#content-tuning').html(`
                <div class="item-tuning">
                    <small>01</small>
                    <i class="fas fa-tire"></i>
                </div>
            `);
        } else if(type === "window") {
            $('#content-tuning').empty()
            $('#content-tuning').show()
            windowsTuning.forEach(function(v,i){
            $('#content-tuning').append(`
                <div class="item-tuning" onclick="setWindows(${i})">
                    <small>${i}</small>
                    <i class="fas fa-tire"></i>
                </div>
            `);
            })
        } else {
            $('#content-tuning').empty()
            $('#content-tuning').show()
            lightTuning.forEach(function(v,i){
                $('#content-tuning').append(`
                    <div class="item-tuning" onclick="setXenon(${i})">
                        <small>${i}</small>
                        <i class="fas fa-lightbulb-on"></i>
                    </div>
                `);
            })
        }
    },

    select_category: (element) => {
        $('.category-options .btn').animate({
            width: 150,
        }, 200, function() {
            $('.category-options .btn').attr('disabled', false);
            $('.category-options .btn').removeClass('active-category');
            $('.category-options .btn').find('span').fadeIn()
        });
        $(element).animate({
            width: 40, 
        }, 200, function() {
            $(element).attr('disabled', true);
            $(element).addClass('active-category');
            $(element).find('span').hide()
        });
    },

    select_car: (element) => {
        modelSelect = element.dataset.spaw

        $.post('https://ws-conce/get_vehInfo',JSON.stringify({veh:modelSelect}),(data)=>{
            $('.card-info-car').show();
            $('.owl-carousel .item-car').removeClass('activeCar');
            $(element).addClass('activeCar');
            $('#name-car').html(element.dataset.name);
            $('#weight').html(element.dataset.weight);
            $('#estoque').html(data.estoque);
            $('#price').html(element.dataset.price);
            $('#vehicle-type').html(element.dataset.category);
    
            $('#barEstoque').css('width', element.dataset.estoque+'%');
            $('#barWeight').css('width', element.dataset.weight+'%');
            cb.load_vehicle(element.dataset.spaw)
        })
    },

    change_cam: () =>{
        app.close_footer();
        $('.freecam').animate({
            width: 200,
            borderRadius: 30,
        }, 300, function() {
            $('.freecam').find('span').show();
            $('.freecam').addClass('active-category');
        });
        if (!freeCam) {
            freeCam = true;
            $.post('https://ws-conce/chance_cam',JSON.stringify({}))
        }
    }
}

const app_action = {
    comprar_carros: () => {
        $('#main-section').animate({
            opacity: 0,
            left: "-1000",
        }, 1000, function() {
            $('selected').animate({
                right: 0,
                opacity: 1,
            }, 1000, function() {
                $.post('https://ws-conce/stopBlur');
            });
        });
        cb.create_categorias()
    },
    return_home: () => {
        $('selected').animate({
            opacity: 0,
            right: "-1000",
        }, 1000, function() {
            $('#main-section').animate({
                left: 0,
                opacity: 1,
            }, 1000, function() {
                $.post('https://ws-conce/startBlur');
            });
        });
    },
    comprar_carros2: (element) => {
        $('#main-section').animate({
            opacity: 0,
            left: "-1000",
        }, 1000, function() {
            $('selected').animate({
                right: 0,
                opacity: 1,
            }, 1000, function() {
                $.post('https://ws-conce/stopBlur');
            });
        });

        $('.card-info-car').show();
        $('.owl-carousel .item-car').removeClass('activeCar');
        $(element).addClass('activeCar');
        $('#name-car').html(element.dataset.name);
        $('#weight').html(element.dataset.weight);
        $('#estoque').html(element.dataset.estoque);
        $('#price').html(element.dataset.price);
        $('#vehicle-type').html(element.dataset.category);

        $('#barEstoque').css('width', element.dataset.estoque+'%');
        $('#barWeight').css('width', element.dataset.weight+'%');
        modelSelect = element.dataset.spaw
    },

}

const cb = {
    create_categorias: () => {
        $.post('https://ws-conce/get_categorias',JSON.stringify({}),(data)=>{
           let cat = data.categorias
           $('.category-options').empty()
           Object.entries(cat).forEach(([k, v]) => {
               $('.category-options').append(`
                    <button class="btn" onclick="cb.get_vehicles('${k}');app.select_category(this);">
                        <i class="fas fa-cars"></i>
                        <span>${k}</span>
                    </button> 
               `)
           });
        })
    },
    get_vehicles: (categoria) => {
        activeFooter = true
        app.open_footer();
        $('#removeScript').remove();
        $('.carousel-fix').empty();
        $('.carousel-fix').append(`<div class="owl-carousel ${categoria}"></div>`)
        $.post('https://ws-conce/get_vehicles',JSON.stringify({categoria:categoria}),(data)=>{
            let veiculos = data.veiculos
            Object.entries(veiculos).forEach(([k, v]) => {
                $('.'+categoria).append(`
                    <div class="item-car" 
                    data-name="${v.nome}"
                    data-spaw="${v.spaw}"


                    data-category="${categoria}"
                    data-weight="${v.peso}"
                    data-price="${formatarNumero(v.valor)}"
                    onclick="app.select_car(this)">
                        <span>${v.nome}</span>
                        <img src="http:${ip}/vehicles/${v.spaw}.png">
                    </div>
                `)
            });
            //data-estoque="${v.estoque}"
            $('body').append(`
                <script id="removeScript">
                    $('.${categoria}').owlCarousel({
                        loop:true,
                        nav: true,
                        margin:210,
                        responsiveClass:true,
                        responsive:{0:{items:2,nav:true},600:{items:4,nav:true},1000:{items:9,nav:true,}},
                        navText: ["<div class='prev'><img src='assets/565870.svg'></div>","<div class='next'><img src='assets/565870.svg'></div>"]
                    });
                </script>
            `)
        })
    },

    load_vehicle: (vehicle) => {
        $.post('https://ws-conce/load_vehicle',JSON.stringify({vehicle:vehicle}))
    },
    sell_vehicle:(spaw,name,price) => {
        $('.sell-modal').fadeIn();
        $('.extra-vehicles').hide();

        $('.sell-modal').html(`
        <div class="title-modal">Deseja vender ${name} por ${formatarNumero(price*sellPayment)}?</div>
            <img src="http://${ip}/vehicles/${spaw}.png">
            <div class="close-modal" onclick="app.close_modal()"><i class="fal fa-times"></i></div>
            <div class="modal-content">
            <i class="fas fa-exclamation-circle icon"></i>
            <span>Apos confirmar está ação nao podera ser desfeita !</span>
            <small style="position: absolute;left: 190px;opacity: .5;font-weight: 100;">seu carro será anunciado na concessionaria apos confirmar</small>
            <div class="modal-btn">
                <button onclick="app.confirm_sell('${spaw}')">Confirmar</button>
                <button onclick="app.cancel_sell()">Cancelar</button>
            </div>
        </div>
        `);
    },

    update_sell:()=>{
        $('.extra-content').empty()
        $.post('https://ws-conce/myVehicles',JSON.stringify({}),(data)=>{
            let cat = data.myVeh
            Object.entries(cat).forEach(([k, v]) => {
                $('.extra-content').append(`
                    <div class="extra-item" onclick="cb.sell_vehicle('${k}','${v.nome}',${v.price})">
                        <span>${v.nome}</span>
                        <img src="http://${ip}/vehicles/${k}.png">
                    </div>
                `)
            });
        })
    }
}

const setWindows = (index) => {
    $.post('https://ws-conce/change_window',JSON.stringify({color:index}))
}

const setXenon = (index) =>{
    $.post('https://ws-conce/change_xenon',JSON.stringify({color:index}))
}

$('.close-footer').on('click', function() {
    if (activeFooter === true) {
        activeFooter = false
        app.close_footer();
    } else {
        activeFooter = true
        app.open_footer();
    }
});

$(document).ready(function() {
	window.addEventListener("message",function(data){
        let action = event.data;
        switch(action.show){
            case "show":
                ip = action.ip;
                app.open_nui();
                
                Object.entries(action.button).forEach(([k, v]) => {
                    if (v === true) {
                        $('.card-actions').append(tamplate_button(k))
                    }
                })
                sellPayment = action.sellPayment;

                if(action.tuning == true){
                    $('.tuning').html(tamplate_tuning())
                }

                //tamplate_button
            break

            case "notify":
                $("body").fadeIn(0)
                $('notify').fadeIn(500)
                if(action.mode == "sucesso"){
                    $('notify').html(tamplate_notify_sucess(action.title,action.message));
                } else {
                    $('notify').html(tamplate_notify_error(action.title,action.message));
                }
                
                setTimeout(function(){
                    $('notify').fadeOut(500)
                },5000)
            break

            case "notifyfinish":
                $('selected').hide()
                $('notifyFinish').show()
                setTimeout(function(){
                    $('selected').show()
                    $('notifyFinish').hide()
                    app_action.return_home()
                },4000)
            break

            case "updateSell":
                cb.update_sell()
            break
        }
        if (action.freeCam == false){
            freeCam = false;
            $('.freecam').animate({
                width: 50,
                borderRadius: 100,
            }, 300, function() {
                $('.freecam').find('span').hide();
                $('.freecam').removeClass('active-category');
            });
            app.open_footer();
        }
        document.onkeyup = function(data){
			if (data.which == 27){
                app.close_nui()
			}
		}; 
    })
})

function change_slide(element) {
    if (isAnimating) {

        $('#pagination button').removeClass('activee');
        $(element).addClass('activee');

        let slideId = parseInt(element.dataset.slide, 10);

        let slideTitleEl = $('#slide-title');
        let slideImageEl = $('#slide-image');
        let slideStatusEl = $('#slide-status');

        let nextSlideImage = $(`[data-slide-img="${slideId}"]`).attr('src');
        let nextSlideTitle = $(`[data-slide-title="${slideId}"]`).html();
        let nextSlideStatus = $(`[data-slide-status="${slideId}"]`).html();

        TweenLite.fromTo(slideTitleEl, 0.5, {
                autoAlpha: 1,
                filter: 'blur(0px)',
                y: 0
            },
            {
                autoAlpha: 0,
                filter: 'blur(10px)',
                y: 20,
                ease: 'Expo.easeIn',
                onComplete: function() {
                slideTitleEl.html(nextSlideTitle);

                TweenLite.to(slideTitleEl, 0.5, {
                    autoAlpha: 1,
                    filter: 'blur(0px)',
                    y: 0
                });
            }
        });
        TweenLite.fromTo(slideStatusEl, 0.5, {
                autoAlpha: 1,
                filter: 'blur(0px)',
                y: 0
            },
            {
                autoAlpha: 0,
                filter: 'blur(10px)',
                y: 20,
                ease: 'Expo.easeIn',
                onComplete: function() {
                slideStatusEl.html(nextSlideStatus);

                TweenLite.to(slideStatusEl, 0.5, {
                    autoAlpha: 1,
                    filter: 'blur(0px)',
                    y: 0,
                    delay: 0.1
                });
            }
        });
        TweenLite.fromTo(slideImageEl, 0.5, {
                autoAlpha: 1,
                filter: 'blur(0px)',
                y: 0
            },
            {
                autoAlpha: 0,
                filter: 'blur(10px)',
                y: 20,
                ease: 'Expo.easeIn',
                onComplete: function() {
                slideImageEl.attr('src', nextSlideImage);

                TweenLite.to(slideImageEl, 0.5, {
                    autoAlpha: 1,
                    filter: 'blur(0px)',
                    y: 0,
                    delay: 0.1
                });
            }
        });
    }
};

function tamplate_notify_sucess(title,message){
    return `
    <div class="svg">
        <svg class="checkmark success" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52"><circle class="checkmark_circle_success" cx="26" cy="26" r="25" fill="none"/><path class="checkmark_check" stroke-linecap="round" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/></svg>
    </div>
    <div class="line"></div>
    <div class="text">
        <span>${title}</span><br>
        <small>${message}</small>
    </div>
    `
}

function tamplate_notify_error(title,message){
    return `
    <div class="svg">
        <svg class="checkmark error" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52"><circle class="checkmark_circle_error" cx="26" cy="26" r="25" fill="none"/><path class="checkmark_check" stroke-linecap="round" fill="none" d="M16 16 36 36 M36 16 16 36"/></svg>
    </div>
    <div class="line"></div>
    <div class="text">
        <span>${title}</span><br>
        <small>${message}</small>
    </div>
    `
}



function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
  }
    
const openTuning = () =>{
    $('.tuningContent').animate({
        width: 500,
        opacity: 1
    }, 1000);
    $('.tuningOpen').animate({
        width: 80,
        height: 130,
        borderRadius: 0,
    }, 1000);
}

const closeTuning = () =>{
    $('.tuningContent').animate({
        width: 0,
        opacity: 0
    }, 1000, function() {
    $('.tuningOpen').animate({
        width: 50,
        height: 50,
        borderRadius: 100,
    });
});
}

const formatarNumero = (n) => {
    var n = n.toString();
    var r = '';
    var x = 0;

    for (var i = n.length; i > 0; i--) {
        r += n.substr(i - 1, 1) + (x == 2 && i != 1 ? '.' : '');
        x = x == 2 ? 0 : x + 1;
    }

    return r.split('').reverse().join('');
}

const tamplate_button = (type) =>{
    switch (type){
        case "comprar":
            return `    
            <button class="action" onclick="app.action_buy(this)" data-action="buy">
                <i class="fas fa-shopping-bag"></i> 
                <div class="toltip flex">Comprar Veiculo</div>
            </button>`
        break

        case "alugar":
            return `   
            <button class="action" onclick="app.action_buy(this)" data-action="rent">
                <img src="assets/rent.svg">
                <div class="toltip flex">Alugar Veiculo</div>
            </button>`
        break

        case "test_drive":
    	    return `
            <button class="action" onclick="app.action_buy(this)" data-action="test">
                <img src="assets/driving-test.svg">
                <div class="toltip flex">Test Drive</div>
            </button>
            `
        break
    }
}

const tamplate_tuning = () =>{
    return `
    <div class="tuningOpen" style="z-index: 101;" onclick="openTuning()">
        <i class="fas fa-fire"></i>
    </div>
    <div class="tuningContent">
        <div class="tuningClose" onclick="closeTuning()">
            <i class="fal fa-times"></i>
        </div>
        <div class="content-item content-header">
            <nav>
                <ul>
                    <li class="active-tuning" onclick="app.change_tuning(this)" data-tuning="color">Cor do veiculo</li>
                    <li onclick="app.change_tuning(this)" data-tuning="window">Janelas do veiculo</li>
                    <li onclick="app.change_tuning(this)" data-tuning="light">Cor do farol</li>
                </ul>
            </nav>
        </div>
        <div class="content-item content-footer">
            <div class="scroll" id="color">
                <input type="color" id="color-input">
                <label for="color-input" id="pseudo-color-input" style="background-color: #fff;"></label>
            </div>
            <div class="scroll" id="content-tuning" style="display: none;"></div>
        </div>
    </div>

    <script>
    $('#color-input').on('change', function () {
        $(this)
        .next('#pseudo-color-input')
        .css('background-color', $(this).val());
        let carColor = [hexToRgb($(this).val()).r,hexToRgb($(this).val()).g,hexToRgb($(this).val()).b]
        $.post('https://ws-conce/change_color',JSON.stringify({color:carColor}));
    });
    </script>
    `
}