object FILMLERIM_FORM: TFILMLERIM_FORM
  Left = 0
  Top = 0
  ClientHeight = 600
  ClientWidth = 800
  Caption = 'FILMLERIM_FORM'
  OnShow = UniFormShow
  BorderStyle = bsNone
  WindowState = wsMaximized
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  Script.Strings = (
    'window.triggerSearch = function() {'
    
      '    var searchInput = document.getElementById("movieSearchInput"' +
      ').value;'
    
      '    var targetInput = document.getElementById("searchTargetInput' +
      '").value; '
    '    if (searchInput.trim() !== "") {'
    
      '        document.getElementById("searchResults").innerHTML = "<d' +
      'iv class='#39'loading-container'#39'><i class='#39'fa-solid fa-circle-notch ' +
      'fa-spin loading-icon'#39'></i><br>ARANIYOR...</div>";'
    
      '        ajaxRequest(FILMLERIM_FORM.UniHTMLFrame1, "FilmAra", ["k' +
      'elime=" + searchInput, "hedef=" + targetInput]);'
    '    }'
    '};'
    ''
    'window.toggleSidebar = function() {'
    '    var sidebar = document.getElementById('#39'sidebar'#39');'
    '    var overlay = document.getElementById('#39'sidebarOverlay'#39');'
    '    if (sidebar && overlay) {'
    '        sidebar.classList.toggle('#39'open'#39');'
    '        overlay.classList.toggle('#39'show'#39');'
    '    }'
    '};'
    ''
    'window.openAddMovieModal = function(e, targetList) {'
    '    if (e) e.stopPropagation();'
    '    var modal = document.getElementById('#39'addMovieModal'#39');'
    '    var input = document.getElementById('#39'movieSearchInput'#39');'
    '    var results = document.getElementById('#39'searchResults'#39');'
    
      '    var targetInput = document.getElementById('#39'searchTargetInput' +
      #39'); '
    '    if (targetInput) targetInput.value = targetList; '
    
      '    var modalTitle = document.getElementById('#39'searchModalTitle'#39')' +
      ';'
    '    if (modalTitle) {'
    '        if (targetList == 1) {'
    
      '            modalTitle.innerHTML = '#39'<i class="fa-solid fa-heart"' +
      '></i> '#304'ZLEME L'#304'STES'#304'NE F'#304'LM ARA_'#39';'
    '            modalTitle.className = '#39'section-title title-pink'#39';'
    '        } else {'
    
      '            modalTitle.innerHTML = '#39'<i class="fa-solid fa-magnif' +
      'ying-glass"></i> '#304'ZLENEN F'#304'LM ARA_'#39';'
    '            modalTitle.className = '#39'section-title title-blue'#39';'
    '        }'
    '    }'
    '    if (input) input.value = '#39#39';'
    '    if (results) results.innerHTML = '#39#39';'
    '    if (modal) {'
    '        modal.classList.add('#39'show'#39');'
    '        setTimeout(function() {'
    '            if (input) input.focus();'
    '        }, 300);'
    '    }'
    '};'
    ''
    'window.closeAddMovieModal = function(e) {'
    '    if (e) e.stopPropagation();'
    '    var modal = document.getElementById('#39'addMovieModal'#39');'
    '    if (modal) modal.classList.remove('#39'show'#39');'
    '    setTimeout(function() {'
    '        var input = document.getElementById('#39'movieSearchInput'#39');'
    '        var results = document.getElementById('#39'searchResults'#39');'
    '        if (input) input.value = '#39#39';'
    '        if (results) results.innerHTML = '#39#39';'
    '    }, 300);'
    '};'
    ''
    'window.toggleAccordion = function(element) {'
    '    var item = element.closest('#39'.accordion-item'#39');'
    '    var allItems = document.querySelectorAll('#39'.accordion-item'#39');'
    '    if (item.classList.contains('#39'active'#39')) {'
    '        item.classList.remove('#39'active'#39');'
    '        return;'
    '    }'
    '    allItems.forEach(function(i) {'
    '        i.classList.remove('#39'active'#39');'
    '    });'
    '    item.classList.add('#39'active'#39');'
    '};'
    ''
    'window.openMovieDetail = function(element, movieId) {'
    '    var posterSrc = element.getAttribute('#39'data-poster'#39') || '#39#39'; '
    
      '    var movieName = element.querySelector('#39'.card-game-title'#39').in' +
      'nerText;'
    '    var movieScore = element.getAttribute('#39'data-score'#39') || '#39'--'#39';'
    '    var movieYear = element.getAttribute('#39'data-year'#39') || '#39'--'#39';'
    '    var movieGenre = element.getAttribute('#39'data-genre'#39') || '#39'--'#39';'
    
      '    var movieDirector = element.getAttribute('#39'data-platform'#39') ||' +
      ' '#39'--'#39';'
    
      '    var movieSummary = element.getAttribute('#39'data-summary'#39') || '#39 +
      'A'#231#305'klama bulunamad'#305'.'#39';'
    
      '    var movieRuntime = element.getAttribute('#39'data-runtime'#39') || '#39 +
      '--'#39';'
    '    var movieNotes = element.getAttribute('#39'data-notes'#39') || '#39#39';'
    '    '
    
      '    var finishDate = element.getAttribute('#39'data-finishdate'#39') || ' +
      #39'Belirtilmedi'#39';'
    '    var rawDate = element.getAttribute('#39'data-rawdate'#39') || '#39#39'; '
    
      '    var isWishlist = element.getAttribute('#39'data-wishlist'#39') || '#39'0' +
      #39'; '
    '    '
    
      '    document.getElementById('#39'resPoster'#39').style.backgroundImage =' +
      ' "url('#39'" + posterSrc + "'#39')";'
    '    document.getElementById('#39'resTitle'#39').innerText = movieName;'
    '    document.getElementById('#39'resScore'#39').innerText = movieScore;'
    '    document.getElementById('#39'resYear'#39').innerText = movieYear;'
    '    document.getElementById('#39'resGenre'#39').innerText = movieGenre;'
    
      '    document.getElementById('#39'resPlatform'#39').innerText = movieDire' +
      'ctor;'
    
      '    document.getElementById('#39'resSummary'#39').innerText = movieSumma' +
      'ry;'
    
      '    document.getElementById('#39'resRuntime'#39').innerText = movieRunti' +
      'me;'
    '    document.getElementById('#39'resNotesText'#39').value = movieNotes;'
    '    '
    '    var scoreSpan = document.getElementById('#39'resScore'#39');'
    '    var scoreTagDiv = scoreSpan.parentElement;'
    '    '
    '    var scoreStr = movieScore.split('#39'/'#39')[0].replace('#39','#39', '#39'.'#39');'
    '    var scoreNum = parseFloat(scoreStr);'
    ''
    '    if (!isNaN(scoreNum)) {'
    '        if (scoreNum <= 10.0) {'
    '            scoreNum = scoreNum * 10;'
    '        }'
    ''
    '        var neonColor = '#39#39';'
    '        if (scoreNum < 50) {'
    '            neonColor = '#39'#ff2a6d'#39'; '
    '        } else if (scoreNum < 75) {'
    '            neonColor = '#39'#ffea00'#39'; '
    '        } else {'
    '            neonColor = '#39'#39ff14'#39'; '
    '        }'
    '        '
    '        scoreTagDiv.style.borderColor = neonColor;'
    
      '        scoreTagDiv.style.boxShadow = '#39'0 0 10px '#39' + neonColor + ' +
      #39', inset 0 0 5px '#39' + neonColor;'
    '        '
    '    } else {'
    '        scoreTagDiv.style.borderColor = '#39'var(--neon-blue)'#39';'
    
      '        scoreTagDiv.style.boxShadow = '#39'0 0 10px var(--neon-blue)' +
      #39';'
    '    }'
    '    '
    '    // --- FRAGMAN ALANI ---'
    
      '    var trailerContainer = document.getElementById('#39'trailerConta' +
      'iner'#39');'
    '    if (isWishlist === '#39'1'#39') {'
    
      '        var encodedTitle = encodeURIComponent(movieName).replace' +
      '(/'#39'/g, "%27");'
    '        trailerContainer.style.display = '#39'block'#39';'
    
      '        trailerContainer.innerHTML = '#39'<button class="action-btn-' +
      'detail btn-mode-pink" onclick="window.open(\'#39'https://www.youtube' +
      '.com/results?search_query='#39' + encodedTitle + '#39'+fragman\'#39', \'#39'_bla' +
      'nk\'#39')" style="width: 100%; margin-top: 0 !important;"><i class="' +
      'fa-brands fa-youtube" style="font-size: 1.2rem;"></i> YOUTUBE\'#39'D' +
      'A FRAGMAN '#304'ZLE</button>'#39';'
    '    } else {'
    '        trailerContainer.style.display = '#39'none'#39';'
    '        trailerContainer.innerHTML = '#39#39';'
    '    }'
    ''
    
      '    var finishDateTag = document.getElementById('#39'metaFinishDateT' +
      'ag'#39');'
    '    if (isWishlist === '#39'0'#39') {'
    '        finishDateTag.style.display = '#39'flex'#39'; '
    
      '        document.getElementById('#39'resFinishDate'#39').innerText = fin' +
      'ishDate;'
    '        '
    
      '        document.getElementById('#39'btnEditFinishDate'#39').onclick = f' +
      'unction() {'
    
      '            var currentRawDate = element.getAttribute('#39'data-rawd' +
      'ate'#39') || '#39#39';'
    '            // TEMA DUYARLI INPUT KUTUSU'
    
      '            var inputHTML = '#39'<input type="text" id="swal-input-d' +
      'ate" class="neon-input" style="width:140px; display:block; margi' +
      'n:15px auto 0 auto; color:var(--text-main); background:var(--inp' +
      'ut-bg); border:1px solid var(--border-color); padding:10px; bord' +
      'er-radius:5px; text-align:center; font-family:\'#39'Outfit\'#39', sans-s' +
      'erif; font-size:1.1rem; outline:none; cursor:pointer;" placehold' +
      'er="Tarih Se'#231'in...">'#39';'
    '            '
    '            Swal.fire({'
    '                title: '#39#304'ZLEME TAR'#304'H'#304'_'#39','
    '                html: inputHTML,'
    
      '                background: '#39'var(--sidebar-bg)'#39', // TEMA DUYARLI' +
      ' ARKAPLAN'
    
      '                color: '#39'var(--text-main)'#39', // TEMA DUYARLI YAZI ' +
      'RENG'#304
    '                showCancelButton: true,'
    '                confirmButtonText: '#39'KAYDET'#39','
    '                cancelButtonText: '#39#304'PTAL'#39','
    '                buttonsStyling: false,'
    '                didOpen: function() {'
    
      '                    document.querySelector('#39'.swal2-container'#39').s' +
      'tyle.zIndex = '#39'9999999'#39';'
    
      '                    var confBtn = Swal.getConfirmButton(); var c' +
      'ancBtn = Swal.getCancelButton();'
    
      '                    confBtn.style.border = '#39'2px solid var(--neon' +
      '-blue)'#39'; confBtn.style.background = '#39'transparent'#39'; confBtn.style' +
      '.color = '#39'var(--neon-blue)'#39'; confBtn.style.padding = '#39'10px 20px'#39 +
      '; confBtn.style.fontFamily = '#39'"Press Start 2P", cursive'#39'; confBt' +
      'n.style.fontSize = '#39'0.7rem'#39'; confBtn.style.marginRight = '#39'15px'#39';' +
      ' confBtn.style.cursor = '#39'pointer'#39';'
    
      '                    cancBtn.style.border = '#39'2px solid var(--neon' +
      '-pink)'#39'; cancBtn.style.background = '#39'transparent'#39'; cancBtn.style' +
      '.color = '#39'var(--neon-pink)'#39'; cancBtn.style.padding = '#39'10px 20px'#39 +
      '; cancBtn.style.fontFamily = '#39'"Press Start 2P", cursive'#39'; cancBt' +
      'n.style.fontSize = '#39'0.7rem'#39'; cancBtn.style.cursor = '#39'pointer'#39';'
    ''
    '                    if (typeof flatpickr !== '#39'undefined'#39') {'
    '                        flatpickr("#swal-input-date", {'
    '                            locale: "tr",              '
    '                            dateFormat: "Y-m-d",        '
    '                            altInput: true,             '
    '                            altFormat: "d.m.Y",         '
    
      '                            defaultDate: currentRawDate !== '#39#39' ?' +
      ' currentRawDate : "today",'
    '                            disableMobile: true         '
    '                        });'
    '                    } else {'
    
      '                        document.getElementById('#39'swal-input-date' +
      #39').type = '#39'date'#39';'
    
      '                        document.getElementById('#39'swal-input-date' +
      #39').value = currentRawDate;'
    '                    }'
    '                },'
    '                preConfirm: function() {'
    
      '                    var fpInput = document.querySelector('#39'.flatp' +
      'ickr-input[type="hidden"]'#39');'
    '                    if (fpInput && fpInput.value !== '#39#39') {'
    '                        return fpInput.value;'
    '                    }'
    
      '                    return document.getElementById('#39'swal-input-d' +
      'ate'#39').value;'
    '                }'
    '            }).then(function(result) {'
    '                if (result.isConfirmed && result.value) {'
    
      '                    ajaxRequest(FILMLERIM_FORM.UniHTMLFrame1, '#39'F' +
      'ilmTarihGuncelleDB'#39', ['#39'film_id='#39' + movieId, '#39'tarih='#39' + result.va' +
      'lue]);'
    
      '                    var formattedDate = result.value.split('#39'-'#39').' +
      'reverse().join('#39'.'#39');'
    
      '                    document.getElementById('#39'resFinishDate'#39').inn' +
      'erText = formattedDate;'
    
      '                    element.setAttribute('#39'data-rawdate'#39', result.' +
      'value);'
    
      '                    element.setAttribute('#39'data-finishdate'#39', form' +
      'attedDate); '
    '                }'
    '            });'
    '        };'
    '    } else {'
    '        finishDateTag.style.display = '#39'none'#39'; '
    '    }'
    ''
    '    // --- BUTON Y'#214'NET'#304'M'#304' BA'#350'LANGI'#199' ---'
    '    var actionBtn = document.getElementById('#39'btnActionMovie'#39');'
    
      '    var revertBtn = document.getElementById('#39'btnRevertMovie'#39'); /' +
      '/ Yeni buton'
    ''
    '    if (isWishlist === '#39'1'#39') {'
    '        // '#304'STEK L'#304'STES'#304'NDE '#304'SE'
    '        actionBtn.style.display = '#39'flex'#39';'
    '        revertBtn.style.display = '#39'none'#39';'
    '        '
    
      '        actionBtn.innerHTML = '#39'<i class="fa-solid fa-check"></i>' +
      ' '#304'ZLEND'#304' OLARAK '#304#350'ARETLE'#39';'
    '        actionBtn.className = '#39'action-btn-detail btn-mode-blue'#39';'
    '        actionBtn.onclick = function() {'
    '            // Status 0 -> '#304'zlenenler'
    
      '            ajaxRequest(FILMLERIM_FORM.UniHTMLFrame1, '#39'FilmGunce' +
      'lleDB'#39', ['#39'film_id='#39' + movieId, '#39'yeni_durum=0'#39']);'
    '            window.closeMovieDetail();'
    '        };'
    '    } else {'
    '        // ZATEN '#304'ZLENM'#304#350'SE'
    '        actionBtn.style.display = '#39'none'#39';'
    '        revertBtn.style.display = '#39'flex'#39';'
    '        '
    '        revertBtn.onclick = function() {'
    '            // Status 1 -> '#304'stek Listesi (Geri Al)'
    
      '            ajaxRequest(FILMLERIM_FORM.UniHTMLFrame1, '#39'FilmGunce' +
      'lleDB'#39', ['#39'film_id='#39' + movieId, '#39'yeni_durum=1'#39']);'
    '            window.closeMovieDetail();'
    '        };'
    '    }'
    '    // --- BUTON Y'#214'NET'#304'M'#304' B'#304'T'#304#350' ---'
    ''
    '    var btnDelete = document.getElementById('#39'btnDeleteMovie'#39');'
    '    btnDelete.onclick = function() {'
    
      '        var swalHTML = '#39'<span style="color:var(--neon-pink); fon' +
      't-weight:bold;">'#39' + movieName + '#39'</span><br><br>k'#252't'#252'phanenizden ' +
      'kal'#305'c'#305' olarak kald'#305'r'#305'lacakt'#305'r.<br>Onayl'#305'yor musunuz?'#39';'
    '        Swal.fire({'
    '            title: '#39'S'#304'LME ONAYI_'#39','
    '            html: swalHTML,'
    '            icon: '#39'warning'#39','
    '            iconColor: '#39'var(--neon-pink)'#39', '
    '            showCancelButton: true,'
    '            confirmButtonText: '#39'EVET, S'#304'L'#39','
    '            cancelButtonText: '#39#304'PTAL'#39','
    '            background: '#39'var(--sidebar-bg)'#39', '
    '            color: '#39'var(--text-main)'#39', '
    '            buttonsStyling: false,'
    '            didOpen: function() {'
    
      '                document.querySelector('#39'.swal2-container'#39').style' +
      '.zIndex = '#39'9999999'#39';'
    
      '                var confBtn = Swal.getConfirmButton(); var cancB' +
      'tn = Swal.getCancelButton();'
    
      '                confBtn.style.border = '#39'2px solid var(--neon-blu' +
      'e)'#39'; confBtn.style.background = '#39'transparent'#39'; confBtn.style.col' +
      'or = '#39'var(--neon-blue)'#39'; confBtn.style.padding = '#39'10px 20px'#39'; co' +
      'nfBtn.style.fontFamily = '#39'"Press Start 2P", cursive'#39'; confBtn.st' +
      'yle.fontSize = '#39'0.7rem'#39'; confBtn.style.marginRight = '#39'15px'#39'; con' +
      'fBtn.style.cursor = '#39'pointer'#39';'
    
      '                cancBtn.style.border = '#39'2px solid var(--neon-pin' +
      'k)'#39'; cancBtn.style.background = '#39'transparent'#39'; cancBtn.style.col' +
      'or = '#39'var(--neon-pink)'#39'; cancBtn.style.padding = '#39'10px 20px'#39'; ca' +
      'ncBtn.style.fontFamily = '#39'"Press Start 2P", cursive'#39'; cancBtn.st' +
      'yle.fontSize = '#39'0.7rem'#39'; cancBtn.style.cursor = '#39'pointer'#39';'
    '            }'
    '        }).then(function(result) {'
    '            if (result.isConfirmed) {'
    
      '                ajaxRequest(FILMLERIM_FORM.UniHTMLFrame1, '#39'FilmS' +
      'ilDB'#39', ['#39'film_id='#39' + movieId]);'
    '                window.closeMovieDetail();'
    '            }'
    '        });'
    '    };'
    '    '
    '    var btnSaveNotes = document.getElementById('#39'btnSaveNotes'#39');'
    '    btnSaveNotes.onclick = function() {'
    
      '        var newNote = document.getElementById('#39'resNotesText'#39').va' +
      'lue;'
    '        '
    
      '        ajaxRequest(FILMLERIM_FORM.UniHTMLFrame1, '#39'FilmNotKaydet' +
      'DB'#39', ['#39'film_id='#39' + movieId, '#39'not='#39' + newNote]);'
    '        '
    '        var icon = document.getElementById('#39'notesStatusIcon'#39');'
    '        icon.style.display = '#39'block'#39';'
    '        icon.style.color = '#39'var(--neon-blue)'#39';'
    '        setTimeout(function(){ '
    '           icon.style.color = '#39'var(--text-muted)'#39'; '
    '        }, 2000);'
    '        '
    '        element.setAttribute('#39'data-notes'#39', newNote);'
    '    };'
    '    '
    '    var modal = document.getElementById('#39'movieDetailModal'#39');'
    '    var box = document.getElementById('#39'resultBox'#39');'
    '    '
    '    modal.classList.add('#39'show'#39');'
    '    setTimeout(function() {'
    '        box.classList.add('#39'reveal'#39');'
    '    }, 50); '
    '};'
    ''
    'window.closeMovieDetail = function() {'
    '    var box = document.getElementById('#39'resultBox'#39');'
    '    var modal = document.getElementById('#39'movieDetailModal'#39');'
    '    box.classList.remove('#39'reveal'#39');'
    '    setTimeout(function() {'
    '        modal.classList.remove('#39'show'#39');'
    '    }, 400); '
    '};'
    ''
    'window.initTheme = function() {'
    '    var currentTheme = localStorage.getItem('#39'bitd-theme'#39');'
    '    if (currentTheme === '#39'light'#39') {'
    '        document.body.classList.add('#39'light-theme'#39');'
    '    }'
    '};'
    'setTimeout(window.initTheme, 50);')
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
      '  '
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
      '    --modal-overlay-bg: rgba(1, 1, 43, 0.85);'
      '    --scanline-opacity: 0.15;'
      '    --gradient-center: rgba(16, 0, 43, 0.5);'
      '    --input-bg: rgba(5, 5, 25, 0.6);'
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
      '    --modal-overlay-bg: rgba(240, 245, 250, 0.95);'
      '    --scanline-opacity: 0.03; '
      '    --gradient-center: rgba(255, 255, 255, 0.5);'
      '    --input-bg: rgba(255, 255, 255, 0.9);'
      '  }'
      '  '
      '  /* --- S'#304'BERPUNK TAKV'#304'M TASARIMI --- */'
      
        '  .flatpickr-calendar { background: var(--sidebar-bg) !important' +
        '; border: 1px solid var(--neon-blue) !important; box-shadow: 0 0' +
        ' 25px rgba(5, 217, 232, 0.3) !important; font-family: '#39'Outfit'#39', ' +
        'sans-serif !important; z-index: 99999999 !important; }'
      
        '  .flatpickr-months .flatpickr-month { background: transparent !' +
        'important; color: var(--neon-blue) !important; height: 40px !imp' +
        'ortant; }'
      
        '  .flatpickr-current-month .flatpickr-monthDropdown-months { fon' +
        't-family: '#39'Press Start 2P'#39', cursive !important; font-size: 0.6re' +
        'm !important; padding-top: 5px !important;}'
      
        '  .flatpickr-current-month input.cur-year { font-family: '#39'Press ' +
        'Start 2P'#39', cursive !important; font-size: 0.7rem !important; fon' +
        't-weight: normal !important; color: var(--neon-pink) !important;' +
        '}'
      
        '  span.flatpickr-weekday { color: var(--text-muted) !important; ' +
        'font-family: '#39'Press Start 2P'#39', cursive !important; font-size: 0.' +
        '5rem !important; margin-top: 10px !important;}'
      '  .flatpickr-day { color: var(--text-main) !important; }'
      
        '  .flatpickr-day:hover, .flatpickr-day:focus { background: rgba(' +
        '5, 217, 232, 0.2) !important; border-color: var(--neon-blue) !im' +
        'portant; }'
      
        '  .flatpickr-day.selected { background: var(--neon-pink) !import' +
        'ant; border-color: var(--neon-pink) !important; color: #fff !imp' +
        'ortant; font-weight: bold; box-shadow: 0 0 10px var(--neon-pink)' +
        '; }'
      
        '  .flatpickr-day.today { border-color: var(--neon-blue) !importa' +
        'nt; }'
      
        '  .flatpickr-calendar.arrowTop:before, .flatpickr-calendar.arrow' +
        'Top:after { border-bottom-color: var(--neon-blue) !important; }'
      
        '  .flatpickr-calendar.arrowBottom:before, .flatpickr-calendar.ar' +
        'rowBottom:after { border-top-color: var(--neon-blue) !important;' +
        ' }'
      
        '  .flatpickr-months .flatpickr-prev-month, .flatpickr-months .fl' +
        'atpickr-next-month { fill: var(--neon-pink) !important; }'
      
        '  .flatpickr-months .flatpickr-prev-month:hover svg, .flatpickr-' +
        'months .flatpickr-next-month:hover svg { fill: var(--neon-blue) ' +
        '!important; }'
      '  '
      '  ::-webkit-scrollbar { width: 8px; }'
      
        '  ::-webkit-scrollbar-track { background: var(--bg-main); transi' +
        'tion: 0.4s; }'
      
        '  ::-webkit-scrollbar-thumb { background: var(--neon-blue); bord' +
        'er-radius: 10px; box-shadow: 0 0 10px var(--neon-blue); transiti' +
        'on: 0.4s; }'
      
        '  ::-webkit-scrollbar-thumb:hover { background: var(--neon-pink)' +
        '; }'
      '  '
      
        '  body, html { margin: 0; padding: 0; height: 100%; background-c' +
        'olor: var(--bg-main) !important; font-family: '#39'Outfit'#39', sans-ser' +
        'if; color: var(--text-main); overflow: hidden; transition: backg' +
        'round-color 0.4s ease, color 0.4s ease; }'
      '  '
      
        '  .dashboard-container { display: flex; position: fixed; top: 0;' +
        ' left: 0; width: 100vw; height: 100vh; z-index: 1; background-co' +
        'lor: var(--bg-main); transition: background-color 0.4s ease; }'
      
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
      '  '
      
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
      '  '
      
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
        '-gradient(90deg, rgba(5, 217, 232, 0.1) 0%, transparent 100%); }' +
        ' '
      
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
      '  .welcome-section { margin-bottom: 50px; }'
      
        '  .welcome-section h1 { margin: 0; font-family: '#39'Press Start 2P'#39 +
        ', cursive; font-size: 1.1rem; color: var(--text-main); transitio' +
        'n: 0.4s; }'
      
        '  .welcome-section span { color: var(--neon-pink); transition: 0' +
        '.4s; }'
      
        '  .changing-text { margin-top: 25px; font-family: '#39'Press Start 2' +
        'P'#39', cursive; font-size: 0.7rem; color: var(--neon-blue); min-hei' +
        'ght: 1.5rem; display: inline-block; position: relative; transiti' +
        'on: 0.4s; }'
      
        '  .changing-text::after { content: '#39'_'#39'; animation: blink 0.8s in' +
        'finite; color: var(--neon-pink); }'
      
        '  @keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0; ' +
        '} }'
      '  '
      
        '  .full-section { display: flex; flex-direction: column; width: ' +
        '100%; margin-bottom: 50px; }'
      
        '  .section-title { font-family: '#39'Press Start 2P'#39', cursive; font-' +
        'size: 0.7rem; margin-bottom: 30px; display: flex; align-items: c' +
        'enter; gap: 12px; padding-bottom: 15px; transition: 0.4s; }'
      
        '  .title-pink { color: var(--neon-pink); border-bottom: 1px soli' +
        'd rgba(255, 42, 109, 0.2); }'
      
        '  .title-blue { color: var(--neon-blue); border-bottom: 1px soli' +
        'd rgba(5, 217, 232, 0.2); }'
      '  '
      
        '  .media-grid { display: grid; grid-template-columns: repeat(aut' +
        'o-fill, minmax(160px, 1fr)); grid-auto-rows: max-content; align-' +
        'content: start; align-items: start; gap: 25px; }'
      '  .media-card:empty { display: none !important; }'
      
        '  .media-card { aspect-ratio: 2/3; border-radius: 10px; backgrou' +
        'nd: var(--card-bg); border: 1px solid var(--border-color); curso' +
        'r: pointer; transition: 0.4s; overflow: hidden; position: relati' +
        've; }'
      
        '  .media-card:hover { transform: translateY(-10px); border-color' +
        ': var(--neon-blue); box-shadow: 0 10px 25px rgba(5, 217, 232, 0.' +
        '2); }'
      
        '  .media-card .poster-bg { width: 100%; height: 100%; background' +
        '-position: center !important; background-size: cover !important;' +
        ' background-repeat: no-repeat !important; transition: all 0.5s e' +
        'ase; }'
      
        '  .media-card:hover .poster-bg { filter: brightness(0.35) contra' +
        'st(1.2) grayscale(0.2); transform: scale(1.08); }'
      ''
      
        '  .card-game-title { position: absolute; bottom: 0; left: 0; wid' +
        'th: 100%; background: linear-gradient(to top, rgba(1, 1, 43, 0.9' +
        '5) 0%, rgba(1, 1, 43, 0.7) 60%, transparent 100%); padding: 30px' +
        ' 10px 15px 10px; text-align: center; font-family: '#39'Outfit'#39', sans' +
        '-serif; font-weight: 700; font-size: 0.9rem; box-sizing: border-' +
        'box; transform: translateY(100%); opacity: 0; transition: all 0.' +
        '4s cubic-bezier(0.175, 0.885, 0.32, 1.275); }'
      
        '  .media-card .card-game-title { color: #fff; text-shadow: 0 0 1' +
        '0px var(--neon-blue); border-bottom: 3px solid var(--neon-blue);' +
        ' }'
      
        '  .wishlist-card .card-game-title { color: #fff; text-shadow: 0 ' +
        '0 10px var(--neon-pink); border-bottom: 3px solid var(--neon-pin' +
        'k); }'
      
        '  .media-card:hover .card-game-title { transform: translateY(0);' +
        ' opacity: 1; }'
      ''
      '  .wishlist-card { border-color: rgba(255, 42, 109, 0.1); }'
      
        '  .wishlist-card:hover { border-color: var(--neon-pink); box-sha' +
        'dow: 0 10px 25px rgba(255, 42, 109, 0.2); }'
      ''
      
        '  .detail-trigger-btn { position: absolute; top: 10px; right: 10' +
        'px; background: rgba(1, 1, 43, 0.8); color: var(--neon-blue); wi' +
        'dth: 30px; height: 30px; border-radius: 50%; display: flex; just' +
        'ify-content: center; align-items: center; opacity: 0; transform:' +
        ' scale(0.5); transition: all 0.3s cubic-bezier(0.175, 0.885, 0.3' +
        '2, 1.275); z-index: 10; border: 1px solid var(--neon-blue); }'
      
        '  .media-card:hover .detail-trigger-btn { opacity: 1 !important;' +
        ' transform: scale(1) !important; }'
      
        '  .detail-trigger-btn:hover { background: var(--neon-blue) !impo' +
        'rtant; color: #000; box-shadow: 0 0 15px var(--neon-blue); }'
      
        '  .wishlist-card .detail-trigger-btn { color: var(--neon-pink); ' +
        'border-color: var(--neon-pink); }'
      
        '  .wishlist-card .detail-trigger-btn:hover { background: var(--n' +
        'eon-pink) !important; color: #fff; box-shadow: 0 0 15px var(--ne' +
        'on-pink); }'
      '  '
      
        '  .add-card { display: flex; align-items: center; justify-conten' +
        't: center; border: 2px dashed rgba(5, 217, 232, 0.4); background' +
        ': var(--card-bg); color: var(--neon-blue); font-size: 3rem; tran' +
        'sition: 0.4s; }'
      
        '  .add-card:hover { border: 2px solid var(--neon-blue); backgrou' +
        'nd: rgba(5, 217, 232, 0.1); box-shadow: 0 0 15px rgba(5, 217, 23' +
        '2, 0.2); }'
      
        '  .add-card-pink { display: flex; align-items: center; justify-c' +
        'ontent: center; border: 2px dashed rgba(255, 42, 109, 0.4); back' +
        'ground: var(--card-bg); color: var(--neon-pink); font-size: 3rem' +
        '; transition: 0.4s; }'
      
        '  .add-card-pink:hover { border: 2px solid var(--neon-pink); bac' +
        'kground: rgba(255, 42, 109, 0.1); box-shadow: 0 0 15px rgba(255,' +
        ' 42, 109, 0.2); }'
      '  '
      '  /* ARAMA VE EKLEME MODALI */'
      
        '  .modal-overlay { position: fixed; top: 0; left: 0; width: 100v' +
        'w; height: 100vh; background: var(--modal-overlay-bg); backdrop-' +
        'filter: blur(8px); display: flex; justify-content: center; align' +
        '-items: center; z-index: 2000; opacity: 0; visibility: hidden; t' +
        'ransition: background-color 0.4s ease, opacity 0.3s ease; }'
      '  .modal-overlay.show { opacity: 1; visibility: visible; }'
      
        '  .modal-content { background: var(--sidebar-bg); border: 1px so' +
        'lid var(--neon-blue); box-shadow: 0 0 25px rgba(5, 217, 232, 0.1' +
        '5); width: 90%; max-width: 500px; max-height: 85vh; display: fle' +
        'x; flex-direction: column; border-radius: 10px; padding: 30px; p' +
        'osition: relative; transform: translateY(-50px); transition: tra' +
        'nsform 0.3s ease, background-color 0.4s ease; }'
      
        '  .modal-overlay.show .modal-content { transform: translateY(0);' +
        ' }'
      '  '
      
        '  .close-modal { position: absolute; top: 20px; right: 25px; col' +
        'or: var(--text-muted); font-size: 1.5rem; cursor: pointer; trans' +
        'ition: 0.3s; z-index: 10;}'
      
        '  .close-modal:hover { color: var(--neon-pink); transform: scale' +
        '(1.2); filter: drop-shadow(0 0 8px var(--neon-pink)); }'
      '  '
      
        '  .search-container { display: flex; gap: 15px; margin-top: 15px' +
        '; margin-bottom: 20px; flex-shrink: 0;}'
      
        '  .neon-input { flex: 1; background: var(--input-bg); border: 1p' +
        'x solid var(--border-color); color: var(--text-main); padding: 1' +
        '5px 20px; font-family: '#39'Outfit'#39', sans-serif; font-size: 1rem; bo' +
        'rder-radius: 5px; outline: none; transition: 0.3s; width: 100%; ' +
        'box-sizing: border-box;}'
      
        '  .neon-input:focus { border-color: var(--neon-blue); box-shadow' +
        ': 0 0 10px rgba(5, 217, 232, 0.2); }'
      
        '  .neon-btn { background: transparent; border: 1px solid var(--n' +
        'eon-pink); color: var(--neon-pink); padding: 0 25px; cursor: poi' +
        'nter; font-family: '#39'Press Start 2P'#39', cursive; font-size: 0.6rem;' +
        ' border-radius: 5px; transition: 0.3s; display: flex; align-item' +
        's: center; justify-content: center; }'
      
        '  .neon-btn:hover { background: var(--neon-pink); color: #fff; b' +
        'ox-shadow: 0 0 15px var(--neon-pink); }'
      '  '
      
        '  #searchResults { overflow-y: auto; display: flex; flex-directi' +
        'on: column; gap: 10px; padding-right: 5px; flex: 1; }'
      '  #searchResults::-webkit-scrollbar { width: 4px; }'
      
        '  #searchResults::-webkit-scrollbar-thumb { background: var(--ne' +
        'on-blue); border-radius: 10px; }'
      '  '
      
        '  .accordion-item { background: var(--card-bg); border: 1px soli' +
        'd rgba(5, 217, 232, 0.2); border-radius: 8px; overflow: hidden; ' +
        'transition: all 0.3s ease; flex-shrink: 0 !important; height: au' +
        'to !important; min-height: 80px; }'
      
        '  .accordion-item.active { border-color: var(--neon-pink); box-s' +
        'hadow: 0 0 15px rgba(255, 42, 109, 0.2); }'
      
        '  .accordion-header { display: flex; align-items: center; paddin' +
        'g: 10px 15px; cursor: pointer; gap: 15px; }'
      
        '  .accordion-header:hover { background: rgba(5, 217, 232, 0.1); ' +
        '}'
      
        '  .accordion-poster { width: 40px; height: 60px; border-radius: ' +
        '4px; object-fit: cover; border: 1px solid var(--border-color); }'
      
        '  .accordion-title { flex: 1; font-family: '#39'Outfit'#39', sans-serif;' +
        ' font-weight: 700; color: var(--text-main); font-size: 0.95rem; ' +
        'line-height: 1.4; word-break: break-word; padding-right: 10px; }'
      
        '  .accordion-icon { color: var(--neon-blue); transition: transfo' +
        'rm 0.3s ease; font-size: 0.9rem;}'
      
        '  .accordion-item.active .accordion-icon { transform: rotate(180' +
        'deg); color: var(--neon-pink); }'
      
        '  .accordion-content { max-height: 0; opacity: 0; padding: 0 15p' +
        'x; transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94); ba' +
        'ckground: rgba(0, 0, 0, 0.1); overflow: hidden;}'
      
        '  .accordion-item.active .accordion-content { max-height: 400px;' +
        ' opacity: 1; padding: 15px; border-top: 1px dashed rgba(255, 42,' +
        ' 109, 0.3); }'
      
        '  .acc-details { display: grid; grid-template-columns: 1fr 1fr; ' +
        'gap: 12px; margin-bottom: 15px; font-size: 0.8rem; color: var(--' +
        'text-main); }'
      
        '  .acc-detail-item strong { color: var(--neon-blue); font-family' +
        ': '#39'Press Start 2P'#39', cursive; font-size: 0.5rem; display: block; ' +
        'margin-bottom: 5px; }'
      '  .acc-actions { display: flex; gap: 10px; }'
      
        '  .acc-btn { flex: 1; padding: 12px 10px; border: none; border-r' +
        'adius: 4px; cursor: pointer; font-family: '#39'Press Start 2P'#39', curs' +
        'ive; font-size: 0.5rem; text-align: center; transition: 0.3s; di' +
        'splay: flex; justify-content: center; align-items: center; gap: ' +
        '5px; line-height: 1.4;}'
      
        '  .acc-btn-lib { background: rgba(5, 217, 232, 0.1); color: var(' +
        '--neon-blue); border: 1px solid var(--neon-blue); }'
      
        '  .acc-btn-lib:hover { background: var(--neon-blue); color: #fff' +
        '; box-shadow: 0 0 10px var(--neon-blue); }'
      
        '  .acc-btn-wish { background: rgba(255, 42, 109, 0.1); color: va' +
        'r(--neon-pink); border: 1px solid var(--neon-pink); }'
      
        '  .acc-btn-wish:hover { background: var(--neon-pink); color: #ff' +
        'f; box-shadow: 0 0 10px var(--neon-pink); }'
      '  '
      
        '  .loading-container { color: var(--neon-blue); text-align: cent' +
        'er; padding: 40px 20px; font-family: '#39'Press Start 2P'#39', cursive; ' +
        'font-size: 0.6rem; line-height: 2; transition: 0.4s; }'
      
        '  .loading-icon { font-size: 1.5rem; color: var(--neon-pink); ma' +
        'rgin-bottom: 15px; }'
      '  '
      '  /* DETAY MODALI VE KART YAPISI */'
      
        '  .random-modal-overlay { position: fixed; top: 0; left: 0; widt' +
        'h: 100vw; height: 100vh; background: var(--modal-overlay-bg); z-' +
        'index: 9999999; display: flex; justify-content: center; align-it' +
        'ems: center; opacity: 0; pointer-events: none; transition: backg' +
        'round-color 0.4s ease, opacity 0.5s ease; backdrop-filter: blur(' +
        '15px); }'
      
        '  .random-modal-overlay.show { opacity: 1; pointer-events: all; ' +
        '}'
      '  '
      
        '  .result-container { display: flex; flex-direction: row; align-' +
        'items: stretch; gap: 40px; background: var(--card-bg); border: 1' +
        'px solid var(--border-color); padding: 30px; border-radius: 16px' +
        '; box-shadow: 0 0 40px rgba(0, 0, 0, 0.3); max-width: 1200px; wi' +
        'dth: 95%; max-height: 85vh; overflow: hidden; opacity: 0; transf' +
        'orm: scale(0.8) translateY(50px); transition: all 0.8s cubic-bez' +
        'ier(0.34, 1.56, 0.64, 1); z-index: 2; backdrop-filter: blur(10px' +
        '); } '
      
        '  .result-container.reveal { opacity: 1; transform: scale(1) tra' +
        'nslateY(0); }'
      '  '
      
        '  .result-poster-frame { width: 300px; min-width: 300px; flex-sh' +
        'rink: 0; aspect-ratio: 2/3; background-size: cover; background-p' +
        'osition: center; border-radius: 8px; box-shadow: 0 0 30px rgba(5' +
        ', 217, 232, 0.2); border: 2px solid var(--neon-blue); position: ' +
        'relative; overflow: hidden; transition: 0.4s; align-self: flex-s' +
        'tart;}'
      
        '  .result-poster-frame::before { content: '#39#39'; position: absolute' +
        '; top: 0; left: 0; width: 100%; height: 100%; background: inheri' +
        't; filter: brightness(1.5) contrast(1.2); mix-blend-mode: hard-l' +
        'ight; opacity: 0; }'
      
        '  .result-container.reveal .result-poster-frame::before { animat' +
        'ion: glitch-reveal 1s linear forwards; }'
      
        '  @keyframes glitch-reveal { 0% { opacity: 1; transform: transla' +
        'te(-5px, 5px); } 20% { transform: translate(5px, -5px); } 40% { ' +
        'transform: translate(-5px, -5px); opacity: 0.5; } 60% { transfor' +
        'm: translate(5px, 5px); } 80% { transform: translate(0, 0); opac' +
        'ity: 0.8; } 100% { opacity: 0; } }'
      '  '
      
        '  .result-details { display: flex; flex-direction: column; justi' +
        'fy-content: flex-start; text-align: left; opacity: 0; flex: 1; m' +
        'in-width: 0; max-height: calc(85vh - 60px); }'
      
        '  .result-container.reveal .result-details { animation: fade-in-' +
        'right 0.8s ease forwards 0.3s; }'
      
        '  @keyframes fade-in-right { from { opacity: 0; transform: trans' +
        'lateX(-20px); } to { opacity: 1; transform: translateX(0); } }'
      '  '
      
        '  .result-title { font-family: '#39'Press Start 2P'#39', sans-serif; fon' +
        't-size: 1.2rem; color: var(--text-main); text-shadow: 2px 2px va' +
        'r(--neon-pink); margin: 0; line-height: 1.4; white-space: nowrap' +
        '; overflow: hidden; text-overflow: ellipsis; display: block; tra' +
        'nsition: 0.4s; }'
      
        '  .result-meta { display: flex; gap: 12px; margin-bottom: 20px; ' +
        'flex-wrap: wrap; }'
      
        '  .meta-tag { background: rgba(5, 217, 232, 0.05); border: 1px s' +
        'olid var(--neon-blue); color: var(--neon-blue); padding: 8px 12p' +
        'x; border-radius: 4px; font-size: 0.7rem; font-family: '#39'Press St' +
        'art 2P'#39', cursive; display: flex; align-items: flex-start; gap: 8' +
        'px; line-height: 1.5; text-align: left; transition: 0.4s; }'
      '  .meta-tag i { color: var(--neon-pink); margin-top: 2px;}'
      '  '
      '  .meta-tag.score {'
      '    background: rgba(5, 217, 232, 0.05);'
      '    border: 1px solid var(--neon-blue);'
      '    color: var(--neon-blue);'
      '    padding: 8px 12px;'
      '    border-radius: 4px;'
      '    font-size: 0.7rem;'
      '    font-family: '#39'Press Start 2P'#39', cursive;'
      '    display: flex;'
      '    align-items: flex-start;'
      '    gap: 8px;'
      '    line-height: 1.5;'
      '    text-align: left;'
      
        '    box-shadow: 0 0 10px var(--neon-blue), inset 0 0 5px var(--n' +
        'eon-blue);'
      '    transition: all 0.4s ease-out; '
      '  }'
      '  '
      
        '  .result-summary { color: var(--text-muted); font-size: 0.95rem' +
        '; line-height: 1.6; padding-right: 10px; margin-bottom: 20px; bo' +
        'rder-left: 2px solid var(--neon-pink); padding-left: 15px; flex:' +
        ' 1; overflow-y: auto; min-height: 80px; transition: 0.4s; }'
      '  .result-summary::-webkit-scrollbar { width: 6px; }'
      
        '  .result-summary::-webkit-scrollbar-thumb { background: var(--n' +
        'eon-pink); border-radius: 10px; }'
      '  '
      
        '  .action-btn-detail { align-self: stretch; margin-top: auto; pa' +
        'dding: 12px 30px; font-family: '#39'Press Start 2P'#39', cursive; cursor' +
        ': pointer; transition: 0.3s; font-size: 0.7rem; display: flex; j' +
        'ustify-content: center; align-items: center; gap: 10px; flex-shr' +
        'ink: 0;}'
      
        '  .btn-mode-pink { background: rgba(255, 42, 109, 0.1); color: v' +
        'ar(--neon-pink); border: 2px solid var(--neon-pink); }'
      
        '  .btn-mode-pink:hover { background: var(--neon-pink); color: #f' +
        'ff; box-shadow: 0 0 20px var(--neon-pink); transform: scale(1.02' +
        '); }'
      
        '  .btn-mode-blue { background: rgba(5, 217, 232, 0.1); color: va' +
        'r(--neon-blue); border: 2px solid var(--neon-blue); }'
      
        '  .btn-mode-blue:hover { background: var(--neon-blue); color: #f' +
        'ff; box-shadow: 0 0 20px var(--neon-blue); transform: scale(1.02' +
        '); }'
      '  '
      '  /* --- MODAL '#220'ST BUTONLARI VE '#304'KONLAR --- */'
      
        '  .modal-header-btn { background: none; border: none; color: var' +
        '(--text-muted); cursor: pointer; transition: 0.3s; padding: 0; }'
      '  #btnDeleteMovie:hover { color: #ff003c !important; } '
      
        '  .close-detail-btn:hover { color: var(--neon-pink) !important; ' +
        '}'
      '  '
      
        '  #btnEditFinishDate { margin-left: 8px; cursor: pointer; color:' +
        ' var(--text-main); transition: color 0.3s ease; }'
      '  #btnEditFinishDate:hover { color: var(--neon-blue); }'
      ''
      
        '  .modal-content.shake-error { animation: glitchShake 0.4s 1; bo' +
        'rder-color: var(--neon-pink) !important; box-shadow: 0 0 30px rg' +
        'ba(255, 42, 109, 0.4) !important; }'
      
        '  @keyframes glitchShake { 0%, 100% { transform: translateX(0) t' +
        'ranslateY(0); } 20%, 60% { transform: translateX(-8px) translate' +
        'Y(2px); } 40%, 80% { transform: translateX(8px) translateY(-2px)' +
        '; } }'
      '  '
      '  /* S'#304'BERPUNK NOT DEFTER'#304' */'
      '  .result-notes-panel {'
      
        '    width: 280px; min-width: 280px; flex-shrink: 0; display: fle' +
        'x; flex-direction: column;'
      
        '    border-left: 1px dashed rgba(255, 42, 109, 0.3); padding-lef' +
        't: 30px;'
      
        '    opacity: 0; transform: translateX(20px); transition: all 0.8' +
        's ease 0.5s;'
      '  }'
      
        '  .result-container.reveal .result-notes-panel { opacity: 1; tra' +
        'nsform: translateX(0); }'
      
        '  .notes-title { font-family: '#39'Press Start 2P'#39', cursive; font-si' +
        'ze: 0.65rem; color: var(--neon-pink); margin-bottom: 15px; displ' +
        'ay: flex; align-items: center; justify-content: space-between; t' +
        'ransition: 0.4s;}'
      '  .notes-textarea {'
      
        '    flex: 1; background: var(--input-bg); border: 1px solid var(' +
        '--border-color);'
      
        '    border-radius: 8px; color: var(--text-main); font-family: '#39'O' +
        'utfit'#39', sans-serif;'
      
        '    font-size: 0.9rem; padding: 15px; resize: none; outline: non' +
        'e; line-height: 1.5;'
      '    transition: 0.3s; margin-bottom: 15px;'
      '  }'
      
        '  .notes-textarea:focus { border-color: var(--neon-pink); box-sh' +
        'adow: 0 0 15px rgba(255, 42, 109, 0.2); }'
      '  .notes-textarea::-webkit-scrollbar { width: 4px; }'
      
        '  .notes-textarea::-webkit-scrollbar-thumb { background: var(--n' +
        'eon-pink); border-radius: 10px; }'
      '  '
      '  /* Mobil Uyumluluk */'
      '  @media (max-width: 1000px) {'
      
        '    .result-container { flex-direction: column; overflow-y: auto' +
        '; }'
      
        '    .result-notes-panel { width: 100%; border-left: none; border' +
        '-top: 1px dashed rgba(255, 42, 109, 0.3); padding-left: 0; paddi' +
        'ng-top: 20px; min-height: 250px; }'
      '  }'
      '  '
      '  @media (max-width: 800px) { '
      '    .main-content { padding: 25px 15px; } '
      
        '    .sidebar { position: fixed; left: -300px; top: 0; height: 10' +
        '0vh; z-index: 1001; transition: left 0.4s cubic-bezier(0.25, 0.4' +
        '6, 0.45, 0.94); }'
      
        '    .sidebar.open { left: 0; box-shadow: 10px 0 30px rgba(5, 217' +
        ', 232, 0.1); }'
      '    .mobile-header { display: flex; } '
      '    .welcome-section h1 { font-size: 0.9rem; }'
      '    .search-container { flex-direction: column; }'
      '    .neon-btn { padding: 15px; }'
      
        '    .modal-content { padding: 25px 15px; width: 95%; max-height:' +
        ' 90vh; }'
      
        '    .media-grid { grid-template-columns: repeat(2, 1fr); gap: 15' +
        'px; }'
      '    .acc-actions { flex-direction: column; } '
      
        '    .result-container { flex-direction: column; align-items: cen' +
        'ter; padding: 25px 20px; gap: 20px; overflow-y: auto; }'
      
        '    .result-details { max-height: none; overflow: visible; width' +
        ': 100%; display: flex; flex-direction: column; }'
      
        '    .result-poster-frame { width: 220px !important; min-width: 2' +
        '20px !important; align-self: center !important; margin: 0 auto; ' +
        '}'
      
        '    .result-details > div:first-child { flex-direction: column !' +
        'important; gap: 15px !important; align-items: center !important;' +
        ' text-align: center; }'
      
        '    .result-title { text-align: center; font-size: 1.2rem; white' +
        '-space: normal !important; word-wrap: break-word; word-break: br' +
        'eak-word; line-height: 1.4; }'
      '    .result-meta { justify-content: center; width: 100%; }'
      
        '    .meta-tag { flex: 1 1 auto; justify-content: center; text-al' +
        'ign: center; font-size: 0.65rem; white-space: normal; }'
      
        '    .result-summary { border-left: none; border-top: 2px solid v' +
        'ar(--neon-pink); padding-top: 15px; padding-left: 0; text-align:' +
        ' left; flex: none; overflow-y: visible; }'
      '  }'
      '</style>'
      ''
      '<div class="dashboard-container">'
      
        '  <div class="sidebar-overlay" id="sidebarOverlay" onclick="wind' +
        'ow.toggleSidebar()"></div>'
      '  <aside class="sidebar" id="sidebar">'
      '    <div class="sidebar-header">'
      '      <div class="sidebar-brand">B.I.T.D.</div>'
      '      <div class="sidebar-tagline">Back In The Day</div>'
      '    </div>'
      '    <nav class="nav-group">'
      
        '      <div class="nav-item" onclick="ajaxRequest(FILMLERIM_FORM.' +
        'UniHTMLFrame1, '#39'homePageCall'#39', [])"><i class="fa-solid fa-house"' +
        '></i> Ana Sayfa</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(FILMLERIM_FORM.' +
        'UniHTMLFrame1, '#39'gamesPageCall'#39', [])"><i class="fa-solid fa-gamep' +
        'ad"></i> Oyunlar'#305'm</div>'
      
        '      <div class="nav-item active" onclick="ajaxRequest(FILMLERI' +
        'M_FORM.UniHTMLFrame1, '#39'moviesPageCall'#39', [])"><i class="fa-solid ' +
        'fa-film"></i> Filmlerim</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(FILMLERIM_FORM.' +
        'UniHTMLFrame1, '#39'tvShowsPageCall'#39', [])"><i class="fa-solid fa-tv"' +
        '></i> Dizilerim</div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(FILMLERIM_FORM.' +
        'UniHTMLFrame1, '#39'booksPageCall'#39', [])"><i class="fa-solid fa-book"' +
        '></i> Kitaplar'#305'm</div>'
      '    </nav>'
      '    <div style="margin-top: auto; width: 100%;">'
      '      <div class="made-with-love">'
      
        '        Made with <span class="heart"><i class="fa-solid fa-hear' +
        't" style="color: rgb(255, 0, 0);"></i></span><br>'
      
        '        by <span class="author"><a href="https://hasup.net" targ' +
        'et="_blank">Yu'#351'a G'#246'verdik</a></span>'
      '      </div>'
      
        '      <div class="nav-item" onclick="ajaxRequest(FILMLERIM_FORM.' +
        'UniHTMLFrame1, '#39'accountPageCall'#39', [])">'
      '        <i class="fa-solid fa-user-gear"></i> Hesab'#305'm'
      '      </div>'
      
        '      <div class="nav-item logout-btn" onclick="ajaxRequest(FILM' +
        'LERIM_FORM.UniHTMLFrame1, '#39'DoLogout'#39', [])" style="margin-top: 0 ' +
        '!important;"><i class="fa-solid fa-right-from-bracket"></i> '#199#305'k'#305 +
        #351' Yap</div>'
      '    </div>'
      '  </aside>'
      ''
      '  <main class="main-content">'
      '    <div class="mobile-header">'
      
        '      <button class="hamburger-btn" onclick="window.toggleSideba' +
        'r()"><i class="fa-solid fa-bars-staggered"></i></button>'
      
        '      <div class="sidebar-brand" style="font-size: 0.9rem;">B.I.' +
        'T.D.</div>'
      '    </div>'
      '    <header class="welcome-section">'
      
        '      <h1>HO'#350' GELD'#304'N'#304'Z, <span id="spanUser">S'#304'NEMASEVER_</span><' +
        '/h1>'
      '      <div id="dynamicQuote" class="changing-text"></div>'
      '    </header>'
      ''
      '    <section class="full-section" id="wishlistSection">'
      
        '      <div class="section-title title-pink"><i class="fa-solid f' +
        'a-heart"></i> '#304'ZLEME L'#304'STES'#304'_</div>'
      '      <div id="wishlistGrid" class="media-grid">'
      
        '        <div style="grid-column: 1 / -1; display: flex; justify-' +
        'content: center; align-items: center; min-height: 20vh;">'
      
        '          <div class="loading-container"><i class="fa-solid fa-c' +
        'ircle-notch fa-spin loading-icon"></i><br>Y'#220'KLEN'#304'YOR...</div>'
      '        </div>'
      '      </div>'
      '    </section>'
      ''
      '    <section class="full-section" id="completedSection">'
      
        '      <div class="section-title title-blue"><i class="fa-solid f' +
        'a-check-double"></i> '#304'ZLENENLER_</div>'
      '      <div id="completedGrid" class="media-grid">'
      
        '        <div style="grid-column: 1 / -1; display: flex; justify-' +
        'content: center; align-items: center; min-height: 20vh;">'
      
        '          <div class="loading-container"><i class="fa-solid fa-c' +
        'ircle-notch fa-spin loading-icon"></i><br>Y'#220'KLEN'#304'YOR...</div>'
      '        </div>'
      '      </div>'
      '    </section>'
      '  </main>'
      ''
      '  <div class="modal-overlay" id="addMovieModal">'
      '    <div class="modal-content">'
      
        '      <i class="fa-solid fa-xmark close-modal" onclick="window.c' +
        'loseAddMovieModal(event)"></i>'
      
        '      <div class="section-title" id="searchModalTitle" style="ma' +
        'rgin-bottom: 10px;"><i class="fa-solid fa-magnifying-glass"></i>' +
        ' F'#304'LM ARA_</div>'
      '      <div class="search-container">'
      '        <input type="hidden" id="searchTargetInput" value="0">'
      
        '        <input type="text" id="movieSearchInput" class="neon-inp' +
        'ut" placeholder="Matrix, Inception..." onkeypress="if(event.key ' +
        '=== '#39'Enter'#39') window.triggerSearch();">'
      
        '        <button class="neon-btn" onclick="window.triggerSearch()' +
        '">ARA</button>'
      '      </div>'
      '      <div id="searchResults"></div>'
      '    </div>'
      '  </div>'
      ''
      '  <div class="random-modal-overlay" id="movieDetailModal">'
      '    <div class="result-container" id="resultBox">'
      '      <div class="result-poster-frame" id="resPoster"></div>'
      '      <div class="result-details">'
      
        '        <div style="display: flex; justify-content: space-betwee' +
        'n; align-items: center; margin-bottom: 20px; width: 100%; gap: 2' +
        '0px;">'
      
        '          <div style="flex: 1; min-width: 0;"><h2 id="resTitle" ' +
        'class="result-title">BA'#350'LIK</h2></div>'
      
        '          <div style="display: flex; gap: 15px; flex-shrink: 0;"' +
        '>'
      
        '            <button id="btnDeleteMovie" class="modal-header-btn"' +
        ' title="K'#252't'#252'phaneden Sil" style="font-size: 1.2rem;">'
      '              <i class="fa-solid fa-trash"></i>'
      '            </button>'
      
        '            <button class="modal-header-btn close-detail-btn" on' +
        'click="window.closeMovieDetail()" title="Kapat" style="font-size' +
        ': 1.4rem;">'
      '              <i class="fa-solid fa-xmark"></i>'
      '            </button>'
      '          </div>'
      '        </div>'
      ''
      '        <div class="result-meta">'
      
        '          <div class="meta-tag score"><i class="fa-solid fa-star' +
        '"></i> <span id="resScore">--</span></div>'
      
        '          <div class="meta-tag"><i class="fa-solid fa-calendar-d' +
        'ays"></i> <span id="resYear">--</span></div>'
      
        '          <div class="meta-tag"><i class="fa-solid fa-masks-thea' +
        'ter"></i> <span id="resGenre">--</span></div>'
      
        '          <div class="meta-tag"><i class="fa-solid fa-clock"></i' +
        '> <span id="resRuntime">--</span></div>'
      
        '          <div class="meta-tag"><i class="fa-solid fa-video"></i' +
        '> <span id="resPlatform">--</span></div>'
      '          '
      
        '          <div class="meta-tag" id="metaFinishDateTag" style="di' +
        'splay: none; border-color: var(--neon-pink); color: var(--neon-p' +
        'ink);">'
      '            <i class="fa-solid fa-flag-checkered"></i>'
      '            <span id="resFinishDate">Belirtilmedi</span>'
      
        '            <i class="fa-solid fa-pen" id="btnEditFinishDate" ti' +
        'tle="Tarihi D'#252'zenle"></i>'
      '          </div>'
      '        </div>'
      ''
      
        '        <div class="result-summary" id="resSummary">A'#231#305'klama ara' +
        'n'#305'yor...</div>'
      '        '
      
        '        <div style="margin-top: auto; display: flex; flex-direct' +
        'ion: column; gap: 10px; width: 100%; flex-shrink: 0; padding-top' +
        ': 10px;">'
      
        '          <div id="trailerContainer" style="display: none; width' +
        ': 100%;"></div>'
      
        '          <button id="btnActionMovie" class="action-btn-detail b' +
        'tn-mode-blue" style="margin-top: 0 !important;"><i class="fa-sol' +
        'id fa-check"></i> '#304'ZLEND'#304' OLARAK '#304#350'ARETLE</button>'
      '        '
      
        '         <button id="btnRevertMovie" class="action-btn-detail bt' +
        'n-mode-pink" style="display:none; margin-top: 10px;">'
      
        '          <i class="fa-solid fa-rotate-left"></i> '#304'STEK L'#304'STES'#304'N' +
        'E TA'#350'I'
      '         </button>   '
      '        '
      '        </div>'
      '      </div>'
      '      '
      '      <div class="result-notes-panel" id="resNotesPanel">'
      '        <div class="notes-title">'
      
        '          <span><i class="fa-solid fa-feather"></i> '#350'AHS'#304' NOTLAR' +
        '_</span>'
      
        '          <i id="notesStatusIcon" class="fa-solid fa-cloud-arrow' +
        '-up" style="color:var(--text-muted); font-size:0.8rem; display:n' +
        'one;" title="Kaydedildi"></i>'
      '        </div>'
      
        '        <textarea id="resNotesText" class="notes-textarea" place' +
        'holder="Bu film hakk'#305'nda ne d'#252#351#252'n'#252'yorsun? Buraya kendi '#351'ahsi not' +
        'lar'#305'n'#305' b'#305'rakabilirsin..."></textarea>'
      
        '        <button id="btnSaveNotes" class="action-btn-detail btn-m' +
        'ode-pink" style="margin-top:0;"><i class="fa-solid fa-floppy-dis' +
        'k"></i> NOTU KAYDET</button>'
      '      </div>'
      '      '
      '    </div>'
      '  </div>'
      '</div>')
    Align = alClient
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
    Left = 608
    Top = 200
  end
end
