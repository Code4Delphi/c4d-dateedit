program C4DDateEditDemo01;

uses
  Vcl.Forms,
  C4DDateEdit.Demo01.View.Main in 'Src\View\C4DDateEdit.Demo01.View.Main.pas' {C4DMaskEditDemo01ViewMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TC4DDateEditDemo01ViewMain, C4DDateEditDemo01ViewMain);
  Application.Run;
end.
