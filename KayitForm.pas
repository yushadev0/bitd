unit KayitForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniPanel, uniHTMLFrame,
  System.Hash;

type
  TKAYIT_FORM = class(TUniForm)
    UniHTMLFrame1: TUniHTMLFrame;
    procedure UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function KAYIT_FORM: TKAYIT_FORM;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, Main;

function KAYIT_FORM: TKAYIT_FORM;
begin
  Result := TKAYIT_FORM(UniMainModule.GetFormInstance(TKAYIT_FORM));
end;

procedure TKAYIT_FORM.UniHTMLFrame1AjaxEvent(Sender: TComponent;
  EventName: string; Params: TUniStrings);
var
  GelenKullanici, GelenEmail, GelenSifre, GelenSifreTekrar, GelenCaptcha, HashliSifre, GercekCaptcha: string;
begin
  if EventName = 'GoBackLogin' then
  begin
    Self.Close;
    MainForm.Show;
    Exit;
  end;

  if EventName = 'DoRegister' then
  begin
    GelenKullanici    := Trim(Params.Values['user']);
    GelenEmail        := Trim(Params.Values['email']);
    GelenSifre        := Params.Values['pass'];
    GelenSifreTekrar  := Params.Values['passConfirm'];
    GelenCaptcha      := Trim(Params.Values['c_input']);
    GercekCaptcha := Trim(Params.Values['c_actual']);

    // 1. Boşluk Kontrolü
    if (GelenKullanici = '') or (GelenEmail = '') or (GelenSifre = '') then
    begin
      MainForm.ShowSwal('Eksik Bilgi', 'Lütfen tüm alanları doldurur musun? B.I.T.D. boşluk sevmez!', 'warning');
      Exit;
    end;

    // 2. E-Posta Format Kontrolü
    if (Pos('@', GelenEmail) = 0) or (Pos('.', GelenEmail) = 0) then
    begin
      MainForm.ShowSwal('Hatalı E-Posta', 'Girdiğin e-posta adresi pek gerçekçi durmuyor...', 'error');
      Exit;
    end;

    UniMainModule.GenelSorguTable.Close;
    UniMainModule.GenelSorguTable.SQL.Text := 'select * from kullanicilar where Email= '+ #39 + GelenEmail +#39;
    UniMainModule.GenelSorguTable.Open;

    if not UniMainModule.GenelSorguTable.IsEmpty then
    begin
      MainForm.ShowSwal('Kullanılan E-Posta', 'Girdiğin e-posta adresi sisteme zaten kayıtlı!', 'error');
      Exit;
    end;

    UniMainModule.GenelSorguTable.SQL.Clear;

    // 3. Şifre Eşleşme Kontrolü
    if GelenSifre <> GelenSifreTekrar then
    begin
      MainForm.ShowSwal('Şifreler Uyuşmuyor', 'İki şifre kutusu birbiriyle kavgalı, lütfen aynı yap!', 'error');
      Exit;
    end;


   if GelenCaptcha = '' then
    begin
      MainForm.ShowSwal('Güvenlik', 'Lütfen güvenlik kodunu boş bırakma!', 'warning');
      Exit;
    end;

   if not SameText(GelenCaptcha, GercekCaptcha) then
    begin
      // Hata durumunda yeni kod üretmesi için JS'yi tetikle
      UniSession.AddJS('refreshCaptcha();');
      MainForm.ShowSwal('Hatalı Kod', 'Güvenlik kodu uyuşmuyor, lütfen tekrar dene.', 'error');
      Exit;
    end;

    // --- TÜM KONTROLLER GEÇİLDİ ---
    HashliSifre := THashSHA2.GetHashString(GelenSifre);

    try
      // Kullanıcı/Email varlık kontrolü (Önceki kodun aynısı)
      UniMainModule.UpdateQuery.SQL.Text := 'INSERT INTO kullanicilar (kullanici_adi, Email, sifre, IsActive) VALUES (:p_user, :p_email, :p_pass, 1)';
      UniMainModule.UpdateQuery.ParamByName('p_user').AsString  := GelenKullanici;
      UniMainModule.UpdateQuery.ParamByName('p_email').AsString := GelenEmail;
      UniMainModule.UpdateQuery.ParamByName('p_pass').AsString  := HashliSifre;
      UniMainModule.UpdateQuery.Execute;

      MainForm.ShowSwal('Hoş Geldin!', 'Kaydın başarıyla oluşturuldu. Şimdi o efsane kütüphaneye giriş yapabilirsin!', 'success');
      UniApplication.Restart;
    except
      on E: Exception do
        MainForm.ShowSwal('Hata', 'Veritabanı işlemini gerçekleştiremedik: ' + E.Message, 'error');
    end;
  end;
end;

end.
