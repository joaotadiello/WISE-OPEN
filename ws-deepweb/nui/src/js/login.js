let cachelogin = {}
let checked = false

const login = {
    open: () =>{
        $('#home').hide();
        $('#formShop').show();
        if(app.registro){
          $('#formShop').html(form_tamplate('Acessar','conta da deep web'));
        } else {
          $('#formShop').html(form_tamplate_2('Acessar','conta da deep web'));
        }
    },

    criarLogin:()=>{
        $('#formShop').html(register_tamplate('Registrar','conta na deep web'));
        checked = false
    },

    checkToken: () => {
      cachelogin.token = $('#loginShop').val()
        $.post('https://ws-deepweb/checkToken',JSON.stringify({token:$('#loginShop').val(),password:$('#senhaShop').val()}),(data) =>{
          let autenticado = data.autenticado
          if (autenticado) {
            login.loginSucess(data.name);
          } else {
            login.criarLogin();
          }
      })
    },

    loginSucess:(name)=>{
        $('#formShop').hide();
        $('#formShop').empty();
        shop.open(cachelogin.token,name);
    },

    confirmarRegistro:()=>{
      let login = $('#loginShop').val();
      let password = $('#senhaShop').val();
      let name = $('#shopName').val()
      if (login.length > 0 && password.length > 0 && name.length > 0){
        $.post('https://ws-deepweb/criarLoja',JSON.stringify({police:checked,login:login,password:password,name:name}),(data) =>{
          let autenticado = data.autenticado
          if (autenticado){
            $('#formShop').empty();
            $('#formShop').html(form_tamplate('Acessar','conta da deep web'));
          }
        })
      }
    },

    cancelarRegistro:()=>{
      $('#formShop').empty();
      $('#formShop').html(form_tamplate('Acessar','conta da deep web'));
    },

    cancelarLogin:()=>{
      $('#formShop').hide();
      $('#formShop').empty();
      $('#home').show();
      app.open();
    },

    checked:(element)=>{
      checked = !checked;
      if (checked) {
        let result = app.openValue + app.policeValue
        $('#totalPrice').html(`<b>${config.moeda}</b> ${result}`)
      } else {
        let result = (app.openValue + app.policeValue) - app.policeValue
        $('#totalPrice').html(`<b>${config.moeda}</b> ${result}`)
      }
    },
}

const form_tamplate = (text,text2) =>{
    return `
        <div class="title-form">
        <img src="src/img/navegador.png">
        <h1>${text} <br> ${text2}</h1>
        </div>
        <div class="form">
          <div class="steps">
            <div class="step active"></div>
            <div class="step"></div>
          </div>
          <div class="form-input">
            <label>Login</label>
            <input id="loginShop" placeholder="Seu Login..." required>
          </div>
          <div class="form-input">
            <label>Senha</label>
            <input id="senhaShop" placeholder="Sua senha..." required>
          </div>
          <div class="form-actions">
            <button onclick="login.cancelarLogin()">cancelar</button>
            <input type="submit" value="confirmar" onclick="login.checkToken()">
            <button onclick="login.criarLogin()">registrar-se</button>
          </div>
        </div>
        <img id="anonymous" src="src/img/anonymo.png">
    `
}

const form_tamplate_2 = (text,text2) =>{
  return `
      <div class="title-form">
      <img src="src/img/navegador.png">
      <h1>${text} <br> ${text2}</h1>
      </div>
      <div class="form">
        <div class="steps">
          <div class="step active"></div>
          <div class="step"></div>
        </div>
        <div class="form-input">
          <label>Login</label>
          <input id="loginShop" placeholder="Seu Login..." required>
        </div>
        <div class="form-input">
          <label>Senha</label>
          <input id="senhaShop" placeholder="Sua senha..." required>
        </div>
        <div class="form-actions">
          <button onclick="login.cancelarLogin()">cancelar</button>
          <input type="submit" value="confirmar" onclick="login.checkToken()">
        </div>
      </div>
      <img id="anonymous" src="src/img/anonymo.png">
  `
}

const register_tamplate = (text,text2) =>{
  return `
      <div class="title-form">
      <img src="src/img/navegador.png">
      <h1>${text} <br> ${text2}</h1>
      </div>
      <div class="form" id="registerForms">
        <div class="steps">
          <div class="step active"></div>
          <div class="step"></div>
        </div>
        <div class="checkboxs">
          <div class="check-input">
            <div class="toltip">Protege sua loja contra acesso de policiais,<br> usando metodos de criptografia!</div>
            <label for="policept">Proteção contra<br> policia</label>
            <input id="policept" type="checkbox" style="right: -85px;" onclick="login.checked('police')">
          </div>
        </div>
        <div class="form-input">
          <label>Nome da Loja</label>
          <input id="shopName" placeholder="Nome da Loja..." required>
        </div>
        <div class="form-input">
          <label>Login</label>
          <input id="loginShop" placeholder="Seu Login..." required>
        </div>
        <div class="form-input">
          <label>Senha</label>
          <input id="senhaShop" placeholder="Sua senha..." required>
        </div>
        <div class="form-actions">
          <button onclick="login.cancelarRegistro()">cancelar</button>
          <input type="submit" onclick="login.confirmarRegistro()" value="confirmar">
          <small id="totalPrice" style="margin-left:6px;font-size:15px"> <b>R$</b> ${app.openValue}</small>
        </div>

      </div>
      <img id="anonymous" src="src/img/anonymo.png">
  `
}


