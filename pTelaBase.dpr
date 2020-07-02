program pTelaBase;

uses
  Vcl.Forms,
  uBase in 'uBase.pas' {fBase};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfBase, fBase);
  Application.Run;
end.
