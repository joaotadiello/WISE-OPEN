const roubar = () => {
    return `
    <div class="thief-title">
        <div class="title-left">
            Roubar
        </div>
        <div class="title-icon">
            <i class="fad fa-search-plus"></i>
        </div>
        <div class="title-right">
            Jogador
        </div>
    </div>

    <section class="inventory-thief">
        <p id="title">Seu <b>inventário</b></p>

        <div class="thief-content person left-send"></div>
    </section>
    <section class="status-thief">
        <div class="status"><i class="fal fa-signal"></i></div>
    </section>

    <section class="thief-info">
        <div class="thief-offer">
            <p id="title">Inventario <b>interagido</b></p>
            <div class="thief-content right-send"></div>

            <input placeholder="quantidade" id="quantidadeNearest">
        </div>
    </section>
    `
}

const saquear = () => {
    return `
    <div class="thief-title">
        <div class="title-left">
            Saquear
        </div>
        <div class="title-icon">
            <i class="fad fa-search-plus"></i>
        </div>
        <div class="title-right">
            Jogador
        </div>
    </div>

    <section class="inventory-thief">
        <p id="title">Seu <b>inventário</b></p>
        <div class="thief-content person left-send"></div>

    </section>
    <section class="status-thief">
        <div class="status"><i class="fal fa-signal"></i></div>
    </section>

    <section class="thief-info">
        <div class="thief-offer">
            <p id="title">Inventario <b>interagido</b></p>
            <div class="thief-content right-send"></div>

            <input placeholder="quantidade" id="quantidadeNearest">
        </div>
    </section>
    `
}

const revistar = () => {
    return `
    <div class="inspect-title">
    <div class="title-left">
        revistar
    </div>
    <div class="title-icon">
        <i class="fad fa-siren-on"></i>
    </div>
    <div class="title-right">
        cidadão
    </div>
    </div>

    <section class="inspect-info">
        <div class="inspect-offer">
            <div class="inspect-content right-send"></div>
        </div>
    </section>
    `
}

const apreender = () => {
    return `
    <div class="inspect-title">
    <div class="title-left">
        apreender
    </div>
    <div class="title-icon">
        <i class="fad fa-siren-on"></i>
    </div>
    <div class="title-right">
        itens
    </div>
    </div>

    <section class="inspect-info">
        <div class="inspect-offer">
            <p id="title">Inventário da <b>pessoa</b></p>
            <div class="inspect-content right-send"></div>
        </div>
        <button class="btn-default"><i class="fas fa-lock-alt ico" ></i> apreender</button>
        <button class="confirm" onclick="app.sendthief()"><i class="far fa-long-arrow-right"></i></button>
    </section>
    `
}