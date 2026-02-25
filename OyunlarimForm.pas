unit OyunlarimForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniPanel, uniHTMLFrame,
  vcl.Dialogs, REST.Client, REST.Types, System.JSON, System.NetEncoding,
  uniTimer, DateUtils, Math, SecretConsts;

type
  TOYUNLARIM_FORM = class(TUniForm)
    UniTimer1: TUniTimer;
    UniHTMLFrame1: TUniHTMLFrame;
    procedure UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
    procedure UniFormShow(Sender: TObject);
    procedure UniTimer1Timer(Sender: TObject);
  private
    procedure KutuphaneyiDoldur;
    procedure OyunAraAPI(Kelime, Hedef: string);
  public
    { Public declarations }
  end;

function OYUNLARIM_FORM: TOYUNLARIM_FORM;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, AnaSayfaForm, Main, FilmlerimForm,
  DizilerimForm, KitaplarimForm, HesabimForm;

function OYUNLARIM_FORM: TOYUNLARIM_FORM;
begin
  Result := TOYUNLARIM_FORM(UniMainModule.GetFormInstance(TOYUNLARIM_FORM));
end;

// =========================================================================
// YENİ EKLENTİ: DİNAMİK PLACEHOLDER ÜRETİCİSİ (SİBERPUNK TEMALI)
// =========================================================================
function GetPlaceholder(const Title, Kategori, Renk: string): string;
var
  EncTitle: string;
begin
  if Length(Title) > 30 then
    EncTitle := Copy(Title, 1, 27) + '...'
  else
    EncTitle := Title;

  EncTitle := TNetEncoding.URL.Encode(EncTitle);
  EncTitle := StringReplace(EncTitle, '+', '%20', [rfReplaceAll]);
  Result := 'https://placehold.co/300x450/01012b/' + Renk + '/png?text=[' + TNetEncoding.URL.Encode(Kategori) + ']%0A%0A' + EncTitle;
end;

function PuanRengiBul(PuanStr: string): string;
var
  Skor: Double;
begin
  // Varsayılan standart sınır rengi (Puan yoksa veya "--" ise)
  Result := 'rgba(255,255,255,0.08)';

  // Virgüllü puanları (8,5) noktalı (8.5) formata çevirip okumayı garantileyelim
  PuanStr := Trim(StringReplace(PuanStr, ',', '.', [rfReplaceAll]));

  if TryStrToFloat(PuanStr, Skor) then
  begin
    // Eğer puan 10 üzerinden verilmişse (Örn: 8.5), onu 100'lük sisteme (85) çevir
    if Skor <= 10.0 then
      Skor := Skor * 10;

    // SİBERPUNK RENK SKALASI (0-49: Kırmızı, 50-74: Sarı, 75-100: Yeşil)
    if Skor < 50 then
      Result := '#ff2a6d' // Neon Pembe/Kırmızı (Kötü)
    else if Skor < 75 then
      Result := '#ffea00' // Neon Sarı (Ortalama)
    else
      Result := '#39ff14'; // Neon Yeşil (Başyapıt)
  end;
end;

procedure TOYUNLARIM_FORM.OyunAraAPI(Kelime, Hedef: string);
var
  TokenClient, IGDBClient: TRESTClient;
  TokenReq, IGDBReq: TRESTRequest;
  TokenRes, IGDBRes: TRESTResponse;
  TokenJSON: TJSONObject;
  JArray, GenArr: TJSONArray;
  CoverObj: TJSONObject;
  I, J: Integer;
  AccessToken, GameName, ImgID, ImgUrl, GameID, ResultHTML: string;
  InfoYear, InfoGenre, InfoScore: string;
  UnixTime: Int64;
  dVal: Double;
  EkleButonHTML: string;
begin
  TokenClient := TRESTClient.Create('https://id.twitch.tv/oauth2/token');
  TokenReq := TRESTRequest.Create(nil);
  TokenRes := TRESTResponse.Create(nil);
  try
    TokenReq.Client := TokenClient;
    TokenReq.Response := TokenRes;
    TokenReq.Method := rmPOST;
    TokenReq.AddParameter('client_id', API_TWITCH_CLIENT_ID);
    TokenReq.AddParameter('client_secret', API_TWITCH_SECRET);
    TokenReq.AddParameter('grant_type', 'client_credentials');
    TokenReq.Execute;

    if TokenRes.StatusCode = 200 then
    begin
      TokenJSON := TJSONObject.ParseJSONValue(TokenRes.Content) as TJSONObject;
      try
        AccessToken := TokenJSON.GetValue<string>('access_token');
      finally
        TokenJSON.Free;
      end;
    end
    else
    begin
      UniSession.AddJS('document.getElementById("searchResults").innerHTML = ''<div style="color:red;">Twitch Kimlik Doğrulama Hatası!</div>'';');
      Exit;
    end;
  finally
    TokenClient.Free; TokenReq.Free; TokenRes.Free;
  end;

  IGDBClient := TRESTClient.Create('https://api.igdb.com/v4/games');
  IGDBReq := TRESTRequest.Create(nil);
  IGDBRes := TRESTResponse.Create(nil);
  try
    IGDBReq.Client := IGDBClient;
    IGDBReq.Response := IGDBRes;
    IGDBReq.Method := rmPOST;

    IGDBReq.AddAuthParameter('Authorization', 'Bearer ' + AccessToken, pkHTTPHEADER, [poDoNotEncode]);
    IGDBReq.AddAuthParameter('Client-ID', API_TWITCH_CLIENT_ID, pkHTTPHEADER, [poDoNotEncode]);

    IGDBReq.AddBody('search "' + Kelime + '"; fields id, name, cover.image_id, first_release_date, genres.name, rating; limit 10;', ctTEXT_PLAIN);
    IGDBReq.Execute;

    if IGDBRes.StatusCode = 200 then
    begin
      JArray := TJSONObject.ParseJSONValue(IGDBRes.Content) as TJSONArray;
      try
        ResultHTML := '';

        if JArray.Count = 0 then
        begin
          ResultHTML := '<div style="color:var(--neon-pink); text-align:center;">Veritabanında eşleşme bulunamadı.</div>';
        end
        else
        begin
          for I := 0 to JArray.Count - 1 do
          begin
            GameID := JArray.Items[I].GetValue<string>('id');
            GameName := JArray.Items[I].GetValue<string>('name');

            // PLACEHOLDER UYARLAMASI
            if JArray.Items[I].TryGetValue<TJSONObject>('cover', CoverObj) and CoverObj.TryGetValue<string>('image_id', ImgID) then
              ImgUrl := 'https://images.igdb.com/igdb/image/upload/t_cover_big/' + ImgID + '.jpg'
            else
              ImgUrl := GetPlaceholder(GameName, 'OYUN', '05d9e8'); // Eğer oyunun resmi yoksa Siberpunk resim bas!

            if JArray.Items[I].TryGetValue<Int64>('first_release_date', UnixTime) then
              InfoYear := IntToStr(YearOf(UnixToDateTime(UnixTime)))
            else
              InfoYear := '--';

            if JArray.Items[I].TryGetValue<Double>('rating', dVal) then
              InfoScore := IntToStr(Round(dVal)) + '/100'
            else
              InfoScore := '--';

            InfoGenre := '';
            if JArray.Items[I].TryGetValue<TJSONArray>('genres', GenArr) then
            begin
              for J := 0 to GenArr.Count - 1 do
              begin
                if InfoGenre <> '' then InfoGenre := InfoGenre + ', ';
                InfoGenre := InfoGenre + GenArr.Items[J].GetValue<string>('name');
              end;
            end;
            if InfoGenre = '' then InfoGenre := '--';

            GameName := StringReplace(GameName, '''', '\&#39;', [rfReplaceAll]);
            InfoGenre := StringReplace(InfoGenre, '''', '\&#39;', [rfReplaceAll]);

            if Hedef = '1' then
            begin
              EkleButonHTML := '<button class="acc-btn acc-btn-wish" onclick="event.stopPropagation(); ajaxRequest(OYUNLARIM_FORM.UniHTMLFrame1, ''OyunEkleDB'', [''oyun_id=' + GameID + ''', ''istek=' + Hedef + ''']);"><i class="fa-solid fa-heart"></i> LİSTEYE EKLE</button>';
            end
            else
            begin
              EkleButonHTML := '<button class="acc-btn acc-btn-lib" onclick="event.stopPropagation(); ajaxRequest(OYUNLARIM_FORM.UniHTMLFrame1, ''OyunEkleDB'', [''oyun_id=' + GameID + ''', ''istek=' + Hedef + ''']);"><i class="fa-solid fa-check-double"></i> TAMAMLANDI OLARAK EKLE</button>';
            end;

            ResultHTML := ResultHTML +
              '<div class="accordion-item">' +
              '  <div class="accordion-header" onclick="window.toggleAccordion(this)">' +
              '    <img src="' + ImgUrl + '" class="accordion-poster">' +
              '    <div class="accordion-title">' + GameName + '</div>' +
              '    <i class="fa-solid fa-chevron-down accordion-icon"></i>' +
              '  </div>' +
              '  <div class="accordion-content">' +
              '    <div class="acc-details">' +
              '      <div class="acc-detail-item"><strong>ÇIKIŞ YILI</strong><span>' + InfoYear + '</span></div>' +
              '      <div class="acc-detail-item"><strong>TÜR</strong><span>' + InfoGenre + '</span></div>' +
              '      <div class="acc-detail-item" style="grid-column: 1 / -1;"><strong>PUAN</strong><span>' + InfoScore + '</span></div>' +
              '    </div>' +
              '    <div class="acc-actions">' +
              EkleButonHTML +
              '    </div>' +
              '  </div>' +
              '</div>';
          end;
        end;

        UniSession.AddJS('document.getElementById("searchResults").innerHTML = `' + ResultHTML + '`;');
      finally
        JArray.Free;
      end;
    end
    else
    begin
      UniSession.AddJS('document.getElementById("searchResults").innerHTML = ''<div style="color:red;">IGDB Bağlantı Hatası! Status: ' + IntToStr(IGDBRes.StatusCode) + '</div>'';');
    end;
  finally
    IGDBClient.Free; IGDBReq.Free; IGDBRes.Free;
  end;
end;


procedure TOYUNLARIM_FORM.UniFormShow(Sender: TObject);
var
  KullaniciAdi, JSKodu: String;
begin
  KullaniciAdi := UniMainModule.GirisTable.FieldByName('kullanici_adi').Text;

  JSKodu := 'var checkExist = setInterval(function() { ' +
    '  var userSpan = document.getElementById("spanUser"); ' +
    '  if (userSpan) { ' + '    userSpan.innerText = "' + KullaniciAdi + '_"; '
    + '    clearInterval(checkExist); ' +
    '  } ' + '}, 100);';

  UniSession.AddJS(JSKodu);

  UniTimer1.Enabled := True;
end;

procedure TOYUNLARIM_FORM.UniHTMLFrame1AjaxEvent(Sender: TComponent;
  EventName: string; Params: TUniStrings);
var
  GelenKullanici,GelenTarih, ArananKelime, SecilenOyunID, UserID,GelenKelime, GelenHedef, EkleButonRengi,ArananHedef,GelenOyunID,GelenIstekMi,YeniDurum: String;
begin
  if EventName = 'homePageCall' then begin ANA_SAYFA_FORM.Show; Self.Close; end;
  if EventName = 'moviesPageCall' then begin FILMLERIM_FORM.Show; Self.Close; end;
  if EventName = 'tvShowsPageCall' then begin DIZILERIM_FORM.Show; Self.Close; end;
  if EventName = 'booksPageCall' then begin KITAPLARIM_FORM.Show; Self.Close; end;
    if EventName = 'accountPageCall' then begin HESABIM_FORM.Show; Self.Close; end;

  if EventName = 'DoLogout' then
  begin
    GelenKullanici := UniMainModule.GirisTable.FieldByName('kullanici_adi').Text;
    UniApplication.Cookies.SetCookie('BITD_USER', '', Now - 1);
    UniApplication.Cookies.SetCookie('BITD_TOKEN', '', Now - 1);

    UniMainModule.UpdateQuery.SQL.Text := 'UPDATE kullanicilar SET RememberToken = NULL WHERE kullanici_adi = :p_kullanici';
    UniMainModule.UpdateQuery.ParamByName('p_kullanici').AsString := GelenKullanici;
    UniMainModule.UpdateQuery.Execute;
    UniApplication.Restart;
  end;

  if EventName = 'OyunAra' then
  begin
    ArananKelime := Params.Values['kelime'];
    ArananHedef := Params.Values['hedef'];
    if Trim(ArananKelime) <> '' then OyunAraAPI(ArananKelime, ArananHedef);
  end;

  if EventName = 'OyunEkleDB' then
  begin
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    GelenOyunID := Params.Values['oyun_id'];
    GelenIstekMi := Params.Values['istek'];

    if GelenIstekMi = '' then GelenIstekMi := '0';

    UniMainModule.KullaniciOyunlarTable.Close;
    UniMainModule.KullaniciOyunlarTable.SQL.Text := 'SELECT id FROM kullanici_oyunlar WHERE kullanici_id = ' + UserID + ' AND api_oyun_id = ' + QuotedStr(GelenOyunID);
    UniMainModule.KullaniciOyunlarTable.Open;

    if UniMainModule.KullaniciOyunlarTable.IsEmpty then
    begin
      UniMainModule.KullaniciOyunlarTable.Close;
      if GelenIstekMi = '0' then
        UniMainModule.KullaniciOyunlarTable.SQL.Text := 'INSERT INTO kullanici_oyunlar (kullanici_id, api_oyun_id, istek_mi, bitirme_tarihi) VALUES (' + UserID + ', ' + QuotedStr(GelenOyunID) + ', 0, ''' + FormatDateTime('yyyy-mm-dd', Now) + ''')'
      else
        UniMainModule.KullaniciOyunlarTable.SQL.Text := 'INSERT INTO kullanici_oyunlar (kullanici_id, api_oyun_id, istek_mi) VALUES (' + UserID + ', ' + QuotedStr(GelenOyunID) + ', 1)';

      UniMainModule.KullaniciOyunlarTable.ExecSQL;
      UniSession.AddJS('window.closeAddGameModal();');
      KutuphaneyiDoldur;
    end
    else
    begin
    UniSession.AddJS(
        'var modalContent = document.querySelector("#addGameModal .modal-content"); ' +
        'if (modalContent) { ' +
        '  modalContent.classList.remove("shake-error"); ' +
        '  void modalContent.offsetWidth; ' +
        '  modalContent.classList.add("shake-error"); ' +
        '} '
      );
      MainForm.ShowSwalMini('Bu oyun zaten listenizde mevcut!', 'error');
    end;
  end;

  if EventName = 'OyunGuncelleDB' then
  begin
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    GelenOyunID := Params.Values['oyun_id'];
    YeniDurum := Params.Values['yeni_durum'];

    UniMainModule.KullaniciOyunlarTable.Close;
    UniMainModule.KullaniciOyunlarTable.SQL.Text :=
      'UPDATE kullanici_oyunlar SET istek_mi = ' + YeniDurum + ', bitirme_tarihi = ''' + FormatDateTime('yyyy-mm-dd', Now) + ''' WHERE kullanici_id = ' + UserID + ' AND api_oyun_id = ' + QuotedStr(GelenOyunID);
    UniMainModule.KullaniciOyunlarTable.ExecSQL;
    KutuphaneyiDoldur;
  end;

  if EventName = 'OyunTarihGuncelleDB' then
  begin
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    GelenOyunID := Params.Values['oyun_id'];
    GelenTarih := Params.Values['tarih'];

    UniMainModule.KullaniciOyunlarTable.Close;
    UniMainModule.KullaniciOyunlarTable.SQL.Text :=
      'UPDATE kullanici_oyunlar SET bitirme_tarihi = ' + QuotedStr(GelenTarih) +
      ' WHERE kullanici_id = ' + UserID + ' AND api_oyun_id = ' + QuotedStr(GelenOyunID);
    UniMainModule.KullaniciOyunlarTable.ExecSQL;
    KutuphaneyiDoldur;
  end;

  if SameText(EventName, 'OyunSilDB') then
  begin
    SecilenOyunID := Params.Values['oyun_id'];
    UniMainModule.KullaniciOyunlarTable.Close;
    UniMainModule.KullaniciOyunlarTable.SQL.Text :=
      'DELETE FROM kullanici_oyunlar WHERE kullanici_id = ' +
      UniMainModule.GirisTable.FieldByName('id').AsString +
      ' AND api_oyun_id = ' + SecilenOyunID;
    UniMainModule.KullaniciOyunlarTable.ExecSQL;
    MainForm.ShowSwalMini('Başarıyla Silindi!', 'success');
    KutuphaneyiDoldur;
  end;

  if SameText(EventName, 'OyunNotKaydetDB') then
  begin
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    GelenOyunID := Params.Values['oyun_id'];
    var GelenNot := Params.Values['not'];

    // Uzun ve özel karakterli metinlerde SQL patlamaması için parametre kullanıyoruz
    UniMainModule.UpdateQuery.Close;
    UniMainModule.UpdateQuery.SQL.Text :=
      'UPDATE kullanici_oyunlar SET kisisel_not = :p_not ' +
      'WHERE kullanici_id = :p_uid AND api_oyun_id = :p_oid';

    UniMainModule.UpdateQuery.ParamByName('p_not').AsString := GelenNot;
    UniMainModule.UpdateQuery.ParamByName('p_uid').AsString := UserID;
    UniMainModule.UpdateQuery.ParamByName('p_oid').AsString := GelenOyunID;
    UniMainModule.UpdateQuery.ExecSQL;

    // İşlem başarılı! JS tarafında bulut ikonu zaten yandığı için burada ekstra Swal göstermemize gerek yok, sessiz ve profesyonelce kaydeder.
  end;
end;

procedure TOYUNLARIM_FORM.UniTimer1Timer(Sender: TObject);
begin
  UniTimer1.Enabled := False;
  KutuphaneyiDoldur;
end;

procedure TOYUNLARIM_FORM.KutuphaneyiDoldur;
var
  IDListesi: string;
  HTMLCompleted, HTMLWishlist: string;
  CountCompleted, CountWishlist: Integer;
  TokenClient, IGDBClient: TRESTClient;
  TokenReq, IGDBReq: TRESTRequest;
  TokenRes, IGDBRes: TRESTResponse;
  TokenJSON: TJSONObject;
  JArray: TJSONArray;
  CoverObj: TJSONObject;
  I: Integer;
  AccessToken, GameName, ImgID, ImgUrl, CurrentGameID, UserID: string;
  IsWishlist: Integer;
  UnixTime: Int64;
  dVal: Double;
  InfoYear, InfoScore, InfoSummary: string;
  GenreArr, PlatArr, ScreenArr: TJSONArray;
  J: Integer;
  InfoGenre, InfoPlatform, InfoScreenshots: string;
  RawDate, DisplayDate: string;
  DBTarih, Y, M, D,DBNot: string;
begin
  UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

  UniMainModule.KullaniciOyunlarTable.Close;
  UniMainModule.KullaniciOyunlarTable.SQL.Text :=
    'SELECT api_oyun_id, istek_mi, bitirme_tarihi, kisisel_not FROM kullanici_oyunlar WHERE kullanici_id = ' + UserID +
    ' ORDER BY eklenme_tarihi DESC';
  UniMainModule.KullaniciOyunlarTable.Open;

  if UniMainModule.KullaniciOyunlarTable.IsEmpty then
  begin
    HTMLCompleted := '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-blue); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">HENÜZ OYUN BİTİRMEDİN_</div><div class="add-card" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddGameModal(event, 0)"><i class="fa-solid fa-plus"></i></div></div>';
    HTMLWishlist := '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-pink); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">İSTEK LİSTEN BOŞ_</div><div class="add-card-pink" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddGameModal(event, 1)"><i class="fa-solid fa-plus"></i></div></div>';

    UniSession.AddJS('document.getElementById("completedGrid").innerHTML = `' + HTMLCompleted + '`;');
    UniSession.AddJS('document.getElementById("wishlistGrid").innerHTML = `' + HTMLWishlist + '`;');
    Exit;
  end;

  IDListesi := '';
  UniMainModule.KullaniciOyunlarTable.First;
  while not UniMainModule.KullaniciOyunlarTable.Eof do
  begin
    if IDListesi <> '' then IDListesi := IDListesi + ',';
    IDListesi := IDListesi + UniMainModule.KullaniciOyunlarTable.FieldByName('api_oyun_id').AsString;
    UniMainModule.KullaniciOyunlarTable.Next;
  end;

  TokenClient := TRESTClient.Create('https://id.twitch.tv/oauth2/token');
  TokenReq := TRESTRequest.Create(nil);
  TokenRes := TRESTResponse.Create(nil);
  try
    TokenReq.Client := TokenClient;
    TokenReq.Response := TokenRes;
    TokenReq.Method := rmPOST;
    TokenReq.AddParameter('client_id', API_TWITCH_CLIENT_ID);
    TokenReq.AddParameter('client_secret', API_TWITCH_SECRET);
    TokenReq.AddParameter('grant_type', 'client_credentials');
    TokenReq.Execute;

    if TokenRes.StatusCode = 200 then
    begin
      TokenJSON := TJSONObject.ParseJSONValue(TokenRes.Content) as TJSONObject;
      try
        AccessToken := TokenJSON.GetValue<string>('access_token');
      finally
        TokenJSON.Free;
      end;
    end
    else Exit;
  finally
    TokenClient.Free; TokenReq.Free; TokenRes.Free;
  end;

  IGDBClient := TRESTClient.Create('https://api.igdb.com/v4/games');
  IGDBReq := TRESTRequest.Create(nil);
  IGDBRes := TRESTResponse.Create(nil);
  try
    IGDBReq.Client := IGDBClient;
    IGDBReq.Response := IGDBRes;
    IGDBReq.Method := rmPOST;
    IGDBReq.AddAuthParameter('Authorization', 'Bearer ' + AccessToken, pkHTTPHEADER, [poDoNotEncode]);
    IGDBReq.AddAuthParameter('Client-ID', API_TWITCH_CLIENT_ID, pkHTTPHEADER, [poDoNotEncode]);

    IGDBReq.AddBody('where id = (' + IDListesi + '); fields name, cover.image_id, rating, first_release_date, summary, genres.name, platforms.name, screenshots.image_id; limit 500;', ctTEXT_PLAIN);
    IGDBReq.Execute;

    if IGDBRes.StatusCode = 200 then
    begin
      JArray := TJSONObject.ParseJSONValue(IGDBRes.Content) as TJSONArray;
      try
        CountCompleted := 0;
        CountWishlist := 0;
        HTMLCompleted := '<div class="media-card add-card" onclick="window.openAddGameModal(event, 0)"><i class="fa-solid fa-plus"></i></div>';
        HTMLWishlist := '<div class="media-card add-card-pink" onclick="window.openAddGameModal(event, 1)"><i class="fa-solid fa-plus"></i></div>';

        UniMainModule.KullaniciOyunlarTable.First;
        while not UniMainModule.KullaniciOyunlarTable.Eof do
        begin
          CurrentGameID := UniMainModule.KullaniciOyunlarTable.FieldByName('api_oyun_id').AsString;

          DBNot := UniMainModule.KullaniciOyunlarTable.FieldByName('kisisel_not').AsString;
          DBNot := StringReplace(DBNot, '''', '&apos;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, '"', '&quot;', [rfReplaceAll]);
          // Enter tuşlarını HTML Textarea'nın anlayacağı formata çeviriyoruz
          DBNot := StringReplace(DBNot, #13#10, '&#10;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, #10, '&#10;', [rfReplaceAll]);

          if not UniMainModule.KullaniciOyunlarTable.FieldByName('bitirme_tarihi').IsNull then
          begin
            DBTarih := Trim(UniMainModule.KullaniciOyunlarTable.FieldByName('bitirme_tarihi').AsString);
            if (Length(DBTarih) >= 10) and (DBTarih[5] = '-') and (DBTarih[8] = '-') then
            begin
              Y := Copy(DBTarih, 1, 4); M := Copy(DBTarih, 6, 2); D := Copy(DBTarih, 9, 2);
              RawDate := Y + '-' + M + '-' + D; DisplayDate := D + '.' + M + '.' + Y;
            end
            else
            begin
              try
                RawDate := FormatDateTime('yyyy-mm-dd', UniMainModule.KullaniciOyunlarTable.FieldByName('bitirme_tarihi').AsDateTime);
                DisplayDate := FormatDateTime('dd.mm.yyyy', UniMainModule.KullaniciOyunlarTable.FieldByName('bitirme_tarihi').AsDateTime);
              except
                RawDate := ''; DisplayDate := 'Belirtilmedi';
              end;
            end;
          end
          else begin RawDate := ''; DisplayDate := 'Belirtilmedi'; end;

          if UniMainModule.KullaniciOyunlarTable.FieldByName('istek_mi').AsBoolean then
            IsWishlist := 1 else IsWishlist := 0;

          for I := 0 to JArray.Count - 1 do
          begin
            if JArray.Items[I].GetValue<string>('id') = CurrentGameID then
            begin
              GameName := JArray.Items[I].GetValue<string>('name');

              // PLACEHOLDER UYARLAMASI
              if JArray.Items[I].TryGetValue<TJSONObject>('cover', CoverObj) and CoverObj.TryGetValue<string>('image_id', ImgID) then
                ImgUrl := 'https://images.igdb.com/igdb/image/upload/t_cover_big/' + ImgID + '.jpg'
              else
                ImgUrl := GetPlaceholder(GameName, 'OYUN', '05d9e8');

              if JArray.Items[I].TryGetValue<Int64>('first_release_date', UnixTime) then
                InfoYear := IntToStr(YearOf(UnixToDateTime(UnixTime))) else InfoYear := '--';

             var PuanRengi: string;
              if JArray.Items[I].TryGetValue<Double>('rating', dVal) then
              begin
                InfoScore := IntToStr(Round(dVal)) + '/100';
                PuanRengi := PuanRengiBul(FloatToStr(dVal)); // Puan varsa rengi hesapla
              end
              else
              begin
                InfoScore := '--';
                PuanRengi := 'rgba(255,255,255,0.08)'; // Puan yoksa standart renkte kalsın
              end;


              if not JArray.Items[I].TryGetValue<string>('summary', InfoSummary) then
                InfoSummary := 'Bu oyun için bir açıklama bulunmuyor.';

              InfoGenre := '';
              if JArray.Items[I].TryGetValue<TJSONArray>('genres', GenreArr) then
              begin
                for J := 0 to GenreArr.Count - 1 do
                begin
                  if InfoGenre <> '' then InfoGenre := InfoGenre + ', ';
                  InfoGenre := InfoGenre + GenreArr.Items[J].GetValue<string>('name');
                end;
              end;
              if InfoGenre = '' then InfoGenre := '--';

              InfoPlatform := '';
              if JArray.Items[I].TryGetValue<TJSONArray>('platforms', PlatArr) then
              begin
                for J := 0 to PlatArr.Count - 1 do
                begin
                  if InfoPlatform <> '' then InfoPlatform := InfoPlatform + ', ';
                  InfoPlatform := InfoPlatform + PlatArr.Items[J].GetValue<string>('name');
                end;
              end;
              if InfoPlatform = '' then InfoPlatform := '--';

              InfoScreenshots := '';
              if JArray.Items[I].TryGetValue<TJSONArray>('screenshots', ScreenArr) then
              begin
                for J := 0 to Min(ScreenArr.Count - 1, 5) do
                begin
                  if InfoScreenshots <> '' then InfoScreenshots := InfoScreenshots + ',';
                  InfoScreenshots := InfoScreenshots + 'https://images.igdb.com/igdb/image/upload/t_screenshot_med/' + ScreenArr.Items[J].GetValue<string>('image_id') + '.jpg';
                end;
              end;

              GameName := StringReplace(GameName, #13#10, ' ', [rfReplaceAll]);
              GameName := StringReplace(GameName, #10, ' ', [rfReplaceAll]);
              GameName := StringReplace(GameName, '''', '&apos;', [rfReplaceAll]);
              GameName := StringReplace(GameName, '"', '&quot;', [rfReplaceAll]);

              InfoSummary := StringReplace(InfoSummary, #13#10, ' ', [rfReplaceAll]);
              InfoSummary := StringReplace(InfoSummary, #10, ' ', [rfReplaceAll]);
              InfoSummary := StringReplace(InfoSummary, '''', '&apos;', [rfReplaceAll]);
              InfoSummary := StringReplace(InfoSummary, '"', '&quot;', [rfReplaceAll]);

              InfoGenre := StringReplace(InfoGenre, '''', '&apos;', [rfReplaceAll]);
              InfoPlatform := StringReplace(InfoPlatform, '''', '&apos;', [rfReplaceAll]);
              InfoPlatform := StringReplace(InfoPlatform, '"', '&quot;', [rfReplaceAll]);

              if Length(InfoSummary) > 400 then
                InfoSummary := Copy(InfoSummary, 1, 400) + '...';

              if IsWishlist = 1 then
              begin
                Inc(CountWishlist);
                HTMLWishlist := HTMLWishlist +
                  '<div class="media-card wishlist-card" ' +
                  'data-notes="' + DBNot + '" ' +
                  'data-wishlist="1" ' +
                  'data-poster="' + ImgUrl + '" ' +
                  'data-score="' + InfoScore + '" ' +
                  'data-year="' + InfoYear + '" ' +
                  'data-genre="' + InfoGenre + '" ' +
                  'data-platform="' + InfoPlatform + '" ' +
                  'data-summary="' + InfoSummary + '" ' +
                  'data-screenshots="' + InfoScreenshots + '" ' +
                  'data-rawdate="' + RawDate + '" ' +
                  'data-finishdate="' + DisplayDate + '" ' +
                  'onclick="window.openGameDetail(this, ''' + CurrentGameID + ''')">' +
                  '  <div class="poster-bg" style="background-image: url(''' + ImgUrl + ''');"></div>' +
                  '  <div class="detail-trigger-btn"><i class="fa-solid fa-ellipsis-vertical"></i></div>' +
                  '  <div class="card-game-title">' + GameName + '</div>' +
                  '</div>';
              end
              else
              begin
                Inc(CountCompleted);
                HTMLCompleted := HTMLCompleted +
                  '<div class="media-card" ' +
                  'data-notes="' + DBNot + '" ' +
                  'data-wishlist="0" ' +
                  'data-poster="' + ImgUrl + '" ' +
                  'data-score="' + InfoScore + '" ' +
                  'data-year="' + InfoYear + '" ' +
                  'data-genre="' + InfoGenre + '" ' +
                  'data-platform="' + InfoPlatform + '" ' +
                  'data-summary="' + InfoSummary + '" ' +
                  'data-screenshots="' + InfoScreenshots + '" ' +
                  'data-rawdate="' + RawDate + '" ' +
                  'data-finishdate="' + DisplayDate + '" ' +
                  'onclick="window.openGameDetail(this, ''' + CurrentGameID + ''')">' +
                  '  <div class="poster-bg" style="background-image: url(''' + ImgUrl + ''');"></div>' +
                  '  <div class="detail-trigger-btn"><i class="fa-solid fa-ellipsis-vertical"></i></div>' +
                  '  <div class="card-game-title">' + GameName + '</div>' +
                  '</div>';
              end;
              Break;
            end;
          end;
          UniMainModule.KullaniciOyunlarTable.Next;
        end;

        if CountCompleted = 0 then
          HTMLCompleted := '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-blue); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">HENÜZ OYUN BİTİRMEDİN_</div><div class="add-card" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddGameModal(event, 0)"><i class="fa-solid fa-plus"></i></div></div>';

        if CountWishlist = 0 then
          HTMLWishlist := '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-pink); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">İSTEK LİSTEN BOŞ_</div><div class="add-card-pink" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddGameModal(event, 1)"><i class="fa-solid fa-plus"></i></div></div>';

        UniSession.AddJS('document.getElementById("completedGrid").innerHTML = `' + HTMLCompleted + '`;');
        UniSession.AddJS('document.getElementById("wishlistGrid").innerHTML = `' + HTMLWishlist + '`;');

      finally
        JArray.Free;
      end;
    end;
  finally
    IGDBClient.Free; IGDBReq.Free; IGDBRes.Free;
  end;
end;

end.
