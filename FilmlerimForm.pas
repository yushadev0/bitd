unit FilmlerimForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniPanel, uniHTMLFrame,
  REST.Client, REST.Types, System.JSON, System.NetEncoding, Math, uniTimer, SecretConsts;

type
  TFILMLERIM_FORM = class(TUniForm)
    UniHTMLFrame1: TUniHTMLFrame;
    UniTimer1: TUniTimer;
    procedure UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
    procedure UniFormShow(Sender: TObject);
    procedure UniTimer1Timer(Sender: TObject);
  private
    procedure KutuphaneyiDoldur;
    procedure FilmAraAPI(Kelime, Hedef: string);
  public
    { Public declarations }
  end;

function FILMLERIM_FORM: TFILMLERIM_FORM;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, Main, AnaSayfaForm, OyunlarimForm,
  DizilerimForm, KitaplarimForm, HesabimForm;

function FILMLERIM_FORM: TFILMLERIM_FORM;
begin
  Result := TFILMLERIM_FORM(UniMainModule.GetFormInstance(TFILMLERIM_FORM));
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

procedure TFILMLERIM_FORM.FilmAraAPI(Kelime, Hedef: string);
  function GetTMDBGenreName(ID: Integer): string;
  begin
    case ID of
      28: Result := 'Aksiyon'; 12: Result := 'Macera'; 16: Result := 'Animasyon'; 35: Result := 'Komedi';
      80: Result := 'Suç'; 99: Result := 'Belgesel'; 18: Result := 'Dram'; 10751: Result := 'Aile';
      14: Result := 'Fantastik'; 36: Result := 'Tarih'; 27: Result := 'Korku'; 10402: Result := 'Müzik';
      9648: Result := 'Gizem'; 10749: Result := 'Romantik'; 878: Result := 'Bilim Kurgu'; 10770: Result := 'TV Filmi';
      53: Result := 'Gerilim'; 10752: Result := 'Savaş'; 37: Result := 'Vahşi Batı'; else Result := '';
    end;
  end;

var
  RestClient: TRESTClient;
  RestReq: TRESTRequest;
  RestRes: TRESTResponse;
  JSONObj: TJSONObject;
  JArray, GenreArr: TJSONArray;
  I, J: Integer;
  MovieID, MovieTitle, PosterPath, ImgUrl, ResultHTML: string;
  ReleaseDate, InfoYear, InfoGenre, InfoScore, EncodedTitle: string;
  VoteAvg: Double;
  EkleButonHTML: string;
begin
  RestClient := TRESTClient.Create('https://api.themoviedb.org/3/search/movie');
  RestReq := TRESTRequest.Create(nil);
  RestRes := TRESTResponse.Create(nil);
  try
    RestReq.Client := RestClient;
    RestReq.Response := RestRes;
    RestReq.Method := rmGET;
    RestReq.AddParameter('query', Kelime);
    RestReq.AddParameter('language', 'tr-TR');
    RestReq.AddAuthParameter('Authorization', 'Bearer ' + API_TMDB_TOKEN, pkHTTPHEADER, [poDoNotEncode]);
    RestReq.Execute;

    if RestRes.StatusCode = 200 then
    begin
      JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
      try
        if JSONObj.TryGetValue<TJSONArray>('results', JArray) then
        begin
          ResultHTML := '';
          if JArray.Count = 0 then
            ResultHTML := '<div style="color:var(--neon-pink); text-align:center;">Veritabanında eşleşen film bulunamadı.</div>'
          else
          begin
            for I := 0 to Min(JArray.Count - 1, 9) do
            begin
              MovieID := JArray.Items[I].GetValue<string>('id');
              MovieTitle := JArray.Items[I].GetValue<string>('title');

              EncodedTitle := TNetEncoding.URL.Encode(MovieTitle);
              EncodedTitle := StringReplace(EncodedTitle, '''', '%27', [rfReplaceAll]);
              EncodedTitle := StringReplace(EncodedTitle, '"', '%22', [rfReplaceAll]);
              MovieTitle := StringReplace(MovieTitle, '''', '&apos;', [rfReplaceAll]);
              MovieTitle := StringReplace(MovieTitle, '"', '&quot;', [rfReplaceAll]);

              // PLACEHOLDER UYARLAMASI (FİLM)
              if JArray.Items[I].TryGetValue<string>('poster_path', PosterPath) and (PosterPath <> '') then
                ImgUrl := 'https://image.tmdb.org/t/p/w500' + PosterPath
              else
                ImgUrl := GetPlaceholder(MovieTitle, 'FİLM', 'ff2a6d');

              if JArray.Items[I].TryGetValue<string>('release_date', ReleaseDate) and (Length(ReleaseDate) >= 4) then
                InfoYear := Copy(ReleaseDate, 1, 4) else InfoYear := '--';

              if JArray.Items[I].TryGetValue<Double>('vote_average', VoteAvg) and (VoteAvg > 0) then
              begin
                FormatSettings.DecimalSeparator := '.';
                InfoScore := FormatFloat('0.0', VoteAvg) + '/10';
              end
              else InfoScore := '--';

              InfoGenre := '';
              if JArray.Items[I].TryGetValue<TJSONArray>('genre_ids', GenreArr) then
              begin
                for J := 0 to GenreArr.Count - 1 do
                begin
                  if GetTMDBGenreName(GenreArr.Items[J].GetValue<Integer>) <> '' then
                  begin
                    if InfoGenre <> '' then InfoGenre := InfoGenre + ', ';
                    InfoGenre := InfoGenre + GetTMDBGenreName(GenreArr.Items[J].GetValue<Integer>);
                  end;
                end;
              end;
              if InfoGenre = '' then InfoGenre := '--';

              if Hedef = '1' then
                EkleButonHTML := '<button class="acc-btn acc-btn-wish" onclick="event.stopPropagation(); ajaxRequest(FILMLERIM_FORM.UniHTMLFrame1, ''FilmEkleDB'', [''film_id=' + MovieID + ''', ''istek=' + Hedef + ''']);"><i class="fa-solid fa-heart"></i> LİSTEYE EKLE</button>'
              else
                EkleButonHTML := '<button class="acc-btn acc-btn-lib" onclick="event.stopPropagation(); ajaxRequest(FILMLERIM_FORM.UniHTMLFrame1, ''FilmEkleDB'', [''film_id=' + MovieID + ''', ''istek=' + Hedef + ''']);"><i class="fa-solid fa-check-double"></i> İZLENDİ OLARAK EKLE</button>';

              ResultHTML := ResultHTML +
                '<div class="accordion-item">' +
                '  <div class="accordion-header" onclick="window.toggleAccordion(this)">' +
                '    <img src="' + ImgUrl + '" class="accordion-poster">' +
                '    <div class="accordion-title">' + MovieTitle + '</div>' +
                '    <i class="fa-solid fa-chevron-down accordion-icon"></i>' +
                '  </div>' +
                '  <div class="accordion-content">' +
                '    <div class="acc-details">' +
                '      <div class="acc-detail-item"><strong>YAPIM YILI</strong><span>' + InfoYear + '</span></div>' +
                '      <div class="acc-detail-item"><strong>TÜR</strong><span>' + InfoGenre + '</span></div>' +
                '      <div class="acc-detail-item" style="grid-column: 1 / -1;"><strong>IMDB PUANI</strong><span>' + InfoScore + '</span></div>' +
                '    </div>' +
                '    <div class="acc-actions">' +
                '      <button class="acc-btn acc-btn-yt" onclick="event.stopPropagation(); window.open(''https://www.youtube.com/results?search_query=' + EncodedTitle + '+fragman'', ''_blank'');"><i class="fa-brands fa-youtube" style="font-size: 1rem;"></i> FRAGMAN</button>' +
                       EkleButonHTML +
                '    </div>' +
                '  </div>' +
                '</div>';
            end;
          end;
          UniSession.AddJS('document.getElementById("searchResults").innerHTML = `' + ResultHTML + '`;');
        end;
      finally
        JSONObj.Free;
      end;
    end;
  finally
    RestClient.Free; RestReq.Free; RestRes.Free;
  end;
end;

procedure TFILMLERIM_FORM.UniFormShow(Sender: TObject);
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

procedure TFILMLERIM_FORM.UniHTMLFrame1AjaxEvent(Sender: TComponent;
  EventName: string; Params: TUniStrings);
var
  SecilenFilmID, UserID, GelenKullanici, ArananKelime, ArananHedef, GelenIstekMi, YeniDurum, GelenTarih: String;
begin

  if SameText(EventName, 'FilmSilDB') then
  begin
    SecilenFilmID := Params.Values['film_id'];
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

    UniMainModule.KullaniciFilmlerTable.Close;
    UniMainModule.KullaniciFilmlerTable.SQL.Text :=
      'DELETE FROM kullanici_filmler WHERE kullanici_id = ' + UserID +
      ' AND api_film_id = ' + SecilenFilmID;
    UniMainModule.KullaniciFilmlerTable.ExecSQL;

    MainForm.ShowSwalMini('Film kütüphaneden kaldırıldı!', 'info');
    KutuphaneyiDoldur;
  end;

  if EventName = 'homePageCall' then begin ANA_SAYFA_FORM.Show; Self.Close; end;
  if EventName = 'tvShowsPageCall' then begin DIZILERIM_FORM.Show; Self.Close; end;
  if EventName = 'gamesPageCall' then begin OYUNLARIM_FORM.Show; Self.Close; end;
  if EventName = 'booksPageCall' then begin KITAPLARIM_FORM.Show; Self.Close; end;
    if EventName = 'accountPageCall' then begin HESABIM_FORM.Show; Self.Close; end;

  if EventName = 'DoLogout' then
  begin
    GelenKullanici := UniMainModule.GirisTable.FieldByName('kullanici_adi').Text;
    UniApplication.Cookies.SetCookie('BITD_USER', '', Now - 1);
    UniApplication.Cookies.SetCookie('BITD_TOKEN', '', Now - 1);

    UniMainModule.UpdateQuery.SQL.Text :=
      'UPDATE kullanicilar SET RememberToken = NULL WHERE kullanici_adi = :p_kullanici';
    UniMainModule.UpdateQuery.ParamByName('p_kullanici').AsString := GelenKullanici;
    UniMainModule.UpdateQuery.Execute;
    UniApplication.Restart;
  end;

  if SameText(EventName, 'FilmAra') then
  begin
    ArananKelime := Params.Values['kelime'];
    ArananHedef := Params.Values['hedef'];
    if Trim(ArananKelime) <> '' then
      FilmAraAPI(ArananKelime, ArananHedef);
  end;

  if SameText(EventName, 'FilmEkleDB') then
  begin
    SecilenFilmID := Params.Values['film_id'];
    GelenIstekMi := Params.Values['istek'];
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    if GelenIstekMi = '' then GelenIstekMi := '0';

    UniMainModule.KullaniciFilmlerTable.Close;
    UniMainModule.KullaniciFilmlerTable.SQL.Text := 'SELECT id FROM kullanici_filmler WHERE kullanici_id = ' + UserID + ' AND api_film_id = ' + SecilenFilmID;
    UniMainModule.KullaniciFilmlerTable.Open;

    if not UniMainModule.KullaniciFilmlerTable.IsEmpty then
    begin
      UniSession.AddJS('var m = document.querySelector("#addMovieModal .modal-content"); if (m) { m.classList.remove("shake-error"); void m.offsetWidth; m.classList.add("shake-error"); }');
      MainForm.ShowSwalMini('Bu film zaten listenizde mevcut!', 'warning');
    end
    else
    begin
      UniMainModule.KullaniciFilmlerTable.Close;
      if GelenIstekMi = '0' then
        UniMainModule.KullaniciFilmlerTable.SQL.Text := 'INSERT INTO kullanici_filmler (kullanici_id, api_film_id, istek_mi, bitirme_tarihi, eklenme_tarihi) VALUES (' + UserID + ', ' + SecilenFilmID + ', 0, ''' + FormatDateTime('yyyy-mm-dd', Now) + ''', CURRENT_TIMESTAMP)'
      else
        UniMainModule.KullaniciFilmlerTable.SQL.Text := 'INSERT INTO kullanici_filmler (kullanici_id, api_film_id, istek_mi, eklenme_tarihi) VALUES (' + UserID + ', ' + SecilenFilmID + ', 1, CURRENT_TIMESTAMP)';

      UniMainModule.KullaniciFilmlerTable.ExecSQL;

      UniSession.AddJS('window.closeAddMovieModal(null);');
      MainForm.ShowSwalMini('Film başarıyla eklendi!', 'success');
      KutuphaneyiDoldur;
    end;
  end;

  if SameText(EventName, 'FilmGuncelleDB') then
  begin
    SecilenFilmID := Params.Values['film_id'];
    YeniDurum := Params.Values['yeni_durum'];
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

    UniMainModule.KullaniciFilmlerTable.Close;
    UniMainModule.KullaniciFilmlerTable.SQL.Text :=
      'UPDATE kullanici_filmler SET istek_mi = ' + YeniDurum + ', bitirme_tarihi = ''' + FormatDateTime('yyyy-mm-dd', Now) + ''' WHERE kullanici_id = ' + UserID + ' AND api_film_id = ' + SecilenFilmID;
    UniMainModule.KullaniciFilmlerTable.ExecSQL;

    MainForm.ShowSwalMini('İzlenenlere taşındı!', 'success');
    KutuphaneyiDoldur;
  end;

  if SameText(EventName, 'FilmTarihGuncelleDB') then
  begin
    SecilenFilmID := Params.Values['film_id'];
    GelenTarih := Params.Values['tarih'];
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

    UniMainModule.KullaniciFilmlerTable.Close;
    UniMainModule.KullaniciFilmlerTable.SQL.Text :=
      'UPDATE kullanici_filmler SET bitirme_tarihi = ' + QuotedStr(GelenTarih) + ' WHERE kullanici_id = ' + UserID + ' AND api_film_id = ' + SecilenFilmID;
    UniMainModule.KullaniciFilmlerTable.ExecSQL;

    MainForm.ShowSwalMini('Tarih güncellendi!', 'success');
    KutuphaneyiDoldur;
  end;

  if SameText(EventName, 'FilmNotKaydetDB') then
  begin
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    var GelenFilmID := Params.Values['film_id'];
    var GelenNot := Params.Values['not'];

    UniMainModule.UpdateQuery.Close;
    UniMainModule.UpdateQuery.SQL.Text :=
      'UPDATE kullanici_filmler SET kisisel_not = :p_not ' +
      'WHERE kullanici_id = :p_uid AND api_film_id = :p_oid';

    UniMainModule.UpdateQuery.ParamByName('p_not').AsString := GelenNot;
    UniMainModule.UpdateQuery.ParamByName('p_uid').AsString := UserID;
    UniMainModule.UpdateQuery.ParamByName('p_oid').AsString := GelenFilmID;
    UniMainModule.UpdateQuery.ExecSQL;
  end;

end;

procedure TFILMLERIM_FORM.UniTimer1Timer(Sender: TObject);
begin
  UniTimer1.Enabled := False;
  KutuphaneyiDoldur;
end;

procedure TFILMLERIM_FORM.KutuphaneyiDoldur;
var
  IDListesi: string;
  HTMLCompleted, HTMLWishlist: string;
  CountCompleted, CountWishlist: Integer;
  ResultHTML, CurrentMovieID, UserID: string;
  MovieName, PosterPath, ImgUrl, InfoSummary, EncodedTitle: string;
  InfoScore, InfoYear, InfoGenre, ReleaseDate, InfoRuntime: string;
  RestClient: TRESTClient;
  RestReq: TRESTRequest;
  RestRes: TRESTResponse;
  JSONObj: TJSONObject;
  GenresArr: TJSONArray;
  I, rVal: Integer;
  dVal: Double;
  InfoDirector: string;
  CreditsObj: TJSONObject;
  CrewArr: TJSONArray;
  CrewObj: TJSONObject;
  J: Integer;
  IsWishlist: Integer;
  RawDate, DisplayDate: string;
  DBTarih, Y, M, D, DBNot: string;
begin
  UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

  UniMainModule.KullaniciFilmlerTable.Close;
  UniMainModule.KullaniciFilmlerTable.SQL.Text :=
    'SELECT api_film_id, istek_mi, bitirme_tarihi, kisisel_not FROM kullanici_filmler WHERE kullanici_id = ' + UserID +
    ' ORDER BY eklenme_tarihi DESC';
  UniMainModule.KullaniciFilmlerTable.Open;

  if UniMainModule.KullaniciFilmlerTable.IsEmpty then
  begin
    HTMLCompleted := '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-blue); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">HENÜZ FİLM BİTİRMEDİN_</div><div class="add-card" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddMovieModal(event, 0)"><i class="fa-solid fa-plus"></i></div></div>';
    HTMLWishlist := '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-pink); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">İZLEME LİSTEN BOŞ_</div><div class="add-card-pink" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddMovieModal(event, 1)"><i class="fa-solid fa-plus"></i></div></div>';

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
    RestReq.AddAuthParameter('Authorization', 'Bearer ' + API_TMDB_TOKEN, pkHTTPHEADER, [poDoNotEncode]);

    CountCompleted := 0;
    CountWishlist := 0;
    HTMLCompleted := '<div class="media-card add-card" onclick="window.openAddMovieModal(event, 0)"><i class="fa-solid fa-plus"></i></div>';
    HTMLWishlist := '<div class="media-card add-card-pink" onclick="window.openAddMovieModal(event, 1)"><i class="fa-solid fa-plus"></i></div>';

    UniMainModule.KullaniciFilmlerTable.First;
    while not UniMainModule.KullaniciFilmlerTable.Eof do
    begin
      CurrentMovieID := UniMainModule.KullaniciFilmlerTable.FieldByName('api_film_id').AsString;

      DBNot := UniMainModule.KullaniciFilmlerTable.FieldByName('kisisel_not').AsString;
          DBNot := StringReplace(DBNot, '''', '&apos;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, '"', '&quot;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, #13#10, '&#10;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, #10, '&#10;', [rfReplaceAll]);

      if UniMainModule.KullaniciFilmlerTable.FieldByName('istek_mi').AsBoolean then
        IsWishlist := 1
      else
        IsWishlist := 0;

      if not UniMainModule.KullaniciFilmlerTable.FieldByName('bitirme_tarihi').IsNull then
      begin
        DBTarih := Trim(UniMainModule.KullaniciFilmlerTable.FieldByName('bitirme_tarihi').AsString);
        if (Length(DBTarih) >= 10) and (DBTarih[5] = '-') and (DBTarih[8] = '-') then
        begin
          Y := Copy(DBTarih, 1, 4); M := Copy(DBTarih, 6, 2); D := Copy(DBTarih, 9, 2);
          RawDate := Y + '-' + M + '-' + D;
          DisplayDate := D + '.' + M + '.' + Y;
        end
        else
        begin
          try
            RawDate := FormatDateTime('yyyy-mm-dd', UniMainModule.KullaniciFilmlerTable.FieldByName('bitirme_tarihi').AsDateTime);
            DisplayDate := FormatDateTime('dd.mm.yyyy', UniMainModule.KullaniciFilmlerTable.FieldByName('bitirme_tarihi').AsDateTime);
          except
            RawDate := ''; DisplayDate := 'Belirtilmedi';
          end;
        end;
      end
      else
      begin
        RawDate := ''; DisplayDate := 'Belirtilmedi';
      end;

      RestClient.BaseURL := 'https://api.themoviedb.org/3/movie/' + CurrentMovieID;
      RestReq.Params.Clear;
      RestReq.AddParameter('language', 'tr-TR');
      RestReq.AddParameter('append_to_response', 'credits');
      RestReq.Execute;

      if RestRes.StatusCode = 200 then
      begin
        JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
        try
          MovieName := JSONObj.GetValue<string>('title');

          // PLACEHOLDER UYARLAMASI (FİLM)
          if JSONObj.TryGetValue<string>('poster_path', PosterPath) and (PosterPath <> '') then
            ImgUrl := 'https://image.tmdb.org/t/p/w500' + PosterPath
          else
            ImgUrl := GetPlaceholder(MovieName, 'FİLM', 'ff2a6d');

          if JSONObj.TryGetValue<Double>('vote_average', dVal) then
            InfoScore := IntToStr(Round(dVal * 10)) + '/100' else InfoScore := '--';

          if JSONObj.TryGetValue<string>('release_date', ReleaseDate) and (Length(ReleaseDate) >= 4) then
            InfoYear := Copy(ReleaseDate, 1, 4) else InfoYear := '--';

          if not JSONObj.TryGetValue<string>('overview', InfoSummary) or (InfoSummary = '') then
            InfoSummary := 'Bu film için bir açıklama bulunmuyor.';

          InfoGenre := '';
          if JSONObj.TryGetValue<TJSONArray>('genres', GenresArr) then
          begin
            for I := 0 to GenresArr.Count - 1 do
            begin
              if InfoGenre <> '' then InfoGenre := InfoGenre + ', ';
              InfoGenre := InfoGenre + (GenresArr.Items[I] as TJSONObject).GetValue<string>('name');
            end;
          end;
          if InfoGenre = '' then InfoGenre := '--';

          if JSONObj.TryGetValue<Integer>('runtime', rVal) and (rVal > 0) then
            InfoRuntime := IntToStr(rVal) + ' dk' else InfoRuntime := '--';

          InfoDirector := '';
          if JSONObj.TryGetValue<TJSONObject>('credits', CreditsObj) then
          begin
            if CreditsObj.TryGetValue<TJSONArray>('crew', CrewArr) then
            begin
              for J := 0 to CrewArr.Count - 1 do
              begin
                CrewObj := CrewArr.Items[J] as TJSONObject;
                if CrewObj.GetValue<string>('job') = 'Director' then
                begin
                  InfoDirector := CrewObj.GetValue<string>('name');
                  Break;
                end;
              end;
            end;
          end;
          if InfoDirector = '' then InfoDirector := '--';

          MovieName := StringReplace(MovieName, '''', '&apos;', [rfReplaceAll]);
          MovieName := StringReplace(MovieName, '"', '&quot;', [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, #13#10, ' ', [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, #10, ' ', [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, '''', '&apos;', [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, '"', '&quot;', [rfReplaceAll]);
          InfoDirector := StringReplace(InfoDirector, '''', '&apos;', [rfReplaceAll]);
          InfoDirector := StringReplace(InfoDirector, '"', '&quot;', [rfReplaceAll]);
          InfoGenre := StringReplace(InfoGenre, '''', '&apos;', [rfReplaceAll]);
          InfoGenre := StringReplace(InfoGenre, '"', '&quot;', [rfReplaceAll]);

          if Length(InfoSummary) > 400 then InfoSummary := Copy(InfoSummary, 1, 400) + '...';

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
              'data-platform="' + InfoDirector + '" ' +
              'data-summary="' + InfoSummary + '" ' +
              'data-screenshots="" ' +
              'data-rawdate="' + RawDate + '" ' +
              'data-finishdate="' + DisplayDate + '" ' +
              'data-runtime="' + InfoRuntime + '" ' +
              'onclick="window.openMovieDetail(this, ''' + CurrentMovieID + ''')">' +
              '  <div class="poster-bg" style="background-image: url(''' + ImgUrl + ''');"></div>' +
              '  <div class="detail-trigger-btn"><i class="fa-solid fa-ellipsis-vertical"></i></div>' +
              '  <div class="card-game-title">' + MovieName + '</div>' +
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
              'data-platform="' + InfoDirector + '" ' +
              'data-summary="' + InfoSummary + '" ' +
              'data-runtime="' + InfoRuntime + '" ' +
              'data-screenshots="" ' +
              'data-rawdate="' + RawDate + '" ' +
              'data-finishdate="' + DisplayDate + '" ' +
              'onclick="window.openMovieDetail(this, ''' + CurrentMovieID + ''')">' +
              '  <div class="poster-bg" style="background-image: url(''' + ImgUrl + ''');"></div>' +
              '  <div class="detail-trigger-btn"><i class="fa-solid fa-ellipsis-vertical"></i></div>' +
              '  <div class="card-game-title">' + MovieName + '</div>' +
              '</div>';
          end;

        finally
          JSONObj.Free;
        end;
      end;
      UniMainModule.KullaniciFilmlerTable.Next;
    end;

    if CountCompleted = 0 then
      HTMLCompleted := '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-blue); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">HENÜZ FİLM BİTİRMEDİN_</div><div class="add-card" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddMovieModal(event, 0)"><i class="fa-solid fa-plus"></i></div></div>';

    if CountWishlist = 0 then
      HTMLWishlist := '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-pink); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">İZLEME LİSTEN BOŞ_</div><div class="add-card-pink" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddMovieModal(event, 1)"><i class="fa-solid fa-plus"></i></div></div>';

    UniSession.AddJS('document.getElementById("completedGrid").innerHTML = `' + HTMLCompleted + '`;');
    UniSession.AddJS('document.getElementById("wishlistGrid").innerHTML = `' + HTMLWishlist + '`;');

  finally
    RestClient.Free;
    RestReq.Free;
    RestRes.Free;
  end;
end;

end.
