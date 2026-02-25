object MainForm: TMainForm
  Left = 0
  Top = 0
  ClientHeight = 600
  ClientWidth = 800
  Caption = 'MainForm'
  Color = clBlack
  OnShow = UniFormShow
  BorderStyle = bsNone
  WindowState = wsMaximized
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  Script.Strings = (
    'window.openForgotPassModal = function() {'
    
      '  document.getElementById('#39'forgotPassModal'#39').classList.add('#39'show' +
      #39');'
    '  document.getElementById('#39'fpStep1'#39').style.display = '#39'block'#39';'
    '  document.getElementById('#39'fpStep2'#39').style.display = '#39'none'#39';'
    '  document.getElementById('#39'fpStep3'#39').style.display = '#39'none'#39';'
    '  document.getElementById('#39'fpEmail'#39').value = '#39#39';'
    '  document.getElementById('#39'fpCode'#39').value = '#39#39';'
    '  document.getElementById('#39'fpNewPass'#39').value = '#39#39';'
    '  document.getElementById('#39'fpNewPass2'#39').value = '#39#39';'
    '  document.getElementById('#39'fpStep1'#39').style.opacity = '#39'1'#39';'
    '};'
    ''
    'window.closeForgotPassModal = function() {'
    
      '  document.getElementById('#39'forgotPassModal'#39').classList.remove('#39's' +
      'how'#39');'
    '};'
    ''
    'window.fpSendCode = function() {'
    '  var email = document.getElementById('#39'fpEmail'#39').value;'
    
      '  if(email.trim() === '#39#39') { alert('#39'L'#252'tfen e-posta girin.'#39'); retu' +
      'rn; }'
    '  '
    '  '
    '  document.getElementById('#39'fpStep1'#39').style.opacity = '#39'0.5'#39'; '
    '  '
    ''
    
      '  ajaxRequest(MainForm.UniHTMLFrame1, '#39'FPSendCode'#39', ['#39'email='#39' + ' +
      'email]);'
    '};'
    ''
    'window.fpVerifyCode = function() {'
    '  var code = document.getElementById('#39'fpCode'#39').value;'
    '  var email = document.getElementById('#39'fpEmail'#39').value;'
    
      '  if(code.trim() === '#39#39') { alert('#39'L'#252'tfen kodu girin.'#39'); return; ' +
      '}'
    '  '
    ''
    
      '  ajaxRequest(MainForm.UniHTMLFrame1, '#39'FPVerifyCode'#39', ['#39'email='#39' ' +
      '+ email, '#39'code='#39' + code]);'
    '};'
    ''
    'window.fpSavePass = function() {'
    '  var email = document.getElementById('#39'fpEmail'#39').value;'
    '  var p1 = document.getElementById('#39'fpNewPass'#39').value;'
    '  var p2 = document.getElementById('#39'fpNewPass2'#39').value;'
    '  '
    
      '  if(p1.trim() === '#39#39' || p2.trim() === '#39#39') { alert('#39#350'ifre alanla' +
      'r'#305' bo'#351' b'#305'rak'#305'lamaz!'#39'); return; }'
    
      '  if(p1 !== p2) { alert('#39#350'ifreler birbiriyle e'#351'le'#351'miyor!'#39'); retu' +
      'rn; }'
    '  '
    
      '  ajaxRequest(MainForm.UniHTMLFrame1, '#39'FPSavePass'#39', ['#39'email='#39' + ' +
      'email, '#39'pass='#39' + p1]);'
    '};')
  TextHeight = 15
  object UniHTMLFrame1: TUniHTMLFrame
    Left = 0
    Top = 0
    Width = 800
    Height = 600
    Hint = ''
    HTML.Strings = (
      '<style>'
      
        '  @import url('#39'https://fonts.googleapis.com/css2?family=Press+St' +
        'art+2P&family=Outfit:wght@300;400;700&display=swap'#39');'
      ''
      '  :root {'
      '    --neon-pink: #ff2a6d;'
      '    --neon-blue: #05d9e8;'
      '    --bg-dark: #01012b;'
      '  }'
      ''
      '  /* Ana Container */'
      '.modern-retro-wrap {'
      '    position: fixed; '
      '    top: 0; '
      '    left: 0; '
      '    width: 100vw; '
      '    height: 100vh;'
      '    display: flex; justify-content: center; align-items: center;'
      '    background-color: var(--bg-dark);'
      '    overflow: hidden;'
      '    z-index: 9999;'
      '  }'
      ''
      '  /* Arka Plan Efektleri (Bulan'#305'k afi'#351'ler/grid hissi) */'
      '  .modern-retro-wrap::before {'
      '    content: '#39#39';'
      '    position: absolute;'
      '    top: 0; left: 0; width: 100%; height: 100%;'
      
        '    /* Buraya ileride oyun/film kolaj'#305' olan bir g'#246'rsel linki koy' +
        'abilirsin */'
      
        '    background: radial-gradient(circle at center, #10002b 0%, #0' +
        '00000 100%);'
      '    z-index: 0;'
      '  }'
      ''
      '  /* CRT Tarama '#199'izgileri */'
      '  .modern-retro-wrap::after {'
      '    content: '#39#39';'
      '    position: absolute;'
      '    top: 0; left: 0; width: 100%; height: 100%;'
      
        '    background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0,' +
        ' 0, 0, 0.25) 50%), linear-gradient(90deg, rgba(255, 0, 0, 0.06),' +
        ' rgba(0, 255, 0, 0.02), rgba(0, 0, 255, 0.06));'
      '    background-size: 100% 2px, 3px 100%;'
      '    pointer-events: none;'
      '    z-index: 2;'
      '  }'
      ''
      '  /* Cam Efektli (Glassmorphism) Giri'#351' Kutusu */'
      '  .glass-panel {'
      '    background: rgba(10, 10, 25, 0.6);'
      '    backdrop-filter: blur(12px);'
      '    -webkit-backdrop-filter: blur(12px);'
      '    border: 1px solid rgba(5, 217, 232, 0.3);'
      '    border-radius: 16px;'
      '    padding: 40px 30px;'
      '    width: 90%;'
      '    max-width: 400px;'
      '    text-align: center;'
      '    box-shadow: 0 0 30px rgba(5, 217, 232, 0.1);'
      '    z-index: 1;'
      '  }'
      ''
      '  /* Logo Alan'#305' */'
      '  .cat-logo-placeholder {'
      '    width: 80px;'
      '    height: 80px;'
      '    margin: 0 auto 15px auto;'
      '    background-color: transparent;'
      '    border-radius: 50%;'
      
        '    /* Logonu ekledi'#287'inde img tagi ile buray'#305' de'#287'i'#351'tirebilirsin ' +
        '*/'
      '    border: 2px dashed var(--neon-pink); '
      '    display: flex;'
      '    justify-content: center;'
      '    align-items: center;'
      '    color: var(--neon-pink);'
      '    font-size: 0.8rem;'
      '    box-shadow: 0 0 15px rgba(255, 42, 109, 0.4);'
      '  }'
      ''
      '  /* Ba'#351'l'#305'klar */'
      '  .brand-title {'
      '    font-family: '#39'Press Start 2P'#39', cursive;'
      '    color: var(--neon-blue);'
      '    font-size: 2rem;'
      '    margin-bottom: 5px;'
      '    text-shadow: 2px 2px 0px var(--neon-pink);'
      '  }'
      ''
      '  .brand-subtitle {'
      '    color: #fff;'
      '    font-size: 0.9rem;'
      '    letter-spacing: 3px;'
      '    margin-bottom: 35px;'
      '    opacity: 0.7;'
      '  }'
      ''
      '  /* Modern Inputlar */'
      '  .input-wrapper {'
      '    position: relative;'
      '    margin-bottom: 25px;'
      '  }'
      ''
      '  .cyber-input {'
      '    width: 100%;'
      '    padding: 15px 15px 15px 10px;'
      '    background: rgba(0, 0, 0, 0.5);'
      '    border: none;'
      '    border-bottom: 2px solid rgba(255, 255, 255, 0.2);'
      '    color: #fff;'
      '    font-size: 1rem;'
      '    outline: none;'
      '    transition: 0.3s;'
      '    border-radius: 4px 4px 0 0;'
      '    box-sizing: border-box;'
      '  }'
      ''
      '  .cyber-input:focus {'
      '    border-bottom: 2px solid var(--neon-blue);'
      '    box-shadow: inset 0 -3px 5px -3px var(--neon-blue);'
      '  }'
      ''
      '  .cyber-input::placeholder {'
      '    color: rgba(255, 255, 255, 0.4);'
      '  }'
      ''
      '  /* Buton */'
      '  .btn-login {'
      '    width: 100%;'
      '    padding: 15px;'
      '    background: transparent;'
      '    color: var(--neon-pink);'
      '    border: 2px solid var(--neon-pink);'
      '    border-radius: 4px;'
      '    font-size: 1.1rem;'
      '    font-weight: bold;'
      '    letter-spacing: 1px;'
      '    cursor: pointer;'
      '    transition: 0.3s;'
      '    text-transform: uppercase;'
      '    margin-top: 10px;'
      '  }'
      ''
      '  .btn-login:hover {'
      '    background: var(--neon-pink);'
      '    color: #fff;'
      '    box-shadow: 0 0 15px var(--neon-pink);'
      '  }'
      '  '
      ' /* G'#246'z '#304'konu Standart Tasar'#305'm'#305' */'
      '  .eye-icon {'
      '    position: absolute;'
      '    right: 12px;'
      '    top: 50%;'
      '    transform: translateY(-50%);'
      '    width: 20px;'
      '    height: 20px;'
      '    cursor: pointer;'
      '    color: rgba(255, 255, 255, 0.4);'
      '    transition: all 0.3s;'
      '  }'
      ''
      
        '  /* '#350'ifre G'#246'r'#252'n'#252'r Oldu'#287'undaki Durum (T'#305'kland'#305#287#305'nda JS bu class'#39 +
        #305' ekleyecek) */'
      '  .eye-icon.active {'
      '    color: var(--neon-pink);'
      '    filter: drop-shadow(0 0 5px var(--neon-pink));'
      '  }'
      ''
      
        '  /* Hover (CSS hiyerar'#351'isinde en altta olmal'#305' ki active durumun' +
        'u da ezebilsin) */'
      '  .eye-icon:hover {'
      '    color: var(--neon-blue) !important;'
      '    filter: drop-shadow(0 0 5px var(--neon-blue)) !important;'
      '  }'
      '  '
      '  /* Alt Se'#231'enekler Konteyneri */'
      '  .action-options {'
      '    display: flex;'
      '    flex-direction: column;'
      '    align-items: center;'
      '    margin-top: 10px; /* '#350'ifre kutusundan biraz uzakla'#351't'#305'rd'#305'k */'
      '    margin-bottom: 25px; /* Butonla aras'#305'na bo'#351'luk koyduk */'
      '    gap: 15px; /* Checkbox ile linkler aras'#305' bo'#351'luk */'
      '  }'
      ''
      '  /* Beni Hat'#305'rla Kutusu */'
      '  .remember-box {'
      '    display: flex;'
      '    align-items: center;'
      '    gap: 8px;'
      '    color: rgba(255, 255, 255, 0.7);'
      '    font-size: 0.95rem;'
      '    cursor: pointer;'
      '  }'
      ''
      '  .remember-box input[type="checkbox"] {'
      '    accent-color: var(--neon-pink);'
      '    cursor: pointer;'
      '    width: 16px;'
      '    height: 16px;'
      '  }'
      ''
      '  .remember-box label {'
      '    cursor: pointer;'
      '  }'
      ''
      '  /* Retro Linkler */'
      '  .retro-links {'
      '    display: flex;'
      '    gap: 15px;'
      '    font-size: 0.85rem;'
      '  }'
      ''
      '  .retro-links a {'
      '    color: var(--neon-blue);'
      '    text-decoration: none;'
      '    transition: all 0.3s;'
      '    letter-spacing: 1px;'
      '    opacity: 0.8;'
      '    cursor: pointer;'
      '  }'
      ''
      '  .retro-links a:hover {'
      '    color: var(--neon-pink);'
      '    opacity: 1;'
      '    text-shadow: 0 0 8px var(--neon-pink);'
      '  }'
      ''
      '  .retro-links .divider {'
      '    color: rgba(255, 255, 255, 0.2);'
      '  }'
      '  '
      '  .fp-modal-overlay {'
      
        '    position: fixed; top: 0; left: 0; width: 100vw; height: 100v' +
        'h;'
      '    background: rgba(1, 1, 43, 0.9); z-index: 9999;'
      '    display: flex; justify-content: center; align-items: center;'
      '    backdrop-filter: blur(5px);'
      '    opacity: 0; visibility: hidden; '
      '    transition: all 0.4s ease;'
      '  }'
      '  .fp-modal-overlay.show {'
      '    opacity: 1; visibility: visible;'
      '  }'
      '  '
      '  .fp-modal-content {'
      
        '    background: rgba(10, 10, 35, 0.95); border: 1px solid var(--' +
        'neon-pink);'
      
        '    padding: 40px; border-radius: 10px; width: 90%; max-width: 4' +
        '00px;'
      
        '    text-align: center; box-shadow: 0 0 30px rgba(255, 42, 109, ' +
        '0.3);'
      '    position: relative;'
      '    transform: translateY(-50px) scale(0.9); opacity: 0;'
      
        '    transition: all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275)' +
        '; /* Yaylanma efekti */'
      '  }'
      '  .fp-modal-overlay.show .fp-modal-content {'
      '    transform: translateY(0) scale(1); opacity: 1;'
      '  }'
      '</style>'
      ''
      '<div class="modern-retro-wrap">'
      '  <div class="glass-panel">'
      '    '
      '    <div class="brand-title">B.I.T.D.</div>'
      '    <div class="brand-subtitle">BACK IN THE DAY</div>'
      '    '
      '    <div class="input-wrapper">'
      
        '      <input type="text" id="username" class="cyber-input" place' +
        'holder="Kullan'#305'c'#305' Ad'#305'" autocomplete="off" autofocus '
      
        '             onkeydown="if(event.key === '#39'Enter'#39' || event.key ==' +
        '= '#39'Tab'#39') { event.preventDefault(); document.getElementById('#39'pass' +
        'word'#39').focus(); }">'
      '    </div>'
      '    '
      '    <div class="input-wrapper">'
      
        '      <input type="password" id="password" class="cyber-input" p' +
        'laceholder="'#350'ifre" style="padding-right: 40px;" '
      
        '             onkeydown="if(event.key === '#39'Enter'#39') { event.preven' +
        'tDefault(); window.sendLogin(); } else if(event.key === '#39'Tab'#39') {' +
        ' event.preventDefault(); document.getElementById('#39'btnLogin'#39').foc' +
        'us(); }">'
      '      '
      
        '      <svg class="eye-icon" id="eyeIcon" onclick="togglePassword' +
        '()" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill=' +
        '"none" stroke="currentColor" stroke-width="2" stroke-linecap="ro' +
        'und" stroke-linejoin="round">'
      
        '        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"><' +
        '/path>'
      '        <circle cx="12" cy="12" r="3"></circle>'
      '      </svg>'
      '    </div>'
      '    '
      '    <div class="action-options">'
      '      <div class="remember-box">'
      '        <input type="checkbox" id="rememberMe">'
      '        <label for="rememberMe">Oturumum A'#231#305'k Kals'#305'n_</label>'
      '      </div>'
      '      '
      '      <div class="retro-links">'
      
        '        <a onclick="window.openForgotPassModal(); return false;"' +
        '>'#350'ifremi Unuttum</a>'
      '        <span class="divider">|</span>'
      '        <a onclick="signUp(); return false;">Kay'#305't Ol</a>'
      '      </div>'
      '    </div>'
      '    '
      
        '    <button id="btnLogin" class="btn-login" onclick="sendLogin()' +
        '" onkeydown="if(event.key === '#39'Enter'#39') { event.preventDefault();' +
        ' window.sendLogin(); }">Sisteme Gir_</button>'
      '    '
      '    </div>'
      '</div>'
      ''
      '<div class="fp-modal-overlay" id="forgotPassModal">'
      '  <div class="fp-modal-content">'
      
        '    <i class="fa-solid fa-xmark" style="position:absolute; top:1' +
        '5px; right:20px; color:#fff; cursor:pointer; font-size:1.5rem; t' +
        'ransition:0.3s;" onmouseover="this.style.color='#39'#ff2a6d'#39'" onmous' +
        'eout="this.style.color='#39'#fff'#39'" onclick="window.closeForgotPassMo' +
        'dal()"></i>'
      '    '
      '    <div id="fpStep1">'
      
        '      <h3 style="color:#ff2a6d; font-family:'#39'Press Start 2P'#39', cu' +
        'rsive; font-size:0.8rem; margin-bottom:20px;">A'#286'A ER'#304#350#304'M KURTARM' +
        'A_</h3>'
      
        '      <p style="color:#aaa; font-size:0.8rem; margin-bottom:20px' +
        '; font-family:'#39'Outfit'#39', sans-serif;">Sisteme kay'#305'tl'#305' e-posta adr' +
        'esinizi girin. Size tek kullan'#305'ml'#305'k bir '#351'ifre (OTP) g'#246'nderece'#287'iz' +
        '.</p>'
      '      '
      
        '      <input type="email" id="fpEmail" placeholder="E-Posta Adre' +
        'si" style="width:100%; padding:15px; background:rgba(5,5,25,0.8)' +
        '; border:1px solid #05d9e8; color:#fff; margin-bottom:20px; outl' +
        'ine:none; border-radius:5px; box-sizing:border-box; font-family:' +
        #39'Outfit'#39', sans-serif;"'
      
        '             onkeydown="if(event.key === '#39'Enter'#39') { event.preven' +
        'tDefault(); window.fpSendCode(); }">'
      '             '
      
        '      <button onclick="window.fpSendCode()" style="width:100%; p' +
        'adding:15px; background:rgba(255,42,109,0.1); border:1px solid #' +
        'ff2a6d; color:#ff2a6d; cursor:pointer; font-family:'#39'Press Start ' +
        '2P'#39', cursive; font-size:0.7rem; transition:0.3s;" onmouseover="t' +
        'his.style.background='#39'#ff2a6d'#39'; this.style.color='#39'#fff'#39';" onmous' +
        'eout="this.style.background='#39'rgba(255,42,109,0.1)'#39'; this.style.c' +
        'olor='#39'#ff2a6d'#39';">KOD G'#214'NDER</button>'
      '    </div>'
      ''
      '    <div id="fpStep2" style="display:none;">'
      
        '      <h3 style="color:#05d9e8; font-family:'#39'Press Start 2P'#39', cu' +
        'rsive; font-size:0.8rem; margin-bottom:20px;">KODU G'#304'R'#304'N_</h3>'
      
        '      <p style="color:#aaa; font-size:0.8rem; margin-bottom:20px' +
        '; font-family:'#39'Outfit'#39', sans-serif;">Mail adresinize g'#246'nderilen ' +
        '6 haneli kodu girin.</p>'
      '      '
      
        '      <input type="text" id="fpCode" maxlength="6" placeholder="' +
        #214'rn: 849201" style="width:100%; padding:15px; background:rgba(5,' +
        '5,25,0.8); border:1px solid #05d9e8; color:#fff; text-align:cent' +
        'er; font-size:1.5rem; letter-spacing:10px; margin-bottom:20px; o' +
        'utline:none; border-radius:5px; box-sizing:border-box; font-fami' +
        'ly:'#39'Outfit'#39', sans-serif;"'
      
        '             onkeydown="if(event.key === '#39'Enter'#39') { event.preven' +
        'tDefault(); window.fpVerifyCode(); }">'
      '             '
      
        '      <button onclick="window.fpVerifyCode()" style="width:100%;' +
        ' padding:15px; background:rgba(5,217,232,0.1); border:1px solid ' +
        '#05d9e8; color:#05d9e8; cursor:pointer; font-family:'#39'Press Start' +
        ' 2P'#39', cursive; font-size:0.7rem; transition:0.3s;" onmouseover="' +
        'this.style.background='#39'#05d9e8'#39'; this.style.color='#39'#000'#39';" onmou' +
        'seout="this.style.background='#39'rgba(5,217,232,0.1)'#39'; this.style.c' +
        'olor='#39'#05d9e8'#39';">DO'#286'RULA</button>'
      '    </div>'
      ''
      '    <div id="fpStep3" style="display:none;">'
      
        '      <h3 style="color:#05d9e8; font-family:'#39'Press Start 2P'#39', cu' +
        'rsive; font-size:0.8rem; margin-bottom:20px;">YEN'#304' '#350#304'FRE OLU'#350'TUR' +
        '_</h3>'
      '      '
      
        '      <input type="password" id="fpNewPass" placeholder="Yeni '#350'i' +
        'fre" style="width:100%; padding:15px; background:rgba(5,5,25,0.8' +
        '); border:1px solid #05d9e8; color:#fff; margin-bottom:10px; out' +
        'line:none; border-radius:5px; box-sizing:border-box; font-family' +
        ':'#39'Outfit'#39', sans-serif;"'
      
        '             onkeydown="if(event.key === '#39'Enter'#39' || event.key ==' +
        '= '#39'Tab'#39') { event.preventDefault(); document.getElementById('#39'fpNe' +
        'wPass2'#39').focus(); }">'
      '             '
      
        '      <input type="password" id="fpNewPass2" placeholder="Yeni '#350 +
        'ifre (Tekrar)" style="width:100%; padding:15px; background:rgba(' +
        '5,5,25,0.8); border:1px solid #05d9e8; color:#fff; margin-bottom' +
        ':20px; outline:none; border-radius:5px; box-sizing:border-box; f' +
        'ont-family:'#39'Outfit'#39', sans-serif;"'
      
        '             onkeydown="if(event.key === '#39'Enter'#39') { event.preven' +
        'tDefault(); window.fpSavePass(); }">'
      '             '
      
        '      <button onclick="window.fpSavePass()" style="width:100%; p' +
        'adding:15px; background:rgba(5,217,232,0.1); border:1px solid #0' +
        '5d9e8; color:#05d9e8; cursor:pointer; font-family:'#39'Press Start 2' +
        'P'#39', cursive; font-size:0.7rem; transition:0.3s;" onmouseover="th' +
        'is.style.background='#39'#05d9e8'#39'; this.style.color='#39'#000'#39';" onmouse' +
        'out="this.style.background='#39'rgba(5,217,232,0.1)'#39'; this.style.col' +
        'or='#39'#05d9e8'#39';">'#350#304'FREY'#304' G'#220'NCELLE</button>'
      '    </div>'
      ''
      '  </div>'
      '</div>')
    Align = alClient
    ClientEvents.ExtEvents.Strings = (
      
        'afterrender=function afterrender(sender, eOpts)'#13#10'{'#13#10'    window.s' +
        'endLogin = function() {'#13#10'        var user = document.getElementB' +
        'yId('#39'username'#39').value;'#13#10'        var pass = document.getElementBy' +
        'Id('#39'password'#39').value;'#13#10'        var rem = document.getElementById' +
        '('#39'rememberMe'#39').checked ? '#39'1'#39' : '#39'0'#39';'#13#10'        '#13#10'        ajaxReque' +
        'st(sender, '#39'TestSinyali'#39', ['#39'user='#39' + user, '#39'pass='#39' + pass, '#39'reme' +
        'mber='#39' + rem]);'#13#10'    };'#13#10'    '#13#10' window.togglePassword = function' +
        '() {'#13#10'        var passInput = document.getElementById('#39'password'#39 +
        ');'#13#10'        var eyeIcon = document.getElementById('#39'eyeIcon'#39');'#13#10' ' +
        '       '#13#10'        if (passInput.type === '#39'password'#39') {'#13#10'         ' +
        '   passInput.type = '#39'text'#39'; // '#350'ifreyi g'#246'r'#252'n'#252'r yap'#13#10'            ' +
        'eyeIcon.style.color = '#39'var(--neon-pink)'#39'; // Rengi neon pembe ya' +
        'p'#13#10'            eyeIcon.style.filter = '#39'drop-shadow(0 0 5px var(-' +
        '-neon-pink))'#39';'#13#10'        } else {'#13#10'            passInput.type = '#39 +
        'password'#39'; // '#350'ifreyi tekrar gizle'#13#10'            eyeIcon.style.co' +
        'lor = '#39'rgba(255, 255, 255, 0.4)'#39'; // Eski rengine d'#246'n'#13#10'         ' +
        '   eyeIcon.style.filter = '#39'none'#39';'#13#10'        }'#13#10'    };'#13#10'    '#13#10'    ' +
        'window.forgotPassword = function() {'#13#10'        ajaxRequest(sender' +
        ', '#39'ForgotPassword'#39', []);'#13#10'    };'#13#10#13#10'    window.signUp = function' +
        '() {'#13#10'        ajaxRequest(sender, '#39'SignUp'#39', []);'#13#10'    };'#13#10'    '#13#10 +
        '}')
    OnAjaxEvent = UniHTMLFrame1AjaxEvent
  end
end
