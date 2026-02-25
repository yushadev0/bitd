unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniButton, vcl.Dialogs,
  uniPanel, uniHTMLFrame, System.Hash, System.Math, System.DateUtils,
  IdSMTP, IdMessage, IdSSLOpenSSL, IdExplicitTLSClientServerBase, IdText, SecretConsts;

type
  TMainForm = class(TUniForm)
    UniHTMLFrame1: TUniHTMLFrame;
    procedure UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
    procedure UniFormShow(Sender: TObject);
    procedure ShowSwal(const ATitle, AMessage, AIcon: string);
    procedure ShowSwalMini(const AMessage, AIcon: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, KayitForm, AnaSayfaForm, test;

function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;

// =========================================================================
// MAİL GÖNDERME MOTORU
// =========================================================================
function SifreSifirlamaMailiGonder(AliciMail, DogrulamaKodu, KullaniciAdi: string; out HataMesaji: string): Boolean;
var
  SMTP: TIdSMTP;
  MailMesaji: TIdMessage;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  HTMLGovde: string;
  MesajKismi: TIdText;
begin
  Result := False;
  HataMesaji := '';

  SMTP := TIdSMTP.Create(nil);
  MailMesaji := TIdMessage.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    try
      SSLHandler.Destination := 'smtp.gmail.com:587';
      SSLHandler.Host := 'smtp.gmail.com';
      SSLHandler.Port := 587;
      SSLHandler.SSLOptions.Method := sslvTLSv1_2;
      SSLHandler.SSLOptions.Mode := sslmUnassigned;

      SMTP.IOHandler := SSLHandler;
      SMTP.UseTLS := utUseExplicitTLS;
      SMTP.Host := 'smtp.gmail.com';
      SMTP.Port := 587;
      SMTP.AuthType := satDefault;

      SMTP.Username := 'backinthedayinfo0@gmail.com';
      SMTP.Password := GOOGLE_APP_PASS;

      MailMesaji.From.Address := 'backinthedayinfo0@gmail.com';
      MailMesaji.From.Name := 'B.I.T.D. SİSTEM MERKEZİ';
      MailMesaji.Recipients.Add.Address := AliciMail;
      MailMesaji.Subject := 'B.I.T.D. - Güvenlik Kodunuz_';
      MailMesaji.ContentType := 'multipart/mixed';
      MailMesaji.CharSet := 'UTF-8';

      HTMLGovde :=
        '<html><head><meta charset="UTF-8"></head><body style="margin:0; padding:0;">' +
        '<div style="background-color: #01012b; padding: 40px; font-family: ''Courier New'', Courier, monospace; color: #ffffff; text-align: center; border: 2px solid #05d9e8; border-radius: 10px; max-width: 500px; margin: 0 auto;">' +
        '  <h1 style="color: #05d9e8; text-shadow: 0 0 10px #05d9e8; margin-bottom: 5px;">AĞA ERİŞİM TALEBİ_</h1>' +
        '  <div style="border-bottom: 1px dashed #ff2a6d; margin-bottom: 20px; width: 50%; margin-left: auto; margin-right: auto;"></div>' +
        '  <p style="font-size: 14px; color: #cccccc; line-height: 1.6;">Sevgili <span style="color:#ff2a6d;">' + KullaniciAdi + '_</span>,<br>Şifrenizi sıfırlamak için bir talep aldık.<br>Sistem kilitlerini açmak için gereken tek kullanımlık kodunuz aşağıdadır:</p>' +
        '  <div style="background-color: rgba(5, 217, 232, 0.1); border: 2px solid #ff2a6d; padding: 15px; margin: 30px auto; width: 150px; font-size: 32px; font-weight: bold; color: #ff2a6d; letter-spacing: 5px; text-shadow: 0 0 10px #ff2a6d;">' +
        '    ' + DogrulamaKodu +
        '  </div>' +
        '  <p style="font-size: 12px; color: rgba(255, 255, 255, 0.5); margin-top: 30px;">Bu kod 15 dakika boyunca geçerlidir.<br>Eğer bu talebi siz yapmadıysanız, bu mesajı görmezden gelin.</p>' +
        '</div></body></html>';

      MesajKismi := TIdText.Create(MailMesaji.MessageParts, nil);
      MesajKismi.Body.Text := HTMLGovde;
      MesajKismi.ContentType := 'text/html';
      MesajKismi.CharSet := 'UTF-8';
      MesajKismi.ContentTransfer := 'quoted-printable';

      SMTP.Connect;
      SMTP.Send(MailMesaji);
      SMTP.Disconnect;

      Result := True;
    except
      on E: Exception do
      begin
        HataMesaji := E.Message;
        Result := False;
      end;
    end;
  finally
    SMTP.Free;
    MailMesaji.Free;
    SSLHandler.Free;
  end;
end;

procedure TMainForm.ShowSwal(const ATitle, AMessage, AIcon: string);
var
  JSCode: string;
begin
  JSCode :=
    'if (!document.getElementById("neonSwalBigStyle")) {' +
    '  const style = document.createElement("style");' +
    '  style.id = "neonSwalBigStyle";' +
    '  style.innerHTML = `' +
    '    .neon-swal-big-popup { ' +
    '      background: rgba(10, 10, 35, 0.95) !important; ' +
    '      backdrop-filter: blur(15px); ' +
    '      border: 1px solid var(--neon-blue) !important; ' +
    '      box-shadow: 0 0 30px rgba(5, 217, 232, 0.3) !important; ' +
    '      color: #fff !important; ' +
    '      font-family: "Outfit", sans-serif !important; ' +
    '      border-radius: 12px !important; ' +
    '      padding: 30px !important; ' +
    '    } ' +
    '    .neon-swal-big-title { ' +
    '      font-family: "Press Start 2P", cursive !important; ' +
    '      color: var(--neon-blue) !important; ' +
    '      font-size: 1.2rem !important; ' +
    '      text-shadow: 2px 2px 0px var(--neon-pink) !important; ' +
    '      margin-bottom: 15px !important; ' +
    '    } ' +
    '    .neon-swal-big-html { ' +
    '      color: rgba(255, 255, 255, 0.8) !important; ' +
    '      font-size: 1.1rem !important; ' +
    '      line-height: 1.5 !important; ' +
    '    } ' +
    '    .neon-swal-btn { ' +
    '      background: transparent !important; ' +
    '      color: var(--neon-pink) !important; ' +
    '      border: 2px solid var(--neon-pink) !important; ' +
    '      font-family: "Press Start 2P", cursive !important; ' +
    '      font-size: 0.8rem !important; ' +
    '      padding: 12px 25px !important; ' +
    '      border-radius: 4px !important; ' +
    '      box-shadow: none !important; ' +
    '      transition: all 0.3s ease !important; ' +
    '    } ' +
    '    .neon-swal-btn:hover { ' +
    '      background: var(--neon-pink) !important; ' +
    '      color: #fff !important; ' +
    '      box-shadow: 0 0 15px var(--neon-pink) !important; ' +
    '    } ' +
    '    .neon-swal-big-icon { ' +
    '      border: none !important; ' +
    '      color: var(--neon-blue) !important; ' +
    '      font-size: 3rem !important; ' +
    '      display: flex !important; ' +
    '      align-items: center !important; ' +
    '      justify-content: center !important; ' +
    '      text-shadow: 0 0 20px var(--neon-blue) !important; ' +
    '      margin-top: 10px !important; ' +
    '    }' +
    '    .neon-swal-big-icon.error-icon { color: var(--neon-pink) !important; text-shadow: 0 0 20px var(--neon-pink) !important; }' +
    '  `;' +
    '  document.head.appendChild(style);' +
    '}' +
    'let faClassBig = "fa-solid fa-circle-check";' +
    'let extraClassBig = "";' +
    'if ("' + AIcon + '" === "error") { faClassBig = "fa-solid fa-circle-xmark"; extraClassBig = "error-icon"; }' +
    'else if ("' + AIcon + '" === "warning") { faClassBig = "fa-solid fa-triangle-exclamation"; extraClassBig = "warning-icon"; }' +
    'else if ("' + AIcon + '" === "info") { faClassBig = "fa-solid fa-circle-info"; }' +
    'Swal.fire({' +
    '  title: "' + ATitle + '",' +
    '  html: "' + AMessage + '",' +
    '  iconHtml: `<i class="${faClassBig}"></i>`,' +
    '  confirmButtonText: "ANLADIM",' +
    '  buttonsStyling: false,' +
    '  customClass: {' +
    '    popup: "neon-swal-big-popup",' +
    '    title: "neon-swal-big-title",' +
    '    htmlContainer: "neon-swal-big-html",' +
    '    confirmButton: "neon-swal-btn",' +
    '    icon: "neon-swal-big-icon " + extraClassBig' +
    '  },' +
    '  didOpen: () => {' +
    '    document.querySelector(".swal2-container").style.zIndex = "999999";' +
    '    document.querySelector(".swal2-backdrop-show").style.background = "rgba(0, 0, 0, 0.8)";' + // Arkadaki siyahlığı biraz koyulttuk
    '  }' +
    '});';

  UniSession.AddJS(JSCode);
end;

procedure TMainForm.ShowSwalMini(const AMessage, AIcon: string);
var
  JSCode: string;
begin
  JSCode :=
    'if (!document.getElementById("neonSwalStyle")) {' +
    '  const style = document.createElement("style");' +
    '  style.id = "neonSwalStyle";' +
    '  style.innerHTML = `' +
    '    .neon-swal-popup { ' +
    '      background: rgba(10, 10, 35, 0.95) !important; ' +
    '      backdrop-filter: blur(10px); ' +
    '      border: 1px solid var(--neon-blue) !important; ' +
    '      box-shadow: 0 0 15px rgba(5, 217, 232, 0.2) !important; ' +
    '      color: #fff !important; ' +
    '      font-family: "Outfit", sans-serif !important; ' +
    '      border-radius: 8px !important; ' +
    '    } ' +
    '    .neon-swal-popup .swal2-title { ' +
    '      color: #fff !important; ' +
    '      font-size: 1rem !important; /* Metin boyutu eski haline döndü */ ' +
    '      font-weight: 300 !important; ' +
    '    } ' +
    '    .neon-swal-popup .swal2-timer-progress-bar { ' +
    '      background: var(--neon-pink) !important; ' +
    '    } ' +
    '    .neon-swal-icon { ' +
    '      border: none !important; ' +
    '      color: var(--neon-blue) !important; ' +
    '      font-size: 0.85rem !important; /* SADECE İKON KÜÇÜLTÜLDÜ */ ' +
    '      margin: 0 10px 0 15px !important; ' +
    '      display: flex !important; ' +
    '      align-items: center !important; ' +
    '      justify-content: center !important; ' +
    '      text-shadow: 0 0 10px var(--neon-blue) !important; ' +
    '    }' +
    '    .neon-swal-icon.error-icon { color: var(--neon-pink) !important; text-shadow: 0 0 10px var(--neon-pink) !important; }' +
    '  `;' +
    '  document.head.appendChild(style);' +
    '}' +

    'let faClass = "fa-solid fa-check";' +
    'let extraClass = "";' +
    'if ("' + AIcon + '" === "error") { faClass = "fa-solid fa-xmark"; extraClass = "error-icon"; }' +
    'else if ("' + AIcon + '" === "warning") { faClass = "fa-solid fa-triangle-exclamation"; extraClass = "warning-icon"; }' +
    'else if ("' + AIcon + '" === "info") { faClass = "fa-solid fa-circle-info"; }' +

    'const Toast = Swal.mixin({' +
    '  toast: true,' +
    '  position: "top-end",' +
    '  showConfirmButton: false,' +
    '  timer: 2000,' +
    '  timerProgressBar: true,' +
    '  customClass: {' +
    '    popup: "neon-swal-popup",' +
    '    icon: "neon-swal-icon " + extraClass' +
    '  },' +
    '  didOpen: (toast) => {' +
    '    toast.onmouseenter = Swal.stopTimer;' +
    '    toast.onmouseleave = Swal.resumeTimer;' +
    '    document.querySelector(".swal2-container").style.zIndex = "99999";' +
    '  }' +
    '});' +
    'Toast.fire({' +
    '  iconHtml: `<i class="${faClass}"></i>`,' +
    '  title: "' + AMessage + '"' +
    '});';

  UniSession.AddJS(JSCode);
end;


procedure TMainForm.UniFormShow(Sender: TObject);
begin
  UniMainModule.UniConnection1.Connect;

  var
  CookieUser, CookieToken: string;
begin
  CookieUser := UniApplication.Cookies.GetCookie('BITD_USER');
  CookieToken := UniApplication.Cookies.GetCookie('BITD_TOKEN');

  if (CookieUser <> '') and (CookieToken <> '') then
  begin
    try
      UniMainModule.GirisTable.Close;
      UniMainModule.GirisTable.SQL.Text :=
        'SELECT * FROM kullanicilar WHERE kullanici_adi = :p_kullanici AND RememberToken = :p_token';

      UniMainModule.GirisTable.ParamByName('p_kullanici').AsString := CookieUser;
      UniMainModule.GirisTable.ParamByName('p_token').AsString := CookieToken;
      UniMainModule.GirisTable.Open;

      if UniMainModule.GirisTable.RecordCount = 1 then
      begin
        // Login Confirmed.
        ANA_SAYFA_FORM.Show;
        Self.Hide
      end
      else
      begin
        UniApplication.Cookies.SetCookie('BITD_USER', '', Now - 1);
        UniApplication.Cookies.SetCookie('BITD_TOKEN', '', Now - 1);
      end;
    except

    end;
  end;


end
end;
procedure TMainForm.UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string; Params: TUniStrings);
var
GelenKullanici, GelenSifre, GelenHatirla: string;
  YeniToken: string;
  Guid: TGUID;
begin
  if EventName= 'ForgotPassword' then
  begin
    ShowMessage('Şifremi Unuttum');
  end;

  if EventName= 'SignUp' then
  begin
  KAYIT_FORM.ShowModal();
  Self.Hide;
  end;

  if EventName = 'TestSinyali' then
  begin
    GelenKullanici := Trim(Params.Values['user']);
    GelenSifre := Trim(Params.Values['pass']);
    GelenHatirla := Params.Values['remember'];


    if (GelenKullanici = '') or (GelenSifre = '') then
    begin
      ShowSwal('Uyarı', 'Kullanıcı adı ve şifre boş bırakılamaz!', 'warning');
      Exit;
    end;
    try
     UniMainModule.GirisTable.Close;
      UniMainModule.GirisTable.SQL.Text :=
        'SELECT * FROM kullanicilar WHERE kullanici_adi = :p_kullanici AND sifre = :p_sifre';

      UniMainModule.GirisTable.ParamByName('p_kullanici').AsString := GelenKullanici;
      UniMainModule.GirisTable.ParamByName('p_sifre').AsString := THashSHA2.GetHashString(GelenSifre);

      UniMainModule.GirisTable.Open;

      if UniMainModule.GirisTable.RecordCount = 1 then
      begin
        //ANA_MENU_FORM.ShowModal;

        if GelenHatirla = '1' then
      begin
        CreateGUID(Guid);
        YeniToken := StringReplace(GUIDToString(Guid), '{', '', [rfReplaceAll]);
        YeniToken := StringReplace(YeniToken, '}', '', [rfReplaceAll]);
        YeniToken := StringReplace(YeniToken, '-', '', [rfReplaceAll]);

        UniMainModule.UpdateQuery.SQL.Text := 'UPDATE kullanicilar SET RememberToken = :p_token WHERE kullanici_adi = :p_kullanici';
        UniMainModule.UpdateQuery.ParamByName('p_token').AsString := YeniToken;
        UniMainModule.UpdateQuery.ParamByName('p_kullanici').AsString := GelenKullanici;
        UniMainModule.UpdateQuery.Execute;

        UniApplication.Cookies.SetCookie('BITD_USER', GelenKullanici, Now + 30);
        UniApplication.Cookies.SetCookie('BITD_TOKEN', YeniToken, Now + 30);
      end else
      begin
        UniApplication.Cookies.SetCookie('BITD_USER', '', Now - 1);
        UniApplication.Cookies.SetCookie('BITD_TOKEN', '', Now - 1);

        UniMainModule.UpdateQuery.SQL.Text := 'UPDATE kullanicilar SET RememberToken = NULL WHERE kullanici_adi = :p_kullanici';
        UniMainModule.UpdateQuery.ParamByName('p_kullanici').AsString := GelenKullanici;
        UniMainModule.UpdateQuery.Execute;
      end;
        ANA_SAYFA_FORM.Show;
        Self.Hide;
        exit;
      end
      else
      begin
         ShowSwal('Uyarı', 'Kullanıcı adı veya şifre hatalı!', 'warning');
      end;

    except
      on E: Exception do
      begin
        ShowMessage('Sistem Hatası: Veritabanına ulaşılamadı. Detay: ' + E.Message);
      end;
    end;
  end;

  // =========================================================================
  // BÖLÜM 1: E-POSTA KONTROLÜ VE MAİL GÖNDERİMİ
  // =========================================================================
  if SameText(EventName, 'FPSendCode') then
  begin
    try
      var GelenMail := Trim(Params.Values['email']);
      var HataMesaji, HedefKullaniciAdi: string;


      UniMainModule.GirisTable.Close;
      UniMainModule.GirisTable.SQL.Text := 'SELECT id, kullanici_adi FROM kullanicilar WHERE Email = ' + QuotedStr(GelenMail);
      UniMainModule.GirisTable.Open;

      if UniMainModule.GirisTable.IsEmpty then
      begin
        UniSession.AddJS('document.getElementById("fpStep1").style.opacity = "1";');
        MainForm.ShowSwalMini('Sistemde böyle bir e-posta kayıtlı değil!', 'error');
        Exit;
      end;

      HedefKullaniciAdi := UniMainModule.GirisTable.FieldByName('kullanici_adi').AsString;

      Randomize;
      var UretilenKod := IntToStr(RandomRange(100000, 999999));

      UniMainModule.UpdateQuery.SQL.Text :=
        'UPDATE kullanicilar SET reset_kod = ' + QuotedStr(UretilenKod) +
        ', reset_kod_zaman = CURRENT_TIMESTAMP WHERE Email = ' + QuotedStr(GelenMail);
      UniMainModule.UpdateQuery.ExecSQL;

      if SifreSifirlamaMailiGonder(GelenMail, UretilenKod, HedefKullaniciAdi, HataMesaji) then
      begin
        UniSession.AddJS('document.getElementById("fpStep1").style.opacity = "1";');
        UniSession.AddJS('document.getElementById("fpStep1").style.display="none"; document.getElementById("fpStep2").style.display="block";');
        MainForm.ShowSwalMini('Doğrulama kodu e-postanıza gönderildi!', 'success');
      end
      else
      begin
        UniSession.AddJS('document.getElementById("fpStep1").style.opacity = "1";');
        UniSession.AddJS('alert("Mail gönderilemedi: ' + HataMesaji + '");');
      end;

    except
      on E: Exception do
      begin
        UniSession.AddJS('document.getElementById("fpStep1").style.opacity = "1";');
        UniSession.AddJS('alert("SİSTEM HATASI: ' + E.Message + '");');
      end;
    end;
  end;

  // =========================================================================
  // BÖLÜM 2: KOD VE ZAMAN DOĞRULAMASI
  // =========================================================================
  if SameText(EventName, 'FPVerifyCode') then
  begin
    var GelenMail := Trim(Params.Values['email']);
    var GelenKod := Trim(Params.Values['code']);

    UniMainModule.GirisTable.Close;
    UniMainModule.GirisTable.SQL.Text :=
      'SELECT reset_kod_zaman FROM kullanicilar WHERE Email = ' + QuotedStr(GelenMail) +
      ' AND reset_kod = ' + QuotedStr(GelenKod);
    UniMainModule.GirisTable.Open;

    if UniMainModule.GirisTable.IsEmpty then
    begin
      UniSession.AddJS('document.getElementById("fpCode").value = "";');
      MainForm.ShowSwalMini('Hatalı kod girdiniz!', 'error');
    end
    else
    begin
      if MinutesBetween(Now, UniMainModule.GirisTable.FieldByName('reset_kod_zaman').AsDateTime) > 15 then
      begin
        UniSession.AddJS('document.getElementById("fpCode").value = "";');
        MainForm.ShowSwalMini('Bu kodun süresi (15 dk) dolmuş!', 'warning');
      end
      else
      begin
        // Kod doğru ve süresi geçmemiş! 3. Adıma geç.
        UniSession.AddJS('document.getElementById("fpStep2").style.display="none"; document.getElementById("fpStep3").style.display="block";');
      end;
    end;
  end;

  // =========================================================================
  // BÖLÜM 3: YENİ ŞİFREYİ KAYDET
  // =========================================================================
  if SameText(EventName, 'FPSavePass') then
  begin
    var GelenMail := Trim(Params.Values['email']);
    var YeniSifre := Trim(Params.Values['pass']);

    YeniSifre := THashSHA2.GetHashString(YeniSifre);

    UniMainModule.UpdateQuery.SQL.Text :=
      'UPDATE kullanicilar SET sifre = ' + QuotedStr(YeniSifre) +
      ', reset_kod = NULL, reset_kod_zaman = NULL WHERE Email = ' + QuotedStr(GelenMail);
    UniMainModule.UpdateQuery.ExecSQL;

    UniSession.AddJS('window.closeForgotPassModal();');
    MainForm.ShowSwal('Başarılı','Sistem Kilitleri Kırıldı! Şifreniz başarıyla güncellendi.', 'success');
  end;


end;

initialization
  RegisterAppFormClass(TMainForm);

end.
