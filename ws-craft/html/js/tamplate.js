const gerarReceitasDisponiveis = (ip) =>{
    $('.recipe-send').empty();
    $.post('https://ws-craft/updateReceitas',JSON.stringify({}),(data)=>{
        data.receitas.forEach(function(v,k){
            $('.recipe-send').append(`                
            <div class="item" onclick="openTable('${v}')">
                <img src="${ip}/${v}.png">
            </div>`)
        })
    });
}

const gerarMeusItens = (itens) =>{
    itens.forEach(function(v,k){
        $('.inspect-content').append(`
        <div class="item">
            <span>${v.name}</span>
            <img src="${ip}/${v.index}.png">
            <small>${v.amount}x</small>
        </div>
        `)
    })
}

const openModal = (slot,nomeDoItem,key,index) =>{
    $('.modal').empty();
    $('.modal').show();
    $('.modal').append(`
        <span>${nomeDoItem}</span>
        <div class="close-modal" onclick="close_modal()">
        <i class="fal fa-times"></i></div>
        <div class="flex">
            <input id="amountModal" value ="1" placeholder="insira aqui..." type="number">
            <button class="confirm" onclick="confirmarModal('${key}','${index}', ${slot},'${nomeDoItem}')">confirmar</button>
        </div>
    `)
}
