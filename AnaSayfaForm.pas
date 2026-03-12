unit AnaSayfaForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniPanel, uniHTMLFrame,
  uniButton, uniBitBtn, REST.Client, REST.Types, System.JSON, System.NetEncoding,
  uniTimer, DateUtils, SecretConsts;

type
  TANA_SAYFA_FORM = class(TUniForm)
    UniTimer1: TUniTimer;
    UniHTMLFrame1: TUniHTMLFrame;
    procedure UniFormShow(Sender: TObject);
    procedure UniTimer1Timer(Sender: TObject);
    procedure UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
  private
    procedure DashboardDoldur;
  public
    { Public declarations }
  end;

function ANA_SAYFA_FORM: TANA_SAYFA_FORM;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, OyunlarimForm, FilmlerimForm, Main,
  DizilerimForm, KitaplarimForm, HesabimForm;

function ANA_SAYFA_FORM: TANA_SAYFA_FORM;
begin
  Result := TANA_SAYFA_FORM(UniMainModule.GetFormInstance(TANA_SAYFA_FORM));
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
  I: Integer; InTag: Boolean;
begin
  Result := ''; InTag := False;
  for I := 1 to Length(S) do
  begin
    if S[I] = '<' then InTag := True
    else if S[I] = '>' then InTag := False
    else if not InTag then Result := Result + S[I];
  end;
end;


procedure TANA_SAYFA_FORM.UniFormShow(Sender: TObject);
var
  KullaniciAdi, JSKodu: String;
begin
  UniSession.AddJS('setTimeout(typeWriter, 200);');
  KullaniciAdi := UniMainModule.GirisTable.FieldByName('kullanici_adi').Text;

  JSKodu := 'var checkExist = setInterval(function() { ' +
            '  var userSpan = document.getElementById("spanUser"); ' +
            '  if (userSpan) { ' +
            '    userSpan.innerText = "' + KullaniciAdi + '_"; ' +
            '    clearInterval(checkExist); ' +
            '  } ' +
            '}, 100);';

  UniSession.AddJS(JSKodu);
  UniTimer1.Enabled :=  True;
end;

procedure TANA_SAYFA_FORM.UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string; Params: TUniStrings);
var
  UserID, CurrentID, ImgUrl, TempImg, AccessToken: string;
  InfoTitle, InfoScore, InfoGenre, InfoYear, InfoExtra, InfoSummary, GelenKullanici: string;
  GameHTML, MovieHTML, TvHTML, BookHTML, IDsString, ImgID, PosterPath: string;
  RestClient: TRESTClient;
  RestReq: TRESTRequest;
  RestRes: TRESTResponse;
  TokenJSON, JSONObj, CoverObj, VolumeInfo, ImageLinks: TJSONObject;
  JArray, GenArr, PlatArr, AuthorsArr: TJSONArray;
  I, J, runtimeVal: Integer;
  dVal: Double;
  UnixTime: Int64;
  Tema: Boolean;
begin

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

  if EventName = 'gamesPageCall' then begin OYUNLARIM_FORM.Show; Self.Close; end;
  if EventName = 'tvShowsPageCall' then begin DIZILERIM_FORM.Show; Self.Close; end;
  if EventName = 'moviesPageCall' then begin FILMLERIM_FORM.Show; Self.Close; end;
  if EventName = 'booksPageCall' then begin KITAPLARIM_FORM.Show; Self.Close; end;
  if EventName = 'accountPageCall' then begin HESABIM_FORM.Show; Self.Close; end;

  UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

  if SameText(EventName, 'TemaGuncelleDB') then
  begin
    var GelenTema := Params.Values['tema_durumu'];
    if GelenTema = '1' then Tema := True else Tema := False;
    UniMainModule.GirisTable.Edit;
    UniMainModule.GirisTable.FieldByName('tema').AsBoolean := Tema;
    UniMainModule.GirisTable.Post;
  end

  // =========================================================
  // ZAR 1: OYUNLAR (IGDB) - RANDOM SEÇİCİ
  // =========================================================
  else if SameText(EventName, 'RandomGame') then
  begin
    UniMainModule.KullaniciOyunlarTable.Close;
    UniMainModule.KullaniciOyunlarTable.SQL.Text := 'SELECT TOP 1 api_oyun_id FROM kullanici_oyunlar WHERE kullanici_id = ' + UserID + ' and  istek_mi = 1 ORDER BY NEWID()';
    UniMainModule.KullaniciOyunlarTable.Open;

    if UniMainModule.KullaniciOyunlarTable.IsEmpty then begin MainForm.ShowSwal('Uyarı', 'Oyun Kütüphanenizde istek listeniz boş! Lütfen oynamak istediğiniz oyunları oraya ekleyin.', 'warning'); Exit; end;

    CurrentID := UniMainModule.KullaniciOyunlarTable.FieldByName('api_oyun_id').AsString;
    RestClient := TRESTClient.Create(''); RestReq := TRESTRequest.Create(nil); RestRes := TRESTResponse.Create(nil);
    try
      RestReq.Client := RestClient; RestReq.Response := RestRes;
      RestClient.BaseURL := 'https://id.twitch.tv/oauth2/token';
      RestReq.Method := rmPOST; RestReq.AddParameter('client_id', API_TWITCH_CLIENT_ID); RestReq.AddParameter('client_secret', API_TWITCH_SECRET); RestReq.AddParameter('grant_type', 'client_credentials');
      RestReq.Execute;

      if RestRes.StatusCode = 200 then
      begin
        TokenJSON := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject; AccessToken := TokenJSON.GetValue<string>('access_token'); TokenJSON.Free;
        RestClient.BaseURL := 'https://api.igdb.com/v4/games';
        RestReq.Params.Clear; RestReq.ClearBody; RestReq.Method := rmPOST;
        RestReq.AddAuthParameter('Authorization', 'Bearer ' + AccessToken, pkHTTPHEADER, [poDoNotEncode]);
        RestReq.AddAuthParameter('Client-ID', API_TWITCH_CLIENT_ID, pkHTTPHEADER, [poDoNotEncode]);
        RestReq.AddBody('where id = ' + CurrentID + '; fields name, cover.image_id, rating, genres.name, summary, first_release_date, platforms.name;', ctTEXT_PLAIN);
        RestReq.Execute;

        if RestRes.StatusCode = 200 then
        begin
          JArray := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONArray;
          try
            if (JArray <> nil) and (JArray.Count > 0) then
            begin
              JSONObj := JArray.Items[0] as TJSONObject;
              InfoTitle := JSONObj.GetValue<string>('name');

              if JSONObj.TryGetValue<TJSONObject>('cover', CoverObj) and CoverObj.TryGetValue<string>('image_id', ImgUrl) then
                ImgUrl := 'https://images.igdb.com/igdb/image/upload/t_cover_big/' + ImgUrl + '.jpg'
              else ImgUrl := GetPlaceholder(InfoTitle, 'OYUN', '05d9e8');

              if JSONObj.TryGetValue<Double>('rating', dVal) then InfoScore := IntToStr(Round(dVal)) + ' / 100' else InfoScore := 'Puan Yok';
              InfoGenre := '';
              if JSONObj.TryGetValue<TJSONArray>('genres', GenArr) then
                for J := 0 to GenArr.Count - 1 do begin if InfoGenre <> '' then InfoGenre := InfoGenre + ', '; InfoGenre := InfoGenre + GenArr.Items[J].GetValue<string>('name'); end;
              if InfoGenre = '' then InfoGenre := '--';
              if not JSONObj.TryGetValue<string>('summary', InfoSummary) then InfoSummary := 'Açıklama bulunamadı.';
              if JSONObj.TryGetValue<Int64>('first_release_date', UnixTime) then InfoYear := IntToStr(YearOf(UnixToDateTime(UnixTime))) else InfoYear := '--';
              InfoExtra := '';
              if JSONObj.TryGetValue<TJSONArray>('platforms', PlatArr) then
                for J := 0 to PlatArr.Count - 1 do begin if InfoExtra <> '' then InfoExtra := InfoExtra + ', '; InfoExtra := InfoExtra + PlatArr.Items[J].GetValue<string>('name'); end;
              if InfoExtra = '' then InfoExtra := '--';

              InfoTitle := StringReplace(InfoTitle, '''', '&apos;', [rfReplaceAll]); InfoTitle := StringReplace(InfoTitle, '"', '&quot;', [rfReplaceAll]);
              InfoGenre := StringReplace(InfoGenre, '''', '&apos;', [rfReplaceAll]); InfoGenre := StringReplace(InfoGenre, '"', '&quot;', [rfReplaceAll]);
              InfoExtra := StringReplace(InfoExtra, '''', '&apos;', [rfReplaceAll]); InfoExtra := StringReplace(InfoExtra, '"', '&quot;', [rfReplaceAll]);
              InfoSummary := StringReplace(InfoSummary, '''', '&apos;', [rfReplaceAll]); InfoSummary := StringReplace(InfoSummary, '"', '&quot;', [rfReplaceAll]);
              InfoSummary := StringReplace(InfoSummary, #13#10, '<br>', [rfReplaceAll]); InfoSummary := StringReplace(InfoSummary, #10, '<br>', [rfReplaceAll]);

              UniSession.AddJS('triggerRandomizerReveal(''' + ImgUrl + ''', ''' + InfoTitle + ''', ''' + InfoScore + ''', ''' + InfoGenre + ''', ''' + InfoYear + ''', ''' + InfoExtra + ''', ''' + InfoSummary + ''', ''game'');');
            end;
          finally JArray.Free; end;
        end;
      end;
    finally RestClient.Free; RestReq.Free; RestRes.Free; end;
  end

  // =========================================================
  // ZAR 2: FİLMLER (TMDB) - RANDOM SEÇİCİ
  // =========================================================
  else if SameText(EventName, 'RandomMovie') then
  begin
    UniMainModule.KullaniciFilmlerTable.Close;
    UniMainModule.KullaniciFilmlerTable.SQL.Text := 'SELECT TOP 1 api_film_id FROM kullanici_filmler WHERE kullanici_id = ' + UserID + ' and  istek_mi = 1 ORDER BY NEWID()';
    UniMainModule.KullaniciFilmlerTable.Open;
    if UniMainModule.KullaniciFilmlerTable.IsEmpty then begin MainForm.ShowSwal('Uyarı', 'Film Kütüphanenizde istek listeniz boş! Lütfen izlemek istediğiniz filmleri oraya ekleyin.', 'warning'); Exit; end;

    CurrentID := UniMainModule.KullaniciFilmlerTable.FieldByName('api_film_id').AsString;
    RestClient := TRESTClient.Create(''); RestReq := TRESTRequest.Create(nil); RestRes := TRESTResponse.Create(nil);
    try
      RestReq.Client := RestClient; RestReq.Response := RestRes;
      RestClient.BaseURL := 'https://api.themoviedb.org/3/movie/' + CurrentID;
      RestReq.Method := rmGET; RestReq.AddParameter('language', 'tr-TR'); RestReq.AddAuthParameter('Authorization', 'Bearer ' + API_TMDB_TOKEN, pkHTTPHEADER, [poDoNotEncode]);
      RestReq.Execute;

      if RestRes.StatusCode = 200 then
      begin
        JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
        try
          InfoTitle := JSONObj.GetValue<string>('title');
          if JSONObj.TryGetValue<string>('poster_path', ImgUrl) and (ImgUrl <> '') then ImgUrl := 'https://image.tmdb.org/t/p/w500' + ImgUrl else ImgUrl := GetPlaceholder(InfoTitle, 'FİLM', 'ff2a6d');

          if JSONObj.TryGetValue<Double>('vote_average', dVal) then InfoScore := IntToStr(Round(dVal*10)) + ' / 100' else InfoScore := 'Puan Yok';
          InfoGenre := '';
          if JSONObj.TryGetValue<TJSONArray>('genres', GenArr) then
            for J := 0 to GenArr.Count - 1 do begin if InfoGenre <> '' then InfoGenre := InfoGenre + ', '; InfoGenre := InfoGenre + GenArr.Items[J].GetValue<string>('name'); end;
          if InfoGenre = '' then InfoGenre := '--';
          if not JSONObj.TryGetValue<string>('overview', InfoSummary) or (InfoSummary = '') then InfoSummary := 'Açıklama bulunamadı.';
          if JSONObj.TryGetValue<string>('release_date', InfoYear) and (Length(InfoYear) >= 4) then InfoYear := Copy(InfoYear, 1, 4) else InfoYear := '--';
          if JSONObj.TryGetValue<Integer>('runtime', runtimeVal) and (runtimeVal > 0) then InfoExtra := IntToStr(runtimeVal div 60) + 's ' + IntToStr(runtimeVal mod 60) + 'dk' else InfoExtra := '--';

          InfoTitle := StringReplace(InfoTitle, '''', '&apos;', [rfReplaceAll]); InfoTitle := StringReplace(InfoTitle, '"', '&quot;', [rfReplaceAll]);
          InfoGenre := StringReplace(InfoGenre, '''', '&apos;', [rfReplaceAll]); InfoGenre := StringReplace(InfoGenre, '"', '&quot;', [rfReplaceAll]);
          InfoExtra := StringReplace(InfoExtra, '''', '&apos;', [rfReplaceAll]); InfoExtra := StringReplace(InfoExtra, '"', '&quot;', [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, '''', '&apos;', [rfReplaceAll]); InfoSummary := StringReplace(InfoSummary, '"', '&quot;', [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, #13#10, '<br>', [rfReplaceAll]); InfoSummary := StringReplace(InfoSummary, #10, '<br>', [rfReplaceAll]);
          UniSession.AddJS('triggerRandomizerReveal(''' + ImgUrl + ''', ''' + InfoTitle + ''', ''' + InfoScore + ''', ''' + InfoGenre + ''', ''' + InfoYear + ''', ''' + InfoExtra + ''', ''' + InfoSummary + ''', ''movie'');');
        finally JSONObj.Free; end;
      end;
    finally RestClient.Free; RestReq.Free; RestRes.Free; end;
  end

  // =========================================================
  // ZAR 3: DİZİLER (TMDB) - RANDOM SEÇİCİ
  // =========================================================
  else if SameText(EventName, 'RandomTv') then
  begin
    UniMainModule.KullaniciDizilerTable.Close;
    UniMainModule.KullaniciDizilerTable.SQL.Text := 'SELECT TOP 1 api_dizi_id FROM kullanici_diziler WHERE kullanici_id = ' + UserID + ' and  istek_mi = 1 ORDER BY NEWID()';
    UniMainModule.KullaniciDizilerTable.Open;
    if UniMainModule.KullaniciDizilerTable.IsEmpty then begin MainForm.ShowSwal('Uyarı', 'Dizi Kütüphanenizde istek listeniz boş! Lütfen izlemek istediğiniz dizilerini oraya ekleyin.', 'warning'); Exit; end;

    CurrentID := UniMainModule.KullaniciDizilerTable.FieldByName('api_dizi_id').AsString;
    RestClient := TRESTClient.Create(''); RestReq := TRESTRequest.Create(nil); RestRes := TRESTResponse.Create(nil);
    try
      RestReq.Client := RestClient; RestReq.Response := RestRes;
      RestClient.BaseURL := 'https://api.themoviedb.org/3/tv/' + CurrentID;
      RestReq.Method := rmGET; RestReq.AddParameter('language', 'tr-TR'); RestReq.AddAuthParameter('Authorization', 'Bearer ' + API_TMDB_TOKEN, pkHTTPHEADER, [poDoNotEncode]);
      RestReq.Execute;

      if RestRes.StatusCode = 200 then
      begin
        JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
        try
          InfoTitle := JSONObj.GetValue<string>('name');
          if JSONObj.TryGetValue<string>('poster_path', ImgUrl) and (ImgUrl <> '') then ImgUrl := 'https://image.tmdb.org/t/p/w500' + ImgUrl else ImgUrl := GetPlaceholder(InfoTitle, 'DİZİ', '05d9e8');

          if JSONObj.TryGetValue<Double>('vote_average', dVal) then InfoScore := IntToStr(Round(dVal*10)) + ' / 100' else InfoScore := 'Puan Yok';
          InfoGenre := '';
          if JSONObj.TryGetValue<TJSONArray>('genres', GenArr) then
            for J := 0 to GenArr.Count - 1 do begin if InfoGenre <> '' then InfoGenre := InfoGenre + ', '; InfoGenre := InfoGenre + GenArr.Items[J].GetValue<string>('name'); end;
          if InfoGenre = '' then InfoGenre := '--';
          if not JSONObj.TryGetValue<string>('overview', InfoSummary) or (InfoSummary = '') then InfoSummary := 'Açıklama bulunamadı.';
          if JSONObj.TryGetValue<string>('first_air_date', InfoYear) and (Length(InfoYear) >= 4) then InfoYear := Copy(InfoYear, 1, 4) else InfoYear := '--';
          if JSONObj.TryGetValue<Integer>('number_of_seasons', runtimeVal) then InfoExtra := IntToStr(runtimeVal) + ' Sezon' else InfoExtra := '--';

          InfoTitle := StringReplace(InfoTitle, '''', '&apos;', [rfReplaceAll]); InfoTitle := StringReplace(InfoTitle, '"', '&quot;', [rfReplaceAll]);
          InfoGenre := StringReplace(InfoGenre, '''', '&apos;', [rfReplaceAll]); InfoGenre := StringReplace(InfoGenre, '"', '&quot;', [rfReplaceAll]);
          InfoExtra := StringReplace(InfoExtra, '''', '&apos;', [rfReplaceAll]); InfoExtra := StringReplace(InfoExtra, '"', '&quot;', [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, '''', '&apos;', [rfReplaceAll]); InfoSummary := StringReplace(InfoSummary, '"', '&quot;', [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, #13#10, '<br>', [rfReplaceAll]); InfoSummary := StringReplace(InfoSummary, #10, '<br>', [rfReplaceAll]);
          UniSession.AddJS('triggerRandomizerReveal(''' + ImgUrl + ''', ''' + InfoTitle + ''', ''' + InfoScore + ''', ''' + InfoGenre + ''', ''' + InfoYear + ''', ''' + InfoExtra + ''', ''' + InfoSummary + ''', ''tv'');');
        finally JSONObj.Free; end;
      end;
    finally RestClient.Free; RestReq.Free; RestRes.Free; end;
  end

  // =========================================================
  // ZAR 4: KİTAPLAR (GOOGLE BOOKS) - RANDOM SEÇİCİ
  // =========================================================
  else if SameText(EventName, 'RandomBook') then
  begin
    UniMainModule.KullaniciKitaplarTable.Close;
    UniMainModule.KullaniciKitaplarTable.SQL.Text := 'SELECT TOP 1 api_kitap_id FROM kullanici_kitaplar WHERE kullanici_id = ' + UserID + ' and  istek_mi = 1 ORDER BY NEWID()';
    UniMainModule.KullaniciKitaplarTable.Open;
    if UniMainModule.KullaniciKitaplarTable.IsEmpty then begin MainForm.ShowSwal('Uyarı', 'Kitap Kütüphanenizde istek listeniz boş! Lütfen okumak istediğiniz kitapları oraya ekleyin.', 'warning'); Exit; end;

    CurrentID := Trim(UniMainModule.KullaniciKitaplarTable.FieldByName('api_kitap_id').AsString);
    RestClient := TRESTClient.Create(''); RestReq := TRESTRequest.Create(nil); RestRes := TRESTResponse.Create(nil);
    try
      RestReq.Client := RestClient; RestReq.Response := RestRes;
      RestClient.BaseURL := 'https://www.googleapis.com/books/v1/volumes/' + CurrentID;
      RestReq.Method := rmGET;

      // YENİ EKLENEN SATIR: Google API Key
      RestReq.AddParameter('key', API_GOOGLE_BOOKS_KEY);

      RestReq.Execute;

      if RestRes.StatusCode = 200 then
      begin
        JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
        try
          if JSONObj.TryGetValue<TJSONObject>('volumeInfo', VolumeInfo) then
          begin
            if not VolumeInfo.TryGetValue<string>('title', InfoTitle) then InfoTitle := 'Bilinmeyen Kitap';
            TempImg := '';
            if VolumeInfo.TryGetValue<TJSONObject>('imageLinks', ImageLinks) then ImageLinks.TryGetValue<string>('thumbnail', TempImg);
            if TempImg <> '' then ImgUrl := StringReplace(TempImg, 'http://', 'https://', [rfReplaceAll]) else ImgUrl := GetPlaceholder(InfoTitle, 'KİTAP', 'ff2a6d');

            InfoScore := 'Not/A';
            InfoGenre := '';
            if VolumeInfo.TryGetValue<TJSONArray>('categories', GenArr) and (GenArr.Count > 0) then InfoGenre := (GenArr.Items[0] as TJSONString).Value else InfoGenre := '--';
            if not VolumeInfo.TryGetValue<string>('description', InfoSummary) then InfoSummary := 'Açıklama bulunamadı.';
            InfoSummary := TemizleHTML(InfoSummary);
            if VolumeInfo.TryGetValue<string>('publishedDate', InfoYear) and (Length(InfoYear) >= 4) then InfoYear := Copy(InfoYear, 1, 4) else InfoYear := '--';
            InfoExtra := '';
            if VolumeInfo.TryGetValue<TJSONArray>('authors', AuthorsArr) and (AuthorsArr.Count > 0) then InfoExtra := (AuthorsArr.Items[0] as TJSONString).Value else InfoExtra := '--';

            InfoTitle := StringReplace(InfoTitle, '''', '&apos;', [rfReplaceAll]); InfoTitle := StringReplace(InfoTitle, '"', '&quot;', [rfReplaceAll]);
            InfoGenre := StringReplace(InfoGenre, '''', '&apos;', [rfReplaceAll]); InfoGenre := StringReplace(InfoGenre, '"', '&quot;', [rfReplaceAll]);
            InfoExtra := StringReplace(InfoExtra, '''', '&apos;', [rfReplaceAll]); InfoExtra := StringReplace(InfoExtra, '"', '&quot;', [rfReplaceAll]);
            InfoSummary := StringReplace(InfoSummary, '''', '&apos;', [rfReplaceAll]); InfoSummary := StringReplace(InfoSummary, '"', '&quot;', [rfReplaceAll]);
            InfoSummary := StringReplace(InfoSummary, #13#10, '<br>', [rfReplaceAll]); InfoSummary := StringReplace(InfoSummary, #10, '<br>', [rfReplaceAll]);
            UniSession.AddJS('triggerRandomizerReveal(''' + ImgUrl + ''', ''' + InfoTitle + ''', ''' + InfoScore + ''', ''' + InfoGenre + ''', ''' + InfoYear + ''', ''' + InfoExtra + ''', ''' + InfoSummary + ''', ''book'');');
          end;
        finally JSONObj.Free; end;
      end;
    finally RestClient.Free; RestReq.Free; RestRes.Free; end;
  end

  // =========================================================
  // ASENKRON GRID YÜKLEYİCİLER (PERFORMANS VE BAĞLANTI FİXİ)
  // =========================================================

  // ---> OYUNLAR (IGDB)
  else if SameText(EventName, 'LoadGamesGrid') then
  begin
    GameHTML := '<div class="media-card random-card-btn" onclick="ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, ''RandomGame'', [])"><i class="fa-solid fa-dice"></i><span>Bugün Ne<br><br>Oynamalıyım?</span></div>';
    RestClient := TRESTClient.Create(''); RestReq := TRESTRequest.Create(nil); RestRes := TRESTResponse.Create(nil);
    try
      try
        RestReq.Client := RestClient; RestReq.Response := RestRes;
        UniMainModule.KullaniciOyunlarTable.Close;
        UniMainModule.KullaniciOyunlarTable.SQL.Text := 'SELECT TOP 5 api_oyun_id FROM kullanici_oyunlar WHERE kullanici_id = ' + UserID + ' ORDER BY eklenme_tarihi DESC';
        UniMainModule.KullaniciOyunlarTable.Open;

        if UniMainModule.KullaniciOyunlarTable.IsEmpty then begin
          GameHTML := '<div class="empty-state-container" style="grid-column: 1 / -1;"><i class="fa-solid fa-gamepad empty-state-icon"></i><div class="empty-state-title">AĞA OYUN EKLENMEDİ_</div><div class="empty-state-desc">Görünüşe göre koleksiyonun henüz boş. Arşivini inşa etmeye başlamak için oyun kütüphanene git.</div><button class="empty-state-btn" onclick="ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, ''gamesPageCall'', [])"><i class="fa-solid fa-plus"></i> KÜTÜPHANEYE GİT</button></div>';
        end else begin
          IDsString := '(';
          while not UniMainModule.KullaniciOyunlarTable.Eof do begin
            IDsString := IDsString + UniMainModule.KullaniciOyunlarTable.FieldByName('api_oyun_id').AsString + ',';
            UniMainModule.KullaniciOyunlarTable.Next;
          end;
          Delete(IDsString, Length(IDsString), 1); IDsString := IDsString + ')';

          RestClient.BaseURL := 'https://id.twitch.tv/oauth2/token'; RestReq.Method := rmPOST; RestReq.AddParameter('client_id', API_TWITCH_CLIENT_ID); RestReq.AddParameter('client_secret', API_TWITCH_SECRET); RestReq.AddParameter('grant_type', 'client_credentials');
          RestReq.Execute;
          if RestRes.StatusCode = 200 then begin
            TokenJSON := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject; AccessToken := TokenJSON.GetValue<string>('access_token'); TokenJSON.Free;
            RestClient.BaseURL := 'https://api.igdb.com/v4/games'; RestReq.Params.Clear; RestReq.ClearBody; RestReq.Method := rmPOST;
            RestReq.AddAuthParameter('Authorization', 'Bearer ' + AccessToken, pkHTTPHEADER, [poDoNotEncode]); RestReq.AddAuthParameter('Client-ID', API_TWITCH_CLIENT_ID, pkHTTPHEADER, [poDoNotEncode]);
            RestReq.AddBody('where id = ' + IDsString + '; fields name, cover.image_id; limit 5;', ctTEXT_PLAIN); RestReq.Execute;
            if RestRes.StatusCode = 200 then begin
              JArray := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONArray;
              if Assigned(JArray) then begin
                for I := 0 to JArray.Count - 1 do begin
                  InfoTitle := JArray.Items[I].GetValue<string>('name');
                  if JArray.Items[I].TryGetValue<TJSONObject>('cover', CoverObj) and CoverObj.TryGetValue<string>('image_id', ImgID) then ImgUrl := 'https://images.igdb.com/igdb/image/upload/t_cover_big/' + ImgID + '.jpg' else ImgUrl := GetPlaceholder(InfoTitle, 'OYUN', '05d9e8');
                  GameHTML := GameHTML + '<div class="media-card" style="background: url(''' + ImgUrl + ''') center/cover no-repeat;" onclick="window.openGameDetail()"></div>';
                end; JArray.Free;
              end;
            end;
          end;
        end;
        UniSession.AddJS('var gg = document.getElementById("gameGrid"); if(gg) { gg.innerHTML = `' + GameHTML + '`; }');
      except
        on E: Exception do UniSession.AddJS('console.error("IGDB Hata: ' + E.Message + '");');
      end;
    finally
      RestClient.Free; RestReq.Free; RestRes.Free;
    end;
  end

  // ---> FİLMLER (TMDB) (WAF FİXİ UYGULANDI)
  else if SameText(EventName, 'LoadMoviesGrid') then
  begin
    MovieHTML := '<div class="media-card random-card-btn" onclick="ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, ''RandomMovie'', [])"><i class="fa-solid fa-shuffle"></i><span>Bugün Ne<br><br>İzlemeliyim?</span></div>';
    RestClient := TRESTClient.Create(''); RestReq := TRESTRequest.Create(nil); RestRes := TRESTResponse.Create(nil);
    try
      try
        RestReq.Client := RestClient; RestReq.Response := RestRes; RestReq.Method := rmGET;
        UniMainModule.KullaniciFilmlerTable.Close;
        UniMainModule.KullaniciFilmlerTable.SQL.Text := 'SELECT TOP 5 api_film_id FROM kullanici_filmler WHERE kullanici_id = ' + UserID + ' ORDER BY eklenme_tarihi DESC';
        UniMainModule.KullaniciFilmlerTable.Open;

        if UniMainModule.KullaniciFilmlerTable.IsEmpty then begin
          MovieHTML := '<div class="empty-state-container" style="grid-column: 1 / -1;"><i class="fa-solid fa-film empty-state-icon"></i><div class="empty-state-title">AĞA FİLM EKLENMEDİ_</div><div class="empty-state-desc">Görünüşe göre koleksiyonun henüz boş. Arşivini inşa etmeye başlamak için film kütüphanene git.</div><button class="empty-state-btn" onclick="ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, ''moviesPageCall'', [])"><i class="fa-solid fa-plus"></i> KÜTÜPHANEYE GİT</button></div>';
        end else begin
          while not UniMainModule.KullaniciFilmlerTable.Eof do begin
            CurrentID := UniMainModule.KullaniciFilmlerTable.FieldByName('api_film_id').AsString;
            RestClient.BaseURL := 'https://api.themoviedb.org/3/movie/' + CurrentID;

            RestReq.Params.Clear; // Önceki turdan kalan dil parametresini temizle
            RestReq.AddAuthParameter('Authorization', 'Bearer ' + API_TMDB_TOKEN, pkHTTPHEADER, [poDoNotEncode]); // Her döngüde Token'ı tekrar ekle!
            RestReq.AddParameter('language', 'tr-TR');

            RestReq.Execute;
            if RestRes.StatusCode = 200 then begin
              JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
              if Assigned(JSONObj) then begin
                InfoTitle := JSONObj.GetValue<string>('title');
                if JSONObj.TryGetValue<string>('poster_path', PosterPath) and (PosterPath <> '') then ImgUrl := 'https://image.tmdb.org/t/p/w500' + PosterPath else ImgUrl := GetPlaceholder(InfoTitle, 'FİLM', 'ff2a6d');
                MovieHTML := MovieHTML + '<div class="media-card" style="background: url(''' + ImgUrl + ''') center/cover no-repeat;" onclick="window.openMovieDetail()"></div>'; JSONObj.Free;
              end;
            end; UniMainModule.KullaniciFilmlerTable.Next;
          end;
        end;
        UniSession.AddJS('var mg = document.getElementById("movieGrid"); if(mg) { mg.innerHTML = `' + MovieHTML + '`; }');
      except
        on E: Exception do UniSession.AddJS('console.error("TMDB Film Hata: ' + E.Message + '");');
      end;
    finally
      RestClient.Free; RestReq.Free; RestRes.Free;
    end;
  end

  // ---> DİZİLER (TMDB) (WAF FİXİ UYGULANDI)
  else if SameText(EventName, 'LoadTvGrid') then
  begin
    TvHTML := '<div class="media-card random-card-btn" onclick="ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, ''RandomTv'', [])"><i class="fa-solid fa-tv"></i><span>Bugün Ne<br><br>İzlemeliyim?</span></div>';
    RestClient := TRESTClient.Create(''); RestReq := TRESTRequest.Create(nil); RestRes := TRESTResponse.Create(nil);
    try
      try
        RestReq.Client := RestClient; RestReq.Response := RestRes; RestReq.Method := rmGET;
        UniMainModule.KullaniciDizilerTable.Close;
        UniMainModule.KullaniciDizilerTable.SQL.Text := 'SELECT TOP 5 api_dizi_id FROM kullanici_diziler WHERE kullanici_id = ' + UserID + ' ORDER BY eklenme_tarihi DESC';
        UniMainModule.KullaniciDizilerTable.Open;

        if UniMainModule.KullaniciDizilerTable.IsEmpty then begin
          TvHTML := '<div class="empty-state-container" style="grid-column: 1 / -1;"><i class="fa-solid fa-tv empty-state-icon"></i><div class="empty-state-title">AĞA DİZİ EKLENMEDİ_</div><div class="empty-state-desc">Görünüşe göre koleksiyonun henüz boş. Arşivini inşa etmeye başlamak için dizi kütüphanene git.</div><button class="empty-state-btn" onclick="ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, ''tvShowsPageCall'', [])"><i class="fa-solid fa-plus"></i> KÜTÜPHANEYE GİT</button></div>';
        end else begin
          while not UniMainModule.KullaniciDizilerTable.Eof do begin
            CurrentID := UniMainModule.KullaniciDizilerTable.FieldByName('api_dizi_id').AsString;
            RestClient.BaseURL := 'https://api.themoviedb.org/3/tv/' + CurrentID;

            RestReq.Params.Clear; // Temizle
            RestReq.AddAuthParameter('Authorization', 'Bearer ' + API_TMDB_TOKEN, pkHTTPHEADER, [poDoNotEncode]); // Koru!
            RestReq.AddParameter('language', 'tr-TR');

            RestReq.Execute;
            if RestRes.StatusCode = 200 then begin
              JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
              if Assigned(JSONObj) then begin
                InfoTitle := JSONObj.GetValue<string>('name');
                if JSONObj.TryGetValue<string>('poster_path', PosterPath) and (PosterPath <> '') then ImgUrl := 'https://image.tmdb.org/t/p/w500' + PosterPath else ImgUrl := GetPlaceholder(InfoTitle, 'DİZİ', '05d9e8');
                TvHTML := TvHTML + '<div class="media-card" style="background: url(''' + ImgUrl + ''') center/cover no-repeat;" onclick="window.openTvShowDetail()"></div>'; JSONObj.Free;
              end;
            end; UniMainModule.KullaniciDizilerTable.Next;
          end;
        end;
        UniSession.AddJS('var tg = document.getElementById("tvGrid"); if(tg) { tg.innerHTML = `' + TvHTML + '`; }');
      except
        on E: Exception do UniSession.AddJS('console.error("TMDB Dizi Hata: ' + E.Message + '");');
      end;
    finally
      RestClient.Free; RestReq.Free; RestRes.Free;
    end;
  end

  // ---> KİTAPLAR (GOOGLE BOOKS)
  else if SameText(EventName, 'LoadBooksGrid') then
  begin
    BookHTML := '<div class="media-card random-card-btn" onclick="ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, ''RandomBook'', [])"><i class="fa-solid fa-book-open"></i><span>Sırada Hangi<br><br>Kitap Var?</span></div>';
    RestClient := TRESTClient.Create(''); RestReq := TRESTRequest.Create(nil); RestRes := TRESTResponse.Create(nil);
    try
      try
        RestReq.Client := RestClient; RestReq.Response := RestRes; RestReq.Method := rmGET;
        UniMainModule.KullaniciKitaplarTable.Close;
        UniMainModule.KullaniciKitaplarTable.SQL.Text := 'SELECT TOP 5 api_kitap_id FROM kullanici_kitaplar WHERE kullanici_id = ' + UserID + ' ORDER BY eklenme_tarihi DESC';
        UniMainModule.KullaniciKitaplarTable.Open;

        if UniMainModule.KullaniciKitaplarTable.IsEmpty then begin
          BookHTML := '<div class="empty-state-container" style="grid-column: 1 / -1;"><i class="fa-solid fa-book empty-state-icon"></i><div class="empty-state-title">AĞA KİTAP EKLENMEDİ_</div><div class="empty-state-desc">Görünüşe göre koleksiyonun henüz boş. Arşivini inşa etmeye başlamak için kitap kütüphanene git.</div><button class="empty-state-btn" onclick="ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, ''booksPageCall'', [])"><i class="fa-solid fa-plus"></i> KÜTÜPHANEYE GİT</button></div>';
        end else begin
          while not UniMainModule.KullaniciKitaplarTable.Eof do begin
            CurrentID := Trim(UniMainModule.KullaniciKitaplarTable.FieldByName('api_kitap_id').AsString);
            if CurrentID <> '' then begin
              try
                RestClient.BaseURL := 'https://www.googleapis.com/books/v1/volumes/' + CurrentID;

                RestReq.Params.Clear;
                // YENİ EKLENEN SATIR: Google API Key
                RestReq.AddParameter('key', API_GOOGLE_BOOKS_KEY);

                RestReq.Execute;
                if RestRes.StatusCode = 200 then begin
                  JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
                  if Assigned(JSONObj) then begin
                    if JSONObj.TryGetValue<TJSONObject>('volumeInfo', VolumeInfo) then begin
                      if not VolumeInfo.TryGetValue<string>('title', InfoTitle) then InfoTitle := 'Bilinmeyen Kitap';
                      TempImg := ''; if VolumeInfo.TryGetValue<TJSONObject>('imageLinks', ImageLinks) then ImageLinks.TryGetValue<string>('thumbnail', TempImg);
                      if TempImg <> '' then ImgUrl := StringReplace(TempImg, 'http://', 'https://', [rfReplaceAll]) else ImgUrl := GetPlaceholder(InfoTitle, 'KİTAP', 'ff2a6d');
                    end else ImgUrl := GetPlaceholder('Bilinmeyen Kitap', 'KİTAP', 'ff2a6d');
                    BookHTML := BookHTML + '<div class="media-card" style="background: url(''' + ImgUrl + ''') center/cover no-repeat;" onclick="window.openBookDetail(this, ''' + CurrentID + ''')"></div>'; JSONObj.Free;
                  end;
                end;
              except
                on E: Exception do UniSession.AddJS('console.error("Kitap HTTP Hata (' + CurrentID + '): ' + E.Message + '");');
              end;
            end; UniMainModule.KullaniciKitaplarTable.Next;
          end;
        end;
        UniSession.AddJS('var bg = document.getElementById("bookGrid"); if(bg) { bg.innerHTML = `' + BookHTML + '`; }');
      except
        on E: Exception do UniSession.AddJS('console.error("Google Books Veritabanı Hata: ' + E.Message + '");');
      end;
    finally
      RestClient.Free; RestReq.Free; RestRes.Free;
    end;
  end;

end;

procedure TANA_SAYFA_FORM.UniTimer1Timer(Sender: TObject);
begin
  UniTimer1.Enabled := False;

  var TemaDegeri := UniMainModule.GirisTable.FieldByName('tema').asBoolean;

  if TemaDegeri then
  begin
    UniSession.AddJS('document.body.classList.add("light-theme");');
    UniSession.AddJS('var cb = document.getElementById("checkboxTheme"); if(cb) cb.checked = true;');
    UniSession.AddJS('localStorage.setItem("bitd-theme", "light");');
  end
  else
  begin
    UniSession.AddJS('document.body.classList.remove("light-theme");');
    UniSession.AddJS('var cb = document.getElementById("checkboxTheme"); if(cb) cb.checked = false;');
    UniSession.AddJS('localStorage.setItem("bitd-theme", "dark");');
  end;

  DashboardDoldur;
end;

// =========================================================================
// YENİ MİMARİ: HIZLI YÜKLEME (UI KİLİTLENMESİ ÖNLENDİ)
// =========================================================================
procedure TANA_SAYFA_FORM.DashboardDoldur;
var
  UserID: string;
  TotC, WishC: Integer;
begin
  UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

  // SADECE HIZLI VERİTABANI İŞLEMLERİ (İSTATİSTİKLER) BURADA YAPILIR
  UniMainModule.GenelSorguTable.Close; UniMainModule.GenelSorguTable.SQL.Text := 'SELECT COUNT(*) as T, SUM(CAST(istek_mi as INT)) as W FROM kullanici_oyunlar WHERE kullanici_id = ' + UserID; UniMainModule.GenelSorguTable.Open;
  TotC := UniMainModule.GenelSorguTable.FieldByName('T').AsInteger; WishC := UniMainModule.GenelSorguTable.FieldByName('W').AsInteger;
  UniSession.AddJS('document.getElementById("statGameCount").innerText = "' + IntToStr(TotC) + '"; document.getElementById("statGameWish").innerText = "(+' + IntToStr(WishC) + ' İstek)";');

  UniMainModule.GenelSorguTable.Close; UniMainModule.GenelSorguTable.SQL.Text := 'SELECT COUNT(*) as T, SUM(CAST(istek_mi as INT)) as W FROM kullanici_filmler WHERE kullanici_id = ' + UserID; UniMainModule.GenelSorguTable.Open;
  TotC := UniMainModule.GenelSorguTable.FieldByName('T').AsInteger; WishC := UniMainModule.GenelSorguTable.FieldByName('W').AsInteger;
  UniSession.AddJS('document.getElementById("statMovieCount").innerText = "' + IntToStr(TotC) + '"; document.getElementById("statMovieWish").innerText = "(+' + IntToStr(WishC) + ' İstek)";');

  UniMainModule.GenelSorguTable.Close; UniMainModule.GenelSorguTable.SQL.Text := 'SELECT COUNT(*) as T, SUM(CAST(istek_mi as INT)) as W FROM kullanici_diziler WHERE kullanici_id = ' + UserID; UniMainModule.GenelSorguTable.Open;
  TotC := UniMainModule.GenelSorguTable.FieldByName('T').AsInteger; WishC := UniMainModule.GenelSorguTable.FieldByName('W').AsInteger;
  UniSession.AddJS('document.getElementById("statTvCount").innerText = "' + IntToStr(TotC) + '"; document.getElementById("statTvWish").innerText = "(+' + IntToStr(WishC) + ' İstek)";');

  UniMainModule.GenelSorguTable.Close; UniMainModule.GenelSorguTable.SQL.Text := 'SELECT COUNT(*) as T, SUM(CAST(istek_mi as INT)) as W FROM kullanici_kitaplar WHERE kullanici_id = ' + UserID; UniMainModule.GenelSorguTable.Open;
  TotC := UniMainModule.GenelSorguTable.FieldByName('T').AsInteger; WishC := UniMainModule.GenelSorguTable.FieldByName('W').AsInteger;
  UniSession.AddJS('document.getElementById("statBookCount").innerText = "' + IntToStr(TotC) + '"; document.getElementById("statBookWish").innerText = "(+' + IntToStr(WishC) + ' İstek)";');

  // Yükleme ekranını hemen kapatıyoruz çünkü arayüz hazır
  UniSession.AddJS('setTimeout(function(){ var l = document.getElementById("globalLoader"); if(l) { l.style.opacity = "0"; setTimeout(function(){ l.style.display = "none"; }, 500); } }, 300);');

  // ASENKRON TETİKLEYİCİLER:
  // Ana ekran kilitlenmeden arka planda API isteklerini başlatır ve bittikçe yerlerine oturtur.
  UniSession.AddJS('ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, "LoadGamesGrid", []);');
  UniSession.AddJS('ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, "LoadMoviesGrid", []);');
  UniSession.AddJS('ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, "LoadTvGrid", []);');
  UniSession.AddJS('ajaxRequest(ANA_SAYFA_FORM.UniHTMLFrame1, "LoadBooksGrid", []);');
end;

end.
