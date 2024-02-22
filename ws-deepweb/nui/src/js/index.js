let app = {
    open:() =>{
        $('#home').html(app.homeHTML())
        $('body').fadeIn(500);
    },

    close:()=>{
      $('body').fadeOut(500);
      window.location.reload();
      $.post('http://ws-deepweb/close')
    },

    homeHTML:()=>{
        return `
        <header class="align-items">
          <div class="moneyType align-items">
            <img src="src/img/etherium.png">
            <span>carteira<br> <b>${wallet.atualizarSaldo()}</b>$</span>
          </div>
          <div class="url">
            <div class="prefix"><i class="fal fa-globe"></i> www</div>
            <p>home.onion</p>
            <div class="home"><i class="fas fa-home"></i></div>
          </div>
          <div class="pageBtns">
            <div onclick="app.close()"><i class="far fa-times"></i></div>
          </div>
        </header>
        <content class="align-colums">
          <small>Acessar</small>
          <h1>opções disponiveis</h1>
          <div class="card-content align-center">
            <div class="card align-colums" onclick="login.open()">
              <span>acessar loja</span>
              <img src="src/img/market-icon.png">
            </div>
            <div class="card align-colums" onclick="market.open()">
              <span>Mercado Ilegal</span>
              <img src="src/img/ilegal.png">
            </div>
            <div class="card align-colums" onclick="wallet.open()">
              <span>minhas lojas</span>
              <img src="src/img/wallet.png">
            </div>
          </div>
        </content>
        `
    },

}

$(document).ready(function() {
	window.addEventListener("message",function(data){
        let _action = event.data;
      
		    switch(_action.display){
            case "show":
                app.open();
                app.policeValue = _action.policeValue;
                app.openValue = _action.openValue;
                app.ip = _action.ip;
                app.registro = _action.registro;
            break
        }
      	document.onkeyup = function(data){
			if (data.which == 27){
        close()
			}
		};
	})
})


const close = () =>{
    $('body').fadeOut(500);
	  window.location.reload();
    $.post('http://ws-deepweb/close')
}

