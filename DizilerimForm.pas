unit DizilerimForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniPanel, uniHTMLFrame,
  REST.Client, REST.Types, System.JSON, System.NetEncoding, Math, uniTimer,
  Data.DB, SecretConsts;

type
  TDIZILERIM_FORM = class(TUniForm)
    UniHTMLFrame1: TUniHTMLFrame;
    UniTimer1: TUniTimer;
    procedure UniFormShow(Sender: TObject);
    procedure UniHTMLFrame1AjaxEvent(Sender: TComponent; EventName: string;
      Params: TUniStrings);
    procedure UniTimer1Timer(Sender: TObject);
  private
    procedure KutuphaneyiDoldur;
    procedure DiziAraAPI(Kelime, Hedef: string);
  public
    { Public declarations }
  end;

function DIZILERIM_FORM: TDIZILERIM_FORM;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, AnaSayfaForm, FilmlerimForm, OyunlarimForm,
  Main, KitaplarimForm, HesabimForm;

function DIZILERIM_FORM: TDIZILERIM_FORM;
begin
  Result := TDIZILERIM_FORM(UniMainModule.GetFormInstance(TDIZILERIM_FORM));
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

procedure TDIZILERIM_FORM.UniFormShow(Sender: TObject);
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

procedure TDIZILERIM_FORM.UniHTMLFrame1AjaxEvent(Sender: TComponent;
  EventName: string; Params: TUniStrings);
var
  SecilenDiziID, UserID, GelenIstekMi, YeniDurum, GelenTarih, ArananKelime,
    ArananHedef: string;
begin
  if EventName = 'homePageCall' then
  begin
    ANA_SAYFA_FORM.Show;
    Self.Close;
  end;
  if EventName = 'gamesPageCall' then
  begin
    OYUNLARIM_FORM.Show;
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
      if EventName = 'accountPageCall' then begin HESABIM_FORM.Show; Self.Close; end;

  if EventName = 'DoLogout' then
  begin
    UniApplication.Cookies.SetCookie('BITD_USER', '', Now - 1);
    UniApplication.Cookies.SetCookie('BITD_TOKEN', '', Now - 1);
    UniMainModule.UpdateQuery.SQL.Text :=
      'UPDATE kullanicilar SET RememberToken = NULL WHERE kullanici_adi = :p_kullanici';
    UniMainModule.UpdateQuery.ParamByName('p_kullanici').AsString :=
      UniMainModule.GirisTable.FieldByName('kullanici_adi').Text;
    UniMainModule.UpdateQuery.Execute;
    UniApplication.Restart;
  end;

  if SameText(EventName, 'DiziAra') then
  begin
    ArananKelime := Params.Values['kelime'];
    ArananHedef := Params.Values['hedef'];
    if Trim(ArananKelime) <> '' then
      DiziAraAPI(ArananKelime, ArananHedef);
  end;

  if SameText(EventName, 'DiziEkleDB') then
  begin
    SecilenDiziID := Params.Values['dizi_id'];
    GelenIstekMi := Params.Values['istek'];
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    if GelenIstekMi = '' then
      GelenIstekMi := '0';

    UniMainModule.KullaniciDizilerTable.Close;
    UniMainModule.KullaniciDizilerTable.SQL.Text :=
      'SELECT id FROM kullanici_diziler WHERE kullanici_id = ' + UserID +
      ' AND api_dizi_id = ' + SecilenDiziID;
    UniMainModule.KullaniciDizilerTable.Open;

    if not UniMainModule.KullaniciDizilerTable.IsEmpty then
    begin
      UniSession.AddJS
        ('var m = document.querySelector("#addTvShowModal .modal-content"); if (m) { m.classList.remove("shake-error"); void m.offsetWidth; m.classList.add("shake-error"); }');
      MainForm.ShowSwalMini('Bu dizi zaten listenizde mevcut!', 'warning');
    end
    else
    begin
      UniMainModule.KullaniciDizilerTable.Close;
      if GelenIstekMi = '0' then
        UniMainModule.KullaniciDizilerTable.SQL.Text :=
          'INSERT INTO kullanici_diziler (kullanici_id, api_dizi_id, istek_mi, bitirme_tarihi, eklenme_tarihi) VALUES ('
          + UserID + ', ' + SecilenDiziID + ', 0, ''' +
          FormatDateTime('yyyy-mm-dd', Now) + ''', CURRENT_TIMESTAMP)'
      else
        UniMainModule.KullaniciDizilerTable.SQL.Text :=
          'INSERT INTO kullanici_diziler (kullanici_id, api_dizi_id, istek_mi, eklenme_tarihi) VALUES ('
          + UserID + ', ' + SecilenDiziID + ', 1, CURRENT_TIMESTAMP)';

      UniMainModule.KullaniciDizilerTable.ExecSQL;
      UniSession.AddJS('window.closeAddTvShowModal(null);');
      MainForm.ShowSwalMini('Dizi başarıyla eklendi!', 'success');
      KutuphaneyiDoldur;
    end;
  end;

  if SameText(EventName, 'DiziGuncelleDB') then
  begin
    SecilenDiziID := Params.Values['dizi_id'];
    YeniDurum := Params.Values['yeni_durum'];
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

    UniMainModule.KullaniciDizilerTable.Close;
    UniMainModule.KullaniciDizilerTable.SQL.Text :=
      'UPDATE kullanici_diziler SET istek_mi = ' + YeniDurum +
      ', bitirme_tarihi = ''' + FormatDateTime('yyyy-mm-dd', Now) +
      ''' WHERE kullanici_id = ' + UserID + ' AND api_dizi_id = ' +
      SecilenDiziID;
    UniMainModule.KullaniciDizilerTable.ExecSQL;

    MainForm.ShowSwalMini('İzlenenlere taşındı!', 'success');
    KutuphaneyiDoldur;
  end;

  if SameText(EventName, 'DiziTarihGuncelleDB') then
  begin
    SecilenDiziID := Params.Values['dizi_id'];
    GelenTarih := Params.Values['tarih'];
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

    UniMainModule.KullaniciDizilerTable.Close;
    UniMainModule.KullaniciDizilerTable.SQL.Text :=
      'UPDATE kullanici_diziler SET bitirme_tarihi = ' + QuotedStr(GelenTarih) +
      ' WHERE kullanici_id = ' + UserID + ' AND api_dizi_id = ' + SecilenDiziID;
    UniMainModule.KullaniciDizilerTable.ExecSQL;

    MainForm.ShowSwalMini('Tarih güncellendi!', 'success');
    KutuphaneyiDoldur;
  end;

  if SameText(EventName, 'DiziSilDB') then
  begin
    SecilenDiziID := Params.Values['dizi_id'];
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

    UniMainModule.KullaniciDizilerTable.Close;
    UniMainModule.KullaniciDizilerTable.SQL.Text :=
      'DELETE FROM kullanici_diziler WHERE kullanici_id = ' + UserID +
      ' AND api_dizi_id = ' + SecilenDiziID;
    UniMainModule.KullaniciDizilerTable.ExecSQL;

    MainForm.ShowSwalMini('Dizi kütüphaneden kaldırıldı!', 'info');
    KutuphaneyiDoldur;
  end;

  if SameText(EventName, 'DiziNotKaydetDB') then
  begin
    UserID := UniMainModule.GirisTable.FieldByName('id').AsString;
    var GelenDiziID := Params.Values['dizi_id'];
    var GelenNot := Params.Values['not'];

    UniMainModule.UpdateQuery.Close;
    UniMainModule.UpdateQuery.SQL.Text :=
      'UPDATE kullanici_diziler SET kisisel_not = :p_not ' +
      'WHERE kullanici_id = :p_uid AND api_dizi_id = :p_oid';

    UniMainModule.UpdateQuery.ParamByName('p_not').AsString := GelenNot;
    UniMainModule.UpdateQuery.ParamByName('p_uid').AsString := UserID;
    UniMainModule.UpdateQuery.ParamByName('p_oid').AsString := GelenDiziID;
    UniMainModule.UpdateQuery.ExecSQL;
  end;

end;

procedure TDIZILERIM_FORM.UniTimer1Timer(Sender: TObject);
begin
  UniTimer1.Enabled := False;
  KutuphaneyiDoldur;
end;

procedure TDIZILERIM_FORM.KutuphaneyiDoldur;
var
  HTMLCompleted, HTMLWishlist: string;
  CountCompleted, CountWishlist: Integer;
  ResultHTML, CurrentTvID, UserID: string;
  TvName, PosterPath, ImgUrl, InfoSummary, EncodedTitle: string;
  InfoScore, InfoYear, InfoGenre, FirstAirDate: string;
  InfoSeasons, InfoNetwork: string;
  RestClient: TRESTClient;
  RestReq: TRESTRequest;
  RestRes: TRESTResponse;
  JSONObj: TJSONObject;
  GenresArr, NetworksArr: TJSONArray;
  I: Integer;
  dVal: Double;
  IsWishlist: Integer;
  RawDate, DisplayDate: string;
  DBTarih, Y, M, D: string;
  ExtraClass, DBNot: string;
begin
  UserID := UniMainModule.GirisTable.FieldByName('id').AsString;

  UniMainModule.KullaniciDizilerTable.Close;
  UniMainModule.KullaniciDizilerTable.SQL.Text :=
    'SELECT api_dizi_id, istek_mi, bitirme_tarihi, kisisel_not FROM kullanici_diziler WHERE kullanici_id = '
    + UserID + ' ORDER BY eklenme_tarihi DESC';
  UniMainModule.KullaniciDizilerTable.Open;

  if UniMainModule.KullaniciDizilerTable.IsEmpty then
  begin
    HTMLCompleted :=
      '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-blue); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">HENÜZ DİZİ BİTİRMEDİN_</div><div class="add-card" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddTvShowModal(event, 0)"><i class="fa-solid fa-plus"></i></div></div>';
    HTMLWishlist :=
      '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-pink); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">İZLEME LİSTEN BOŞ_</div><div class="add-card-pink" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddTvShowModal(event, 1)"><i class="fa-solid fa-plus"></i></div></div>';

    UniSession.AddJS('document.getElementById("completedGrid").innerHTML = `' +
      HTMLCompleted + '`;');
    UniSession.AddJS('document.getElementById("wishlistGrid").innerHTML = `' +
      HTMLWishlist + '`;');
    Exit;
  end;

  RestClient := TRESTClient.Create('');
  RestReq := TRESTRequest.Create(nil);
  RestRes := TRESTResponse.Create(nil);
  try
    RestReq.Client := RestClient;
    RestReq.Response := RestRes;
    RestReq.Method := rmGET;
    // DİKKAT: Eski kodda token burada döngü dışındaydı, artık içeride!

    CountCompleted := 0;
    CountWishlist := 0;
    HTMLCompleted :=
      '<div class="media-card add-card" onclick="window.openAddTvShowModal(event, 0)"><i class="fa-solid fa-plus"></i></div>';
    HTMLWishlist :=
      '<div class="media-card add-card-pink" onclick="window.openAddTvShowModal(event, 1)"><i class="fa-solid fa-plus"></i></div>';

    UniMainModule.KullaniciDizilerTable.First;
    while not UniMainModule.KullaniciDizilerTable.Eof do
    begin
      CurrentTvID := UniMainModule.KullaniciDizilerTable.FieldByName
        ('api_dizi_id').AsString;

        DBNot := UniMainModule.KullaniciDizilerTable.FieldByName('kisisel_not').AsString;
          DBNot := StringReplace(DBNot, '''', '&apos;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, '"', '&quot;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, #13#10, '&#10;', [rfReplaceAll]);
          DBNot := StringReplace(DBNot, #10, '&#10;', [rfReplaceAll]);

      if UniMainModule.KullaniciDizilerTable.FieldByName('istek_mi').AsBoolean
      then
        IsWishlist := 1
      else
        IsWishlist := 0;

      if not UniMainModule.KullaniciDizilerTable.FieldByName('bitirme_tarihi').IsNull
      then
      begin
        DBTarih := Trim(UniMainModule.KullaniciDizilerTable.FieldByName
          ('bitirme_tarihi').AsString);
        if (Length(DBTarih) >= 10) and (DBTarih[5] = '-') and (DBTarih[8] = '-')
        then
        begin
          Y := Copy(DBTarih, 1, 4);
          M := Copy(DBTarih, 6, 2);
          D := Copy(DBTarih, 9, 2);
          RawDate := Y + '-' + M + '-' + D;
          DisplayDate := D + '.' + M + '.' + Y;
        end
        else
        begin
          try
            RawDate := FormatDateTime('yyyy-mm-dd',
              UniMainModule.KullaniciDizilerTable.FieldByName('bitirme_tarihi')
              .AsDateTime);
            DisplayDate := FormatDateTime('dd.mm.yyyy',
              UniMainModule.KullaniciDizilerTable.FieldByName('bitirme_tarihi')
              .AsDateTime);
          except
            RawDate := '';
            DisplayDate := 'Belirtilmedi';
          end;
        end;
      end
      else
      begin
        RawDate := '';
        DisplayDate := 'Belirtilmedi';
      end;

      RestClient.BaseURL := 'https://api.themoviedb.org/3/tv/' + CurrentTvID;

      RestReq.Params.Clear;
      // ÇÖZÜM BURADA: Token her döngüde yenileniyor
      RestReq.AddAuthParameter('Authorization', 'Bearer ' + API_TMDB_TOKEN, pkHTTPHEADER, [poDoNotEncode]);
      RestReq.AddParameter('language', 'tr-TR');
      RestReq.Execute;

      if RestRes.StatusCode = 200 then
      begin
        JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
        try
          TvName := JSONObj.GetValue<string>('name');

          // YENİ EKLENTİ: PLACEHOLDER UYARLAMASI
          if JSONObj.TryGetValue<string>('poster_path', PosterPath) and
            (PosterPath <> '') then
            ImgUrl := 'https://image.tmdb.org/t/p/w500' + PosterPath
          else
            ImgUrl := GetPlaceholder(TvName, 'DİZİ', '05d9e8');

          if JSONObj.TryGetValue<Double>('vote_average', dVal) then
            InfoScore := IntToStr(Round(dVal * 10)) + '/100'
          else
            InfoScore := '--';

          if JSONObj.TryGetValue<string>('first_air_date', FirstAirDate) and
            (Length(FirstAirDate) >= 4) then
            InfoYear := Copy(FirstAirDate, 1, 4)
          else
            InfoYear := '--';

          if not JSONObj.TryGetValue<string>('overview', InfoSummary) or
            (InfoSummary = '') then
            InfoSummary := 'Bu dizi için bir açıklama bulunmuyor.';

          InfoGenre := '';
          if JSONObj.TryGetValue<TJSONArray>('genres', GenresArr) then
          begin
            for I := 0 to GenresArr.Count - 1 do
            begin
              if InfoGenre <> '' then
                InfoGenre := InfoGenre + ', ';
              InfoGenre := InfoGenre + (GenresArr.Items[I] as TJSONObject)
                .GetValue<string>('name');
            end;
          end;
          if InfoGenre = '' then
            InfoGenre := '--';

          InfoSeasons := JSONObj.GetValue<string>('number_of_seasons')
            + ' Sezon';

          InfoNetwork := '';
          if JSONObj.TryGetValue<TJSONArray>('networks', NetworksArr) and
            (NetworksArr.Count > 0) then
            InfoNetwork := (NetworksArr.Items[0] as TJSONObject)
              .GetValue<string>('name');
          if InfoNetwork = '' then
            InfoNetwork := '--';

          TvName := StringReplace(TvName, '''', '&apos;', [rfReplaceAll]);
          TvName := StringReplace(TvName, '"', '&quot;', [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, #13#10, ' ',
            [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, #10, ' ', [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, '''', '&apos;',
            [rfReplaceAll]);
          InfoSummary := StringReplace(InfoSummary, '"', '&quot;',
            [rfReplaceAll]);
          InfoGenre := StringReplace(InfoGenre, '''', '&apos;', [rfReplaceAll]);
          InfoGenre := StringReplace(InfoGenre, '"', '&quot;', [rfReplaceAll]);
          InfoNetwork := StringReplace(InfoNetwork, '''', '&apos;',
            [rfReplaceAll]);
          InfoNetwork := StringReplace(InfoNetwork, '"', '&quot;',
            [rfReplaceAll]);

          if Length(InfoSummary) > 400 then
            InfoSummary := Copy(InfoSummary, 1, 400) + '...';

          EncodedTitle := TNetEncoding.URL.Encode(TvName);
          EncodedTitle := StringReplace(EncodedTitle, '''', '%27',
            [rfReplaceAll]);

          if IsWishlist = 1 then
            ExtraClass := ' wishlist-card'
          else
            ExtraClass := '';

          ResultHTML := '<div class="media-card' + ExtraClass + '" ' +
            'data-wishlist="' + IntToStr(IsWishlist) + '" ' +
            'data-notes="' + DBNot + '" ' + 'data-poster="' +
            ImgUrl + '" ' + 'data-score="' + InfoScore + '" ' + 'data-year="' +
            InfoYear + '" ' + 'data-genre="' + InfoGenre + '" ' +
            'data-seasons="' + InfoSeasons + '" ' + 'data-network="' +
            InfoNetwork + '" ' + 'data-summary="' + InfoSummary + '" ' +
            'data-rawdate="' + RawDate + '" ' + 'data-finishdate="' +
            DisplayDate + '" ' + 'onclick="window.openTvShowDetail(this, ''' +
            CurrentTvID + ''')">' +
            '  <div class="poster-bg" style="background-image: url(''' + ImgUrl
            + ''');"></div>' +
            '  <div class="detail-trigger-btn"><i class="fa-solid fa-ellipsis-vertical"></i></div>'
            + '  <div class="card-game-title">' + TvName + '</div>' + '</div>';

          if IsWishlist = 1 then
          begin
            Inc(CountWishlist);
            HTMLWishlist := HTMLWishlist + ResultHTML;
          end
          else
          begin
            Inc(CountCompleted);
            HTMLCompleted := HTMLCompleted + ResultHTML;
          end;

        finally
          JSONObj.Free;
        end;
      end;
      UniMainModule.KullaniciDizilerTable.Next;
    end;

    if CountCompleted = 0 then
      HTMLCompleted :=
        '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-blue); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">HENÜZ DİZİ BİTİRMEDİN_</div><div class="add-card" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddTvShowModal(event, 0)"><i class="fa-solid fa-plus"></i></div></div>';
    if CountWishlist = 0 then
      HTMLWishlist :=
        '<div style="grid-column: 1 / -1; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 15vh; text-align: center;"><div style="color: var(--neon-pink); font-family: ''Press Start 2P'', cursive; font-size: 0.6rem; margin-bottom: 15px;">İZLEME LİSTEN BOŞ_</div><div class="add-card-pink" style="width: 60px; height: 60px; border-radius: 50%; font-size: 1.5rem; cursor:pointer;" onclick="window.openAddTvShowModal(event, 1)"><i class="fa-solid fa-plus"></i></div></div>';

    UniSession.AddJS('document.getElementById("completedGrid").innerHTML = `' +
      HTMLCompleted + '`;');
    UniSession.AddJS('document.getElementById("wishlistGrid").innerHTML = `' +
      HTMLWishlist + '`;');

  finally
    RestClient.Free;
    RestReq.Free;
    RestRes.Free;
  end;
end;

procedure TDIZILERIM_FORM.DiziAraAPI(Kelime, Hedef: string);
  function GetTMDBTvGenreName(ID: Integer): string;
  begin
    case ID of
      10759:
        Result := 'Aksiyon & Macera';
      16:
        Result := 'Animasyon';
      35:
        Result := 'Komedi';
      80:
        Result := 'Suç';
      99:
        Result := 'Belgesel';
      18:
        Result := 'Dram';
      10751:
        Result := 'Aile';
      10762:
        Result := 'Çocuk';
      9648:
        Result := 'Gizem';
      10763:
        Result := 'Haberler';
      10764:
        Result := 'Reality';
      10765:
        Result := 'Bilim Kurgu & Fantastik';
      10766:
        Result := 'Pembe Dizi';
      10767:
        Result := 'Talk Show';
      10768:
        Result := 'Savaş & Politik';
      37:
        Result := 'Vahşi Batı';
    else
      Result := '';
    end;
  end;

var
  RestClient: TRESTClient;
  RestReq: TRESTRequest;
  RestRes: TRESTResponse;
  JSONObj: TJSONObject;
  JArray, GenreArr: TJSONArray;
  I, J: Integer;
  TvID, TvName, PosterPath, ImgUrl, ResultHTML: string;
  FirstAirDate, InfoYear, InfoGenre, InfoScore, EncodedTitle: string;
  VoteAvg: Double;
  EkleButonHTML: string;
begin
  RestClient := TRESTClient.Create('https://api.themoviedb.org/3/search/tv');
  RestReq := TRESTRequest.Create(nil);
  RestRes := TRESTResponse.Create(nil);
  try
    RestReq.Client := RestClient;
    RestReq.Response := RestRes;
    RestReq.Method := rmGET;
    RestReq.AddParameter('query', Kelime);
    RestReq.AddParameter('language', 'tr-TR');
    RestReq.AddAuthParameter('Authorization', 'Bearer ' + API_TMDB_TOKEN,
      pkHTTPHEADER, [poDoNotEncode]);
    RestReq.Execute;

    if RestRes.StatusCode = 200 then
    begin
      JSONObj := TJSONObject.ParseJSONValue(RestRes.Content) as TJSONObject;
      try
        if JSONObj.TryGetValue<TJSONArray>('results', JArray) then
        begin
          ResultHTML := '';
          if JArray.Count = 0 then
            ResultHTML :=
              '<div style="color:var(--neon-pink); text-align:center;">Veritabanında eşleşen dizi bulunamadı.</div>'
          else
          begin
            for I := 0 to Min(JArray.Count - 1, 9) do
            begin
              TvID := JArray.Items[I].GetValue<string>('id');
              TvName := JArray.Items[I].GetValue<string>('name');

              EncodedTitle := TNetEncoding.URL.Encode(TvName);
              EncodedTitle := StringReplace(EncodedTitle, '''', '%27',
                [rfReplaceAll]);
              EncodedTitle := StringReplace(EncodedTitle, '"', '%22',
                [rfReplaceAll]);
              TvName := StringReplace(TvName, '''', '&apos;', [rfReplaceAll]);
              TvName := StringReplace(TvName, '"', '&quot;', [rfReplaceAll]);

              // YENİ EKLENTİ: PLACEHOLDER UYARLAMASI
              if JArray.Items[I].TryGetValue<string>('poster_path', PosterPath)
                and (PosterPath <> '') then
                ImgUrl := 'https://image.tmdb.org/t/p/w500' + PosterPath
              else
                ImgUrl := GetPlaceholder(TvName, 'DİZİ', '05d9e8');

              if JArray.Items[I].TryGetValue<string>('first_air_date',
                FirstAirDate) and (Length(FirstAirDate) >= 4) then
                InfoYear := Copy(FirstAirDate, 1, 4)
              else
                InfoYear := '--';

              if JArray.Items[I].TryGetValue<Double>('vote_average', VoteAvg)
                and (VoteAvg > 0) then
              begin
                FormatSettings.DecimalSeparator := '.';
                InfoScore := FormatFloat('0.0', VoteAvg) + '/10';
              end
              else
                InfoScore := '--';

              InfoGenre := '';
              if JArray.Items[I].TryGetValue<TJSONArray>('genre_ids', GenreArr)
              then
              begin
                for J := 0 to GenreArr.Count - 1 do
                begin
                  if GetTMDBTvGenreName(GenreArr.Items[J].GetValue<Integer>) <> ''
                  then
                  begin
                    if InfoGenre <> '' then
                      InfoGenre := InfoGenre + ', ';
                    InfoGenre := InfoGenre + GetTMDBTvGenreName
                      (GenreArr.Items[J].GetValue<Integer>);
                  end;
                end;
              end;
              if InfoGenre = '' then
                InfoGenre := '--';

              if Hedef = '1' then
                EkleButonHTML :=
                  '<button class="acc-btn acc-btn-wish" onclick="event.stopPropagation(); ajaxRequest(DIZILERIM_FORM.UniHTMLFrame1, ''DiziEkleDB'', [''dizi_id='
                  + TvID + ''', ''istek=' + Hedef +
                  ''']);"><i class="fa-solid fa-heart"></i> LİSTEYE EKLE</button>'
              else
                EkleButonHTML :=
                  '<button class="acc-btn acc-btn-lib" onclick="event.stopPropagation(); ajaxRequest(DIZILERIM_FORM.UniHTMLFrame1, ''DiziEkleDB'', [''dizi_id='
                  + TvID + ''', ''istek=' + Hedef +
                  ''']);"><i class="fa-solid fa-check-double"></i> İZLENDİ OLARAK EKLE</button>';

              ResultHTML := ResultHTML + '<div class="accordion-item">' +
                '  <div class="accordion-header" onclick="window.toggleAccordion(this)">'
                + '    <img src="' + ImgUrl + '" class="accordion-poster">' +
                '    <div class="accordion-title">' + TvName + '</div>' +
                '    <i class="fa-solid fa-chevron-down accordion-icon"></i>' +
                '  </div>' + '  <div class="accordion-content">' +
                '    <div class="acc-details">' +
                '      <div class="acc-detail-item"><strong>BAŞLAMA YILI</strong><span>'
                + InfoYear + '</span></div>' +
                '      <div class="acc-detail-item"><strong>TÜR</strong><span>'
                + InfoGenre + '</span></div>' +
                '      <div class="acc-detail-item" style="grid-column: 1 / -1;"><strong>IMDB PUANI</strong><span>'
                + InfoScore + '</span></div>' + '    </div>' +
                '    <div class="acc-actions">' +
                '      <button class="acc-btn acc-btn-yt" onclick="event.stopPropagation(); window.open(''https://www.youtube.com/results?search_query='
                + EncodedTitle +
                '+dizi+fragman'', ''_blank'');"><i class="fa-brands fa-youtube" style="font-size: 1rem;"></i> FRAGMAN</button>'
                + EkleButonHTML + '    </div>' + '  </div>' + '</div>';
            end;
          end;
          UniSession.AddJS
            ('document.getElementById("searchResults").innerHTML = `' +
            ResultHTML + '`;');
        end;
      finally
        JSONObj.Free;
      end;
    end;
  finally
    RestClient.Free;
    RestReq.Free;
    RestRes.Free;
  end;
end;

end.
