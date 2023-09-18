unit C4D.DateEdit;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Mask,
  C4D.DateEdit.Third;

type
  TC4DDateEdit = class(TC4DCustomDateEdit)
  protected
    procedure SetDate(Value: TDateTime); override;
  public
    constructor Create(AOwner: TComponent); override;
    property EditMask;
  published
    property DateAutoBetween;
    property MinDate;
    property MaxDate;
    property Align;
    property AutoSelect;
    property BlanksChar;
    property BorderStyle;
    property ButtonHint;
    property CalendarHints;
    property CheckOnExit;
    property ClickKey;
    property Color;
    property Ctl3D;
    property DefaultToday;
    property DialogTitle;
    property DirectInput;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ErrorRaise;
    property Font;
    property GlyphKind;
    { Ensure GlyphKind is declared before Glyph and ButtonWidth }
    property Glyph;
    property ButtonWidth;
    property HideSelection;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property NumGlyphs;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupAlign;
    property PopupColor;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property CalendarStyle;
    property StartOfWeek;
    property Weekends;
    property WeekendColor;
    property YearDigits;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnAcceptDate;
    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnContextPopup;
    property OnEndDock;
    property OnStartDock;
  end;

procedure Register;

implementation

{.$R *.RES}
{.$R C4DDateEdit.dcr}
{.$R .\Images\csComponent.dcr}

uses
  C4D.DateEdit.Consts,
  C4D.DateEdit.Utils,
  C4D.DateEdit.Third.Utils;

procedure Register;
begin
  RegisterComponents('C4D', [TC4DDateEdit]);
end;

constructor TC4DDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  UpdateMask;
end;

procedure TC4DDateEdit.SetDate(Value: TDateTime);
const
  SDateOutOfRange = '''%s'' - data inválida. O valor deve estar entre ''%s'' and ''%s''';
  SDateOutOfMin = '''%s'' - data inválida. O valor deve ser maior que ''%s''';
  SDateOutOfMax = '''%s'' - data inválida. O valor deve ser menor que ''%s''';
begin
  if not FDateAutoBetween then
    if Value <> NullDate then
    begin
      if((MinDate <> NullDate) and (MaxDate <> NullDate)and((Value < MinDate) or (Value > MaxDate)))then
        raise Exception.CreateFmt(SDateOutOfRange,[FormatDateTime(DateFormat, Value),FormatDateTime(DateFormat, MinDate), FormatDateTime(DateFormat, MaxDate)])
      else if ((MinDate <> NullDate) and (Value < MinDate))then
        raise Exception.CreateFmt(SDateOutOfMin,[FormatDateTime(DateFormat, Value),FormatDateTime(DateFormat,MinDate)])
      else if ((MaxDate <> NullDate) and (Value > MaxDate)) then
        raise Exception.CreateFmt(SDateOutOfMax,[FormatDateTime(DateFormat, Value),FormatDateTime(DateFormat,MaxDate)]);
    end;
  inherited SetDate(Value);
end;

end.
