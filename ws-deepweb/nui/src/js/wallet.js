const wallet = {
    open:() => {
        $('#home').hide();
        $('#wallet').show();
        $('#wallet').html(myShopsWallet());
        wallet.atualizarSaldo();
        wallet.genarateMeShops();
    },

    pegarSaldo:()=>{
        let saldo = 0.0
        return new Promise(resolve =>{
            $.post('https://ws-deepweb/atualizarSaldoCarteira',JSON.stringify({}),(data) =>{
                resolve(data.saldo)
            })
        })
    },

    genarateMeShops:()=>{
      $('.websites').empty();
      $.post('https://ws-deepweb/getMyShops',JSON.stringify({}),(data)=>{
        data.shops.forEach(function (v, k) {
          $('.websites').append(myWebsites(v.nome,v.token))
        })
      })
    },

    modalTransfer:(token)=>{
      $('main').css('filter', 'blur(5px)');
      $('panel').show();
      $('panel').html(`
        <div class="title">Transferir site</div>

        <div class="panel-input">
          <label>Passaporte</label>
          <input id="stock" placeholder="EX: 10">
        </div>

        <button class="confirmar" onclick="wallet.confirmModal('transferir','${token}')"><i class="far fa-check icon" ></i> Aceitar</button>
        <button id="cancelar" onclick="wallet.cancelModal()"><i class="fas fa-times icon"></i> Cancelar</button>
        <div class="panel-warning">
          Preencha os campos corretamente antes de aceitar!
        </div>
      `);
    },

    modalConfirm:(token)=>{
      $('main').css('filter', 'blur(5px)');
      $('panel').show();
      $('panel').html(`
        <div class="title">Excluir Website ?</div>

        <button class="confirmar" onclick="wallet.confirmModal('deletar','${token}')"><i class="far fa-check icon" ></i> Aceitar</button>
        <button id="cancelar" onclick="wallet.cancelModal()"><i class="fas fa-times icon"></i> Cancelar</button>
        <div class="panel-warning">
          Essa ação não podera ser revertida!
        </div>
      `);
    },

    confirmModal:(type,token)=>{
      $('main').css('filter', 'blur(0px)');
      $('panel').hide();
      if(type == 'deletar'){
        $.post('https://ws-deepweb/deleteShop',JSON.stringify({token:token}))
        setTimeout(function(){
          wallet.genarateMeShops();
        },500)
      } else {
        console.log(token,$('#stock').val())
        $.post('https://ws-deepweb/transferirShop',JSON.stringify({token:token,target:$('#stock').val()}))
        setTimeout(function(){
          wallet.genarateMeShops();
        },500)
      }
    },

    cancelModal:()=>{
      $('main').css('filter', 'blur(0px)');
      $('panel').hide();
    },

    infoShop:(token)=> {
      $('main').css('filter', 'blur(5px)');
      $('panel').show();
      $.post('https://ws-deepweb/infoShop',JSON.stringify({token:token}),(data)=>{
        $('panel').html(`
          <div class="title">Dados da Loja</div>

          <div class="panel-input">
            <label>Login</label>
            <input value="${data.login}" disabled>
          </div>

          <div class="panel-input">
            <label>Senha</label>
            <input value="${data.senha}" disabled>
          </div>

          <button class="confirmar" onclick="wallet.cancelModal()"><i class="far fa-check icon" ></i> Fechar</button>
          <button id="cancelar" onclick="wallet.cancelModal()"><i class="fas fa-times icon"></i> Confirmar</button>
          <div class="panel-warning">
            Essa ação não podera ser revertida!
          </div>
        `);
      })
    },

    atualizarSaldo:()=>{
        $.post('https://ws-deepweb/atualizarSaldoCarteira',JSON.stringify({}),(data) =>{
            let saldo = parseInt(data.saldo);
            $('header span').html(`carteira<br> <b>${formatter.format(saldo)}</b>`);
            return saldo;
        })
    },
}

const myWebsites = (nome,token)=>{
  let url = nome.replace(' ', '-');
  return `
  <div class="website">
    <small>${url}.onion</small>
    <div class="website-info">
      <h3>${nome}</h3>
      <button onclick="wallet.modalTransfer('${token}')">transferir</button>
      <button onclick="wallet.modalConfirm('${token}')">deletar</button>
      <button onclick="wallet.infoShop('${token}')">dados</button>
    </div>
    <p><b>Aviso:</b> Caso tenha dinheiro em seu site, realize o saque antes de <br> deletar!</p>
  </div>
  `
}

const myShopsWallet = () =>{
    return `
    <header class="align-items">
      <div class="moneyType align-items">
        <img src="src/img/etherium.png">
        <span>carteira<br> <b>0</b>$</span>
      </div>
      <div class="url">
        <div class="prefix"><i class="fal fa-globe"></i> www</div>
        <p>my-shops.onion</p>
        <div class="home" onclick="market.backHome();"><i class="fas fa-home"></i></div>
      </div>
      <div class="pageBtns">
        <div onclick="app.close()"><i class="far fa-times"></i></div>
      </div>
    </header>
    <div class="websites"></div>
    `
}