unit HesabimForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniPanel, uniHTMLFrame,
  System.Hash, System.Math, System.DateUtils,
  IdSMTP, IdMessage, IdSSLOpenSSL, IdExplicitTLSClientServerBase, IdText, SecretConsts;

type
  THESABIM_FORM = class(TUniForm)
    UniHTMLFrame1: TUniHTMLFrame;
    procedure UniFormShow(Sender: TObject);
    procedure UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function HESABIM_FORM: THESABIM_FORM;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, Main, AnaSayfaForm, DizilerimForm,
  FilmlerimForm, KitaplarimForm, OyunlarimForm;

function HESABIM_FORM: THESABIM_FORM;
begin
  Result := THESABIM_FORM(UniMainModule.GetFormInstance(THESABIM_FORM));
end;

// =========================================================================
// MAİL GÖNDERME MOTORU
// =========================================================================
function SifreSifirlamaMailiGonder(AliciMail, DogrulamaKodu,
  KullaniciAdi: string; out HataMesaji: string): Boolean;
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
        '<html><head><meta charset="UTF-8"></head><body style="margin:0; padding:0;">'
        + '<div style="background-color: #01012b; padding: 40px; font-family: ''Courier New'', Courier, monospace; color: #ffffff; text-align: center; border: 2px solid #05d9e8; border-radius: 10px; max-width: 500px; margin: 0 auto;">'
        + '  <h1 style="color: #05d9e8; text-shadow: 0 0 10px #05d9e8; margin-bottom: 5px;">AĞA ERİŞİM TALEBİ_</h1>'
        + '  <div style="border-bottom: 1px dashed #ff2a6d; margin-bottom: 20px; width: 50%; margin-left: auto; margin-right: auto;"></div>'
        + '  <p style="font-size: 14px; color: #cccccc; line-height: 1.6;">Sevgili <span style="color:#ff2a6d;">'
        + KullaniciAdi +
        '_</span>,<br>Şifrenizi sıfırlamak için bir talep aldık.<br>Sistem kilitlerini açmak için gereken tek kullanımlık kodunuz aşağıdadır:</p>'
        + '  <div style="background-color: rgba(5, 217, 232, 0.1); border: 2px solid #ff2a6d; padding: 15px; margin: 30px auto; width: 150px; font-size: 32px; font-weight: bold; color: #ff2a6d; letter-spacing: 5px; text-shadow: 0 0 10px #ff2a6d;">'
        + '    ' + DogrulamaKodu + '  </div>' +
        '  <p style="font-size: 12px; color: rgba(255, 255, 255, 0.5); margin-top: 30px;">Bu kod 15 dakika boyunca geçerlidir.<br>Eğer bu talebi siz yapmadıysanız, bu mesajı görmezden gelin.</p>'
        + '</div></body></html>';

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

procedure THESABIM_FORM.UniFormShow(Sender: TObject);
var
  GelenMail, GelenKullaniciAdi, JSKodu: String;
begin
  GelenMail := UniMainModule.GirisTable.FieldByName('Email').Text;
  GelenKullaniciAdi := UniMainModule.GirisTable.FieldByName
    ('kullanici_adi').Text;

  JSKodu := 'var checkExist = setInterval(function() { ' +
    '  var u = document.getElementById("accUsername"); ' +
    '  var e = document.getElementById("accEmail"); ' + '  if (u && e) { ' +
    '    u.value = "' + GelenKullaniciAdi + '"; ' + '    e.value = "' +
    GelenMail + '"; ' + '    clearInterval(checkExist); ' + '  } ' + '}, 100);';

  UniSession.AddJS(JSKodu);

end;

procedure THESABIM_FORM.UniHTMLFrame1AjaxEvent(Sender: TComponent;
  EventName: string; Params: TUniStrings);
var
  YeniKullaniciAdi, YeniEmail, GelenKullanici: String;
begin
  if EventName = 'UpdateProfileDB' then
  begin
    YeniKullaniciAdi := Params.Values['kullanici_adi'];
    YeniEmail := Params.Values['eposta'];

    UniMainModule.GirisTable.Edit;
    UniMainModule.GirisTable.FieldByName('kullanici_adi').Text :=
      YeniKullaniciAdi;

    UniMainModule.GirisTable.FieldByName('Email').Text := YeniEmail;
    UniMainModule.GirisTable.Post;

    MainForm.ShowSwalMini('Değiştirme işlemi başarılı!', 'success');
  end;

  if EventName = 'DoLogout' then
  begin
    GelenKullanici := UniMainModule.GirisTable.FieldByName
      ('kullanici_adi').Text;
    UniApplication.Cookies.SetCookie('BITD_USER', '', Now - 1);
    UniApplication.Cookies.SetCookie('BITD_TOKEN', '', Now - 1);
    UniMainModule.UpdateQuery.SQL.Text :=
      'UPDATE kullanicilar SET RememberToken = NULL WHERE kullanici_adi = :p_kullanici';
    UniMainModule.UpdateQuery.ParamByName('p_kullanici').AsString :=
      GelenKullanici;
    UniMainModule.UpdateQuery.Execute;
    UniApplication.Restart;
  end;

  if EventName = 'gamesPageCall' then
  begin
    OYUNLARIM_FORM.Show;
    Self.Close;
  end;
  if EventName = 'tvShowsPageCall' then
  begin
    DIZILERIM_FORM.Show;
    Self.Close;
  end;
  if EventName = 'moviesPageCall' then
  begin
    FILMLERIM_FORM.Show;
    Self.Close;
  end;
  if EventName = 'booksPageCall' then
  begin
    KITAPLARIM_FORM.Show;
    Self.Close;
  end;
  if EventName = 'homePageCall' then
  begin
    ANA_SAYFA_FORM.Show;
    Self.Close;
  end;
   var UserID := UniMainModule.GirisTable.FieldByName('id').Text;
   var Tema : Boolean;
  if SameText(EventName, 'TemaGuncelleDB') then
  begin
    var GelenTema := Params.Values['tema_durumu'];
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

    if GelenTema = '1' then
    begin
      Tema := True;
    end else
    begin
      Tema := False;
    end;

    UniMainModule.GirisTable.Edit;
    UniMainModule.GirisTable.FieldByName('tema').AsBoolean := Tema;
    UniMainModule.GirisTable.Post;
  end;

  // =========================================================================
  // BÖLÜM 1: E-POSTA KONTROLÜ VE MAİL GÖNDERİMİ
  // =========================================================================
  if SameText(EventName, 'FPSendCode') then
  begin
    try
      var
      GelenMail := Trim(Params.Values['email']);
      var
        HataMesaji, HedefKullaniciAdi: string;

      UniMainModule.GirisTable.Close;
      UniMainModule.GirisTable.SQL.Text :=
        'SELECT id, kullanici_adi FROM kullanicilar WHERE Email = ' +
        QuotedStr(GelenMail);
      UniMainModule.GirisTable.Open;

      if UniMainModule.GirisTable.IsEmpty then
      begin
        UniSession.AddJS
          ('document.getElementById("accFpStep1").style.opacity="1";');
        MainForm.ShowSwalMini
          ('Sistemde böyle bir e-posta kayıtlı değil!', 'error');
        exit;
      end;

      HedefKullaniciAdi := UniMainModule.GirisTable.FieldByName
        ('kullanici_adi').AsString;

      Randomize;
      var
      UretilenKod := IntToStr(RandomRange(100000, 999999));

      UniMainModule.UpdateQuery.SQL.Text := 'UPDATE kullanicilar SET reset_kod='
        + QuotedStr(UretilenKod) +
        ', reset_kod_zaman=CURRENT_TIMESTAMP WHERE Email=' +
        QuotedStr(GelenMail);
      UniMainModule.UpdateQuery.ExecSQL;

      if SifreSifirlamaMailiGonder(GelenMail, UretilenKod, HedefKullaniciAdi,
        HataMesaji) then
      begin
        UniSession.AddJS
          ('document.getElementById("accFpStep1").style.opacity="1";');
        UniSession.AddJS
          ('document.getElementById("accFpStep1").style.display="none";' +
          'document.getElementById("accFpStep2").style.display="block";');
        MainForm.ShowSwalMini('Doğrulama kodu e-postanıza gönderildi!',
          'success');
      end
      else
      begin
        UniSession.AddJS
          ('document.getElementById("accFpStep1").style.opacity="1";');
        UniSession.AddJS('alert("Mail gönderilemedi: ' + HataMesaji + '");');
      end;

    except
      on E: Exception do
      begin
        UniSession.AddJS
          ('document.getElementById("accFpStep1").style.opacity="1";');
        UniSession.AddJS('alert("SİSTEM HATASI: ' + E.Message + '");');
      end;
    end;
  end;

  // =========================================================================
  // BÖLÜM 2: KOD VE ZAMAN DOĞRULAMASI
  // =========================================================================
  if SameText(EventName, 'FPVerifyCode') then
  begin
    var
    GelenMail := Trim(Params.Values['email']);
    var
    GelenKod := Trim(Params.Values['code']);

    UniMainModule.GirisTable.Close;
    UniMainModule.GirisTable.SQL.Text :=
      'SELECT reset_kod_zaman FROM kullanicilar WHERE Email=' +
      QuotedStr(GelenMail) + ' AND reset_kod=' + QuotedStr(GelenKod);
    UniMainModule.GirisTable.Open;

    if UniMainModule.GirisTable.IsEmpty then
    begin
      UniSession.AddJS('document.getElementById("accFpCode").value="";');
      MainForm.ShowSwalMini('Hatalı kod girdiniz!', 'error');
    end
    else
    begin
      if MinutesBetween(Now, UniMainModule.GirisTable.FieldByName
        ('reset_kod_zaman').AsDateTime) > 15 then
      begin
        UniSession.AddJS('document.getElementById("accFpCode").value="";');
        MainForm.ShowSwalMini('Bu kodun süresi (15 dk) dolmuş!', 'warning');
      end
      else
      begin
        UniSession.AddJS
          ('document.getElementById("accFpStep2").style.display="none";' +
          'document.getElementById("accFpStep3").style.display="block";');
      end;
    end;
  end;

  // =========================================================================
  // BÖLÜM 3: YENİ ŞİFREYİ KAYDET
  // =========================================================================
  if SameText(EventName, 'FPSavePass') then
  begin
    var
    GelenMail := Trim(Params.Values['email']);
    var
    YeniSifre := Trim(Params.Values['pass']);

    YeniSifre := THashSHA2.GetHashString(YeniSifre);

    UniMainModule.UpdateQuery.SQL.Text := 'UPDATE kullanicilar SET sifre=' +
      QuotedStr(YeniSifre) +
      ', reset_kod=NULL, reset_kod_zaman=NULL, RememberToken=NULL WHERE Email='
      + QuotedStr(GelenMail);
    UniMainModule.UpdateQuery.ExecSQL;

    UniSession.AddJS('window.closeForgotPassModal();');

    UniSession.AddJS('window.showNeonBigSwalAndAjax(' + '"SİSTEM TAMAMLANDI_", '
      + '"Şifreniz başarıyla değiştirildi.<br>Giriş ekranına yönlendirileceksiniz.", '
      + '"info", ' + 'HESABIM_FORM.UniHTMLFrame1, ' + '"GoLogin", ' + '[]' + ');');
  end;

  if EventName = 'GoLogin' then
  begin
    UniApplication.Restart;
  end;
end;

end.
