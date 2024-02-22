const market = {
    open: () =>{
        market.cart = [];
        $('#home').hide();
        $('#ilegal-shops').show();
        $('#ilegal-shops').html(marketTemplate());
        market.genarateAllShops();
    },

    close: () => {
      window.location.reload();
      $.post('http://ws-deepweb/close');
    },

    backHome: () => {
      $('section').hide();
      $('#home').show();
      $('#home').html(app.homeHTML())
    },

    genarateAllShops:()=>{
        $('.websites').empty();
        $.post('https://ws-deepweb/getAllShops',JSON.stringify({}),(data) =>{
          data.shops.forEach(function(v,k){
            let url = v.nome
            url = url.replace(' ', '-');
            $('.websites').append(`
            <div class="website">
              <small>${url}.onion</small>
              <div class="website-info">
                <h3>${v.nome}</h3>
                <button onclick="market.openShop('${v.token}','${v.nome}')">acessar</button>
              </div>
            </div> 
            `)
          });
        })
    },

    openShop:(token,nome)=>{
        market.token = token;
        $('#ilegal-shops').html(shopTamplate(nome));
        market.gerateItensShop(token)
    },

    gerateItensShop:(token)=>{
      $('.shop').empty();
      $.post('https://ws-deepweb/getItensShops',JSON.stringify({token:token}),(data) =>{
        if(data.active == 1) {
          if (data.isPolice) {
            $('.shop').html(`
              <div class="notSignal">
                <i class="far fa-signal-slash"></i>
                <h2>Erro de conexão</h2>
                <small>website criptografado</small>
              </div>
            `)
          } else {
            market.gerateItens(data.itens)
          }
        } else {
          market.gerateItens(data.itens)
        }
      })
    },

    gerateItens:(obj)=>{
      $('.shop').empty('');
      obj.forEach(function(v,k){
        $('.shop').append(`
        <div class="item">
          <div class="item-desc" data-index="${v.index}" data-key="${v.key}">
            <small>Estoque:${v.estoque}</small>
            <span>${v.name}</span>
            <span id="price"><img src="src/img/etherium.png">${formatter.format(v.price)}</span>
          </div>
          <div class="add-cart align-center"><i class="far fa-plus" data-price="${v.price}" data-index="${v.index}" data-key="${v.key}" onclick="market.openModal('${v.key}',${v.price},'${v.index}','${v.name}',${v.estoque})"></i></div>
          <img id="product" src="http://${app.ip}/itens/${v.index}.png">
        </div> 
        `)
      });
    },

    openModal: (item,itemPrice,index,name,amount) => {
      $('main').css('filter', 'blur(5px)');
      $('panel').show();
      $('panel').html(`
      <div class="title">Comprar produto</div>
      <div class="inventory-search">
        <div class="item-search" style="margin-top: 10px;">
          <img src="http://${app.ip}/itens/${index}.png">
          <div>
            <span>${name}</span>
            <small>QTD. ${amount}x</small>
          </div>
        </div>
      </div>
      <div class="panel-input">
        <label>Quantidade que deseja comprar</label>
        <input id="stock" placeholder="EX: 10">
      </div>
      <div class="panel-input">
        <label class="gambi">Valor total:</label>
      </div>
      <button class="confirmar" onclick="market.confirmModal('${item}',${itemPrice})"><i class="far fa-check icon" ></i> Aceitar</button>
      <button id="cancelar" onclick="market.cancelModal()"><i class="fas fa-times icon"></i> Cancelar</button>
      <div class="panel-warning">
        Preencha os campos corretamente antes de aceitar!
      </div>
      `);
      $('panel').on('input', function(){
        let amount = $('#stock').val()
        $('.gambi').html('Total a pagar: ' + (formatter.format(itemPrice*amount)))
      })
    },

    confirmModal:(item,price)=>{
      $('main').css('filter', 'blur(0px)');
      $('panel').hide();
      let amount = $('#stock').val();
      $.post('https://ws-deepweb/buyItem',JSON.stringify({token:market.token,item:item,price:price,amount:amount}))
      setTimeout(function(){
        market.gerateItensShop(market.token)
      },500)
    },

    cancelModal:()=>{
      $('main').css('filter', 'blur(0px)');
      $('panel').hide();
      market.gerateItensShop(market.token)
    }
}

const marketTemplate = ()=>{
    return `
    <header class="align-items">
      <div class="moneyType align-items">
        <img src="src/img/etherium.png">
        <span>carteira<br> <b>${wallet.atualizarSaldo()}</b>$</span>
      </div>
      <div class="url">
        <div class="prefix"><i class="fal fa-globe"></i> www</div>
        <p>home-market.onion</p>
        <div class="home" onclick="market.backHome();"><i class="fas fa-home"></i></div>
      </div>
      <div class="pageBtns">
        <div onclick="app.close()"><i class="far fa-times"></i></div>
      </div>
    </header>
    <div class="websites"></div>
    `
}

const shopTamplate = (nome) =>{
    let url = nome
    url = url.replace(' ', '-');
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
        <div onclick="market.open()"><i class="fas fa-chevron-left"></i></div>
        <div><i class="far fa-times" onclick="app.close()"></i></div>
      </div>
    </header>
    <div class="shop-content">
    <div class="container" style="width: 100%;">
      <div class="title">
        <div class="search">
          <i class="far fa-search icon"></i>
          <input placeholder="Encontrar Produto">
          </div>
        </div>
        <div class="shop shop-itens"></div>
      </div>
    </div>
    `
}