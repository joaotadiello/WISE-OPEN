let slots = {
    usage:{},
    receita:null,
    _itemReceita:null,
    _indexItem:null,
    _itemIndex:null,
    _inCraft:false,

    insertSlotItem:(index,item,amount,slot,ip,name) => {
        slots.usage[slot] = {index:index,item:item,amount:amount,name:name}
        slots.updateSlots(ip)
    },

    initUsage:(ip) => {
        if(!slots._inCraft){
            $.post("https://ws-craft/refound", JSON.stringify({})) //Da o reembolso dos itens para o player
            $('.result-right').hide();
            slots.usage = {}
            bar.set(0,true);
            slots.updateSlots(ip);
            $('.result-center img').attr('src',`assets/empty.png`);
            app.updateItensUser(); //Atualiza os itens do player
            thiefUpdateOptions();
        }
    },

    init:(ip) =>{
        slots._inCraft = false
        slots.usage = {}
        $('.result-right').hide();
        slots.updateSlots(ip);
        bar.set(0,true);
        $('.result-center img').attr('src',`assets/empty.png`);
        app.updateItensUser(); //Atualiza os itens do player
        thiefUpdateOptions();
    },

    updateSlots:(ip) =>{
        $('.craft-table').empty();
        for(var i=0;i <= 8;i++){
            if(slots.usage[i]){
                $('.craft-table').append(`
                <div class="item active">
                    <img src="${ip}/${slots.usage[i].item}.png">
                    <span>${slots.usage[i].name}</span>
                    <small>${slots.usage[i].amount}x</small>
                </div>
                `)
            } else {
                $('.craft-table').append(`<div class="item" data-slot="${i}"></div>`)
            }
        }
        if(slots.checkReceita()){
            $('.result-center img').attr('src',`${ip}/${slots._indexItem}.png`)
            $('.craft-table').fadeOut(1000);
        }
    },

    checkReceita:() =>{
        var erros = 0
        var acertos = 0

        // Gera o numero de acertos que precisa ter
        Object.entries(slots.receita).forEach(([k,v])=>{
            acertos++
        })

        // Cada vez  que o item esta no local correto diminui 1 acerto, caso erre 1, adiciona em erros
        Object.entries(slots.usage).forEach(([k,v])=>{
            if(slots.receita[k]){
                if(slots.receita[k].item == v.item && slots.receita[k].amount === parseInt(v.amount)){
                    acertos--
                } else {
                    erros++
                }
            } else {
                erros++
            }
        })

        if(erros == 0 && acertos == 0){
            $('.recipe-send').empty();
            $('.result-right').show();
            return true
        }
    },
}