object ANA_SAYFA_FORM: TANA_SAYFA_FORM
  Left = 0
  Top = 0
  ClientHeight = 600
  ClientWidth = 800
  Caption = 'ANA_SAYFA_FORM'
  Color = clBlack
  OnShow = UniFormShow
  BorderStyle = bsNone
  WindowState = wsMaximized
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  Script.Strings = (
    
      'window.textArray = ["Bug'#252'n hangi filmi izlediniz?_", "S'#305'rada han' +
      'gi oyun var?_", "Yeni bir diziye mi ba'#351'lad'#305'n'#305'z?_", "Hangi kitab'#305 +
      ' okuyorsunuz?_"];'
    'window.textIndex = window.textIndex || 0; '
    'window.charIndex = window.charIndex || 0;'
    'window.isDeleting = window.isDeleting || false;'
    'window.typeSpeed = 100;'
    'window.deleteSpeed = 50;'
    'window.delayBetweenTexts = 2000;'
    ''
    'if (window.typeWriterTimer) {'
    '    clearTimeout(window.typeWriterTimer);'
    '}'
    ''
    'window.typeWriter = function() {'
    '  var dynamicQuote = document.getElementById("dynamicQuote");'
    '  if (!dynamicQuote) return; '
    ''
    '  var currentString = window.textArray[window.textIndex];'
    ''
    '  if (window.isDeleting) {'
    
      '    dynamicQuote.textContent = currentString.substring(0, window' +
      '.charIndex - 1);'
    '    window.charIndex--;'
    '  } else {'
    
      '    dynamicQuote.textContent = currentString.substring(0, window' +
      '.charIndex + 1);'
    '    window.charIndex++;'
    '  }'
    ''
    
      '  var timeoutSpeed = window.isDeleting ? window.deleteSpeed : wi' +
      'ndow.typeSpeed;'
    ''
    
      '  if (!window.isDeleting && window.charIndex === currentString.l' +
      'ength) {'
    '    timeoutSpeed = window.delayBetweenTexts;'
    '    window.isDeleting = true;'
    '  } '
    '  else if (window.isDeleting && window.charIndex === 0) {'
    '    window.isDeleting = false;'
    
      '    window.textIndex = (window.textIndex + 1) % window.textArray' +
      '.length;'
    '    timeoutSpeed = 500;'
    '  }'
    ''
    
      '  window.typeWriterTimer = setTimeout(window.typeWriter, timeout' +
      'Speed);'
    '};'
    ''
    'window.toggleSidebar = function() {'
    '    const sidebar = document.getElementById('#39'sidebar'#39');'
    '    const overlay = document.getElementById('#39'sidebarOverlay'#39');'
    '    if (sidebar && overlay) {'
    '        sidebar.classList.toggle('#39'open'#39');'
    '        overlay.classList.toggle('#39'show'#39');'
    '    }'
    '};'
    ''
    
      'window.triggerRandomizerReveal = function(imgUrl, titleText, sco' +
      'reText, genreText, yearText, extraText, summaryText, mediaType) ' +
      '{'
    '    const modal = document.getElementById('#39'randomizerModal'#39');'
    '    const vortex = document.getElementById('#39'vortexAnim'#39');'
    '    const flash = document.getElementById('#39'neonFlash'#39');'
    '    const resultBox = document.getElementById('#39'resultBox'#39');'
    '    const subtitle = document.getElementById('#39'vortexSubtitle'#39');'
    ''
    '    if (!modal) return;'
    ''
    '    vortex.classList.remove('#39'collapse'#39');'
    '    flash.classList.remove('#39'trigger'#39');'
    '    resultBox.classList.remove('#39'reveal'#39');'
    '    subtitle.classList.remove('#39'hide'#39'); '
    ''
    '    if (mediaType === '#39'game'#39') {'
    
      '        document.getElementById('#39'extraIcon'#39').className = '#39'fa-sol' +
      'id fa-gamepad'#39';'
    
      '        subtitle.innerHTML = '#39'BUG'#220'N OYNAMAN GEREKEN OYUN...<br><' +
      'span style="color:var(--neon-pink); font-size:0.6rem;">K'#220'T'#220'PHANE' +
      'DEN '#199'EK'#304'L'#304'YOR</span>'#39';'
    '    } else if (mediaType === '#39'movie'#39') {'
    
      '        document.getElementById('#39'extraIcon'#39').className = '#39'fa-sol' +
      'id fa-video'#39';'
    
      '        subtitle.innerHTML = '#39'BUG'#220'N '#304'ZLEMEN GEREKEN F'#304'LM...<br><' +
      'span style="color:var(--neon-pink); font-size:0.6rem;">AR'#350#304'VDEN ' +
      #199'IKARILIYOR</span>'#39';'
    '    } else if (mediaType === '#39'tv'#39') {'
    
      '        document.getElementById('#39'extraIcon'#39').className = '#39'fa-sol' +
      'id fa-tv'#39';'
    
      '        subtitle.innerHTML = '#39'YEN'#304' BA'#350'LAMAN GEREKEN D'#304'Z'#304'...<br><' +
      'span style="color:var(--neon-pink); font-size:0.6rem;">A'#286'DAN '#199'EK' +
      #304'L'#304'YOR</span>'#39';'
    '    } else if (mediaType === '#39'book'#39') {'
    
      '        document.getElementById('#39'extraIcon'#39').className = '#39'fa-sol' +
      'id fa-pen-nib'#39';'
    
      '        subtitle.innerHTML = '#39'SIRADAK'#304' K'#304'TABIN...<br><span style' +
      '="color:var(--neon-pink); font-size:0.6rem;">K'#220'T'#220'PHANEDEN ALINIY' +
      'OR</span>'#39';'
    '    }'
    '    '
    '    modal.classList.add('#39'show'#39');'
    ''
    '    setTimeout(() => {'
    '        vortex.classList.add('#39'collapse'#39');'
    '        subtitle.classList.add('#39'hide'#39'); '
    '        '
    '        setTimeout(() => {'
    '            flash.classList.add('#39'trigger'#39');'
    '            '
    '            setTimeout(() => {'
    
      '                document.getElementById('#39'resPoster'#39').style.backg' +
      'roundImage = `url('#39'${imgUrl}'#39')`;'
    
      '                document.getElementById('#39'resTitle'#39').innerHTML = ' +
      'titleText;'
    
      '                document.getElementById('#39'resScore'#39').innerHTML = ' +
      'scoreText;'
    
      '                document.getElementById('#39'resGenre'#39').innerHTML = ' +
      'genreText;'
    
      '                document.getElementById('#39'resYear'#39').innerHTML = y' +
      'earText;'
    
      '                document.getElementById('#39'resExtra'#39').innerHTML = ' +
      'extraText; '
    
      '                document.getElementById('#39'resSummary'#39').innerHTML ' +
      '= summaryText;'
    ''
    '                resultBox.classList.add('#39'reveal'#39');'
    '            }, 200); '
    ''
    '        }, 600); '
    ''
    '    }, 2800); '
    '};'
    ''
    'window.closeRandomizer = function() {'
    '    const modal = document.getElementById('#39'randomizerModal'#39');'
    '    if (modal) {'
    '        modal.classList.remove('#39'show'#39');'
    '        setTimeout(() => {'
    
      '            document.getElementById('#39'resPoster'#39').style.backgroun' +
      'dImage = '#39'none'#39';'
    '        }, 500);'
    '    }'
    '};'
    ''
    
      'window.openGameDetail = function() { ajaxRequest(ANA_SAYFA_FORM.' +
      'UniHTMLFrame1, '#39'gamesPageCall'#39', []); };'
    
      'window.openMovieDetail = function() { ajaxRequest(ANA_SAYFA_FORM' +
      '.UniHTMLFrame1, '#39'moviesPageCall'#39', []); };'
    
      'window.openTvShowDetail = function() { ajaxRequest(ANA_SAYFA_FOR' +
      'M.UniHTMLFrame1, '#39'tvShowsPageCall'#39', []); };'
    
      'window.openBookDetail = function() { ajaxRequest(ANA_SAYFA_FORM.' +
      'UniHTMLFrame1, '#39'booksPageCall'#39', []); };'
    ''
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
    
      '    ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, '#39'TemaGuncelleDB'#39', ' +
      '['#39'tema_durumu='#39' + isLight]);'
    '};'
    ''
    'setTimeout(window.initTheme, 100);')
  PageMode = True
  ClientEvents.ExtEvents.Strings = (
    
      'window.afterrender=function window.afterrender(sender, eOpts)'#13#10'{' +
      #13#10'  function toggleSidebar() {'#13#10'    var sidebar = document.getEl' +
      'ementById("sidebar");'#13#10'    var btnIcon = document.querySelector(' +
      '"#btnToggle i");'#13#10#13#10'    if (sidebar) {'#13#10'      // open s'#305'n'#305'f'#305'n'#305' e' +
      'kle/'#231#305'kar'#13#10'      sidebar.classList.toggle("open");'#13#10'      '#13#10'    ' +
      '  // '#304'kon animasyonu (Hamburger <-> '#199'arp'#305')'#13#10'      if (sidebar.cl' +
      'assList.contains("open")) {'#13#10'        btnIcon.classList.remove("f' +
      'a-bars");'#13#10'        btnIcon.classList.add("fa-xmark");'#13#10'      } e' +
      'lse {'#13#10'        btnIcon.classList.remove("fa-xmark");'#13#10'        bt' +
      'nIcon.classList.add("fa-bars");'#13#10'      }'#13#10'    }'#13#10'  }'#13#10'}')
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
      '    --modal-overlay-bg: rgba(1, 1, 43, 0.95);'
      '    --scanline-opacity: 0.15;'
      '    --gradient-center: rgba(16, 0, 43, 0.5);'
      '  }'
      ''
      '  /* --- A'#199'IK TEMA KODLARI --- */'
      '  body.light-theme {'
      
        '    --neon-pink: #d90045; /* Okunabilirlik i'#231'in daha koyu pembe ' +
        '*/'
      
        '    --neon-blue: #007a8c; /* Okunabilirlik i'#231'in daha koyu deniz ' +
        'mavisi */'
      '    --bg-main: #f4f7f6; /* G'#246'z yormayan k'#305'r'#305'k beyaz */'
      '    --sidebar-bg: rgba(245, 247, 250, 0.95);'
      '    '
      '    --text-main: #1a1a2e; /* Lacivert/Siyah metin */'
      '    --text-muted: rgba(0, 0, 0, 0.6);'
      '    --card-bg: rgba(255, 255, 255, 0.8);'
      '    --border-color: rgba(0, 0, 0, 0.15);'
      '    --modal-overlay-bg: rgba(240, 245, 250, 0.95);'
      
        '    --scanline-opacity: 0.03; /* A'#231#305'k temada o grid '#231'izgileri g'#246 +
        'z yormas'#305'n diye saydaml'#305#287#305' iyice k'#305'st'#305'k */'
      '    --gradient-center: rgba(255, 255, 255, 0.5);'
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
      '  body, html { '
      '    margin: 0; padding: 0; height: 100%; '
      
        '    background-color: var(--bg-main) !important; /* !important i' +
        'le UniGUI'#39'yi eziyoruz */'
      '    font-family: '#39'Outfit'#39', sans-serif; '
      '    color: var(--text-main); '
      '    overflow: hidden; '
      '    transition: background-color 0.4s ease, color 0.4s ease; '
      '  }'
      ''
      '  /* S'#304'BERPUNK ARKA PLAN EFEKTLER'#304' */'
      '  .dashboard-container { '
      
        '    display: flex; position: fixed; top: 0; left: 0; width: 100v' +
        'w; height: 100vh; z-index: 1; '
      
        '    background-color: var(--bg-main); /* S'#304'H'#304'RL'#304' DOKUNU'#350': Kontey' +
        'ner art'#305'k '#351'effaf de'#287'il! */'
      '    transition: background-color 0.4s ease;'
      '  }'
      
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
      '  /* Y'#220'KLEME EKRANI */'
      
        '  .global-loader { position: fixed; top: 0; left: 0; width: 100v' +
        'w; height: 100vh; background: var(--sidebar-bg); backdrop-filter' +
        ': blur(8px); z-index: 9999; display: flex; flex-direction: colum' +
        'n; justify-content: center; align-items: center; transition: opa' +
        'city 0.5s ease; }'
      
        '  .radar-box { position: relative; width: 160px; height: 160px; ' +
        'border-radius: 50%; border: 2px solid var(--neon-blue); backgrou' +
        'nd: radial-gradient(circle, rgba(5,217,232,0.15) 0%, transparent' +
        ' 60%); box-shadow: 0 0 30px rgba(5, 217, 232, 0.2), inset 0 0 30' +
        'px rgba(5, 217, 232, 0.2); margin-bottom: 30px; overflow: hidden' +
        '; }'
      
        '  .radar-box::before { content: '#39#39'; position: absolute; top: 0; ' +
        'left: 0; width: 100%; height: 100%; background: linear-gradient(' +
        '90deg, transparent 49%, var(--neon-blue) 49%, var(--neon-blue) 5' +
        '1%, transparent 51%), linear-gradient(0deg, transparent 49%, var' +
        '(--neon-blue) 49%, var(--neon-blue) 51%, transparent 51%); opaci' +
        'ty: 0.3; border-radius: 50%; z-index: 2; }'
      
        '  .radar-sweep { position: absolute; top: 0; left: 0; width: 100' +
        '%; height: 100%; background: conic-gradient(from 0deg, rgba(5, 2' +
        '17, 232, 0.8) 0deg, transparent 90deg, transparent 360deg); bord' +
        'er-radius: 50%; animation: radar-spin 1.5s linear infinite; z-in' +
        'dex: 1; }'
      '  @keyframes radar-spin { 100% { transform: rotate(360deg); } }'
      
        '  .loader-text { font-family: '#39'Press Start 2P'#39', cursive; font-si' +
        'ze: 0.8rem; color: var(--neon-pink); text-shadow: 0 0 10px var(-' +
        '-neon-pink); letter-spacing: 2px; animation: blink-text 1s infin' +
        'ite alternate; }'
      
        '  @keyframes blink-text { 0% { opacity: 1; } 100% { opacity: 0.4' +
        '; } }'
      ''
      '  /* MEN'#220' (SIDEBAR) */'
      
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
      
        '  .logout-btn { margin-top: auto; border-top: 1px solid var(--bo' +
        'rder-color) !important; padding: 25px 35px; }'
      
        '  .logout-btn:hover { color: #ff4b2b !important; background: rgb' +
        'a(255, 75, 43, 0.15) !important; }'
      
        '  .logout-btn:hover i { filter: drop-shadow(0 0 12px #ff4b2b) !i' +
        'mportant; transform: translateX(5px) scale(1.1); }'
      '  '
      '  /* '#304#199'ER'#304'K ALANI */'
      
        '  .main-content { flex: 1; overflow-y: auto; padding: 50px; posi' +
        'tion: relative; z-index: 2; box-sizing: border-box; }'
      '  .welcome-section { margin-bottom: 40px; }'
      
        '  .welcome-section h1 { margin: 0; font-family: '#39'Press Start 2P'#39 +
        ', cursive; font-size: 1.1rem; color: var(--text-main); transitio' +
        'n: 0.4s; }'
      
        '  .welcome-section span { color: var(--neon-pink); transition: 0' +
        '.4s; }'
      
        '  .changing-text { margin-top: 15px; font-family: '#39'Press Start 2' +
        'P'#39', cursive; font-size: 0.7rem; color: var(--neon-blue); min-hei' +
        'ght: 1.5rem; display: inline-block; position: relative; transiti' +
        'on: 0.4s; }'
      
        '  .changing-text::after { content: '#39'_'#39'; animation: blink 0.8s in' +
        'finite; color: var(--neon-pink); }'
      '  '
      
        '  .stats-row { display: grid; grid-template-columns: repeat(auto' +
        '-fit, minmax(160px, 1fr)); gap: 15px; margin-bottom: 40px; }'
      
        '  .stat-card { background: var(--card-bg); border: 1px solid var' +
        '(--border-color); border-radius: 12px; padding: 15px 20px; displ' +
        'ay: flex; flex-direction: column; position: relative; overflow: ' +
        'hidden; transition: 0.4s; backdrop-filter: blur(5px); cursor: po' +
        'inter; }'
      
        '  .stat-card:hover { border-color: var(--neon-blue); box-shadow:' +
        ' 0 0 15px rgba(5, 217, 232, 0.1); transform: translateY(-3px); }'
      
        '  .stat-card i { position: absolute; right: -10px; bottom: -10px' +
        '; font-size: 3.5rem; color: var(--border-color); transform: rota' +
        'te(-15deg); transition: 0.4s; }'
      
        '  .stat-value { font-family: '#39'Press Start 2P'#39', cursive; font-siz' +
        'e: 1rem; color: var(--neon-blue); margin-bottom: 5px; text-shado' +
        'w: 0 0 5px var(--neon-blue); transition: 0.4s; }'
      
        '  .stat-label { font-size: 0.6rem; text-transform: uppercase; le' +
        'tter-spacing: 1px; color: var(--text-muted); font-weight: 700; t' +
        'ransition: 0.4s; }'
      
        '  .stat-wishlist { font-size: 0.6rem; color: var(--neon-pink); m' +
        'argin-left: 5px; font-family: '#39'Outfit'#39', sans-serif; text-shadow:' +
        ' none; vertical-align: middle; transition: 0.4s; }'
      ''
      
        '  .split-sections { display: flex; flex-direction: column; gap: ' +
        '40px; width: 100%; }'
      '  .section-column { display: flex; flex-direction: column; }'
      
        '  .section-title { font-family: '#39'Press Start 2P'#39', cursive; font-' +
        'size: 0.65rem; margin-bottom: 20px; color: var(--neon-pink); bor' +
        'der-bottom: 1px solid var(--border-color); padding-bottom: 15px;' +
        ' display: flex; align-items: center; gap: 12px; justify-content:' +
        ' space-between; transition: 0.4s; }'
      '  '
      
        '  .media-grid { display: grid; grid-template-columns: repeat(aut' +
        'o-fill, minmax(130px, 1fr)); gap: 15px; }'
      
        '  .media-card { aspect-ratio: 2/3; border-radius: 8px; backgroun' +
        'd: var(--card-bg); border: 1px solid var(--border-color); cursor' +
        ': pointer; transition: 0.4s; overflow: hidden; position: relativ' +
        'e; }'
      
        '  .media-card:hover { border-color: var(--neon-blue); box-shadow' +
        ': 0 10px 20px rgba(5, 217, 232, 0.2); transform: translateY(-5px' +
        '); }'
      
        '  .media-card .poster-bg { width: 100%; height: 100%; background' +
        '-position: center !important; background-size: cover !important;' +
        ' background-repeat: no-repeat !important; transition: all 0.5s e' +
        'ase; }'
      
        '  .media-card:hover .poster-bg { filter: brightness(0.35) contra' +
        'st(1.2) grayscale(0.2); transform: scale(1.08); }'
      '  '
      
        '  .random-card-btn { display: flex; flex-direction: column; alig' +
        'n-items: center; justify-content: center; border: 2px dashed var' +
        '(--border-color); background: var(--card-bg); color: var(--neon-' +
        'blue); text-align: center; padding: 10px; aspect-ratio: 2/3; bor' +
        'der-radius: 8px; cursor: pointer; transition: 0.4s;}'
      '  .random-card-btn i { font-size: 2rem; margin-bottom: 10px; }'
      
        '  .random-card-btn span { font-family: '#39'Press Start 2P'#39', cursive' +
        '; font-size: 0.5rem; line-height: 1.5; }'
      
        '  .random-card-btn:hover { border: 2px solid var(--neon-pink); b' +
        'ackground: rgba(255, 42, 109, 0.1); color: var(--neon-pink); box' +
        '-shadow: 0 0 15px rgba(255, 42, 109, 0.2); transform: scale(1.02' +
        '); }'
      ''
      '  /* ========================================================='
      '     TAM EKRAN RASTGELE SE'#199#304'C'#304' (MODAL)'
      
        '     ========================================================= *' +
        '/'
      
        '  .random-modal-overlay { position: fixed; top: 0; left: 0; widt' +
        'h: 100vw; height: 100vh; background: var(--modal-overlay-bg); z-' +
        'index: 9999999; display: flex; justify-content: center; align-it' +
        'ems: center; opacity: 0; pointer-events: none; transition: backg' +
        'round-color 0.4s ease, opacity 0.5s ease; backdrop-filter: blur(' +
        '15px); }'
      
        '  .random-modal-overlay.show { opacity: 1; pointer-events: all; ' +
        '}'
      ''
      
        '  .vortex-container { position: absolute; display: flex; justify' +
        '-content: center; align-items: center; }'
      
        '  .vortex-ring { position: absolute; border-radius: 50%; border:' +
        ' 4px solid transparent; border-top-color: var(--neon-blue); bord' +
        'er-bottom-color: var(--neon-pink); animation: spin-vortex var(--' +
        'duration) linear infinite; }'
      
        '  .ring-1 { width: 250px; height: 250px; --duration: 2s; border-' +
        'width: 6px; filter: blur(2px); }'
      
        '  .ring-2 { width: 180px; height: 180px; --duration: 1.5s; borde' +
        'r-width: 4px; border-left-color: var(--neon-blue); }'
      
        '  .ring-3 { width: 120px; height: 120px; --duration: 1s; border-' +
        'width: 8px; border-right-color: var(--neon-pink); filter: blur(1' +
        'px); }'
      '  @keyframes spin-vortex { to { transform: rotate(360deg); } }'
      
        '  .vortex-container.collapse .vortex-ring { transition: all 0.8s' +
        ' cubic-bezier(0.1, 0.7, 0.1, 1); transform: scale(0) rotate(720d' +
        'eg); opacity: 0; }'
      ''
      
        '  .randomizer-subtitle { position: absolute; top: 50%; left: 50%' +
        '; transform: translate(-50%, 170px); width: 100%; text-align: ce' +
        'nter; font-family: '#39'Press Start 2P'#39', cursive; font-size: 0.75rem' +
        '; line-height: 2.2; color: var(--neon-blue); text-shadow: 0 0 10' +
        'px var(--neon-blue); letter-spacing: 2px; animation: subtitle-pu' +
        'lse 1s infinite alternate; transition: all 0.6s cubic-bezier(0.1' +
        ', 0.7, 0.1, 1); z-index: 3; pointer-events: none; }'
      
        '  @keyframes subtitle-pulse { 0% { opacity: 0.6; filter: drop-sh' +
        'adow(0 0 2px var(--neon-pink)); } 100% { opacity: 1; filter: dro' +
        'p-shadow(0 0 12px var(--neon-pink)); } }'
      
        '  .randomizer-subtitle.hide { opacity: 0; transform: translate(-' +
        '50%, 170px) scale(0); }'
      ''
      
        '  .neon-flash { position: absolute; width: 10px; height: 10px; b' +
        'order-radius: 50%; background: #fff; box-shadow: 0 0 100px 50px ' +
        'white, 0 0 200px 100px var(--neon-blue), 0 0 300px 150px var(--n' +
        'eon-pink); opacity: 0; transform: scale(0); pointer-events: none' +
        '; }'
      
        '  .neon-flash.trigger { animation: flash-boom 0.8s ease-out forw' +
        'ards; }'
      
        '  @keyframes flash-boom { 0% { opacity: 1; transform: scale(0.1)' +
        '; } 50% { opacity: 0.8; transform: scale(2); } 100% { opacity: 0' +
        '; transform: scale(3); } }'
      ''
      
        '  .result-container { display: flex; flex-direction: row; align-' +
        'items: stretch; gap: 40px; background: var(--card-bg); border: 1' +
        'px solid var(--border-color); padding: 30px; border-radius: 16px' +
        '; box-shadow: 0 0 40px rgba(0, 0, 0, 0.3); max-width: 850px; wid' +
        'th: 90%; max-height: 90vh; overflow: hidden; opacity: 0; transfo' +
        'rm: scale(0.8) translateY(50px); transition: all 0.8s cubic-bezi' +
        'er(0.34, 1.56, 0.64, 1); z-index: 2; backdrop-filter: blur(10px)' +
        '; }'
      
        '  .result-container.reveal { opacity: 1; transform: scale(1) tra' +
        'nslateY(0); }'
      ''
      
        '  .result-poster-frame { width: 260px; min-width: 260px; flex-sh' +
        'rink: 0; aspect-ratio: 2/3; background-size: cover; background-p' +
        'osition: center; border-radius: 8px; box-shadow: 0 0 30px rgba(5' +
        ', 217, 232, 0.2); border: 2px solid var(--neon-blue); position: ' +
        'relative; overflow: hidden; transition: 0.4s; }'
      
        '  .result-poster-frame::before { content: '#39#39'; position: absolute' +
        '; top: 0; left: 0; width: 100%; height: 100%; background: inheri' +
        't; filter: brightness(1.5) contrast(1.2); mix-blend-mode: hard-l' +
        'ight; opacity: 0; }'
      
        '  .result-container.reveal .result-poster-frame::before { animat' +
        'ion: glitch-reveal 1s linear forwards; }'
      ''
      
        '  .result-details { display: flex; flex-direction: column; justi' +
        'fy-content: flex-start; text-align: left; opacity: 0; flex: 1; m' +
        'in-width: 0; max-height: calc(85vh - 60px); }'
      
        '  .result-container.reveal .result-details { animation: fade-in-' +
        'right 0.8s ease forwards 0.3s; }'
      
        '  @keyframes fade-in-right { from { opacity: 0; transform: trans' +
        'lateX(-20px); } to { opacity: 1; transform: translateX(0); } }'
      ''
      
        '  .result-title { font-family: '#39'Press Start 2P'#39', cursive; font-s' +
        'ize: 1.2rem; color: var(--text-main); text-shadow: 2px 2px var(-' +
        '-neon-pink); margin-top:0; margin-bottom: 20px; line-height: 1.4' +
        '; transition: 0.4s; }'
      
        '  .result-meta { display: flex; gap: 12px; margin-bottom: 20px; ' +
        'flex-wrap: wrap; }'
      
        '  .meta-tag { background: rgba(5, 217, 232, 0.05); border: 1px s' +
        'olid var(--neon-blue); color: var(--neon-blue); padding: 8px 12p' +
        'x; border-radius: 4px; font-size: 0.7rem; font-family: '#39'Press St' +
        'art 2P'#39', cursive; display: flex; align-items: flex-start; gap: 8' +
        'px; line-height: 1.5; text-align: left; white-space: normal; wor' +
        'd-break: break-word; max-width: 100%; box-sizing: border-box; tr' +
        'ansition: 0.4s; }'
      
        '  .meta-tag span { white-space: normal; word-wrap: break-word; o' +
        'verflow-wrap: break-word; color: var(--neon-blue); }'
      '  .meta-tag i { color: var(--neon-pink); }'
      '  '
      
        '  .result-summary { color: var(--text-muted); font-size: 0.95rem' +
        '; line-height: 1.6; padding-right: 10px; margin-bottom: 20px; bo' +
        'rder-left: 2px solid var(--neon-pink); padding-left: 15px; flex:' +
        ' 1; overflow-y: auto; min-height: 80px; transition: 0.4s; }'
      '  .result-summary::-webkit-scrollbar { width: 6px; }'
      
        '  .result-summary::-webkit-scrollbar-thumb { background: var(--n' +
        'eon-pink); border-radius: 10px; }'
      ''
      
        '  .close-random-btn { align-self: flex-start; margin-top: auto; ' +
        'padding: 12px 30px; background: transparent; color: var(--neon-p' +
        'ink); border: 2px solid var(--neon-pink); font-family: '#39'Press St' +
        'art 2P'#39', cursive; cursor: pointer; transition: 0.4s; font-size: ' +
        '0.7rem; }'
      
        '  .close-random-btn:hover { background: var(--neon-pink); color:' +
        ' #fff; box-shadow: 0 0 20px var(--neon-pink); transform: scale(1' +
        '.05); }'
      ''
      
        '  .made-with-love { text-align: center; font-family: '#39'Press Star' +
        't 2P'#39', cursive; font-size: 0.55rem; color: var(--text-muted); ma' +
        'rgin-bottom: 15px; line-height: 1.8; transition: 0.4s; }'
      
        '  .made-with-love .author a { color: var(--neon-blue); text-deco' +
        'ration: none; text-shadow: 0 0 5px var(--neon-blue); transition:' +
        ' 0.4s; }'
      
        '  .made-with-love .author a:hover { color: var(--neon-pink); tex' +
        't-shadow: 0 0 10px var(--neon-pink); }'
      ''
      '  .empty-state-container {'
      '    display: flex;'
      '    flex-direction: column;'
      '    align-items: center;'
      '    justify-content: center;'
      '    padding: 40px 20px;'
      '    background: var(--card-bg);'
      '    border: 1px dashed var(--border-color);'
      '    border-radius: 12px;'
      '    text-align: center;'
      '    transition: all 0.4s ease;'
      '  }'
      '  .empty-state-container:hover {'
      '    border-color: var(--neon-blue);'
      '    box-shadow: 0 0 20px rgba(5, 217, 232, 0.1);'
      '  }'
      '  .empty-state-icon {'
      '    font-size: 3rem;'
      '    color: var(--neon-blue);'
      '    margin-bottom: 15px;'
      '    opacity: 0.5;'
      '    transition: all 0.4s ease;'
      '  }'
      '  .empty-state-container:hover .empty-state-icon {'
      '    opacity: 1;'
      '    text-shadow: 0 0 15px var(--neon-blue);'
      '  }'
      '  .empty-state-title {'
      '    font-family: '#39'Press Start 2P'#39', cursive;'
      '    font-size: 0.8rem;'
      '    color: var(--text-main);'
      '    margin-bottom: 10px;'
      '  }'
      '  .empty-state-desc {'
      '    font-family: '#39'Outfit'#39', sans-serif;'
      '    font-size: 0.9rem;'
      '    color: var(--text-muted);'
      '    max-width: 400px;'
      '    line-height: 1.5;'
      '    margin-bottom: 20px;'
      '  }'
      '  .empty-state-btn {'
      '    background: rgba(5, 217, 232, 0.1);'
      '    color: var(--neon-blue);'
      '    border: 1px solid var(--neon-blue);'
      '    padding: 12px 25px;'
      '    border-radius: 5px;'
      '    font-family: '#39'Press Start 2P'#39', cursive;'
      '    font-size: 0.6rem;'
      '    cursor: pointer;'
      '    transition: 0.3s;'
      '    display: flex;'
      '    align-items: center;'
      '    gap: 10px;'
      '  }'
      '  .empty-state-btn:hover {'
      '    background: var(--neon-blue);'
      '    color: var(--bg-main);'
      '    box-shadow: 0 0 15px var(--neon-blue);'
      '    transform: translateY(-2px);'
      '  }'
      ''
      ''
      '  @media (max-width: 800px) { '
      
        '    .media-grid { grid-template-columns: repeat(3, 1fr); gap: 10' +
        'px; } '
      '    .main-content { padding: 25px 15px; } '
      
        '    .sidebar { position: fixed; left: -300px; top: 0; height: 10' +
        '0vh; z-index: 1001; transition: left 0.4s cubic-bezier(0.25, 0.4' +
        '6, 0.45, 0.94); }'
      
        '    .sidebar.open { left: 0; box-shadow: 10px 0 30px rgba(5, 217' +
        ', 232, 0.1); }'
      '    .mobile-header { display: flex; } '
      '    .welcome-section h1 { font-size: 0.9rem; } '
      '    '
      
        '    .result-container { flex-direction: column; align-items: cen' +
        'ter; padding: 25px 20px; gap: 20px; overflow-y: auto; } '
      
        '    .result-poster-frame { width: 200px; min-width: 200px; flex-' +
        'shrink: 0; align-self: center; margin: 0 auto; } '
      
        '    .result-details { max-height: none; overflow: visible; width' +
        ': 100%; display: flex; flex-direction: column; flex: none; }'
      
        '    .result-title { text-align: center; font-size: 1rem; white-s' +
        'pace: normal !important; word-wrap: break-word; word-break: brea' +
        'k-word; } '
      '    .result-meta { justify-content: center; width: 100%; } '
      
        '    .meta-tag { flex: 1 1 auto; justify-content: center; text-al' +
        'ign: center; font-size: 0.65rem; }'
      
        '    .result-summary { border-left: none; border-top: 2px solid v' +
        'ar(--neon-pink); padding-top: 15px; padding-left: 0; text-align:' +
        ' left; flex: none; overflow-y: visible; } '
      
        '    .close-random-btn { align-self: stretch; text-align: center;' +
        ' margin-top: 10px; } '
      '  }'
      '  @media (max-width: 500px) {'
      '    .media-grid { grid-template-columns: repeat(2, 1fr); }'
      '  }'
      '</style>'
      ''
      '<div class="dashboard-container">'
      '  '
      '  <div class="global-loader" id="globalLoader">'
      '    <div class="radar-box"><div class="radar-sweep"></div></div>'
      '    <div class="loader-text">A'#286'A BA'#286'LANILIYOR...</div>'
      '  </div>'
      ''
      
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
      '      </div>'
      '    '
      '    <nav class="nav-group">'
      
        '      <div class="nav-item active"><i class="fa-solid fa-house">' +
        '</i> Ana Sayfa</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(ANA_SAYFA_FORM.' +
        'UniHTMLFrame1, '#39'gamesPageCall'#39', [])"><i class="fa-solid fa-gamep' +
        'ad"></i> Oyunlar'#305'm</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(ANA_SAYFA_FORM.' +
        'UniHTMLFrame1, '#39'moviesPageCall'#39', [])"><i class="fa-solid fa-film' +
        '"></i> Filmlerim</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(ANA_SAYFA_FORM.' +
        'UniHTMLFrame1, '#39'tvShowsPageCall'#39', [])"><i class="fa-solid fa-tv"' +
        '></i> Dizilerim</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(ANA_SAYFA_FORM.' +
        'UniHTMLFrame1, '#39'booksPageCall'#39', [])"><i class="fa-solid fa-book"' +
        '></i> Kitaplar'#305'm</div>'
      '    </nav>'
      ''
      '    <div style="margin-top: auto; width: 100%;">'
      '    '
      '      <div class="made-with-love">'
      
        '        Made with <span class="heart"><i class="fa-solid fa-hear' +
        't" style="color: rgb(255, 0, 0);"></i></span><br>'
      
        '        by <span class="author"><a href="https://hasup.net" targ' +
        'et="_blank">Yu'#351'a G'#246'verdik</a></span>'
      '      </div>'
      '    '
      
        '      <div class="nav-item" onclick="ajaxRequest(ANA_SAYFA_FORM.' +
        'UniHTMLFrame1, '#39'accountPageCall'#39', [])">'
      '        <i class="fa-solid fa-user-gear"></i> Hesab'#305'm'
      '      </div>'
      
        '      <div class="nav-item logout-btn" onclick="ajaxRequest(ANA_' +
        'SAYFA_FORM.UniHTMLFrame1, '#39'DoLogout'#39', [])" style="margin-top: 0 ' +
        '!important;">'
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
      
        '      <h1>HO'#350' GELD'#304'N'#304'Z, <span id="spanUser">YAZILIMCI_</span></h' +
        '1>'
      
        '      <div id="dynamicQuote" class="changing-text">Sistem haz'#305'r.' +
        '.. Veriler y'#252'kleniyor.</div>'
      '    </header>'
      ''
      '    <div class="stats-row">'
      
        '      <div class="stat-card" onclick="ajaxRequest(ANA_SAYFA_FORM' +
        '.UniHTMLFrame1, '#39'gamesPageCall'#39', [])">'
      '        <i class="fa-solid fa-gamepad"></i>'
      
        '        <div class="stat-value"><span id="statGameCount">0</span' +
        '> <span class="stat-wishlist" id="statGameWish"></span></div>'
      '        <div class="stat-label">Toplam Oyun</div>'
      '      </div>'
      
        '      <div class="stat-card" onclick="ajaxRequest(ANA_SAYFA_FORM' +
        '.UniHTMLFrame1, '#39'moviesPageCall'#39', [])">'
      '        <i class="fa-solid fa-film"></i>'
      
        '        <div class="stat-value"><span id="statMovieCount">0</spa' +
        'n> <span class="stat-wishlist" id="statMovieWish"></span></div>'
      '        <div class="stat-label">Toplam Film</div>'
      '      </div>'
      
        '      <div class="stat-card"onclick="ajaxRequest(ANA_SAYFA_FORM.' +
        'UniHTMLFrame1, '#39'tvShowsPageCall'#39', [])">'
      '        <i class="fa-solid fa-tv"></i>'
      
        '        <div class="stat-value"><span id="statTvCount">0</span> ' +
        '<span class="stat-wishlist" id="statTvWish"></span></div>'
      '        <div class="stat-label">Toplam Dizi</div>'
      '      </div>'
      
        '      <div class="stat-card" onclick="ajaxRequest(ANA_SAYFA_FORM' +
        '.UniHTMLFrame1, '#39'booksPageCall'#39', [])">'
      '        <i class="fa-solid fa-book"></i>'
      
        '        <div class="stat-value"><span id="statBookCount">0</span' +
        '> <span class="stat-wishlist" id="statBookWish"></span></div>'
      '        <div class="stat-label">Toplam Kitap</div>'
      '      </div>'
      '    </div>'
      ''
      '    <div class="split-sections">'
      '      '
      '      <section class="section-column">'
      '        <div class="section-title">'
      
        '          <span><i class="fa-solid fa-gamepad"></i> SON EKLENEN ' +
        'OYUNLAR_</span>'
      
        '          <span style="cursor:pointer;" onclick="ajaxRequest(ANA' +
        '_SAYFA_FORM.UniHTMLFrame1, '#39'gamesPageCall'#39', [])"><i class="fa-so' +
        'lid fa-arrow-right"></i></span>'
      '        </div>'
      '        <div id="gameGrid" class="media-grid"></div>'
      '      </section>'
      ''
      '      <section class="section-column">'
      '        <div class="section-title">'
      
        '          <span><i class="fa-solid fa-film"></i> SON EKLENEN F'#304'L' +
        'MLER_</span>'
      
        '          <span style="cursor:pointer;" onclick="ajaxRequest(ANA' +
        '_SAYFA_FORM.UniHTMLFrame1, '#39'moviesPageCall'#39', [])"><i class="fa-s' +
        'olid fa-arrow-right"></i></span>'
      '        </div>'
      '        <div id="movieGrid" class="media-grid"></div>'
      '      </section>'
      ''
      '      <section class="section-column">'
      '        <div class="section-title">'
      
        '          <span><i class="fa-solid fa-tv"></i> SON EKLENEN D'#304'Z'#304'L' +
        'ER_</span>'
      
        '          <span style="cursor:pointer;" onclick="ajaxRequest(ANA' +
        '_SAYFA_FORM.UniHTMLFrame1, '#39'tvShowsPageCall'#39', [])"><i class="fa-' +
        'solid fa-arrow-right"></i></span>'
      '        </div>'
      '        <div id="tvGrid" class="media-grid"></div>'
      '      </section>'
      ''
      '      <section class="section-column">'
      '        <div class="section-title">'
      
        '          <span><i class="fa-solid fa-book"></i> SON EKLENEN K'#304'T' +
        'APLAR_</span>'
      
        '          <span style="cursor:pointer;" onclick="ajaxRequest(ANA' +
        '_SAYFA_FORM.UniHTMLFrame1, '#39'booksPageCall'#39', [])"><i class="fa-so' +
        'lid fa-arrow-right"></i></span>'
      '        </div>'
      '        <div id="bookGrid" class="media-grid"></div>'
      '      </section>'
      ''
      '    </div>'
      '  </main>'
      '</div>'
      ''
      '<div class="random-modal-overlay" id="randomizerModal">'
      '  <div class="vortex-container" id="vortexAnim">'
      '      <div class="vortex-ring ring-1"></div>'
      '      <div class="vortex-ring ring-2"></div>'
      '      <div class="vortex-ring ring-3"></div>'
      '  </div>'
      
        '  <div class="randomizer-subtitle" id="vortexSubtitle">S'#304'STEM TA' +
        'RAMASI BA'#350'LATILIYOR...</div>'
      '  <div class="neon-flash" id="neonFlash"></div>'
      ''
      '  <div class="result-container" id="resultBox">'
      '      <div class="result-poster-frame" id="resPoster"></div>'
      '      <div class="result-details">'
      '          <h2 class="result-title" id="resTitle">BA'#350'LIK</h2>'
      '          <div class="result-meta">'
      
        '              <div class="meta-tag"><i class="fa-solid fa-star">' +
        '</i> <span id="resScore">--</span></div>'
      
        '              <div class="meta-tag"><i class="fa-solid fa-masks-' +
        'theater"></i> <span id="resGenre">--</span></div>'
      
        '              <div class="meta-tag"><i class="fa-solid fa-calend' +
        'ar-days"></i> <span id="resYear">--</span></div> '
      
        '              <div class="meta-tag"><i class="fa-solid fa-microc' +
        'hip" id="extraIcon"></i> <span id="resExtra">--</span></div> '
      '          </div>'
      
        '          <div class="result-summary" id="resSummary">A'#231#305'klama a' +
        'ran'#305'yor...</div>'
      
        '          <button class="close-random-btn" onclick="window.close' +
        'Randomizer()">S'#304'STEM'#304' KAPAT</button>'
      '      </div>'
      '  </div>'
      '</div>')
    Align = alClient
    ClientEvents.ExtEvents.Strings = (
      
        'afterrender=function afterrender(sender, eOpts)'#13#10'{'#13#10'  window.doL' +
        'ogout = function() {'#13#10'        ajaxRequest(sender, '#39'doLogout'#39', []' +
        ');'#13#10'    };'#13#10'}')
    OnAjaxEvent = UniHTMLFrame1AjaxEvent
  end
  object UniTimer1: TUniTimer
    Interval = 100
    Enabled = False
    ClientEvent.Strings = (
      'function(sender)'
      '{'
      ' '
      '}')
    OnTimer = UniTimer1Timer
    Left = 488
    Top = 144
  end
end
