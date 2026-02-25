//{$define UNIGUI_VCL} // Comment out this line to turn this project into an ISAPI module

{$ifndef UNIGUI_VCL}
library
{$else}
program
{$endif}
  BITD;

uses
  uniGUIISAPI,
  Forms,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in 'MainModule.pas' {UniMainModule: TUniGUIMainModule},
  Main in 'Main.pas' {MainForm: TUniForm},
  KayitForm in 'KayitForm.pas' {KAYIT_FORM: TUniForm},
  AnaSayfaForm in 'AnaSayfaForm.pas' {ANA_SAYFA_FORM: TUniForm},
  OyunlarimForm in 'OyunlarimForm.pas' {OYUNLARIM_FORM: TUniForm},
  FilmlerimForm in 'FilmlerimForm.pas' {FILMLERIM_FORM: TUniForm},
  DizilerimForm in 'DizilerimForm.pas' {DIZILERIM_FORM: TUniForm},
  KitaplarimForm in 'KitaplarimForm.pas' {KITAPLARIM_FORM: TUniForm},
  HesabimForm in 'HesabimForm.pas' {HESABIM_FORM: TUniForm},
  SecretConsts in 'SecretConsts.pas';

{$R *.res}

{$ifndef UNIGUI_VCL}
exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;
{$endif}

begin
{$ifdef UNIGUI_VCL}
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
{$endif}
end.
