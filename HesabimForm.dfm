object HESABIM_FORM: THESABIM_FORM
  Left = 0
  Top = 0
  ClientHeight = 600
  ClientWidth = 800
  Caption = 'HESABIM_FORM'
  OnShow = UniFormShow
  BorderStyle = bsNone
  WindowState = wsMaximized
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  Script.Strings = (
    '  /* MENU AC/KAPAT */'
    '  window.toggleSidebar = function() {'
    '      var sidebar = document.getElementById('#39'sidebar'#39');'
    '      var overlay = document.getElementById('#39'sidebarOverlay'#39');'
    '      if (sidebar && overlay) {'
    '          sidebar.classList.toggle('#39'open'#39');'
    '          overlay.classList.toggle('#39'show'#39');'
    '      }'
    '  };'
    ''
    '  /* PROFIL (KULLANICI ADI & E-POSTA) GUNCELLEME ISTEGI */'
    '  window.reqUpdateProfile = function() {'
    
      '      var newUname = document.getElementById('#39'accUsername'#39').valu' +
      'e.trim();'
    
      '      var newEmail = document.getElementById('#39'accEmail'#39').value.t' +
      'rim();'
    '      '
    '      if (newUname === '#39#39' || newEmail === '#39#39') {'
    
      '          alert('#39'Sistem Uyar'#305's'#305': Kullan'#305'c'#305' ad'#305' veya E-Posta bo'#351' ' +
      'b'#305'rak'#305'lamaz.'#39');'
    '          return;'
    '      }'
    '      '
    '      /* E-Posta formati kontrolu */'
    '      var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;'
    '      if (!emailPattern.test(newEmail)) {'
    
      '          alert('#39'Hatal'#305' ileti'#351'im koordinat'#305' (Ge'#231'ersiz E-Posta fo' +
      'rmat'#305').'#39');'
    '          return;'
    '      }'
    ''
    
      '      var swalHTML = '#39'<span style="color:var(--neon-pink); font-' +
      'weight:bold;">D'#304'KKAT!</span><br>Bilgileriniz de'#287'i'#351'tirilecektir.<' +
      'br>Onayl'#305'yor musunuz?'#39';'
    'Swal.fire({'
    '    title: '#39'DE'#286#304#350'T'#304'RME ONAYI_'#39','
    '    html: swalHTML,'
    '    icon: '#39'warning'#39','
    '    iconColor: '#39'var(--neon-pink)'#39','
    '    showCancelButton: true,'
    '    confirmButtonText: '#39'EVET, DE'#286#304#350'T'#304'R'#39','
    '    cancelButtonText: '#39#304'PTAL'#39','
    '    background: '#39'var(--sidebar-bg)'#39','
    '    color: '#39'var(--text-main)'#39','
    '    buttonsStyling: false,'
    '    didOpen: function() {'
    
      '        document.querySelector('#39'.swal2-container'#39').style.zIndex ' +
      '= '#39'9999999'#39';'
    
      '        var confBtn = Swal.getConfirmButton(); var cancBtn = Swa' +
      'l.getCancelButton();'
    
      '        confBtn.style.border = '#39'2px solid var(--neon-blue)'#39'; con' +
      'fBtn.style.background = '#39'transparent'#39'; confBtn.style.color = '#39'va' +
      'r(--neon-blue)'#39'; confBtn.style.padding = '#39'10px 20px'#39'; confBtn.st' +
      'yle.fontFamily = '#39'"Press Start 2P", cursive'#39'; confBtn.style.font' +
      'Size = '#39'0.7rem'#39'; confBtn.style.marginRight = '#39'15px'#39'; confBtn.sty' +
      'le.cursor = '#39'pointer'#39';'
    
      '        cancBtn.style.border = '#39'2px solid var(--neon-pink)'#39'; can' +
      'cBtn.style.background = '#39'transparent'#39'; cancBtn.style.color = '#39'va' +
      'r(--neon-pink)'#39'; cancBtn.style.padding = '#39'10px 20px'#39'; cancBtn.st' +
      'yle.fontFamily = '#39'"Press Start 2P", cursive'#39'; cancBtn.style.font' +
      'Size = '#39'0.7rem'#39'; cancBtn.style.cursor = '#39'pointer'#39';'
    '    }'
    '}).then(function(result) {'
    '    if (result.isConfirmed) {'
    
      '        ajaxRequest(HESABIM_FORM.UniHTMLFrame1, '#39'UpdateProfileDB' +
      #39', ['#39'kullanici_adi='#39' + newUname, '#39'eposta='#39' + newEmail]);'
    '    }'
    '});'
    '      '
    '  };'
    '  '
    '  '
    '// MODALI A'#199
    'window.openForgotPassModal = function() {'
    
      '  document.getElementById('#39'accForgotPassModal'#39').classList.add('#39's' +
      'how'#39');'
    ''
    '  document.getElementById('#39'accFpStep1'#39').style.display = '#39'block'#39';'
    '  document.getElementById('#39'accFpStep2'#39').style.display = '#39'none'#39';'
    '  document.getElementById('#39'accFpStep3'#39').style.display = '#39'none'#39';'
    ''
    '  document.getElementById('#39'accFpEmail'#39').value = '#39#39';'
    '  document.getElementById('#39'accFpCode'#39').value = '#39#39';'
    '  document.getElementById('#39'accFpNewPass'#39').value = '#39#39';'
    '  document.getElementById('#39'accFpNewPass2'#39').value = '#39#39';'
    ''
    '  document.getElementById('#39'accFpStep1'#39').style.opacity = '#39'1'#39';'
    '};'
    ''
    ''
    ''
    'window.closeForgotPassModal = function() {'
    
      '  document.getElementById('#39'accForgotPassModal'#39').classList.remove' +
      '('#39'show'#39');'
    '};'
    ''
    ''
    ''
    'window.fpSendCode = function() {'
    '  var email = document.getElementById('#39'accFpEmail'#39').value;'
    ''
    '  if (email.trim() === '#39#39') {'
    '    alert('#39'L'#252'tfen e-posta girin.'#39');'
    '    return;'
    '  }'
    ''
    ''
    '  document.getElementById('#39'accFpStep1'#39').style.opacity = '#39'0.5'#39';'
    ''
    '  ajaxRequest('
    '    HESABIM_FORM.UniHTMLFrame1,'
    '    '#39'FPSendCode'#39','
    '    ['#39'email='#39' + email]'
    '  );'
    '};'
    ''
    ''
    'window.fpVerifyCode = function() {'
    '  var code  = document.getElementById('#39'accFpCode'#39').value;'
    '  var email = document.getElementById('#39'accFpEmail'#39').value;'
    ''
    '  if (code.trim() === '#39#39') {'
    '    alert('#39'L'#252'tfen kodu girin.'#39');'
    '    return;'
    '  }'
    ''
    '  ajaxRequest('
    '    HESABIM_FORM.UniHTMLFrame1,'
    '    '#39'FPVerifyCode'#39','
    '    ['
    '      '#39'email='#39' + email,'
    '      '#39'code='#39'  + code'
    '    ]'
    '  );'
    '};'
    ''
    ''
    ''
    'window.fpSavePass = function() {'
    '  var email = document.getElementById('#39'accFpEmail'#39').value;'
    '  var p1 = document.getElementById('#39'accFpNewPass'#39').value;'
    '  var p2 = document.getElementById('#39'accFpNewPass2'#39').value;'
    ''
    '  if (p1.trim() === '#39#39' || p2.trim() === '#39#39') {'
    '    alert('#39#350'ifre alanlar'#305' bo'#351' b'#305'rak'#305'lamaz!'#39');'
    '    return;'
    '  }'
    ''
    '  if (p1 !== p2) {'
    '    alert('#39#350'ifreler birbiriyle e'#351'le'#351'miyor!'#39');'
    '    return;'
    '  }'
    ''
    '  ajaxRequest('
    '    HESABIM_FORM.UniHTMLFrame1,'
    '    '#39'FPSavePass'#39','
    '    ['
    '      '#39'email='#39' + email,'
    '      '#39'pass='#39'  + p1'
    '    ]'
    '  );'
    '};'
    ''
    'window.showNeonBigSwalAndAjax = function ('
    '  title,'
    '  message,'
    '  iconType,        '
    '  ajaxForm,       '
    '  ajaxEventName,   '
    '  ajaxParams      '
    ') {'
    ''
    '  if (!document.getElementById('#39'neonSwalBigStyle'#39')) {'
    '    const style = document.createElement('#39'style'#39');'
    '    style.id = '#39'neonSwalBigStyle'#39';'
    '    style.innerHTML = `'
    '      .neon-swal-big-popup {'
    '        background: rgba(10, 10, 35, 0.95) !important;'
    '        backdrop-filter: blur(15px);'
    '        border: 1px solid var(--neon-blue) !important;'
    '        box-shadow: 0 0 30px rgba(5, 217, 232, 0.3) !important;'
    '        color: #fff !important;'
    '        font-family: "Outfit", sans-serif !important;'
    '        border-radius: 12px !important;'
    '        padding: 30px !important;'
    '      }'
    ''
    '      .neon-swal-big-title {'
    '        font-family: "Press Start 2P", cursive !important;'
    '        color: var(--neon-blue) !important;'
    '        font-size: 1.2rem !important;'
    '        text-shadow: 2px 2px 0px var(--neon-pink) !important;'
    '        margin-bottom: 15px !important;'
    '      }'
    ''
    '      .neon-swal-big-html {'
    '        color: rgba(255,255,255,0.8) !important;'
    '        font-size: 1.1rem !important;'
    '        line-height: 1.5 !important;'
    '      }'
    ''
    '      .neon-swal-btn {'
    '        background: transparent !important;'
    '        color: var(--neon-pink) !important;'
    '        border: 2px solid var(--neon-pink) !important;'
    '        font-family: "Press Start 2P", cursive !important;'
    '        font-size: 0.8rem !important;'
    '        padding: 12px 25px !important;'
    '        border-radius: 4px !important;'
    '        transition: all 0.3s ease !important;'
    '      }'
    ''
    '      .neon-swal-btn:hover {'
    '        background: var(--neon-pink) !important;'
    '        color: #fff !important;'
    '        box-shadow: 0 0 15px var(--neon-pink) !important;'
    '      }'
    ''
    '      .neon-swal-big-icon {'
    '        border: none !important;'
    '        color: var(--neon-blue) !important;'
    '        font-size: 3rem !important;'
    '        display: flex !important;'
    '        align-items: center !important;'
    '        justify-content: center !important;'
    '        text-shadow: 0 0 20px var(--neon-blue) !important;'
    '        margin-top: 10px !important;'
    '      }'
    ''
    '      .neon-swal-big-icon.error-icon {'
    '        color: var(--neon-pink) !important;'
    '        text-shadow: 0 0 20px var(--neon-pink) !important;'
    '      }'
    '    `;'
    '    document.head.appendChild(style);'
    '  }'
    ''
    ''
    '  let faClass = '#39'fa-solid fa-circle-check'#39';'
    '  let extraClass = '#39#39';'
    ''
    '  if (iconType === '#39'error'#39') {'
    '    faClass = '#39'fa-solid fa-circle-xmark'#39';'
    '    extraClass = '#39'error-icon'#39';'
    '  } else if (iconType === '#39'warning'#39') {'
    '    faClass = '#39'fa-solid fa-triangle-exclamation'#39';'
    '  } else if (iconType === '#39'info'#39') {'
    '    faClass = '#39'fa-solid fa-circle-info'#39';'
    '  }'
    ''
    ' '
    '  Swal.fire({'
    '    title: title,'
    '    html: message,'
    '    iconHtml: `<i class="${faClass}"></i>`,'
    '    confirmButtonText: '#39'ANLADIM'#39','
    '    buttonsStyling: false,'
    '    customClass: {'
    '      popup: '#39'neon-swal-big-popup'#39','
    '      title: '#39'neon-swal-big-title'#39','
    '      htmlContainer: '#39'neon-swal-big-html'#39','
    '      confirmButton: '#39'neon-swal-btn'#39','
    '      icon: '#39'neon-swal-big-icon '#39' + extraClass'
    '    },'
    '    didOpen: () => {'
    
      '      document.querySelector('#39'.swal2-container'#39').style.zIndex = ' +
      #39'999999'#39';'
    
      '      document.querySelector('#39'.swal2-backdrop-show'#39').style.backg' +
      'round ='
    '        '#39'rgba(0,0,0,0.8)'#39';'
    '    }'
    '  }).then(function (result) {'
    '    if (result.isConfirmed) {'
    '      ajaxRequest(ajaxForm, ajaxEventName, ajaxParams || []);'
    '    }'
    '  });'
    '};'
    ''
    'window.initTheme = function() {'
    '    var currentTheme = localStorage.getItem('#39'bitd-theme'#39');'
    
      '    var themeCheckbox = document.getElementById('#39'checkboxTheme'#39')' +
      ';'
    '    if (currentTheme === '#39'light'#39') {'
    '        document.body.classList.add('#39'light-theme'#39');'
    '        if (themeCheckbox) {'
    '            themeCheckbox.checked = true;'
    '        }'
    '    }'
    '};'
    ''
    'window.toggleTheme = function() {'
    
      '    var themeCheckbox = document.getElementById('#39'checkboxTheme'#39')' +
      ';'
    '    var isLight = 0;'
    ''
    '    if (themeCheckbox && themeCheckbox.checked) {'
    '        document.body.classList.add('#39'light-theme'#39');'
    '        localStorage.setItem('#39'bitd-theme'#39', '#39'light'#39');'
    '        isLight = 1;'
    '    } else {'
    '        document.body.classList.remove('#39'light-theme'#39');'
    '        localStorage.setItem('#39'bitd-theme'#39', '#39'dark'#39');'
    '        isLight = 0;'
    '    }'
    ''
    
      '    ajaxRequest(HESABIM_FORM.UniHTMLFrame1, '#39'TemaGuncelleDB'#39', ['#39 +
      'tema_durumu='#39' + isLight]);'
    '};'
    ''
    'setTimeout(window.initTheme, 100);')
  PageMode = True
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
      '    /* --- KOYU TEMA (VARSAYILAN) --- */'
      '    --neon-pink: #ff2a6d;'
      '    --neon-blue: #05d9e8;'
      '    --bg-main: #01012b;'
      '    --sidebar-bg: rgba(10, 10, 35, 0.95);'
      '    '
      '    --text-main: #ffffff;'
      '    --text-muted: rgba(255, 255, 255, 0.5);'
      '    --card-bg: rgba(5, 5, 25, 0.4);'
      '    --border-color: rgba(255, 255, 255, 0.08);'
      '    --modal-overlay-bg: rgba(1, 1, 43, 0.9);'
      '    --scanline-opacity: 0.15;'
      '    --gradient-center: rgba(16, 0, 43, 0.5);'
      '    --input-bg: rgba(0, 0, 0, 0.5);'
      '  }'
      ''
      '  /* --- A'#199'IK TEMA KODLARI --- */'
      '  body.light-theme {'
      '    --neon-pink: #d90045; '
      '    --neon-blue: #007a8c; '
      '    --bg-main: #f4f7f6; '
      '    --sidebar-bg: rgba(245, 247, 250, 0.95);'
      '    '
      '    --text-main: #1a1a2e; '
      '    --text-muted: rgba(0, 0, 0, 0.6);'
      '    --card-bg: rgba(255, 255, 255, 0.8);'
      '    --border-color: rgba(0, 0, 0, 0.15);'
      '    --modal-overlay-bg: rgba(240, 245, 250, 0.9);'
      '    --scanline-opacity: 0.03; '
      '    --gradient-center: rgba(255, 255, 255, 0.5);'
      '    --input-bg: rgba(255, 255, 255, 0.9);'
      '  }'
      ''
      '  ::-webkit-scrollbar { width: 8px; }'
      
        '  ::-webkit-scrollbar-track { background: var(--bg-main); transi' +
        'tion: 0.4s; }'
      
        '  ::-webkit-scrollbar-thumb { background: var(--neon-blue); bord' +
        'er-radius: 10px; box-shadow: 0 0 10px var(--neon-blue); transiti' +
        'on: 0.4s; }'
      
        '  ::-webkit-scrollbar-thumb:hover { background: var(--neon-pink)' +
        '; }'
      ''
      
        '  body, html { margin: 0; padding: 0; height: 100%; background-c' +
        'olor: var(--bg-main) !important; font-family: '#39'Outfit'#39', sans-ser' +
        'if; color: var(--text-main); overflow: hidden; transition: backg' +
        'round-color 0.4s ease, color 0.4s ease; }'
      ''
      
        '  .dashboard-container { display: flex; position: fixed; top: 0;' +
        ' left: 0; width: 100vw; height: 100vh; z-index: 10000; backgroun' +
        'd-color: var(--bg-main); transition: background-color 0.4s ease;' +
        ' }'
      
        '  .dashboard-container::before { content: '#39#39'; position: absolute' +
        '; top: 0; left: 0; width: 100%; height: 100%; background: radial' +
        '-gradient(circle at center, var(--gradient-center) 0%, transpare' +
        'nt 100%); z-index: -1; transition: 0.4s; }'
      
        '  .dashboard-container::after { content: '#39#39'; position: absolute;' +
        ' top: 0; left: 0; width: 100%; height: 100%; background: linear-' +
        'gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, var(--scanline-o' +
        'pacity)) 50%), linear-gradient(90deg, rgba(255, 0, 0, 0.03), rgb' +
        'a(0, 255, 0, 0.01), rgba(0, 0, 255, 0.03)); background-size: 100' +
        '% 2px, 3px 100%; pointer-events: none; z-index: 5; transition: 0' +
        '.4s; }'
      ''
      
        '  .mobile-header { display: none; align-items: center; justify-c' +
        'ontent: space-between; margin-bottom: 20px; }'
      
        '  .hamburger-btn { background: transparent; border: 1px solid va' +
        'r(--neon-blue); color: var(--neon-blue); font-size: 1.5rem; padd' +
        'ing: 5px 12px; border-radius: 4px; cursor: pointer; transition: ' +
        '0.3s; box-shadow: 0 0 10px rgba(5, 217, 232, 0.2); }'
      
        '  .hamburger-btn:hover { background: rgba(5, 217, 232, 0.2); box' +
        '-shadow: 0 0 15px var(--neon-blue); color: var(--text-main); }'
      
        '  .sidebar-overlay { position: fixed; top: 0; left: 0; width: 10' +
        '0vw; height: 100vh; background: rgba(0, 0, 0, 0.7); z-index: 100' +
        '0; display: none; opacity: 0; transition: 0.3s; backdrop-filter:' +
        ' blur(5px); }'
      '  .sidebar-overlay.show { display: block; opacity: 1; }'
      ''
      
        '  .sidebar { width: 260px; background: var(--sidebar-bg); backdr' +
        'op-filter: blur(25px); border-right: 1px solid var(--border-colo' +
        'r); display: flex; flex-direction: column; padding: 80px 0 50px ' +
        '0; z-index: 1001; transition: transform 0.4s ease, background-co' +
        'lor 0.4s ease, border-color 0.4s ease; }'
      '  .sidebar-header { text-align: center; margin-bottom: 30px; }'
      
        '  .sidebar-brand { font-family: '#39'Press Start 2P'#39', cursive; color' +
        ': var(--neon-blue); font-size: 1.1rem; text-shadow: 2px 2px var(' +
        '--neon-pink); transition: 0.4s; }'
      
        '  .sidebar-tagline { font-size: 0.6rem; letter-spacing: 3px; col' +
        'or: var(--text-muted); font-weight: bold; text-transform: upperc' +
        'ase; margin-bottom: 15px; transition: 0.4s; }'
      '  '
      '  /* --- TEMA DE'#286#304#350'T'#304'R'#304'C'#304' CSS --- */'
      
        '  .theme-switch-wrapper { display: flex; align-items: center; ju' +
        'stify-content: center; gap: 10px; margin-top: 20px; }'
      
        '  .theme-switch { position: relative; display: inline-block; wid' +
        'th: 44px; height: 22px; }'
      '  .theme-switch input { opacity: 0; width: 0; height: 0; }'
      
        '  .slider { position: absolute; cursor: pointer; top: 0; left: 0' +
        '; right: 0; bottom: 0; background-color: var(--card-bg); border:' +
        ' 1px solid var(--border-color); transition: .4s; border-radius: ' +
        '22px; }'
      
        '  .slider-circle { position: absolute; content: '#39#39'; height: 16px' +
        '; width: 16px; left: 2px; bottom: 2px; background-color: var(--n' +
        'eon-blue); transition: .4s; border-radius: 50%; box-shadow: 0 0 ' +
        '5px var(--neon-blue); }'
      
        '  input:checked + .slider { background-color: rgba(0,0,0,0.05); ' +
        'border-color: var(--neon-pink); }'
      
        '  input:checked + .slider .slider-circle { transform: translateX' +
        '(22px); background-color: var(--neon-pink); box-shadow: 0 0 5px ' +
        'var(--neon-pink); }'
      ''
      
        '  .nav-item { position: relative; padding: 18px 35px; cursor: po' +
        'inter; display: flex; align-items: center; gap: 20px; color: var' +
        '(--text-muted); transition: all 0.3s ease; }'
      
        '  .nav-item i { transition: all 0.3s cubic-bezier(0.25, 0.46, 0.' +
        '45, 0.94); }'
      
        '  .nav-item:hover { color: var(--neon-blue); background: rgba(5,' +
        ' 217, 232, 0.08); }'
      
        '  .nav-item:hover i { transform: scale(1.1); filter: drop-shadow' +
        '(0 0 8px var(--neon-blue)); }'
      
        '  .nav-item.active { color: var(--text-main); background: linear' +
        '-gradient(90deg, rgba(5, 217, 232, 0.1) 0%, transparent 100%); }'
      
        '  .nav-item.active i { color: var(--neon-pink); filter: drop-sha' +
        'dow(0 0 8px var(--neon-pink)); }'
      
        '  .nav-item::before { content: '#39#39'; position: absolute; left: 0; ' +
        'top: 50%; transform: translateY(-50%); width: 0; height: 0; back' +
        'ground: var(--neon-pink); box-shadow: 0 0 15px var(--neon-pink);' +
        ' transition: 0.3s; border-radius: 0 4px 4px 0; }'
      '  .nav-item.active::before { width: 4px; height: 60%; }'
      '  '
      
        '  .logout-btn { margin-top: auto; border-top: 1px solid var(--bo' +
        'rder-color) !important; padding: 25px 35px; }'
      
        '  .logout-btn:hover { color: #ff4b2b !important; background: rgb' +
        'a(255, 75, 43, 0.15) !important; }'
      
        '  .logout-btn:hover i { filter: drop-shadow(0 0 12px #ff4b2b) !i' +
        'mportant; transform: translateX(5px) scale(1.1); }'
      '  '
      
        '  .made-with-love { text-align: center; font-family: '#39'Press Star' +
        't 2P'#39', cursive; font-size: 0.55rem; color: var(--text-muted); ma' +
        'rgin-bottom: 15px; line-height: 1.8; transition: 0.4s; }'
      
        '  .made-with-love .author a { color: var(--neon-blue); text-deco' +
        'ration: none; text-shadow: 0 0 5px var(--neon-blue); transition:' +
        ' 0.4s; }'
      
        '  .made-with-love .author a:hover { color: var(--neon-pink); tex' +
        't-shadow: 0 0 10px var(--neon-pink); }'
      ''
      
        '  .main-content { flex: 1; overflow-y: auto; padding: 50px; posi' +
        'tion: relative; z-index: 2; box-sizing: border-box; }'
      '  .welcome-section { margin-bottom: 40px; }'
      
        '  .welcome-section h1 { margin: 0; font-family: '#39'Press Start 2P'#39 +
        ', cursive; font-size: 1.1rem; color: var(--text-main); transitio' +
        'n: 0.4s;}'
      
        '  .welcome-section span { color: var(--neon-pink); transition: 0' +
        '.4s;}'
      
        '  .changing-text { margin-top: 15px; font-family: '#39'Press Start 2' +
        'P'#39', cursive; font-size: 0.7rem; color: var(--neon-blue); min-hei' +
        'ght: 1.5rem; display: inline-block; position: relative; transiti' +
        'on: 0.4s;}'
      
        '  .changing-text::after { content: '#39'_'#39'; animation: blink 0.8s in' +
        'finite; color: var(--neon-pink); }'
      
        '  @keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0; ' +
        '} }'
      ''
      '  /* ========================================================='
      '     HESABIM KONTROL PANEL'#304' (ACCOUNT DECK) CSS'
      
        '     ========================================================= *' +
        '/'
      
        '  .account-grid { display: grid; grid-template-columns: 1fr 1fr;' +
        ' gap: 40px; max-width: 1000px; margin-top: 20px;}'
      '  '
      
        '  .panel-box { background: var(--card-bg); border-radius: 12px; ' +
        'padding: 40px 30px; position: relative; overflow: hidden; transi' +
        'tion: 0.4s; backdrop-filter: blur(10px); display: flex; flex-dir' +
        'ection: column;}'
      
        '  .panel-box::before { content: '#39#39'; position: absolute; top: 0; ' +
        'left: 0; width: 100%; height: 3px; }'
      '  '
      
        '  .panel-blue { border: 1px solid var(--border-color); box-shado' +
        'w: 0 10px 30px rgba(0,0,0,0.2); }'
      
        '  .panel-blue:hover { border-color: var(--neon-blue); box-shadow' +
        ': 0 10px 40px rgba(5, 217, 232, 0.15); }'
      
        '  .panel-blue::before { background: var(--neon-blue); box-shadow' +
        ': 0 0 15px var(--neon-blue); }'
      '  '
      
        '  .panel-pink { border: 1px solid var(--border-color); box-shado' +
        'w: 0 10px 30px rgba(0,0,0,0.2); }'
      
        '  .panel-pink:hover { border-color: var(--neon-pink); box-shadow' +
        ': 0 10px 40px rgba(255, 42, 109, 0.15); }'
      
        '  .panel-pink::before { background: var(--neon-pink); box-shadow' +
        ': 0 0 15px var(--neon-pink); }'
      ''
      
        '  .panel-header { font-family: '#39'Press Start 2P'#39', cursive; font-s' +
        'ize: 0.8rem; margin-bottom: 30px; display: flex; align-items: ce' +
        'nter; gap: 15px; transition: 0.4s; }'
      '  .panel-blue .panel-header { color: var(--neon-blue); }'
      '  .panel-pink .panel-header { color: var(--neon-pink); }'
      '  .panel-header i { font-size: 1.2rem; }'
      ''
      '  .input-group { margin-bottom: 25px; }'
      
        '  .input-label { font-family: '#39'Press Start 2P'#39', cursive; font-si' +
        'ze: 0.65rem; color: var(--text-muted); margin-bottom: 10px; line' +
        '-height: 20px; transition: 0.4s;}'
      '  '
      
        '  .neon-input { width: 100%; background: var(--input-bg); border' +
        ': 1px solid var(--border-color); color: var(--text-main); paddin' +
        'g: 15px 20px; font-family: '#39'Outfit'#39', sans-serif; font-size: 1rem' +
        '; border-radius: 5px; outline: none; transition: 0.3s; box-sizin' +
        'g: border-box; }'
      
        '  .panel-blue .neon-input:focus { border-color: var(--neon-blue)' +
        '; box-shadow: 0 0 15px rgba(5, 217, 232, 0.2); }'
      
        '  .panel-pink .neon-input:focus { border-color: var(--neon-pink)' +
        '; box-shadow: 0 0 15px rgba(255, 42, 109, 0.2); }'
      ''
      
        '  .action-btn { margin-top: auto; width: 100%; padding: 18px; fo' +
        'nt-family: '#39'Press Start 2P'#39', cursive; font-size: 0.7rem; cursor:' +
        ' pointer; transition: 0.3s; border-radius: 5px; display: flex; j' +
        'ustify-content: center; align-items: center; gap: 10px; backgrou' +
        'nd: transparent;}'
      
        '  .btn-blue { border: 2px solid var(--neon-blue); color: var(--n' +
        'eon-blue); }'
      
        '  .btn-blue:hover { background: var(--neon-blue); color: #fff; b' +
        'ox-shadow: 0 0 20px var(--neon-blue); transform: translateY(-2px' +
        '); }'
      '  '
      
        '  .btn-pink { border: 2px solid var(--neon-pink); color: var(--n' +
        'eon-pink); }'
      
        '  .btn-pink:hover { background: var(--neon-pink); color: #fff; b' +
        'ox-shadow: 0 0 20px var(--neon-pink); transform: translateY(-2px' +
        '); }'
      ''
      '  /* '#350#304'FRE SIFIRLAMA MODALI */'
      '  .fp-modal-overlay {'
      
        '    position: fixed; top: 0; left: 0; width: 100vw; height: 100v' +
        'h;'
      '    background: var(--modal-overlay-bg); z-index: 2147483647;'
      '    display: flex; justify-content: center; align-items: center;'
      '    backdrop-filter: blur(5px);'
      '    opacity: 0; visibility: hidden; '
      '    transition: background-color 0.4s ease, opacity 0.4s ease;'
      '    isolation: isolate;'
      '  }'
      '  .fp-modal-overlay.show {'
      '    opacity: 1; visibility: visible;'
      '  }'
      '  '
      '  .fp-modal-content {'
      
        '    background: var(--sidebar-bg); border: 1px solid var(--neon-' +
        'pink);'
      
        '    padding: 40px; border-radius: 10px; width: 90%; max-width: 4' +
        '00px;'
      
        '    text-align: center; box-shadow: 0 0 30px rgba(255, 42, 109, ' +
        '0.3);'
      '    position: relative;'
      '    transform: translateY(-50px) scale(0.9); opacity: 0;'
      
        '    transition: transform 0.5s cubic-bezier(0.175, 0.885, 0.32, ' +
        '1.275), opacity 0.5s ease, background-color 0.4s ease;'
      '  }'
      '  .fp-modal-overlay.show .fp-modal-content {'
      '    transform: translateY(0) scale(1); opacity: 1;'
      '  }'
      ''
      '  /* MODAL '#304#199#304' D'#304'NAM'#304'K YAZILAR */'
      
        '  .fp-modal-title { font-family:'#39'Press Start 2P'#39', cursive; font-' +
        'size:0.8rem; margin-bottom:20px; transition: 0.4s; }'
      
        '  .fp-modal-desc { color: var(--text-muted); font-size:0.8rem; m' +
        'argin-bottom:20px; font-family:'#39'Outfit'#39', sans-serif; transition:' +
        ' 0.4s; }'
      
        '  .fp-close-icon { position:absolute; top:15px; right:20px; colo' +
        'r: var(--text-muted); cursor:pointer; font-size:1.5rem; transiti' +
        'on:0.3s; }'
      
        '  .fp-close-icon:hover { color: var(--neon-pink); transform: sca' +
        'le(1.2); }'
      ''
      '  @media (max-width: 900px) { '
      '    .account-grid { grid-template-columns: 1fr; gap: 30px; } '
      '    .main-content { padding: 25px 15px; }'
      
        '    .sidebar { position: fixed; left: -300px; top: 0; height: 10' +
        '0vh; z-index: 1001; transition: left 0.4s cubic-bezier(0.25, 0.4' +
        '6, 0.45, 0.94); }'
      
        '    .sidebar.open { left: 0; box-shadow: 10px 0 30px rgba(5, 217' +
        ', 232, 0.1); }'
      '    .mobile-header { display: flex; } '
      '  }'
      '</style>'
      ''
      '<div class="dashboard-container">'
      '  '
      
        '  <div class="sidebar-overlay" id="sidebarOverlay" onclick="wind' +
        'ow.toggleSidebar()"></div>'
      ''
      '  <aside class="sidebar" id="sidebar">'
      '    <div class="sidebar-header">'
      '      <div class="sidebar-brand">B.I.T.D.</div>'
      '      <div class="sidebar-tagline">Back In The Day</div>'
      '      '
      '      <div class="theme-switch-wrapper">'
      
        '        <i class="fa-solid fa-moon" style="color: var(--text-mut' +
        'ed); font-size: 0.8rem;"></i>'
      '        <label class="theme-switch" for="checkboxTheme">'
      
        '            <input type="checkbox" id="checkboxTheme" onchange="' +
        'window.toggleTheme()">'
      '            <div class="slider">'
      '                <div class="slider-circle"></div>'
      '            </div>'
      '        </label>'
      
        '        <i class="fa-solid fa-sun" style="color: var(--neon-pink' +
        '); font-size: 0.8rem;"></i>'
      '      </div>'
      ''
      '    </div>'
      '    <nav class="nav-group">'
      
        '      <div class="nav-item" onclick="ajaxRequest(HESABIM_FORM.Un' +
        'iHTMLFrame1, '#39'homePageCall'#39', [])"><i class="fa-solid fa-house"><' +
        '/i> Ana Sayfa</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(HESABIM_FORM.Un' +
        'iHTMLFrame1, '#39'gamesPageCall'#39', [])"><i class="fa-solid fa-gamepad' +
        '"></i> Oyunlar'#305'm</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(HESABIM_FORM.Un' +
        'iHTMLFrame1, '#39'moviesPageCall'#39', [])"><i class="fa-solid fa-film">' +
        '</i> Filmlerim</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(HESABIM_FORM.Un' +
        'iHTMLFrame1, '#39'tvShowsPageCall'#39', [])"><i class="fa-solid fa-tv"><' +
        '/i> Dizilerim</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(HESABIM_FORM.Un' +
        'iHTMLFrame1, '#39'booksPageCall'#39', [])"><i class="fa-solid fa-book"><' +
        '/i> Kitaplar'#305'm</div>'
      '    </nav>'
      '    <div style="margin-top: auto; width: 100%;">'
      '      <div class="made-with-love">'
      
        '        Made with <span class="heart"><i class="fa-solid fa-hear' +
        't" style="color: rgb(255, 0, 0);"></i></span><br>'
      
        '        by <span class="author"><a href="https://hasup.net" targ' +
        'et="_blank">Yu'#351'a G'#246'verdik</a></span>'
      '      </div>'
      
        '      <div class="nav-item active"><i class="fa-solid fa-user-ge' +
        'ar"></i> Hesab'#305'm</div>'
      
        '      <div class="nav-item logout-btn" onclick="ajaxRequest(HESA' +
        'BIM_FORM.UniHTMLFrame1, '#39'DoLogout'#39', [])" style="margin-top: 0 !i' +
        'mportant;">'
      '        <i class="fa-solid fa-right-from-bracket"></i> '#199#305'k'#305#351' Yap'
      '      </div>'
      '    </div>'
      '  </aside>'
      ''
      '  <main class="main-content">'
      '    '
      '    <div class="mobile-header">'
      
        '      <button class="hamburger-btn" onclick="window.toggleSideba' +
        'r()">'
      '        <i class="fa-solid fa-bars-staggered"></i>'
      '      </button>'
      
        '      <div class="sidebar-brand" style="font-size: 0.9rem;">B.I.' +
        'T.D.</div>'
      '    </div>'
      ''
      '    <header class="welcome-section">'
      '      <h1>KONTROL PANEL'#304'_</h1>'
      
        '      <div class="changing-text">Kimlik ve G'#252'venlik Protokolleri' +
        ' Ayarlan'#305'yor</div>'
      '    </header>'
      ''
      '    <div class="account-grid">'
      '      '
      '      <div class="panel-box panel-blue">'
      '        <div class="panel-header">'
      
        '          <i class="fa-solid fa-id-card"></i> K'#304'ML'#304'K VE '#304'LET'#304#350#304'M' +
        '_'
      '        </div>'
      '        '
      '        <div class="input-group">'
      '          <span class="input-label">Kullan'#305'c'#305' Ad'#305'</span>'
      '          <div style="position: relative;">'
      
        '            <input type="text" id="accUsername" class="neon-inpu' +
        't" style="padding-right: 40px;" placeholder="Kullan'#305'c'#305' ad'#305'n'#305'z...' +
        '">'
      
        '            <i class="fa-solid fa-pen" style="position: absolute' +
        '; right: 15px; top: 50%; transform: translateY(-50%); color: var' +
        '(--neon-blue); opacity: 0.5; pointer-events: none;"></i>'
      '          </div>'
      '        </div>'
      ''
      '        <div class="input-group">'
      '          <span class="input-label">E-Posta Adresi</span>'
      '          <div style="position: relative;">'
      
        '            <input type="email" id="accEmail" class="neon-input"' +
        ' style="padding-right: 40px;" placeholder="E-Posta adresiniz..."' +
        '>'
      
        '            <i class="fa-solid fa-pen" style="position: absolute' +
        '; right: 15px; top: 50%; transform: translateY(-50%); color: var' +
        '(--neon-blue); opacity: 0.5; pointer-events: none;"></i>'
      '          </div>'
      '        </div>'
      ''
      
        '        <button class="action-btn btn-blue" onclick="window.reqU' +
        'pdateProfile()">'
      
        '          <i class="fa-solid fa-satellite-dish"></i> B'#304'LG'#304'LER'#304' G' +
        #220'NCELLE'
      '        </button>'
      '      </div>'
      ''
      '      <div class="panel-box panel-pink">'
      '        <div class="panel-header">'
      
        '          <i class="fa-solid fa-shield-halved"></i> G'#220'VENL'#304'K PRO' +
        'TOKOL'#220'_'
      '        </div>'
      ''
      
        '        <span class="input-label">Mevcut '#350'ifrenizi buradan de'#287'i'#351 +
        'tirebilirsiniz.<br><br> '#350'ifre de'#287'i'#351'tirme esnas'#305'nda E-posta adres' +
        'inize bir OTP kodu g'#246'nderilecektir.</span>'
      '          '
      
        '        <button class="action-btn btn-pink" onclick="window.open' +
        'ForgotPassModal();">'
      '          <i class="fa-solid fa-key"></i> '#350#304'FREY'#304' DE'#286#304#350'T'#304'R'
      '        </button>'
      '      </div>'
      ''
      '    </div>'
      ''
      '  </main>'
      '</div>'
      ''
      '<div class="fp-modal-overlay" id="accForgotPassModal">'
      '  <div class="fp-modal-content">'
      
        '    <i class="fa-solid fa-xmark fp-close-icon" onclick="window.c' +
        'loseForgotPassModal()"></i>'
      '    '
      '    <div id="accFpStep1">'
      
        '      <h3 class="fp-modal-title" style="color:var(--neon-pink);"' +
        '>A'#286'A ER'#304#350#304'M KURTARMA_</h3>'
      
        '      <p class="fp-modal-desc">Sisteme kay'#305'tl'#305' e-posta adresiniz' +
        'i girin. Size tek kullan'#305'ml'#305'k bir '#351'ifre (OTP) g'#246'nderece'#287'iz.</p>'
      '      '
      
        '      <input type="email" id="accFpEmail" class="neon-input" pla' +
        'ceholder="E-Posta Adresi" style="margin-bottom:20px;" onkeydown=' +
        '"if(event.key === '#39'Enter'#39') { event.preventDefault(); window.fpSe' +
        'ndCode(); }">'
      '             '
      
        '      <button class="action-btn btn-pink" style="margin-top:0;" ' +
        'onclick="window.fpSendCode()">'
      '        KOD G'#214'NDER'
      '      </button>'
      '    </div>'
      ''
      '    <div id="accFpStep2" style="display:none;">'
      
        '      <h3 class="fp-modal-title" style="color:var(--neon-blue);"' +
        '>KODU G'#304'R'#304'N_</h3>'
      
        '      <p class="fp-modal-desc">Mail adresinize g'#246'nderilen 6 hane' +
        'li kodu girin.</p>'
      '      '
      
        '      <input type="text" id="accFpCode" class="neon-input" maxle' +
        'ngth="6" placeholder="'#214'rn: 849201" style="text-align:center; fon' +
        't-size:1.5rem; letter-spacing:10px; margin-bottom:20px;" onkeydo' +
        'wn="if(event.key === '#39'Enter'#39') { event.preventDefault(); window.f' +
        'pVerifyCode(); }">'
      '             '
      
        '      <button class="action-btn btn-blue" style="margin-top:0;" ' +
        'onclick="window.fpVerifyCode()">'
      '        DO'#286'RULA'
      '      </button>'
      '    </div>'
      ''
      '    <div id="accFpStep3" style="display:none;">'
      
        '      <h3 class="fp-modal-title" style="color:var(--neon-blue);"' +
        '>YEN'#304' '#350#304'FRE OLU'#350'TUR_</h3>'
      '      '
      
        '      <input type="password" id="accFpNewPass" class="neon-input' +
        '" placeholder="Yeni '#350'ifre" style="margin-bottom:10px;" onkeydown' +
        '="if(event.key === '#39'Enter'#39' || event.key === '#39'Tab'#39') { event.preve' +
        'ntDefault(); document.getElementById('#39'accFpNewPass2'#39').focus(); }' +
        '">'
      '             '
      
        '      <input type="password" id="accFpNewPass2" class="neon-inpu' +
        't" placeholder="Yeni '#350'ifre (Tekrar)" style="margin-bottom:20px;"' +
        ' onkeydown="if(event.key === '#39'Enter'#39') { event.preventDefault(); ' +
        'window.fpSavePass(); }">'
      '             '
      
        '      <button class="action-btn btn-blue" style="margin-top:0;" ' +
        'onclick="window.fpSavePass()">'
      '        '#350#304'FREY'#304' G'#220'NCELLE'
      '      </button>'
      '    </div>'
      ''
      '  </div>'
      '</div>')
    Align = alClient
    OnAjaxEvent = UniHTMLFrame1AjaxEvent
  end
end
