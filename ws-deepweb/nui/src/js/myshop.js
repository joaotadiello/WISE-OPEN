let myShopToken = null;

let shop = {
  open: (token,name) => {
    shop.token = token;
    shop.name = name;
    $('#inventory').show();
    $('#inventory').html(shop_tamplate());
    shop.gerarItens(token);
  },

  getPlayerInventory: () => {
    $.post('https://ws-deepweb/getInventory', JSON.stringify({}), (data) => {
      data.inventory.forEach(function (v, k) {
        $('.inventory-search').append(`
            <div class="item-search" style="display:none" 
            data-item="${v.key}"
            onclick="shop.selectItemSearch(this)">
              <img src="http://${app.ip}/itens/${v.index}.png">
              <div>
                <span>${v.name}</span>
                <small>QTD. ${v.amount}x</small>
              </div>
            </div>
          `)
      })
    });
  },

  selectItemSearch: (element) => {
    $('.item-search').hide();
    $('.item-search').removeClass('activeSearch');

    $(element).show();
    $(element).addClass('activeSearch');
    shop.itemSelecionado = element.dataset.item;
  },

  gerarItens: (token) => {
    $('.shop-itens').empty();
    $.post('https://ws-deepweb/gerarItensMeuShop', JSON.stringify({ token: token }), (data) => {
      data.itens.forEach(function (v, k) {
        $('.shop-itens').append(`
          <div class="item" data-item="${v.key}" data-price="${v.price}" data-estoque="${v.estoque}" onclick="shop.selectItemShop(this)">
            <p id="stock-item">Estoque: ${v.estoque}</p>
            <div class="item-desc">
              <small>Nome</small>
              <span id="itemName">${v.name}</span>
              <span id="price"><img src="src/img/etherium.png">${formatter.format(v.price)}</span>
            </div>
            <img id="product" src="http://${app.ip}/itens/${v.index}.png">
          </div>  
        `)
      });
      shop.refreshSaldoShop();
    })
  },

  selectItemShop: (element) => {
    $('.shop-itens .item').removeClass('active');
    $(element).addClass('active');
    shop.cache = {
      price: element.dataset.price,
      item: element.dataset.item,
      estoque: element.dataset.estoque
    }
  },

  confirmModal: () => {
    let estoque = $('#stock').val();
    let valor = $('#value').val().replace(',', '.');

    $('main').css('filter', 'blur(0px)');
    $('panel').hide();
    if (estoque.length > 0 && valor.length > 0 && shop.itemSelecionado){
      $.post('https://ws-deepweb/addItemShop', JSON.stringify({ token: shop.token, amount: estoque, price: valor, item: shop.itemSelecionado}))
      setTimeout(function(){
        shop.gerarItens(shop.token)
      },500)
    }
  },

  cancelModal: () => {
    $('main').css('filter', 'blur(0px)');
    $('panel').hide();
    shop.gerarItens(shop.token)
  },

  quantityModal:()=> {
    $('main').css('filter', 'blur(5px)');
    $('panel').show();
    $('panel').html(`
      <div class="title">Informe a Quantidade</div>

      <div class="panel-input">
        <label>Quantidade para retirar</label>
        <input id="withdrawInput" placeholder="EX: 500,00">
      </div>

      <button onclick="shop.withdraw()" class="confirmar"><i class="far fa-check icon" ></i> Aceitar</button>
      <button onclick="shop.cancelModal()" id="cancelar"><i class="fas fa-times icon"></i> Cancelar</button>
      <div class="panel-warning">
        Preencha os campos corretamente antes de aceitar!
      </div>
    `);
  },

  withdraw:()=>{
    shop.cancelModal()
    $.post('https://ws-deepweb/withdraw',JSON.stringify({token:shop.token,value:$('#withdrawInput').val()}))
    setTimeout(function(){
      shop.refreshSaldoShop();
    },500)
  },

  openModal: () => {
    $('main').css('filter', 'blur(5px)');
    $('panel').show();
    $('panel').html(`
      <div class="title">Adicionar Produto</div>
      <div class="panel-input">
        <label>Pesquisar Item</label>
        <input id="searchItens" placeholder="Pesquisar entre seus itens">
      </div>
      <div class="inventory-search"></div>
      <div class="panel-input">
        <label>Quantidade para adicionar</label>
        <input id="stock" placeholder="EX: 10">
      </div>
      <div class="panel-input">
        <label>Valor por unidade</label>
        <input id="value" placeholder="EX: 1542">
      </div>
      <button class="confirmar" onclick="shop.confirmModal()"><i class="far fa-check icon" ></i> Aceitar</button>
      <button id="cancelar" onclick="shop.cancelModal()"><i class="fas fa-times icon"></i> Cancelar</button>
      <div class="panel-warning">
        Preencha os campos corretamente antes de aceitar!
      </div>
      `);
    $("#searchItens").on("keyup", function () {
      var value = $(this).val().toLowerCase();
      $(".inventory-search .item-search").filter(function () {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
      });
      if (value.length <= 0) $('.item-search').hide()
    });
    shop.getPlayerInventory();
  },

  removeItem:()=>{
    $.post('https://ws-deepweb/removeItemShop',JSON.stringify({token:shop.token,item:shop.cache.item,price:shop.cache.price,estoque:shop.cache.estoque}))
    setTimeout(function(){
      shop.gerarItens(shop.token)
    },500)
  },

  refreshSaldoShop:()=>{
    $.post('https://ws-deepweb/refreshSaldoShop',JSON.stringify({token:shop.token}),(data)=>{
      $('.wallet-shop p').html(formatter.format(data.value))
    })
  },

  sacar:()=>{
    shop.quantityModal();
  }
}



const shop_tamplate = () => {
  let url = shop.name.replace(' ', '-');
  return `
    <header class="align-items">
      <div class="moneyType align-items">
        <img src="src/img/etherium.png">
        <span>carteira<br> <b>${wallet.atualizarSaldo()}</b>$</span>
      </div>
      <div class="url">
        <div class="prefix"><i class="fal fa-globe"></i> www</div>
        <p>${url}.onion</p>
        <div class="home" onclick="market.backHome();"><i class="fas fa-home"></i></div>
      </div>
      <div class="pageBtns">
        <div onclick="app.close()"><i class="far fa-times"></i></div>
      </div>
    </header>
    <div class="shop-content">
      <div class="container" style="width: 100%;">
        <div class="title">
          <div class="search">
            <i class="far fa-search icon"></i>
            <input placeholder="Encontrar Item">
          </div>
          <div class="wallet-shop">
            <div class="wallet-icon"><i class="fas fa-wallet"></i></div>
            <p>0</p>
            <div class="withdraw" onclick="shop.sacar()">sacar</div>
          </div>
          <div class="button-action">
            <div onclick="shop.openModal()">adicionar</div>
            <div onclick="shop.removeItem()">remover</div>
          </div>
        </div>
        <div class="shop shop-itens"></div>
      </div>
    </div>
    `
}
