unit test;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniPanel, uniHTMLFrame;

type
  TTEST_FORM = class(TUniForm)
    UniHTMLFrame1: TUniHTMLFrame;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function TEST_FORM: TTEST_FORM;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication;

function TEST_FORM: TTEST_FORM;
begin
  Result := TTEST_FORM(UniMainModule.GetFormInstance(TTEST_FORM));
end;

end.
