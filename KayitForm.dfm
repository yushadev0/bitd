object KAYIT_FORM: TKAYIT_FORM
  Left = 0
  Top = 0
  ClientHeight = 600
  ClientWidth = 800
  Caption = 'KAYIT_FORM'
  BorderStyle = bsNone
  WindowState = wsMaximized
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  Script.Strings = (
    'window.currentCaptcha = '#39#39';'
    ''
    'window.generateCaptcha = function() {'
    '    console.log("Captcha '#252'retiliyor...");'
    
      '    var chars = '#39'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstu' +
      'vwxyz0123456789'#39';'
    '    var captcha = '#39#39';'
    '    for (var i = 0; i < 5; i++) {'
    
      '        captcha += chars.charAt(Math.floor(Math.random() * chars' +
      '.length));'
    '    }'
    '    window.currentCaptcha = captcha;'
    '    var displayEl = document.getElementById('#39'captchaDisplay'#39');'
    '    if (displayEl) { '
    '        displayEl.innerText = captcha; '
    '    }'
    '};'
    ''
    'window.refreshCaptcha = function() { '
    '    window.generateCaptcha(); '
    '};'
    ''
    'window.sendRegister = function() {'
    
      '    var user = document.getElementById('#39'reg_username'#39').value.tri' +
      'm();'
    
      '    var email = document.getElementById('#39'reg_email'#39').value.trim(' +
      ');'
    '    var pass = document.getElementById('#39'reg_password'#39').value;'
    
      '    var passConfirm = document.getElementById('#39'reg_password_conf' +
      'irm'#39').value;'
    '    '
    '    // Kullan'#305'c'#305'n'#305'n yazd'#305#287#305' kutu'
    
      '    var captchaInput = document.getElementById('#39'reg_captcha'#39').va' +
      'lue.trim(); '
    '    '
    '    // Ekrandaki pikselli kutuda yazan GER'#199'EK kod'
    
      '    var captchaActual = document.getElementById('#39'captchaDisplay'#39 +
      ').innerText.trim(); '
    '    '
    '    ajaxRequest(KAYIT_FORM.UniHTMLFrame1, '#39'DoRegister'#39', ['
    '        '#39'user='#39' + user, '
    '        '#39'email='#39' + email, '
    '        '#39'pass='#39' + pass, '
    '        '#39'passConfirm='#39' + passConfirm, '
    '        '#39'c_input='#39' + captchaInput,'
    '        '#39'c_actual='#39' + captchaActual'
    '    ]);'
    '};'
    ''
    'window.goBack = function() {'
    '    ajaxRequest(KAYIT_FORM.UniHTMLFrame1, '#39'GoBackLogin'#39', []);'
    '};'
    ''
    'window.toggleRegPass = function(inputId, iconId) {'
    '    var passInput = document.getElementById(inputId);'
    '    var eyeIcon = document.getElementById(iconId);'
    '    '
    '    if (passInput.type === '#39'password'#39') {'
    '        passInput.type = '#39'text'#39';'
    '        eyeIcon.classList.add('#39'active'#39');'
    '    } else {'
    '        passInput.type = '#39'password'#39';'
    '        eyeIcon.classList.remove('#39'active'#39');'
    '    }'
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
      '  html, body {'
      '    height: 100%; margin: 0; padding: 0;'
      
        '    background-color: var(--bg-dark); font-family: '#39'Outfit'#39', san' +
        's-serif;'
      '    overflow: hidden;'
      '  }'
      ''
      '  .modern-retro-wrap {'
      '    position: fixed; '
      '    top: 0; '
      '    left: 0; '
      '    width: 100vw; '
      '    height: 100vh;'
      '    display: flex; justify-content: center; align-items: center;'
      '    background-color: var(--bg-dark);'
      '    overflow: hidden;'
      '    z-index: 9999; '
      '  }'
      '  '
      '  .modern-retro-wrap::before {'
      
        '    content: '#39#39'; position: absolute; top: 0; left: 0; width: 100' +
        '%; height: 100%;'
      
        '    background: radial-gradient(circle at center, #10002b 0%, #0' +
        '00000 100%); z-index: 0;'
      '  }'
      '  .modern-retro-wrap::after {'
      
        '    content: '#39#39'; position: absolute; top: 0; left: 0; width: 100' +
        '%; height: 100%;'
      
        '    background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0,' +
        ' 0, 0, 0.25) 50%), linear-gradient(90deg, rgba(255, 0, 0, 0.06),' +
        ' rgba(0, 255, 0, 0.02), rgba(0, 0, 255, 0.06));'
      
        '    background-size: 100% 2px, 3px 100%; pointer-events: none; z' +
        '-index: 2;'
      '  }'
      '  .glass-panel {'
      
        '    background: rgba(10, 10, 25, 0.6); backdrop-filter: blur(12p' +
        'x); -webkit-backdrop-filter: blur(12px);'
      
        '    border: 1px solid rgba(5, 217, 232, 0.3); border-radius: 16p' +
        'x;'
      '    padding: 40px 30px; width: 90%; max-width: 400px;'
      
        '    text-align: center; box-shadow: 0 0 30px rgba(5, 217, 232, 0' +
        '.1); z-index: 1;'
      '  }'
      ''
      '  .brand-title {'
      
        '    font-family: '#39'Press Start 2P'#39', cursive; color: var(--neon-bl' +
        'ue);'
      
        '    font-size: 2rem; margin-bottom: 5px; text-shadow: 2px 2px 0p' +
        'x var(--neon-pink);'
      '  }'
      '  .brand-subtitle {'
      
        '    color: var(--neon-pink); font-size: 1rem; letter-spacing: 4p' +
        'x;'
      '    margin-bottom: 25px; font-weight: bold;'
      '  }'
      ''
      '  .input-wrapper { position: relative; margin-bottom: 15px; }'
      '  .cyber-input {'
      
        '    width: 100%; padding: 15px 15px 15px 10px; background: rgba(' +
        '0, 0, 0, 0.5);'
      
        '    border: none; border-bottom: 2px solid rgba(255, 255, 255, 0' +
        '.2);'
      
        '    color: #fff; font-size: 0.95rem; outline: none; transition: ' +
        '0.3s;'
      '    border-radius: 4px 4px 0 0; box-sizing: border-box;'
      '  }'
      '  .cyber-input:focus {'
      
        '    border-bottom: 2px solid var(--neon-blue); box-shadow: inset' +
        ' 0 -3px 5px -3px var(--neon-blue);'
      '  }'
      '  .cyber-input::placeholder { color: rgba(255, 255, 255, 0.4); }'
      ''
      '  .captcha-box {'
      
        '    display: flex; align-items: center; justify-content: space-b' +
        'etween;'
      
        '    background: rgba(0, 0, 0, 0.8); border: 1px dashed var(--neo' +
        'n-pink);'
      '    padding: 10px 15px; border-radius: 4px; margin-bottom: 15px;'
      '  }'
      '  .captcha-text {'
      
        '    font-family: '#39'Press Start 2P'#39', cursive; color: var(--neon-bl' +
        'ue);'
      
        '    font-size: 1.2rem; letter-spacing: 5px; text-shadow: 2px 2px' +
        ' 0px var(--neon-pink);'
      '    user-select: none; '
      
        '    background-image: repeating-linear-gradient(45deg, transpare' +
        'nt, transparent 2px, rgba(255,42,109,0.3) 2px, rgba(255,42,109,0' +
        '.3) 4px); '
      '  }'
      '  .captcha-refresh {'
      
        '    background: none; border: none; color: rgba(255,255,255,0.6)' +
        ';'
      
        '    cursor: pointer; font-size: 1.2rem; transition: all 0.3s; pa' +
        'dding: 0;'
      '  }'
      
        '  .captcha-refresh:hover { color: var(--neon-blue); transform: r' +
        'otate(180deg); }'
      ''
      '  .btn-login {'
      
        '    width: 100%; padding: 15px; background: transparent; color: ' +
        'var(--neon-blue);'
      
        '    border: 2px solid var(--neon-blue); border-radius: 4px; font' +
        '-size: 1.1rem;'
      
        '    font-weight: bold; letter-spacing: 1px; cursor: pointer; tra' +
        'nsition: 0.3s;'
      
        '    text-transform: uppercase; margin-top: 10px; margin-bottom: ' +
        '20px;'
      '  }'
      '  .btn-login:hover {'
      
        '    background: var(--neon-blue); color: #000; box-shadow: 0 0 1' +
        '5px var(--neon-blue);'
      '  }'
      '  .bottom-link {'
      
        '    color: rgba(255, 255, 255, 0.6); font-size: 0.9rem; text-dec' +
        'oration: none; transition: 0.3s;'
      '    cursor: pointer;'
      '  }'
      
        '  .bottom-link:hover { color: var(--neon-pink); text-shadow: 0 0' +
        ' 5px var(--neon-pink); }'
      ''
      '   .eye-icon {'
      '  position: absolute;'
      '  right: 12px;'
      '  top: 50%;'
      '  transform: translateY(-50%);'
      '  width: 20px;'
      '  height: 20px;'
      '  cursor: pointer;'
      '  color: rgba(255, 255, 255, 0.4);'
      '  transition: all 0.3s;'
      '  z-index: 10;'
      '}'
      '.eye-icon.active {'
      '  color: var(--neon-pink);'
      '  filter: drop-shadow(0 0 5px var(--neon-pink));'
      '}'
      '.eye-icon:hover {'
      '  color: var(--neon-blue) !important;'
      '  filter: drop-shadow(0 0 5px var(--neon-blue)) !important;'
      '}'
      ''
      '</style>'
      ''
      '<div class="modern-retro-wrap">'
      '  <div class="glass-panel">'
      '    <div class="brand-title">B.I.T.D.</div>'
      '    <div class="brand-subtitle">YEN'#304' KAYIT_</div>'
      '    '
      '    <div class="input-wrapper">'
      
        '      <input type="text" id="reg_username" class="cyber-input" p' +
        'laceholder="Kullan'#305'c'#305' Ad'#305'" autocomplete="off" autofocus tabindex' +
        '="1"'
      
        '             onkeydown="if(event.key === '#39'Enter'#39' || event.key ==' +
        '= '#39'Tab'#39') { event.preventDefault(); document.getElementById('#39'reg_' +
        'email'#39').focus(); }">'
      '    </div>'
      ''
      '    <div class="input-wrapper">'
      
        '      <input type="email" id="reg_email" class="cyber-input" pla' +
        'ceholder="E-Posta Adresi" autocomplete="off" tabindex="2"'
      
        '             onkeydown="if(event.key === '#39'Enter'#39' || event.key ==' +
        '= '#39'Tab'#39') { event.preventDefault(); document.getElementById('#39'reg_' +
        'password'#39').focus(); }">'
      '    </div>'
      '    '
      '    <div class="input-wrapper">'
      
        '      <input type="password" id="reg_password" class="cyber-inpu' +
        't" placeholder="'#350'ifre" style="padding-right: 40px;" tabindex="3"'
      
        '             onkeydown="if(event.key === '#39'Enter'#39' || event.key ==' +
        '= '#39'Tab'#39') { event.preventDefault(); document.getElementById('#39'reg_' +
        'password_confirm'#39').focus(); }">'
      
        '      <svg class="eye-icon" id="eyeIcon1" onclick="toggleRegPass' +
        '('#39'reg_password'#39', '#39'eyeIcon1'#39')" xmlns="http://www.w3.org/2000/svg"' +
        ' viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-wi' +
        'dth="2" stroke-linecap="round" stroke-linejoin="round">'
      
        '        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"><' +
        '/path>'
      '        <circle cx="12" cy="12" r="3"></circle>'
      '      </svg>'
      '    </div>'
      ''
      '    <div class="input-wrapper">'
      
        '      <input type="password" id="reg_password_confirm" class="cy' +
        'ber-input" placeholder="'#350'ifre Tekrar" style="padding-right: 40px' +
        ';" tabindex="4"'
      
        '             onkeydown="if(event.key === '#39'Enter'#39' || event.key ==' +
        '= '#39'Tab'#39') { event.preventDefault(); document.getElementById('#39'reg_' +
        'captcha'#39').focus(); }">'
      
        '      <svg class="eye-icon" id="eyeIcon2" onclick="toggleRegPass' +
        '('#39'reg_password_confirm'#39', '#39'eyeIcon2'#39')" xmlns="http://www.w3.org/2' +
        '000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" s' +
        'troke-width="2" stroke-linecap="round" stroke-linejoin="round">'
      
        '        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"><' +
        '/path>'
      '        <circle cx="12" cy="12" r="3"></circle>'
      '      </svg>'
      '    </div>'
      '    '
      '    <div class="captcha-box">'
      '      <div class="captcha-text" id="captchaDisplay"></div>'
      
        '      <button class="captcha-refresh" onclick="refreshCaptcha();' +
        ' return false;" title="Yenile">'#10227'</button>'
      '    </div>'
      '    '
      '    <div class="input-wrapper">'
      
        '      <input type="text" id="reg_captcha" class="cyber-input" pl' +
        'aceholder="G'#252'venlik Kodunu Girin" autocomplete="off" maxlength="' +
        '5" tabindex="5"'
      
        '             onkeydown="if(event.key === '#39'Enter'#39') { event.preven' +
        'tDefault(); window.sendRegister(); } else if(event.key === '#39'Tab'#39 +
        ') { event.preventDefault(); document.getElementById('#39'btnRegister' +
        #39').focus(); }">'
      '    </div>'
      ''
      
        '    <button id="btnRegister" class="btn-login" onclick="sendRegi' +
        'ster()" tabindex="6" onkeydown="if(event.key === '#39'Enter'#39') { even' +
        't.preventDefault(); window.sendRegister(); }">Sisteme Kat'#305'l_</bu' +
        'tton>'
      ''
      '    <div>'
      
        '      <a id="btnGoBack" class="bottom-link" onclick="goBack(); r' +
        'eturn false;" tabindex="7" onkeydown="if(event.key === '#39'Enter'#39') ' +
        '{ event.preventDefault(); window.goBack(); }">'#304'ptal et ve geri d' +
        #246'n</a>'
      '    </div>'
      '  </div>'
      '</div>'
      ''
      
        '<img src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEA' +
        'AAAALAAAAAABAAEAAAIBRAA7" '
      
        '     onload="if(window.generateCaptcha) { window.generateCaptcha' +
        '(); } else { setTimeout(window.generateCaptcha, 200); }" '
      '     style="display:none;">')
    Align = alClient
    OnAjaxEvent = UniHTMLFrame1AjaxEvent
  end
end
