unit C4DDateEdit.Demo01.View.Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Mask,
  Vcl.Buttons,
  C4D.DateEdit.Third,
  C4D.DateEdit;

type
  TC4DDateEditDemo01ViewMain = class(TForm)
    Edit1: TEdit;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  C4DDateEditDemo01ViewMain: TC4DDateEditDemo01ViewMain;

implementation

{$R *.dfm}

procedure TC4DDateEditDemo01ViewMain.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutDown := True;
end;

procedure TC4DDateEditDemo01ViewMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if(Key = #13)then
  begin
    Key := #0;
    Perform(Wm_NextDlgCtl, 0, 0);
  end;
end;

end.


