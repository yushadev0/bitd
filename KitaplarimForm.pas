unit KitaplarimForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniPanel, uniHTMLFrame,
  REST.Client, REST.Types, System.JSON, System.NetEncoding, Math, uniTimer,
  Data.DB;

type
  TKITAPLARIM_FORM = class(TUniForm)
    UniHTMLFrame1: TUniHTMLFrame;
    UniTimer1: TUniTimer;
    procedure UniFormShow(Sender: TObject);
    procedure UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
    procedure UniTimer1Timer(Sender: TObject);
  private
    procedure KitapAraAPI(Kelime, Hedef: string);
    procedure KutuphaneyiDoldur;
  public
    { Public declarations }
  end;

function KITAPLARIM_FORM: TKITAPLARIM_FORM;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, AnaSayfaForm, DizilerimForm, FilmlerimForm,
  OyunlarimForm, Main, HesabimForm;

function KITAPLARIM_FORM: TKITAPLARIM_FORM;
begin
  Result := TKITAPLARIM_FORM(UniMainModule.GetFormInstance(TKITAPLARIM_FORM));
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

// =========================================================================
// HTML TAG TEMİZLEYİCİ
// =========================================================================
function TemizleHTML(const S: string): string;
var
  I: Integer;
  InTag: Boolean;
begin
  Result := '';
  InTag := False;
  for I := 1 to Length(S) do
  begin
    if S[I] = '<' then InTag := True
    else if S[I] = '>' then InTag := False
    else if not InTag then Result := Result + S[I];
  end;
end;

procedure TKITAPLARIM_FORM.UniFormShow(Sender: TObject);
var
  KullaniciAdi, JSKodu: String;
begin
  KullaniciAdi := UniMainModule.GirisTable.FieldByName('kullanici_adi').Text;

  JSKodu := 'var checkExist = setInterval(function() { ' +
    '  var userSpan = document.getElementById("spanUser"); ' +
    '  if (userSpan) { ' + '    userSpan.innerText = "' + KullaniciAdi + '_"; '
    + '    clearInterval(checkExist); ' + '  } ' + '}, 100);';

  UniSession.AddJS(JSKodu);

  UniTimer1.Enabled := True;
end;

procedure TKITAPLARIM_FORM.KutuphaneyiDoldur;
var
  HTMLCompleted, HTMLWishlist: string;
  CountCompleted, CountWishlist: Integer;
  ResultHTML, CurrentBookID, UserID: string;
  BookTitle, ImgUrl, TempImg, InfoSummary, EncodedTitle: string;
  InfoAuthor, InfoYear, InfoGenre, InfoPages, PreviewLink: string;
  RestClient: TRESTClient;
  RestReq: TRESTRequest;
  RestRes: TRESTResponse;
  JSONObj, VolumeInfo, ImageLinks: TJSONObject;
  AuthorsArr, CategoriesArr: TJSONArray;
  pCount: Integer;
  IsWishlist: Integer;
  RawDate, DisplayDate: string;
  DBTarih, Y, M, D, ExtraClass, DBNot: string;
begin
  UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

  UniMainModule.KullaniciKitaplarTable.Close;
  UniMainModule.KullaniciKitaplarTable.SQL.Text :=
    'SELECT api_kitap_id, istek_mi, bitirme_tarihi, kisisel_not FROM kullanici_kitaplar WHERE kullanici_id = '
    + UserID + ' ORDER BY eklenme_tarihi DESC';
  UniMainModule.KullaniciKitaplarTable.Open;

  if UniMainModule.KullaniciKitaplarTable.IsEmpty then
  begin
    HTMLCompleted :=
      '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-blue); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">HENÜZ KİTAP BİTİRMEDİN_</div><div class="add-card" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddBookModal(event, 0)"><i class="fa-solid fa-plus"></i></div></div>';
    HTMLWishlist :=
      '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-pink); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">OKUNACAKLAR LİSTEN BOŞ_</div><div class="add-card-pink" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddBookModal(event, 1)"><i class="fa-solid fa-plus"></i></div></div>';

    UniSession.AddJS('document.getElementById("completedGrid").innerHTML = `' + HTMLCompleted + '`;');
    UniSession.AddJS('document.getElementById("wishlistGrid").innerHTML = `' + HTMLWishlist + '`;');
    Exit;
  end;

  RestClient := TRESTClient.Create('');
  RestReq := TRESTRequest.Create(nil);
  RestRes := TRESTResponse.Create(nil);
  try
    RestReq.Client := RestClient;
    RestReq.Response := RestRes;
    RestReq.Method := rmGET;

    CountCompleted := 0;
    CountWishlist := 0;
    HTMLCompleted := '<div class="media-card add-card" onclick="window.openAddBookModal(event, 0)"><i class="fa-solid fa-plus"></i></div>';
    HTMLWishlist := '<div class="media-card add-card-pink" onclick="window.openAddBookModal(event, 1)"><i class="fa-solid fa-plus"></i></div>';

    UniMainModule.KullaniciKitaplarTable.First;
    while not UniMainModule.KullaniciKitaplarTable.Eof do
    begin
      try
        CurrentBookID := UniMainModule.KullaniciKitaplarTable.FieldByName('api_kitap_id').AsString;

        if CurrentBookID <> '' then
        begin
          DBNot := UniMainModule.KullaniciKitaplarTable.FieldByName('kisisel_not').AsString;
          DBNot := StringReplace(DBNot, '''', '&apos;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, '"', '&quot;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, #13#10, '&#10;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, #10, '&#10;', [rfReplaceAll]);

          if UniMainModule.KullaniciKitaplarTable.FieldByName('istek_mi').AsBoolean then
            IsWishlist := 1 else IsWishlist := 0;

          if not UniMainModule.KullaniciKitaplarTable.FieldByName('bitirme_tarihi').IsNull then
          begin
            DBTarih := Trim(UniMainModule.KullaniciKitaplarTable.FieldByName('bitirme_tarihi').AsString);
            if (Length(DBTarih) >= 10) and (DBTarih[5] = '-') and (DBTarih[8] = '-') then
            begin
              Y := Copy(DBTarih, 1, 4); M := Copy(DBTarih, 6, 2); D := Copy(DBTarih, 9, 2);
              RawDate := Y + '-' + M + '-' + D; DisplayDate := D + '.' + M + '.' + Y;
            end
            else
            begin
              try
                RawDate := FormatDateTime('yyyy-mm-dd', UniMainModule.KullaniciKitaplarTable.FieldByName('bitirme_tarihi').AsDateTime);
                DisplayDate := FormatDateTime('dd.mm.yyyy', UniMainModule.KullaniciKitaplarTable.FieldByName('bitirme_tarihi').AsDateTime);
              except
                RawDate := ''; DisplayDate := 'Belirtilmedi';
              end;
            end;
          end else begin RawDate := ''; DisplayDate := 'Belirtilmedi'; end;

          RestClient.BaseURL := 'https://www.googleapis.com/books/v1/volumes/' + CurrentBookID;
          RestReq.Execute;

          if RestRes.StatusCode = 200 then
          begin
            JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
            if Assigned(JSONObj) then
            begin
              try
                if JSONObj.TryGetValue<TJSONObject>('volumeInfo', VolumeInfo) then
                begin
                  if not VolumeInfo.TryGetValue<string>('title', BookTitle) then BookTitle := 'Bilinmeyen Kitap';

                  if VolumeInfo.TryGetValue<TJSONArray>('authors', AuthorsArr) and (AuthorsArr.Count > 0) then
                    InfoAuthor := (AuthorsArr.Items[0] as TJSONString).Value else InfoAuthor := '--';

                  if VolumeInfo.TryGetValue<string>('publishedDate', InfoYear) and (Length(InfoYear) >= 4) then
                    InfoYear := Copy(InfoYear, 1, 4) else InfoYear := '--';

                  if VolumeInfo.TryGetValue<Integer>('pageCount', pCount) then
                    InfoPages := IntToStr(pCount) + ' Sayfa' else InfoPages := '--';

                  if VolumeInfo.TryGetValue<TJSONArray>('categories', CategoriesArr) and (CategoriesArr.Count > 0) then
                    InfoGenre := (CategoriesArr.Items[0] as TJSONString).Value else InfoGenre := '--';

                  if not VolumeInfo.TryGetValue<string>('description', InfoSummary) then InfoSummary := 'Açıklama bulunamadı.';
                  if not VolumeInfo.TryGetValue<string>('previewLink', PreviewLink) then PreviewLink := '';

                  TempImg := '';
                  if VolumeInfo.TryGetValue<TJSONObject>('imageLinks', ImageLinks) then
                    ImageLinks.TryGetValue<string>('thumbnail', TempImg);

                  if TempImg <> '' then
                    ImgUrl := StringReplace(TempImg, 'http://', 'https://', [rfReplaceAll])
                  else
                    ImgUrl := GetPlaceholder(BookTitle, 'KİTAP', 'ff2a6d');

                  BookTitle := StringReplace(BookTitle, '''', '&apos;', [rfReplaceAll]);
                  BookTitle := StringReplace(BookTitle, '"', '&quot;', [rfReplaceAll]);

                  InfoSummary := TemizleHTML(InfoSummary);
                  InfoSummary := StringReplace(InfoSummary, #13#10, ' ', [rfReplaceAll]);
                  InfoSummary := StringReplace(InfoSummary, #10, ' ', [rfReplaceAll]);
                  InfoSummary := StringReplace(InfoSummary, '''', '&apos;', [rfReplaceAll]);
                  InfoSummary := StringReplace(InfoSummary, '"', '&quot;', [rfReplaceAll]);

                  if IsWishlist = 1 then ExtraClass := ' wishlist-card' else ExtraClass := '';

                  ResultHTML := '<div class="media-card' + ExtraClass + '" ' +
                    'data-wishlist="' + IntToStr(IsWishlist) + '" ' +
                    'data-notes="' + DBNot + '" ' + 'data-poster="' + ImgUrl + '" ' +
                    'data-author="' + InfoAuthor + '" ' + 'data-year="' + InfoYear + '" ' +
                    'data-genre="' + InfoGenre + '" ' + 'data-pages="' + InfoPages + '" ' +
                    'data-summary="' + InfoSummary + '" ' + 'data-preview="' + PreviewLink + '" ' +
                    'data-rawdate="' + RawDate + '" ' + 'data-finishdate="' + DisplayDate + '" ' +
                    'onclick="window.openBookDetail(this, ''' + CurrentBookID + ''')">' +
                    '  <div class="poster-bg" style="background-image: url(''' + ImgUrl + ''');"></div>' +
                    '  <div class="detail-trigger-btn"><i class="fa-solid fa-ellipsis-vertical"></i></div>' +
                    '  <div class="card-game-title">' + BookTitle + '</div>' + '</div>';

                  if IsWishlist = 1 then begin Inc(CountWishlist); HTMLWishlist := HTMLWishlist + ResultHTML; end
                  else begin Inc(CountCompleted); HTMLCompleted := HTMLCompleted + ResultHTML; end;
                end;
              finally
                JSONObj.Free;
              end;
            end;
          end
          else
          begin
            UniSession.AddJS('console.warn("Kitap ID ' + CurrentBookID + ' çekilemedi. Status: ' + IntToStr(RestRes.StatusCode) + '");');
          end;
        end;
      except
        on E: Exception do UniSession.AddJS('console.error("Kitap Hata (' + CurrentBookID + '): ' + E.Message + '");');
      end;

      UniMainModule.KullaniciKitaplarTable.Next;
    end;

    if CountCompleted = 0 then HTMLCompleted := '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-blue); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">HENÜZ KİTAP BİTİRMEDİN_</div><div class="add-card" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddBookModal(event, 0)"><i class="fa-solid fa-plus"></i></div></div>';
    if CountWishlist = 0 then HTMLWishlist := '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-pink); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">OKUNACAKLAR LİSTEN BOŞ_</div><div class="add-card-pink" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddBookModal(event, 1)"><i class="fa-solid fa-plus"></i></div></div>';

    UniSession.AddJS('document.getElementById("completedGrid").innerHTML = `' + HTMLCompleted + '`;');
    UniSession.AddJS('document.getElementById("wishlistGrid").innerHTML = `' + HTMLWishlist + '`;');

  finally
    RestClient.Free; RestReq.Free; RestRes.Free;
  end;
end;

procedure TKITAPLARIM_FORM.KitapAraAPI(Kelime, Hedef: string);
var
  RestClient: TRESTClient;
  RestReq: TRESTRequest;
  RestRes: TRESTResponse;
  JSONObj, ItemObj, VolumeInfo, ImageLinks: TJSONObject;
  JArray, AuthorsArr, CategoriesArr: TJSONArray;
  I, pCount: Integer;
  BookID, BookTitle, ImgUrl, TempImg, ResultHTML: string;
  InfoAuthor, InfoYear, InfoGenre, InfoPages: string;
  EkleButonHTML: string;
begin
  RestClient := TRESTClient.Create('https://www.googleapis.com/books/v1/volumes');
  RestReq := TRESTRequest.Create(nil);
  RestRes := TRESTResponse.Create(nil);
  try
    RestReq.Client := RestClient; RestReq.Response := RestRes; RestReq.Method := rmGET;
    RestReq.AddParameter('q', Kelime); RestReq.AddParameter('langRestrict', 'tr'); RestReq.AddParameter('maxResults', '10');
    RestReq.Execute;

    if RestRes.StatusCode = 200 then
    begin
      JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
      try
        if JSONObj.TryGetValue<TJSONArray>('items', JArray) then
        begin
          ResultHTML := '';
          for I := 0 to JArray.Count - 1 do
          begin
            ItemObj := JArray.Items[I] as TJSONObject;
            BookID := ItemObj.GetValue<string>('id');

            if ItemObj.TryGetValue<TJSONObject>('volumeInfo', VolumeInfo) then
            begin
              if not VolumeInfo.TryGetValue<string>('title', BookTitle) then BookTitle := 'Bilinmeyen Kitap';

              if VolumeInfo.TryGetValue<TJSONArray>('authors', AuthorsArr) and (AuthorsArr.Count > 0) then
                InfoAuthor := (AuthorsArr.Items[0] as TJSONString).Value else InfoAuthor := '--';

              if VolumeInfo.TryGetValue<string>('publishedDate', InfoYear) and (Length(InfoYear) >= 4) then
                InfoYear := Copy(InfoYear, 1, 4) else InfoYear := '--';

              if VolumeInfo.TryGetValue<Integer>('pageCount', pCount) then
                InfoPages := IntToStr(pCount) + ' Sayfa' else InfoPages := '--';

              if VolumeInfo.TryGetValue<TJSONArray>('categories', CategoriesArr) and (CategoriesArr.Count > 0) then
                InfoGenre := (CategoriesArr.Items[0] as TJSONString).Value else InfoGenre := '--';

              // --- YENİ YER TUTUCU (PLACEHOLDER) UYARLAMASI ---
              TempImg := '';
              if VolumeInfo.TryGetValue<TJSONObject>('imageLinks', ImageLinks) then
                ImageLinks.TryGetValue<string>('thumbnail', TempImg);

              if TempImg <> '' then
                ImgUrl := StringReplace(TempImg, 'http://', 'https://', [rfReplaceAll])
              else
                ImgUrl := GetPlaceholder(BookTitle, 'KİTAP', 'ff2a6d');

              BookTitle := StringReplace(BookTitle, '''', '&apos;', [rfReplaceAll]);
              BookTitle := StringReplace(BookTitle, '"', '&quot;', [rfReplaceAll]);

              if Hedef = '1' then
                EkleButonHTML := '<button class="acc-btn acc-btn-wish" onclick="event.stopPropagation(); ajaxRequest(KITAPLARIM_FORM.UniHTMLFrame1, ''KitapEkleDB'', [''kitap_id=' + BookID + ''', ''istek=' + Hedef + ''']);"><i class="fa-solid fa-heart"></i> LİSTEYE EKLE</button>'
              else
                EkleButonHTML := '<button class="acc-btn acc-btn-lib" onclick="event.stopPropagation(); ajaxRequest(KITAPLARIM_FORM.UniHTMLFrame1, ''KitapEkleDB'', [''kitap_id=' + BookID + ''', ''istek=' + Hedef + ''']);"><i class="fa-solid fa-check-double"></i> OKUNDU OLARAK EKLE</button>';

              ResultHTML := ResultHTML + '<div class="accordion-item">' +
                '  <div class="accordion-header" onclick="window.toggleAccordion(this)">' +
                '    <img src="' + ImgUrl + '" class="accordion-poster">' +
                '    <div class="accordion-title">' + BookTitle + '<br><span style="font-size:0.6rem; color:var(--neon-pink);">' + InfoAuthor + '</span></div>' +
                '    <i class="fa-solid fa-chevron-down accordion-icon"></i>' +
                '  </div>' + '  <div class="accordion-content">' +
                '    <div class="acc-details">' +
                '      <div class="acc-detail-item"><strong>YAYIN YILI</strong><span>' + InfoYear + '</span></div>' +
                '      <div class="acc-detail-item"><strong>TÜR</strong><span>' + InfoGenre + '</span></div>' +
                '      <div class="acc-detail-item" style="grid-column: 1 / -1;"><strong>SAYFA</strong><span>' + InfoPages + '</span></div>' + '    </div>' +
                '    <div class="acc-actions">' + EkleButonHTML + '    </div>' + '  </div>' + '</div>';
            end;
          end;
          UniSession.AddJS('document.getElementById("searchResults").innerHTML = `' + ResultHTML + '`;');
        end else
          UniSession.AddJS('document.getElementById("searchResults").innerHTML = ''<div style="color:var(--neon-pink); text-align:center;">Veritabanında eşleşen kitap bulunamadı.</div>'';');
      finally JSONObj.Free; end;
    end;
  finally RestClient.Free; RestReq.Free; RestRes.Free; end;
end;

procedure TKITAPLARIM_FORM.UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string; Params: TUniStrings);
var
  SecilenKitapID, UserID, GelenIstekMi, YeniDurum, GelenTarih, ArananKelime, ArananHedef: string;
begin
  if EventName = 'homePageCall' then begin ANA_SAYFA_FORM.Show; Self.Close; end;
  if EventName = 'gamesPageCall' then begin OYUNLARIM_FORM.Show; Self.Close; end;
  if EventName = 'moviesPageCall' then begin FILMLERIM_FORM.Show; Self.Close; end;
  if EventName = 'tvShowsPageCall' then begin DIZILERIM_FORM.Show; Self.Close; end;
        if EventName = 'accountPageCall' then begin HESABIM_FORM.Show; Self.Close; end;

  if EventName = 'DoLogout' then
  begin
    UniApplication.Cookies.SetCookie('BITD_USER', '', Now - 1);
    UniApplication.Cookies.SetCookie('BITD_TOKEN', '', Now - 1);
    UniMainModule.UpdateQuery.SQL.Text := 'UPDATE kullanicilar SET RememberToken = NULL WHERE kullanici_adi = :p_kullanici';
    UniMainModule.UpdateQuery.ParamByName('p_kullanici').AsString := UniMainModule.GirisTable.FieldByName('kullanici_adi').Text;
    UniMainModule.UpdateQuery.Execute;
    UniApplication.Restart;
  end;

  if SameText(EventName, 'KitapAra') then
  begin
    ArananKelime := Params.Values['kelime']; ArananHedef := Params.Values['hedef'];
    if Trim(ArananKelime) <> '' then KitapAraAPI(ArananKelime, ArananHedef);
  end;

  if SameText(EventName, 'KitapEkleDB') then
  begin
    SecilenKitapID := Params.Values['kitap_id']; GelenIstekMi := Params.Values['istek']; UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    if GelenIstekMi = '' then GelenIstekMi := '0';

    UniMainModule.GenelSorguTable.Close;
    UniMainModule.GenelSorguTable.SQL.Text := 'SELECT id FROM kullanici_kitaplar WHERE kullanici_id = ' + UserID + ' AND api_kitap_id = ' + QuotedStr(SecilenKitapID);
    UniMainModule.GenelSorguTable.Open;

    if not UniMainModule.GenelSorguTable.IsEmpty then
    begin
      UniSession.AddJS('var m = document.querySelector("#addBookModal .modal-content"); if (m) { m.classList.remove("shake-error"); void m.offsetWidth; m.classList.add("shake-error"); }');
      MainForm.ShowSwalMini('Bu kitap zaten listenizde mevcut!', 'warning');
    end else begin
      UniMainModule.KullaniciKitaplarTable.Close;
      if GelenIstekMi = '0' then
        UniMainModule.KullaniciKitaplarTable.SQL.Text := 'INSERT INTO kullanici_kitaplar (kullanici_id, api_kitap_id, istek_mi, bitirme_tarihi, eklenme_tarihi) VALUES (' + UserID + ', ' + QuotedStr(SecilenKitapID) + ', 0, ''' + FormatDateTime('yyyy-mm-dd', Now) + ''', CURRENT_TIMESTAMP)'
      else
        UniMainModule.KullaniciKitaplarTable.SQL.Text := 'INSERT INTO kullanici_kitaplar (kullanici_id, api_kitap_id, istek_mi, eklenme_tarihi) VALUES (' + UserID + ', ' + QuotedStr(SecilenKitapID) + ', 1, CURRENT_TIMESTAMP)';
      UniMainModule.KullaniciKitaplarTable.ExecSQL;
      UniSession.AddJS('window.closeAddBookModal(null);'); MainForm.ShowSwalMini('Kitap başarıyla eklendi!', 'success'); KutuphaneyiDoldur;
    end;
  end;

  if SameText(EventName, 'KitapGuncelleDB') then
  begin
    SecilenKitapID := Params.Values['kitap_id'];
    YeniDurum := Params.Values['yeni_durum']; // 1: İstek Listesi, 0: Okunanlar
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

    UniMainModule.KullaniciKitaplarTable.Close;

    // EĞER İSTEK LİSTESİNE GERİ ALINIYORSA (YeniDurum = 1)
    if YeniDurum = '1' then
    begin
      // Tarihi NULL yapıyoruz (Sıfırlıyoruz)
      UniMainModule.KullaniciKitaplarTable.SQL.Text :=
        'UPDATE kullanici_kitaplar SET istek_mi = 1, bitirme_tarihi = NULL ' +
        'WHERE kullanici_id = ' + UserID + ' AND api_kitap_id = ' + QuotedStr(SecilenKitapID);
      UniMainModule.KullaniciKitaplarTable.ExecSQL;
    end
    else
    // EĞER OKUNANLARA EKLENİYORSA (YeniDurum = 0)
    begin
      // Tarihi bugünün tarihi yapıyoruz
      UniMainModule.KullaniciKitaplarTable.SQL.Text :=
        'UPDATE kullanici_kitaplar SET istek_mi = 0, bitirme_tarihi = ''' + FormatDateTime('yyyy-mm-dd', Now) + ''' ' +
        'WHERE kullanici_id = ' + UserID + ' AND api_kitap_id = ' + QuotedStr(SecilenKitapID);
      UniMainModule.KullaniciKitaplarTable.ExecSQL;
    end;

    KutuphaneyiDoldur;
  end;

  if SameText(EventName, 'KitapTarihGuncelleDB') then
  begin
    SecilenKitapID := Params.Values['kitap_id']; GelenTarih := Params.Values['tarih']; UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    UniMainModule.KullaniciKitaplarTable.Close;
    UniMainModule.KullaniciKitaplarTable.SQL.Text := 'UPDATE kullanici_kitaplar SET bitirme_tarihi = ' + QuotedStr(GelenTarih) + ' WHERE kullanici_id = ' + UserID + ' AND api_kitap_id = ' + QuotedStr(SecilenKitapID);
    UniMainModule.KullaniciKitaplarTable.ExecSQL;
    MainForm.ShowSwalMini('Tarih güncellendi!', 'success'); KutuphaneyiDoldur;
  end;

  if SameText(EventName, 'KitapSilDB') then
  begin
    SecilenKitapID := Params.Values['kitap_id']; UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    UniMainModule.KullaniciKitaplarTable.Close;
    UniMainModule.KullaniciKitaplarTable.SQL.Text := 'DELETE FROM kullanici_kitaplar WHERE kullanici_id = ' + UserID + ' AND api_kitap_id = ' + QuotedStr(SecilenKitapID);
    UniMainModule.KullaniciKitaplarTable.ExecSQL;
    MainForm.ShowSwalMini('Kitap kütüphaneden kaldırıldı!', 'info'); KutuphaneyiDoldur;
  end;

  if SameText(EventName, 'KitapNotKaydetDB') then
  begin
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    var GelenKitapID := Params.Values['kitap_id'];
    var GelenNot := Params.Values['not'];

    UniMainModule.UpdateQuery.Close;
    UniMainModule.UpdateQuery.SQL.Text :=
      'UPDATE kullanici_kitaplar SET kisisel_not = :p_not ' +
      'WHERE kullanici_id = :p_uid AND api_kitap_id = :p_oid';

    UniMainModule.UpdateQuery.ParamByName('p_not').AsString := GelenNot;
    UniMainModule.UpdateQuery.ParamByName('p_uid').AsString := UserID;
    UniMainModule.UpdateQuery.ParamByName('p_oid').AsString := GelenKitapID;
    UniMainModule.UpdateQuery.ExecSQL;
  end;

end;

procedure TKITAPLARIM_FORM.UniTimer1Timer(Sender: TObject);
begin
  UniTimer1.Enabled := False; KutuphaneyiDoldur;
end;

end.
