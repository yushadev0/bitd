object TEST_FORM: TTEST_FORM
  Left = 0
  Top = 0
  ClientHeight = 561
  ClientWidth = 784
  Caption = 'TEST_FORM'
  WindowState = wsMaximized
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  Script.Strings = (
    'window.runBTTDTypewriter = function() {'
    '    const quotes = ['
    '        "bug'#252'n hangi filmleri izlediniz?", '
    '        "bug'#252'n hangi oyunlar'#305' oynad'#305'n'#305'z?"'
    '    ];'
    '    let qIdx = 0;'
    '    let cIdx = 0;'
    '    let isDeleting = false;'
    ''
    '    function step() {'
    '        const el = document.getElementById('#39'dynamicQuote'#39');'
    '        '
    
      '        // Element yoksa (hen'#252'z render edilmemi'#351'se) 200ms bekle ' +
      've tekrar dene'
    '        if (!el) {'
    '            setTimeout(step, 200);'
    '            return;'
    '        }'
    ''
    '        const fullText = quotes[qIdx];'
    '        '
    '        if (isDeleting) {'
    '            el.innerText = fullText.substring(0, cIdx - 1);'
    '            cIdx--;'
    '        } else {'
    '            el.innerText = fullText.substring(0, cIdx + 1);'
    '            cIdx++;'
    '        }'
    ''
    '        let speed = isDeleting ? 50 : 100;'
    ''
    '        if (!isDeleting && cIdx === fullText.length) {'
    '            isDeleting = true;'
    '            speed = 3000;'
    '        } else if (isDeleting && cIdx === 0) {'
    '            isDeleting = false;'
    '            qIdx = (qIdx + 1) % quotes.length;'
    '            speed = 500;'
    '        }'
    ''
    '        setTimeout(step, speed);'
    '    }'
    ''
    '    step();'
    '};'
    ''
    '// Sayfa y'#252'klendi'#287'inde otomatik tetikle'
    'window.runBTTDTypewriter();')
  TextHeight = 15
  object UniHTMLFrame1: TUniHTMLFrame
    Left = 0
    Top = 0
    Width = 784
    Height = 561
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
      '    --sidebar-bg: rgba(10, 10, 35, 0.95);'
      '  }'
      ''
      '  /* --- SCROLLBAR --- */'
      '  ::-webkit-scrollbar { width: 8px; }'
      '  ::-webkit-scrollbar-track { background: var(--bg-dark); }'
      
        '  ::-webkit-scrollbar-thumb { background: var(--neon-blue); bord' +
        'er-radius: 10px; box-shadow: 0 0 10px var(--neon-blue); }'
      
        '  ::-webkit-scrollbar-thumb:hover { background: var(--neon-pink)' +
        '; }'
      ''
      
        '  body, html { margin: 0; padding: 0; height: 100%; background-c' +
        'olor: var(--bg-dark); font-family: '#39'Outfit'#39', sans-serif; color: ' +
        '#ffffff; overflow: hidden; }'
      ''
      '  /* Arka Plan */'
      
        '  .dashboard-container { display: flex; height: 100vh; width: 10' +
        '0vw; position: relative; z-index: 1; }'
      
        '  .dashboard-container::before { content: '#39#39'; position: absolute' +
        '; top: 0; left: 0; width: 100%; height: 100%; background: radial' +
        '-gradient(circle at center, #10002b 0%, #000000 100%); z-index: ' +
        '-1; }'
      
        '  .dashboard-container::after { content: '#39#39'; position: absolute;' +
        ' top: 0; left: 0; width: 100%; height: 100%; background: linear-' +
        'gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.15) 50%), line' +
        'ar-gradient(90deg, rgba(255, 0, 0, 0.03), rgba(0, 255, 0, 0.01),' +
        ' rgba(0, 0, 255, 0.03)); background-size: 100% 2px, 3px 100%; po' +
        'inter-events: none; z-index: 5; }'
      ''
      '  /* --- MOBILE --- */'
      
        '  .mobile-header { display: none; position: fixed; top: 0; left:' +
        ' 0; width: 100%; height: 70px; background: rgba(10, 10, 35, 0.8)' +
        '; backdrop-filter: blur(15px); border-bottom: 1px solid rgba(5, ' +
        '217, 232, 0.2); z-index: 999; align-items: center; padding: 0 20' +
        'px; box-sizing: border-box; }'
      
        '  .mobile-toggle { display: none; position: fixed; top: 12px; le' +
        'ft: 20px; z-index: 1100; background: rgba(1, 1, 43, 0.8); border' +
        ': 1px solid var(--neon-blue); color: var(--neon-blue); width: 45' +
        'px; height: 45px; border-radius: 8px; cursor: pointer; align-ite' +
        'ms: center; justify-content: center; transition: 0.2s; }'
      ''
      '  /* --- SIDEBAR --- */'
      
        '  .sidebar { width: 260px; background: var(--sidebar-bg); backdr' +
        'op-filter: blur(25px); border-right: 1px solid rgba(5, 217, 232,' +
        ' 0.1); display: flex; flex-direction: column; padding: 80px 0 0 ' +
        '0; z-index: 1001; transition: transform 0.4s ease; }'
      '  .sidebar-header { text-align: center; margin-bottom: 50px; }'
      
        '  .sidebar-brand { font-family: '#39'Press Start 2P'#39', cursive; color' +
        ': var(--neon-blue); font-size: 1.1rem; text-shadow: 2px 2px var(' +
        '--neon-pink); }'
      
        '  .sidebar-tagline { font-size: 0.6rem; letter-spacing: 3px; col' +
        'or: rgba(255,255,255,0.4); font-weight: bold; text-transform: up' +
        'percase; }'
      ''
      '  /* NAV ITEMS */'
      
        '  .nav-group { display: flex; flex-direction: column; width: 100' +
        '%; }'
      
        '  .nav-item { position: relative; padding: 18px 35px; cursor: po' +
        'inter; display: flex; align-items: center; gap: 20px; color: rgb' +
        'a(255,255,255,0.5); transition: 0.3s; font-size: 0.95rem; }'
      
        '  .nav-item:hover { color: var(--neon-blue); background: rgba(5,' +
        ' 217, 232, 0.08); }'
      
        '  .nav-item:hover i { transform: scale(1.1); filter: drop-shadow' +
        '(0 0 8px var(--neon-blue)); }'
      
        '  .nav-item.active { color: #ffffff; background: linear-gradient' +
        '(90deg, rgba(5, 217, 232, 0.1) 0%, transparent 100%); }'
      
        '  .nav-item.active i { color: var(--neon-pink); filter: drop-sha' +
        'dow(0 0 8px var(--neon-pink)); }'
      
        '  .nav-item::before { content: '#39#39'; position: absolute; left: 0; ' +
        'top: 50%; transform: translateY(-50%); width: 0; height: 0; back' +
        'ground: var(--neon-pink); box-shadow: 0 0 15px var(--neon-pink);' +
        ' transition: 0.3s; border-radius: 0 4px 4px 0; }'
      '  .nav-item.active::before { width: 4px; height: 60%; }'
      ''
      '  /* ISOLATED LOGOUT */'
      
        '  .btn-logout { margin-top: auto; padding: 25px 35px; cursor: po' +
        'inter; display: flex; align-items: center; gap: 20px; color: rgb' +
        'a(255, 255, 255, 0.4); border-top: 1px solid rgba(255, 255, 255,' +
        ' 0.1); transition: 0.3s; font-size: 0.95rem; margin-bottom: 30px' +
        '; }'
      
        '  .btn-logout:hover { color: #ff4b2b; background: rgba(255, 75, ' +
        '43, 0.1); }'
      
        '  .btn-logout:hover i { filter: drop-shadow(0 0 10px #ff4b2b); t' +
        'ransform: scale(1.1); }'
      ''
      '  /* MAIN CONTENT */'
      
        '  .main-content { flex: 1; overflow-y: auto; padding: 50px; posi' +
        'tion: relative; z-index: 2; box-sizing: border-box; }'
      '  .welcome-section { margin-bottom: 60px; }'
      
        '  .welcome-section h1 { margin: 0; font-family: '#39'Press Start 2P'#39 +
        ', cursive; font-size: 1.1rem; color: #ffffff; line-height: 1.8; ' +
        '}'
      '  .welcome-section span { color: var(--neon-pink); }'
      
        '  .changing-text { margin-top: 25px; font-family: '#39'Press Start 2' +
        'P'#39', cursive; font-size: 0.7rem; color: var(--neon-blue); min-hei' +
        'ght: 1.5rem; display: inline-block; position: relative; }'
      
        '  .changing-text::after { content: '#39'_'#39'; animation: blink 0.8s in' +
        'finite; color: var(--neon-pink); }'
      
        '  @keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0; ' +
        '} }'
      ''
      '  /* GRID */'
      
        '  .split-sections { display: grid; grid-template-columns: 1fr 1f' +
        'r; gap: 50px; width: 100%; }'
      
        '  .section-title { font-family: '#39'Press Start 2P'#39', cursive; font-' +
        'size: 0.7rem; margin-bottom: 30px; color: var(--neon-pink); bord' +
        'er-bottom: 1px solid rgba(255, 42, 109, 0.2); padding-bottom: 15' +
        'px; display: flex; align-items: center; gap: 12px; }'
      
        '  .media-grid { display: grid; grid-template-columns: repeat(aut' +
        'o-fill, minmax(160px, 1fr)); gap: 25px; }'
      
        '  .media-card { aspect-ratio: 2/3; border-radius: 10px; backgrou' +
        'nd: rgba(5, 5, 25, 0.4); border: 1px solid rgba(255,255,255,0.08' +
        '); cursor: pointer; transition: 0.4s; overflow: hidden; }'
      
        '  .media-card:hover { transform: translateY(-10px); border-color' +
        ': var(--neon-blue); box-shadow: 0 10px 25px rgba(5, 217, 232, 0.' +
        '2); }'
      ''
      '  @media (max-width: 1024px) {'
      '    .mobile-header { display: flex; }'
      '    .mobile-toggle { display: flex; }'
      
        '    .sidebar { position: fixed; left: 0; top: 0; height: 100%; t' +
        'ransform: translateX(-100%); }'
      '    .sidebar.open { transform: translateX(0); }'
      '    .main-content { padding: 100px 20px 30px 20px; }'
      '    .split-sections { grid-template-columns: 1fr; gap: 40px; }'
      '  }'
      '</style>'
      ''
      '<div class="dashboard-container">'
      
        '  <button class="mobile-toggle" id="btnToggle" onclick="if(windo' +
        'w.toggleSidebar) window.toggleSidebar()">'
      '    <i class="fa-solid fa-bars"></i>'
      '  </button>'
      ''
      '  <header class="mobile-header">'
      
        '    <div style="font-family: '#39'Press Start 2P'#39', cursive; font-siz' +
        'e: 0.8rem; color: var(--neon-blue); margin-left: 60px;">B.I.T.D.' +
        '</div>'
      '  </header>'
      ''
      '  <aside class="sidebar" id="sidebar">'
      '    <div class="sidebar-header">'
      '      <div class="sidebar-brand">B.I.T.D.</div>'
      '      <div class="sidebar-tagline">Back In The Day</div>'
      '    </div>'
      '    <nav class="nav-group">'
      
        '      <div class="nav-item active"><i class="fa-solid fa-house">' +
        '</i> Ana Sayfa</div>'
      
        '      <div class="nav-item"><i class="fa-solid fa-gamepad"></i> ' +
        'Oyunlar'#305'm</div>'
      
        '      <div class="nav-item"><i class="fa-solid fa-film"></i> Fil' +
        'mlerim</div>'
      '    </nav>'
      
        '    <div class="btn-logout" onclick="ajaxRequest(window.parent, ' +
        #39'DoLogout'#39', [])">'
      '      <i class="fa-solid fa-right-from-bracket"></i> '#199#305'k'#305#351' Yap'
      '    </div>'
      '  </aside>'
      ''
      '  <main class="main-content">'
      '    <header class="welcome-section">'
      
        '      <h1>HO'#350' GELD'#304'N'#304'Z, <span id="spanUser">YAZILIMCI_</span></h' +
        '1>'
      '      <div id="dynamicQuote" class="changing-text"></div>'
      '    </header>'
      ''
      '    <div class="split-sections">'
      '      <section class="section-column">'
      
        '        <div class="section-title"><i class="fa-solid fa-clapper' +
        'board"></i> SON F'#304'LMLER_</div>'
      
        '        <div id="movieGrid" class="media-grid"><div class="media' +
        '-card"></div></div>'
      '      </section>'
      '      <section class="section-column">'
      
        '        <div class="section-title"><i class="fa-solid fa-headset' +
        '"></i> SON OYUNLAR_</div>'
      
        '        <div id="gameGrid" class="media-grid"><div class="media-' +
        'card"></div></div>'
      '      </section>'
      '    </div>'
      '  </main>'
      '</div>')
    Align = alClient
    ExplicitLeft = -16
    ExplicitTop = -39
    ExplicitWidth = 800
    ExplicitHeight = 600
  end
end
