unit C4D.DateEdit;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Types,
  System.Variants,
  System.SysConst,
  System.UITypes,
  System.StrUtils,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Mask,
  Vcl.Graphics,
  Vcl.Buttons,
  Vcl.Forms,
  Vcl.Menus,
  Vcl.Dialogs,
  Vcl.DBCtrls,
  Data.DB,
  C4D.DateEdit.Third.PickDate,
  C4D.DateEdit.Third.Utils;

type
  TC4DCloseUpEvent = procedure (Sender: TObject; Accept: Boolean) of object;

  TC4DPopupWindow = class(TCustomControl)
  private
    FEditor: TWinControl;
    FCloseUp: TC4DCloseUpEvent;
    procedure WMMouseActivate(var Message: TMessage); message WM_MOUSEACTIVATE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetValue: Variant; virtual; abstract;
    procedure SetValue(const Value: Variant); virtual; abstract;
    procedure InvalidateEditor;
    procedure PopupMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CloseUp(Accept: Boolean); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    function GetPopupText: string; virtual;
    procedure Hide;
    procedure Show(Origin: TPoint); virtual; // Polaris
    property OnCloseUp: TC4DCloseUpEvent read FCloseUp write FCloseUp;
  end;

  TC4DCustomComboEdit = class(TCustomMaskEdit)
  private
//    FButton: TEditButton; // Polaris
    FBtnControl: TWinControl;
    FOnButtonClick: TNotifyEvent;
    FClickKey: TShortCut;
    FReadOnly: Boolean;
    FDirectInput: Boolean;
    FAlwaysEnable: Boolean;
    FAlignment: TAlignment;
//    FPopupVisible: Boolean; // Polaris
//    FFocused: Boolean; // Polaris
    FPopupAlign: TPopupAlign;
    FGlyphKind: TGlyphKind;
    procedure SetEditRect;
    procedure RecreateGlyph;
    procedure UpdateBtnBounds;
    procedure EditButtonClick(Sender: TObject);
    function GetMinHeight: Integer;
    function GetTextHeight: Integer;
//    procedure SetShowCaret; // Polaris
    function GetGlyph: TBitmap;
    procedure SetGlyph(Value: TBitmap);
    function GetPopupVisible: Boolean;
    function GetNumGlyphs: TNumGlyphs;
    procedure SetNumGlyphs(Value: TNumGlyphs);
    function GetButtonWidth: Integer;
    procedure SetButtonWidth(Value: Integer);
    function GetButtonHint: string;
    procedure SetButtonHint(const Value: string);
    function GetDirectInput: Boolean;
//    procedure SetDirectInput(Value: Boolean);  // Polaris
    procedure SetReadOnly(Value: Boolean);
    procedure SetAlignment(Value: TAlignment);
    function IsCustomGlyph: Boolean;
    function BtnWidthStored: Boolean;
    procedure SetGlyphKind(Value: TGlyphKind);
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure CMEnter(var Message: TMessage); message CM_ENTER;
    procedure CNCtlColor(var Message: TMessage); message CN_CTLCOLOREDIT;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TMessage); message WM_SETFOCUS;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
    procedure WMCut(var Message: TWMCut); message WM_CUT;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
  protected
    FButton: TSpeedButton; // Polaris
    FPopupVisible: Boolean; // Polaris
    FFocused: Boolean; // Polaris
    FPopup: TCustomControl;
    FDefNumGlyphs: TNumGlyphs;
    function GetDefaultBitmap(var DestroyNeeded: Boolean): TBitmap; virtual;
    procedure PopupDropDown(DisableEdit: Boolean); virtual;
    procedure PopupCloseUp(Sender: TObject; Accept: Boolean); virtual; //virtual Polaris
    procedure ShowPopup(Origin: TPoint); virtual;
    procedure HidePopup; virtual;
    procedure UpdatePopupVisible;
    procedure DoChange; virtual; //virtual Polaris
    procedure SetShowCaret; // Polaris
    procedure SetDirectInput(Value: Boolean);  // Polaris

    function AcceptPopup(var Value: Variant): Boolean; virtual;
    procedure AcceptValue(const Value: Variant); virtual;
    procedure SetPopupValue(const Value: Variant); virtual;
    function GetPopupValue: Variant; virtual;

    procedure Change; override;
    procedure PopupChange; virtual;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    function EditCanModify: Boolean; override;
    function GetReadOnly: Boolean; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure ButtonClick; dynamic;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AlwaysEnable: Boolean read FAlwaysEnable write FAlwaysEnable default False;
    property Button: TSpeedButton read FButton;
    property ClickKey: TShortCut read FClickKey write FClickKey
      default scAltDown;
    property Glyph: TBitmap read GetGlyph write SetGlyph stored IsCustomGlyph;
    property GlyphKind: TGlyphKind read FGlyphKind write SetGlyphKind default gkCustom;
    property ButtonWidth: Integer read GetButtonWidth write SetButtonWidth
      stored BtnWidthStored;
    property NumGlyphs: TNumGlyphs read GetNumGlyphs write SetNumGlyphs;
    property ButtonHint: string read GetButtonHint write SetButtonHint;
    property DirectInput: Boolean read GetDirectInput write SetDirectInput default True;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property PopupAlign: TPopupAlign read FPopupAlign write FPopupAlign default epaRight;
    property PopupVisible: Boolean read GetPopupVisible;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoClick;
    procedure SelectAll;
  end;

  TC4DExecDateDialog = procedure(Sender: TObject; var ADate: TDateTime; var Action: Boolean) of object;

  TC4DCustomDateEdit = class(TC4DCustomComboEdit)
  private
    FMinDate,
    FMaxDate: TDateTime;  // Polaris
    FErrorRaise: Boolean;
    FTitle: String;
    //FTitle: PString;
    FOnAcceptDate: TC4DExecDateDialog;
    FDefaultToday: Boolean;
    FHooked: Boolean;
    FPopupColor: TColor;
    FCheckOnExit: Boolean;
    FBlanksChar: Char;
    FCalendarHints: TStrings;
    FStartOfWeek: TDayOfWeekName;
    FWeekends: TDaysOfWeek;
    FWeekendColor: TColor;
    FYearDigits: TYearDigits;
    FDateFormat: string;
    FFormatting: Boolean;
// Polaris
    procedure SetMinDate(Value: TDateTime);
    procedure SetMaxDate(Value: TDateTime);
// Polaris
    function GetDate: TDateTime;
//    procedure SetDate(Value: TDateTime);

    procedure SetYearDigits(Value: TYearDigits);
    function GetPopupColor: TColor;
    procedure SetPopupColor(Value: TColor);
    function GetDialogTitle: string;
    procedure SetDialogTitle(const Value: string);
    function IsCustomTitle: Boolean;
    function GetCalendarStyle: TCalendarStyle;
    procedure SetCalendarStyle(Value: TCalendarStyle);
    procedure SetCalendarHints(Value: TStrings);
    procedure CalendarHintsChanged(Sender: TObject);
    procedure SetWeekendColor(Value: TColor);
    procedure SetWeekends(Value: TDaysOfWeek);
    procedure SetStartOfWeek(Value: TDayOfWeekName);
    procedure SetBlanksChar(Value: Char);
    function TextStored: Boolean;

// Polaris
    function StoreMinDate: Boolean;
    function StoreMaxDate: Boolean;
// Polaris

    function FourDigitYear: Boolean;
    function FormatSettingsChange(var Message: TMessage): Boolean;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
  protected
// Polaris
    FDateAutoBetween: Boolean;
    procedure SetDate(Value: TDateTime); virtual;
    procedure SetDateAutoBetween(Value: Boolean); virtual;
    procedure TestDateBetween(var Value: TDateTime); virtual;
// Polaris
    procedure Change; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DestroyWindowHandle; override;

    function AcceptPopup(var Value: Variant): Boolean; override;
    procedure AcceptValue(const Value: Variant); override;
    procedure SetPopupValue(const Value: Variant); override;

    function GetDateFormat: string;
    procedure ApplyDate(Value: TDateTime); virtual;
    function GetDefaultBitmap(var DestroyNeeded: Boolean): TBitmap; override;
    procedure UpdateFormat;
    procedure UpdatePopup;
    procedure ButtonClick; override;
    property BlanksChar: Char read FBlanksChar write SetBlanksChar default ' ';
    property CalendarHints: TStrings read FCalendarHints write SetCalendarHints;
    property CheckOnExit: Boolean read FCheckOnExit write FCheckOnExit default False;
    property DefaultToday: Boolean read FDefaultToday write FDefaultToday
      default False;
    property DialogTitle: string read GetDialogTitle write SetDialogTitle
      stored IsCustomTitle;
    property EditMask stored False;
    property ErrorRaise: Boolean read FErrorRaise write FErrorRaise default False;
    property Formatting: Boolean read FFormatting;
    property GlyphKind default gkDefault;
    property PopupColor: TColor read GetPopupColor write SetPopupColor
      default clBtnFace;
    property CalendarStyle: TCalendarStyle read GetCalendarStyle write SetCalendarStyle default dcsDefault;
    property StartOfWeek: TDayOfWeekName read FStartOfWeek write SetStartOfWeek default Mon;
    property Weekends: TDaysOfWeek read FWeekends write SetWeekends default [Sun];
    property WeekendColor: TColor read FWeekendColor write SetWeekendColor default clRed;
    property YearDigits: TYearDigits read FYearDigits write SetYearDigits default dyDefault;
    property OnAcceptDate: TC4DExecDateDialog read FOnAcceptDate write FOnAcceptDate;
    property MaxLength stored False;
    property Text stored TextStored;
  public
// Polaris
    property DateAutoBetween: Boolean read FDateAutoBetween write SetDateAutoBetween default True;
    property MinDate: TDateTime read FMinDate write SetMinDate stored StoreMinDate;
    property MaxDate: TDateTime read FMaxDate write SetMaxDate stored StoreMaxDate;
    property DateFormat: string read FDateFormat;
    procedure ValidateEdit; override;
// Polaris
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CheckValidDate;
    function GetDateMask: string;
    procedure UpdateMask; virtual;
    property Date: TDateTime read GetDate write SetDate;
    property PopupVisible;
  end;

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

  TC4DDBDateEdit = class(TC4DCustomDateEdit)
  private
    FInReset: Boolean; // Polaris
    FDataLink: TFieldDataLink;
    FCanvas: TControlCanvas;
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetReadOnly(Value: Boolean);
    procedure UpdateData(Sender: TObject);
    procedure AfterPopup(Sender: TObject; var Date: TDateTime; var Action: Boolean);
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  protected
    procedure AcceptValue(const Value: Variant); override;
    procedure ApplyDate(Value: TDateTime); override;
    function GetReadOnly: Boolean; override;
    procedure Change; override;
    function EditCanModify: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Reset; override;

    // Polaris
    procedure SetDate(Value: TDateTime); override;
    function IsValidDate(Value: TDateTime): Boolean;
    // Polaris
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateMask; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    function UseRightToLeftAlignment: Boolean; override;
    property Field: TField read GetField;
  published
    // Polaris
    property DateAutoBetween;
    property MinDate;
    property MaxDate;
    property Align;
    // Polaris
    property CalendarHints;
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property AutoSelect;
    property BlanksChar;
    property BorderStyle;
    property ButtonHint;
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
    property ShowHint;
    property CalendarStyle;
    property TabOrder;
    property TabStop;
    property StartOfWeek;
    property Weekends;
    property WeekendColor;
    property YearDigits;
    property Visible;
    //property Text;
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

uses
  C4D.DateEdit.Consts,
  C4D.DateEdit.Utils;

var
  DateBitmap: TBitmap = nil;
  FileBitmap: TBitmap = nil;

procedure Register;
begin
  RegisterComponents('C4D', [TC4DDateEdit, TC4DDBDateEdit]);
end;

{$REGION 'TC4DDateEdit'}
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
{$ENDREGION}

{$REGION 'TC4DDBDateEdit'}
constructor TC4DDBDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  inherited ReadOnly := True;
  FInReset := False; // Polaris
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  Self.OnAcceptDate := AfterPopup;
  AlwaysEnable := True;
  UpdateMask;
end;

destructor TC4DDBDateEdit.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  FCanvas.Free;
  inherited Destroy;
end;

procedure TC4DDBDateEdit.AfterPopup(Sender: TObject; var Date: TDateTime;
  var Action: Boolean);
begin
  Action := Action and (DataSource <> nil) and (DataSource.DataSet <> nil) and
    DataSource.DataSet.CanModify;
  if Action then Action := EditCanModify;
end;

procedure TC4DDBDateEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TC4DDBDateEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not ReadOnly and ((Key = VK_DELETE) or ((Key = VK_INSERT)
    and (ssShift in Shift))) then
    FDataLink.Edit;
end;

procedure TC4DDBDateEdit.KeyPress(var Key: Char);
begin
{
  if (Key = #27) then begin
    Reset;
    Key := #0;
  end;
}
  inherited KeyPress(Key);
  if CharInSet(Key, [#32..#255]) and (FDataLink.Field <> nil) and
    not CharInSet(Key, ['0'..'9']) and (Key <> FormatSettings.DateSeparator) then
  begin
    //Beep;
    Key := #0;
  end;
  case Key of
    ^H, ^V, ^X, '0'..'9': FDataLink.Edit;
    #27:
      begin
        Reset;
        Key := #0;
      end;
  end;
end;

function TC4DDBDateEdit.EditCanModify: Boolean;
begin
  Result := FDataLink.Edit;
end;

procedure TC4DDBDateEdit.Reset;
begin
  FInReset := True; // Polaris
  FDataLink.Reset;
  SelectAll;
  FInReset := False; // Polaris
end;

// Polaris begin

function TC4DDBDateEdit.IsValidDate(Value: TDateTime): Boolean;
const
  SDateOutOfRange = '''%s'' - data inválida. O valor deve estar entre ''%s'' and ''%s''';
  SDateOutOfMin = '''%s'' - data inválida. O valor deve ser maior que ''%s''';
  SDateOutOfMax = '''%s'' - data inválida. O valor deve ser menor que ''%s''';
begin
  Result := FDateAutoBetween;
  if not Result then
    if (not FInReset) and FDataLink.Editing then
    try
      if (Value <> NullDate) then
      begin
        if((MinDate <> NullDate) and (MaxDate <> NullDate)and((Value < MinDate) or (Value > MaxDate)))then
          raise Exception.CreateFmt(SDateOutOfRange,[FormatDateTime(DateFormat, Value),FormatDateTime(DateFormat, MinDate), FormatDateTime(DateFormat, MaxDate)])
        else if ((MinDate <> NullDate) and (Value < MinDate))then
          raise Exception.CreateFmt(SDateOutOfMin,[FormatDateTime(DateFormat, Value),FormatDateTime(DateFormat,MinDate)])
        else if ((MaxDate <> NullDate) and (Value > MaxDate)) then
          raise Exception.CreateFmt(SDateOutOfMax,[FormatDateTime(DateFormat, Value),FormatDateTime(DateFormat,MaxDate)]);
      end;
      Result := True;
    except
      Reset;
      raise;
    end;
end;

procedure TC4DDBDateEdit.SetDate(Value: TDateTime);
begin
  IsValidDate(Value);
  inherited SetDate(Value);
end;
// Polaris end

procedure TC4DDBDateEdit.Change;
begin
  if not Formatting then FDataLink.Modified;
  inherited Change;
end;

function TC4DDBDateEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TC4DDBDateEdit.SetDataSource(Value: TDataSource);
begin
  if not (FDataLink.DataSourceFixed and (csLoading in ComponentState)) then
    FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TC4DDBDateEdit.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TC4DDBDateEdit.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TC4DDBDateEdit.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TC4DDBDateEdit.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

function TC4DDBDateEdit.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TC4DDBDateEdit.UpdateMask;
begin
  UpdateFormat;
  UpdatePopup;
  DataChange(nil);
end;

procedure TC4DDBDateEdit.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
  begin
    EditMask := GetDateMask;
// Polaris
    inherited SetDate(FDataLink.Field.AsDateTime);
//    Self.Date := FDataLink.Field.AsDateTime;
//    SetDate(FDataLink.Field.AsDateTime);
// Polaris
  end
  else
  begin
    if csDesigning in ComponentState then
    begin
      EditMask := '';
      EditText := Name;
    end
    else
    begin
      EditMask := GetDateMask;
      if DefaultToday then
        Date := System.SysUtils.Date
      else
        Date := NullDate;
    end;
  end;
end;

procedure TC4DDBDateEdit.EditingChange(Sender: TObject);
begin
  inherited ReadOnly := not FDataLink.Editing;
  if FDataLink.Editing and DefaultToday and (FDataLink.Field <> nil) and
    (FDataLink.Field.AsDateTime = NullDate) then
    FDataLink.Field.AsDateTime := System.SysUtils.Now;
end;

procedure TC4DDBDateEdit.UpdateData(Sender: TObject);
var
  D: TDateTime;
begin
  ValidateEdit;
  D := Self.Date;
  if D <> NullDate then
  begin
    if Int(FDataLink.Field.AsDateTime) <> D then
      FDataLink.Field.AsDateTime := D + Frac(FDataLink.Field.AsDateTime)
  end
  else
    FDataLink.Field.Clear;
end;

procedure TC4DDBDateEdit.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

function EditorTextMargins(Editor: TC4DCustomComboEdit): TPoint;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  with Editor do begin
    if NewStyleControls then begin
      if BorderStyle = Vcl.Forms.bsNone then I := 0
      else if Ctl3D then I := 1
      else I := 2;
      Result.X := SendMessage(Handle, EM_GETMARGINS, 0, 0) and $0000FFFF + I;
      Result.Y := I;
    end
    else begin
      if BorderStyle = Vcl.Forms.bsNone then I := 0
      else begin
        DC := GetDC(0);
        GetTextMetrics(DC, SysMetrics);
        SaveFont := SelectObject(DC, Font.Handle);
        GetTextMetrics(DC, Metrics);
        SelectObject(DC, SaveFont);
        ReleaseDC(0, DC);
        I := SysMetrics.tmHeight;
        if I > Metrics.tmHeight then I := Metrics.tmHeight;
        I := I div 4;
      end;
      Result.X := I;
      Result.Y := I;
    end;
  end;
end;

function PaintComboEdit(Editor: TC4DCustomComboEdit; const AText: string;
  AAlignment: TAlignment; StandardPaint: Boolean;
  var ACanvas: TControlCanvas; var Message: TWMPaint): Boolean;
var
  AWidth, ALeft: Integer;
  _Margins: TPoint;
  R: TRect;
  DC: HDC;
  PS: TPaintStruct;
  S: string;
  ExStyle: DWORD;
const
  AlignStyle: array[Boolean, TAlignment] of DWORD =
   ((WS_EX_LEFT, WS_EX_RIGHT, WS_EX_LEFT),
    (WS_EX_RIGHT, WS_EX_LEFT, WS_EX_LEFT));
begin
  Result := True;
  with Editor do
  begin
    if UseRightToLeftAlignment then ChangeBiDiModeAlignment(AAlignment);
    if StandardPaint and not (csPaintCopy in ControlState) then
    begin
      if SysLocale.MiddleEast and HandleAllocated and (IsRightToLeft) then
      begin { This keeps the right aligned text, right aligned }
        ExStyle := DWORD(GetWindowLong(Handle, GWL_EXSTYLE)) and (not WS_EX_RIGHT) and
          (not WS_EX_RTLREADING) and (not WS_EX_LEFTSCROLLBAR);
        if UseRightToLeftReading then
          ExStyle := ExStyle or WS_EX_RTLREADING;
        if UseRightToLeftScrollbar then
          ExStyle := ExStyle or WS_EX_LEFTSCROLLBAR;
        ExStyle := ExStyle or
          AlignStyle[UseRightToLeftAlignment, AAlignment];
        if DWORD(GetWindowLong(Handle, GWL_EXSTYLE)) <> ExStyle then
          SetWindowLong(Handle, GWL_EXSTYLE, ExStyle);
      end;

      Result := False;
      { return false if we need to use standard paint handler }
      Exit;
    end;
    { Since edit controls do not handle justification unless multi-line (and
      then only poorly) we will draw right and center justify manually unless
      the edit has the focus. }
    if ACanvas = nil then
    begin
      ACanvas := TControlCanvas.Create;
      ACanvas.Control := Editor;
    end;
    DC := Message.DC;
    if DC = 0 then DC := BeginPaint(Handle, PS);
    ACanvas.Handle := DC;
    try
      ACanvas.Font := Font;
      if not Enabled and NewStyleControls and not
        (csDesigning in ComponentState) and
        (ColorToRGB(Color) <> ColorToRGB(clGrayText)) then
        ACanvas.Font.Color := clGrayText;
      with ACanvas do begin
        R := ClientRect;
        if not (NewStyleControls and Ctl3D) and
          (BorderStyle = bsSingle) then
        begin
          Brush.Color := clWindowFrame;
          FrameRect(R);
          InflateRect(R, -1, -1);
        end;
        Brush.Color := Color;
        S := AText;
        AWidth := TextWidth(S);
        _Margins := EditorTextMargins(Editor);

        if PopupVisible then ALeft := Editor.Margins.Left
        else
        begin
          if ButtonWidth > 0 then Inc(AWidth);
          case AAlignment of
            taLeftJustify:
              ALeft := _Margins.X;
            taRightJustify:
              ALeft := ClientWidth - ButtonWidth - AWidth - _Margins.X{Polaris - 2};
          else
              ALeft := (ClientWidth - ButtonWidth - AWidth) div 2;
          end;
        end;

        if SysLocale.MiddleEast then UpdateTextFlags;
        TextRect(R, ALeft, _Margins.Y, S);
      end;
    finally
      ACanvas.Handle := 0;
      if Message.DC = 0 then EndPaint(Handle, PS);
    end;
  end;
end;

procedure TC4DDBDateEdit.WMPaint(var Message: TWMPaint);
var
  S: string;
begin
  if (csPaintCopy in ControlState) and (FDataLink.Field <> nil) then
  begin
    if FDataLink.Field.IsNull then
    begin
      S := GetDateFormat;
      S := ReplaceStr(ReplaceStr(ReplaceStr(ReplaceStr(S, '/', FormatSettings.DateSeparator),
        'Y', ' '), 'M', ' '), 'D', ' ');
    end
    else
      S := FormatDateTime(GetDateFormat, FDataLink.Field.AsDateTime);
  end
  else
    S := EditText;
  if not PaintComboEdit(Self, S, Alignment, True, FCanvas, Message) then
    inherited;
end;

procedure TC4DDBDateEdit.AcceptValue(const Value: Variant);
begin
  if VarIsNull(Value) or VarIsEmpty(Value) then
    FDataLink.Field.Clear
  else
    FDataLink.Field.AsDateTime :=
      VarToDateTime(Value) + Frac(FDataLink.Field.AsDateTime);
  DoChange;
end;

procedure TC4DDBDateEdit.ApplyDate(Value: TDateTime);
begin
  FDataLink.Edit;
  inherited ApplyDate(Value);
end;

procedure TC4DDBDateEdit.WMPaste(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TC4DDBDateEdit.WMCut(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TC4DDBDateEdit.CMEnter(var Message: TCMEnter);
begin
  inherited;
end;

procedure TC4DDBDateEdit.CMExit(var Message: TCMExit);
begin
  try
    if not (csDesigning in ComponentState) and CheckOnExit then
      CheckValidDate;
    FDataLink.UpdateRecord;
  except
    SelectAll;
    if CanFocus then SetFocus;
    raise;
  end;
  CheckCursor;
  DoExit;
end;

function TC4DDBDateEdit.UseRightToLeftAlignment: Boolean;
begin
  Result := DBUseRightToLeftAlignment(Self, Field);
end;

function TC4DDBDateEdit.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or (FDataLink <> nil) and
    FDataLink.ExecuteAction(Action);
end;

function TC4DDBDateEdit.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or (FDataLink <> nil) and
    FDataLink.UpdateAction(Action);
end;
{$ENDREGION}

{$REGION 'TC4DCustomComboEdit'}
procedure TC4DCustomComboEdit.SetEditRect;
var
  Loc: TRect;
begin
  SetRect(Loc, 0, 0, ClientWidth - FBtnControl.Width{Polaris - 2}, ClientHeight + 1);
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
//Polaris
//  SendMessage(Handle, EM_SETMARGINS, EC_RIGHTMARGIN, MakeLong(0, FBtnControl.Width));
end;

procedure TC4DCustomComboEdit.RecreateGlyph;
  function CreateEllipsisGlyph: TBitmap;
  var
    W, G, I: Integer;
  begin
    Result := TBitmap.Create;
    with Result do
    try
      Monochrome := True;
      Width := Max(1, FButton.Width - 6);
      Height := 4;
      W := 2;
      G := (Result.Width - 3 * W) div 2;
      if G <= 0 then G := 1;
      if G > 3 then G := 3;
      I := (Width - 3 * W - 2 * G) div 2;
      PatBlt(Canvas.Handle, I, 1, W, W, BLACKNESS);
      PatBlt(Canvas.Handle, I + G + W, 1, W, W, BLACKNESS);
      PatBlt(Canvas.Handle, I + 2 * G + 2 * W, 1, W, W, BLACKNESS);
    except
      Free;
      raise;
    end;
  end;
var
  NewGlyph: TBitmap;
  DestroyNeeded: Boolean;
begin
  case FGlyphKind of
    gkDefault:
      begin
        DestroyNeeded := False;
        NewGlyph := GetDefaultBitmap(DestroyNeeded);
        try
          FButton.Glyph.Assign(NewGlyph);
          NumGlyphs := FDefNumGlyphs;
        finally
          if DestroyNeeded then
            NewGlyph.Destroy;
        end;
      end;
    gkDropDown:
      begin
        FButton.Glyph.Handle := LoadBitmap(0, PChar(32738));
        NumGlyphs := 1;
      end;
    gkEllipsis:
      begin
        NewGlyph := CreateEllipsisGlyph;
        try
          FButton.Glyph := NewGlyph;
          NumGlyphs := 1;
        finally
          NewGlyph.Destroy;
        end;
      end;
  end;
end;

procedure TC4DCustomComboEdit.UpdateBtnBounds;
var
  BtnRect: TRect;
begin

  if NewStyleControls then
  begin
    if Ctl3D and (BorderStyle = bsSingle) then
      BtnRect := Bounds(Width - FButton.Width - 4, 0,
        FButton.Width, Height - 4)
    else
    begin
      if BorderStyle = bsSingle then
        BtnRect := Bounds(Width - FButton.Width - 2, 2,
          FButton.Width, Height - 4)
      else
        BtnRect := Bounds(Width - FButton.Width, 0,
          FButton.Width, Height);
    end;
  end
  else
    BtnRect := Bounds(Width - FButton.Width, 0, FButton.Width, Height);

  with BtnRect do
    FBtnControl.SetBounds(Left, Top, Right - Left, Bottom - Top);
  FButton.Height := FBtnControl.Height;
  SetEditRect;
end;

procedure TC4DCustomComboEdit.EditButtonClick(Sender: TObject);
begin
  if (not FReadOnly) or AlwaysEnable then
    ButtonClick;
end;

function TC4DCustomComboEdit.GetMinHeight: Integer;
var
  I: Integer;
begin
  I := GetTextHeight;
  Result := I + GetSystemMetrics(SM_CYBORDER) * 4 + 1;
end;

function TC4DCustomComboEdit.GetTextHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  try
    GetTextMetrics(DC, SysMetrics);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(0, DC);
  end;
//  Result := Min(SysMetrics.tmHeight, Metrics.tmHeight);  // Polaris
  Result := Metrics.tmHeight;                              // Polaris
end;

function TC4DCustomComboEdit.GetGlyph: TBitmap;
begin
  Result := FButton.Glyph;
end;

procedure TC4DCustomComboEdit.SetGlyph(Value: TBitmap);
begin
  FButton.Glyph := Value;
  FGlyphKind := gkCustom;
end;

function TC4DCustomComboEdit.GetPopupVisible: Boolean;
begin
  Result := (FPopup <> nil) and FPopupVisible;
end;

function TC4DCustomComboEdit.GetNumGlyphs: TNumGlyphs;
begin
  Result := FButton.NumGlyphs;
end;

procedure TC4DCustomComboEdit.SetNumGlyphs(Value: TNumGlyphs);
begin
  if FGlyphKind in [gkDropDown, gkEllipsis] then
    FButton.NumGlyphs := 1
  else if FGlyphKind = gkDefault then
    FButton.NumGlyphs := FDefNumGlyphs
  else
    FButton.NumGlyphs := Value;
end;

function TC4DCustomComboEdit.GetButtonWidth: Integer;
begin
  Result := FButton.Width;
end;

procedure TC4DCustomComboEdit.SetButtonWidth(Value: Integer);
begin
  if ButtonWidth <> Value then
  begin
    FBtnControl.Visible := Value > 1;
    if (csCreating in ControlState) then
    begin
      FBtnControl.Width := Value;
      FButton.Width := Value;
      with FButton do
        ControlStyle := ControlStyle - [csFixedWidth];
      RecreateGlyph;
    end
//    else if (Value <> ButtonWidth) and (Value < ClientWidth) then begin
//Polaris
    else if (Value <> ButtonWidth) and
            ((Assigned(Parent) and (Value < ClientWidth)) or
             (not Assigned(Parent) and (Value < Width)))
    then
    begin
      FButton.Width := Value;
      with FButton do
        ControlStyle := ControlStyle - [csFixedWidth];
      if HandleAllocated then RecreateWnd;
      RecreateGlyph;
    end;
  end;
end;

function TC4DCustomComboEdit.GetButtonHint: string;
begin
  Result := FButton.Hint;
end;

procedure TC4DCustomComboEdit.SetButtonHint(const Value: string);
begin
  FButton.Hint := Value;
end;

function TC4DCustomComboEdit.GetDirectInput: Boolean;
begin
  Result := FDirectInput;
end;

procedure TC4DCustomComboEdit.SetDirectInput(Value: Boolean);
begin
  inherited ReadOnly := not Value or FReadOnly;
  FDirectInput := Value;
end;

function TC4DCustomComboEdit.AcceptPopup(var Value: Variant): Boolean;
begin
  Result := True;
end;

procedure TC4DCustomComboEdit.AcceptValue(const Value: Variant);
begin
  if Text <> VarToStr(Value) then
  begin
    Text := Value;
    Modified := True;
    UpdatePopupVisible;
    DoChange;
  end;
end;

procedure TC4DCustomComboEdit.SetPopupValue(const Value: Variant);
begin
  if FPopup <> nil then
    TC4DPopupWindow(FPopup).SetValue(Value);
end;

function TC4DCustomComboEdit.GetPopupValue: Variant;
begin
  if FPopup <> nil then
    Result := TC4DPopupWindow(FPopup).GetValue
  else
    Result := '';
end;

procedure TC4DCustomComboEdit.Change;
begin
  if not PopupVisible then DoChange
  else PopupChange;
end;

procedure TC4DCustomComboEdit.PopupChange;
begin
end;

procedure TC4DCustomComboEdit.CreateParams(var Params: TCreateParams);
const
  Alignments: array[TAlignment] of Longword = (ES_LEFT, ES_RIGHT, ES_CENTER);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style
    or ES_MULTILINE
    or WS_CLIPCHILDREN
    or Alignments[FAlignment];
end;

procedure TC4DCustomComboEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

function TC4DCustomComboEdit.EditCanModify: Boolean;
begin
  Result := not FReadOnly;
end;

function TC4DCustomComboEdit.GetReadOnly: Boolean;
begin
  Result := FReadOnly;
end;

type
  TCrackWin = class(TWinControl);

procedure TC4DCustomComboEdit.KeyDown(var Key: Word; Shift: TShiftState);
//Polaris
var
  Form: TCustomForm;
begin
//Polaris
  Form := GetParentForm(Self);
  if (ssCtrl in Shift)  then
   case Key of
    VK_RETURN:
     if (Form <> nil) {and Form.KeyPreview} then
     begin
       TCrackWin(Form).KeyDown(Key, Shift);
       Key := 0;
      end;
    VK_TAB:
     if (Form <> nil){ and Form.KeyPreview} then
     begin
       TCrackWin(Form).KeyDown(Key, Shift);
       Key := 0;
     end;
   end;
//Original
  inherited KeyDown(Key, Shift);
  if (FClickKey = ShortCut(Key, Shift)) and (ButtonWidth > 0) then
  begin
    EditButtonClick(Self);
    Key := 0;
  end;
end;

procedure TC4DCustomComboEdit.KeyPress(var Key: Char);
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);

//Polaris  if (Key = Char(VK_RETURN)) or (Key = Char(VK_ESCAPE)) or ((KEY=#10) and PopupVisible) then
  if (Key = Char(VK_RETURN)) or (Key = Char(VK_ESCAPE)) or ((KEY=#10) and PopupVisible) then
  begin
    if PopupVisible then
    begin
//Polaris      PopupCloseUp(FPopup, Key = Char(VK_RETURN));
      PopupCloseUp(FPopup, Key <> Char(VK_ESCAPE));
      Key := #0;
    end
    else
    begin
      { must catch and remove this, since is actually multi-line }
      GetParentForm(Self).Perform(CM_DIALOGKEY, Byte(Key), 0);
      if Key = Char(VK_RETURN) then
      begin
        inherited KeyPress(Key);
        Key := #0;
        Exit;
      end;
    end;
  end;
//Polaris
  if CharInSet(Key, [#10, #9]) then
  begin
    Key := #0;
    if (Form <> nil) {and Form.KeyPreview} then
      TCrackWin(Form).KeyPress(Key);
  end;
//Polaris
  inherited KeyPress(Key);
end;

procedure TC4DCustomComboEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (FPopup <> nil) and (Button = mbLeft) then
  begin
    if CanFocus then
      SetFocus;
    if not FFocused then
      Exit;
    if FPopupVisible then
      PopupCloseUp(FPopup, False);
    {else if (not ReadOnly or AlwaysEnable) and (not DirectInput) then
      PopupDropDown(True);}
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TC4DCustomComboEdit.ButtonClick;
begin
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self);

  if FPopup <> nil then
  begin
    if FPopupVisible then
      PopupCloseUp(FPopup, True)
    else
      PopupDropDown(True);
  end;
end;

procedure TC4DCustomComboEdit.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    RecreateWnd;
  end;
end;

procedure TC4DCustomComboEdit.SetReadOnly(Value: Boolean);
begin
  if Value <> FReadOnly then
  begin
    FReadOnly := Value;
    inherited ReadOnly := Value or not FDirectInput;
  end;
end;

function TC4DCustomComboEdit.IsCustomGlyph: Boolean;
begin
  Result := FGlyphKind = gkCustom;
end;

function TC4DCustomComboEdit.BtnWidthStored: Boolean;
begin
  if (FGlyphKind = gkDefault) and (Glyph <> nil) then
    Result := ButtonWidth <> Max(Glyph.Width div FButton.NumGlyphs + 6, DefEditBtnWidth)
  else if FGlyphKind = gkDropDown then
    Result := ButtonWidth <> GetSystemMetrics(SM_CXVSCROLL) + 1
  else
    Result := ButtonWidth <> DefEditBtnWidth;
end;

procedure TC4DCustomComboEdit.SetGlyphKind(Value: TGlyphKind);
begin
  if FGlyphKind <> Value then
  begin
    FGlyphKind := Value;
    if(FGlyphKind = gkCustom) and (csReading in ComponentState)then
      Glyph := nil;

    RecreateGlyph;

    if(FGlyphKind = gkDefault) and (Glyph <> nil)then
      ButtonWidth := Max(Glyph.Width div FButton.NumGlyphs + 6, FButton.Width)
    else if FGlyphKind = gkDropDown then
    begin
      ButtonWidth := GetSystemMetrics(SM_CXVSCROLL);
      with FButton do
        ControlStyle := ControlStyle + [csFixedWidth];
    end;
  end;
end;

procedure TC4DCustomComboEdit.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  FButton.Enabled := Enabled;
end;

procedure TC4DCustomComboEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if HandleAllocated then SetEditRect;
end;

procedure TC4DCustomComboEdit.CMCancelMode(var Message: TCMCancelMode);
begin
  if (Message.Sender <> Self) and (Message.Sender <> FPopup) and
    (Message.Sender <> FButton) and ((FPopup <> nil) and
    not FPopup.ContainsControl(Message.Sender)) then
    PopupCloseUp(FPopup, False);
end;

procedure TC4DCustomComboEdit.CMEnter(var Message: TMessage);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then SelectAll;
  inherited;
end;

procedure TC4DCustomComboEdit.CNCtlColor(var Message: TMessage);
var
  TextColor: Longint;
begin
  inherited;
  if NewStyleControls then
  begin
    TextColor := ColorToRGB(Font.Color);
    if not Enabled and (ColorToRGB(Color) <> ColorToRGB(clGrayText)) then
      TextColor := ColorToRGB(clGrayText);
    SetTextColor(Message.WParam, TextColor);
  end;
end;

procedure TC4DCustomComboEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  if not (csLoading in ComponentState) then
  begin
    MinHeight := GetMinHeight;
    { text edit bug: if size to less than MinHeight, then edit ctrl does
      not display the text }
    if Height < MinHeight then
    begin
      Height := MinHeight;
      Exit;
    end;
  end
  else
  begin
    if (FPopup <> nil) and (csDesigning in ComponentState) then
      FPopup.SetBounds(0, Height + 1, 10, 10);
  end;
  UpdateBtnBounds;
end;

procedure TC4DCustomComboEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  FFocused := False;
  PopupCloseUp(FPopup, False);
end;

procedure TC4DCustomComboEdit.WMSetFocus(var Message: TMessage);
begin
  inherited;
  FFocused := True;
  SetShowCaret;
end;

procedure TC4DCustomComboEdit.WMPaste(var Message: TWMPaste);
begin
  if not FDirectInput or ReadOnly then Exit;
  inherited;
end;

procedure TC4DCustomComboEdit.WMCut(var Message: TWMCut);
begin
  if not FDirectInput or ReadOnly then Exit;
  inherited;
end;

procedure TC4DCustomComboEdit.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  UpdateBtnBounds;
end;

procedure TC4DCustomComboEdit.CMBiDiModeChanged(var Message: TMessage);
begin
  inherited;
  if FPopup <> nil then
    FPopup.BiDiMode := BiDiMode;
end;

function TC4DCustomComboEdit.GetDefaultBitmap(var DestroyNeeded: Boolean): TBitmap;
begin
  Result := nil;
end;

procedure TC4DCustomComboEdit.PopupDropDown(DisableEdit: Boolean);
var
  P: TPoint;
  Y: Integer;
begin
  if (FPopup <> nil) and not (ReadOnly or FPopupVisible) then
  begin
    P := Parent.ClientToScreen(Point(Left, Top));
    Y := P.Y + Height;
    if Y + FPopup.Height > Screen.Height then
      Y := P.Y - FPopup.Height;
    case FPopupAlign of
      epaRight:
        begin
          Dec(P.X, FPopup.Width - Width);
          if P.X < 0 then Inc(P.X, FPopup.Width - Width);
        end;
      epaLeft:
        begin
          if P.X + FPopup.Width > Screen.Width then
            Dec(P.X, FPopup.Width - Width);
        end;
    end;
    if P.X < 0 then P.X := 0
    else if P.X + FPopup.Width > Screen.Width then
      P.X := Screen.Width - FPopup.Width;

    if Text <> '' then SetPopupValue(Text)
    else SetPopupValue(Null);

    if CanFocus then SetFocus;
    ShowPopup(Point(P.X, Y));
    FPopupVisible := True;
    if DisableEdit then
    begin
      inherited ReadOnly := True;
      HideCaret(Handle);
    end;
  end;
end;

procedure TC4DCustomComboEdit.PopupCloseUp(Sender: TObject; Accept: Boolean);
var
  AValue: Variant;
begin
  if (FPopup <> nil) and FPopupVisible then
  begin
    if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
    AValue := GetPopupValue;
    HidePopup;
    try
      try
        if CanFocus then
        begin
          SetFocus;
          if GetFocus = Handle then
            SetShowCaret;
        end;
      except
        { ignore exceptions }
      end;
      SetDirectInput(DirectInput);
      Invalidate;
      if Accept and AcceptPopup(AValue) and EditCanModify then
      begin
        AcceptValue(AValue);
        if FFocused then
          inherited SelectAll;
      end;
    finally
      FPopupVisible := False;
    end;
  end;
end;

procedure TC4DCustomComboEdit.ShowPopup(Origin: TPoint);
begin
  TC4DPopupWindow(FPopup).Show(Origin);
end;

procedure TC4DCustomComboEdit.HidePopup;
begin
  TC4DPopupWindow(FPopup).Hide;
end;

procedure TC4DCustomComboEdit.UpdatePopupVisible;
begin
  FPopupVisible := (FPopup <> nil) and FPopup.Visible;
end;

procedure TC4DCustomComboEdit.DoChange;
begin
  inherited Change;
end;

procedure TC4DCustomComboEdit.SetShowCaret;
const
  CaretWidth: array[Boolean] of Byte = (1, 2);
begin
  CreateCaret(Handle, 0, CaretWidth[fsBold in Font.Style], GetTextHeight);
  ShowCaret(Handle);
end;

procedure TC4DCustomComboEdit.DoClick;
begin
  EditButtonClick(Self);
end;

procedure TC4DCustomComboEdit.SelectAll;
begin
  if DirectInput then inherited SelectAll;
end;

constructor TC4DCustomComboEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ControlStyle := ControlStyle + [csCaptureMouse];

//  AutoSize := False;   // Polaris
  FDirectInput := True;
  FClickKey := scAltDown;
  FPopupAlign := epaRight;
  FBtnControl := TWinControl.Create(Self);

  with FBtnControl do
    ControlStyle := ControlStyle + [csReplicatable];

  FBtnControl.Width := DefEditBtnWidth;
  FBtnControl.Height := 17;
  FBtnControl.Visible := True;
  FBtnControl.Parent := Self;
  FButton := TSpeedButton.Create(Self);
  FButton.SetBounds(0, 0, FBtnControl.Width, FBtnControl.Height);
  FButton.Visible := True;
  FButton.Parent := FBtnControl;
  TSpeedButton(FButton).OnClick := EditButtonClick;
  Height := 21;
  FDefNumGlyphs := 1;
  FGlyphKind := gkCustom;
end;

destructor TC4DCustomComboEdit.Destroy;
begin
  FButton.OnClick := nil;
  inherited Destroy;
end;
{$ENDREGION}

{$REGION 'TC4DCustomDateEdit'}
constructor TC4DCustomDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDateAutoBetween := True;
  FMinDate := NullDate;
  FMaxDate := NullDate;
  FErrorRaise := False;
  FBlanksChar := ' ';
  FTitle := 'Selecione uma Data';
  FPopupColor := clBtnFace;
  FDefNumGlyphs := 2;
  FStartOfWeek := Sun;// Mon;
  FWeekends := [Sun];
  FWeekendColor := $000080FF; //clRed;
  FYearDigits := dyDefault;
  FCalendarHints := TStringList.Create;
  TStringList(FCalendarHints).OnChange := CalendarHintsChanged;
  ControlState := ControlState + [csCreating];
  //CalendarStyle := dcsDefault;
  try
    UpdateFormat;

    FPopup := TC4DPopupWindow(CreatePopupCalendar(Self, BiDiMode, FMinDate, FMaxDate));
    TC4DPopupWindow(FPopup).OnCloseUp := PopupCloseUp;
    TC4DPopupWindow(FPopup).Color := FPopupColor;

    GlyphKind := gkDefault; { force update }
    FGlyphKind := gkCustom
  finally
    ControlState := ControlState - [csCreating];
  end;
end;

destructor TC4DCustomDateEdit.Destroy;
begin
  if FHooked then
  begin
    Application.UnhookMainWindow(FormatSettingsChange);
    FHooked := False;
  end;
  if FPopup <> nil then TC4DPopupWindow(FPopup).OnCloseUp := nil;
  FPopup.Free;
  FPopup := nil;
  TStringList(FCalendarHints).OnChange := nil;
  FCalendarHints.Free;
  FCalendarHints := nil;
  inherited Destroy;
end;

procedure TC4DCustomDateEdit.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited CreateWindowHandle(Params);
  if Handle <> 0 then
  begin
    UpdateMask;
    if not (csDesigning in ComponentState) and not (IsLibrary or FHooked) then
    begin
      Application.HookMainWindow(FormatSettingsChange);
      FHooked := True;
    end;
  end;
end;

procedure TC4DCustomDateEdit.DestroyWindowHandle;
begin
  if FHooked then
  begin
    Application.UnhookMainWindow(FormatSettingsChange);
    FHooked := False;
  end;
  inherited DestroyWindowHandle;
end;

procedure TC4DCustomDateEdit.UpdateFormat;
begin
  FDateFormat := DefDateFormat(FourDigitYear);
end;

function TC4DCustomDateEdit.GetDateFormat: string;
begin
  Result := FDateFormat;
end;

function TC4DCustomDateEdit.TextStored: Boolean;
begin
  Result := not IsEmptyStr(Text, [#0, ' ', FormatSettings.DateSeparator, FBlanksChar]);
end;

// Polaris
function TC4DCustomDateEdit.StoreMinDate: Boolean;
begin
  Result := FMinDate <> NullDate;
end;

function TC4DCustomDateEdit.StoreMaxDate: Boolean;
begin
  Result := FMaxDate <> NullDate;
end;
// Polaris

procedure TC4DCustomDateEdit.CheckValidDate;
begin
  if TextStored then
    try
      FFormatting := True;
      try
        SetDate(StrToDateFmt(FDateFormat, Text));
      finally
        FFormatting := False;
      end;
    except
      if not FErrorRaise then
        ShowMessage('Data informada é inválida')
      else
      begin
        Self.Date := 0;
        Invalidate;
      end;
      if CanFocus then SetFocus;
      if FErrorRaise then
        raise;
    end;
end;

procedure TC4DCustomDateEdit.Change;
begin
  if not FFormatting then inherited Change;
end;

procedure TC4DCustomDateEdit.CMExit(var Message: TCMExit);
begin
  if not (csDesigning in ComponentState) and CheckOnExit then
    CheckValidDate;
  inherited;
end;

function TC4DCustomDateEdit.GetDefaultBitmap(var DestroyNeeded: Boolean): TBitmap;
begin
  DestroyNeeded := False;
  if DateBitmap = nil then
  begin
    DateBitmap := TBitmap.Create;
    DateBitmap.Handle := LoadBitmap(hInstance, sDateBmp);
  end;
  Result := DateBitmap;
end;

procedure TC4DCustomDateEdit.SetBlanksChar(Value: Char);
begin
  if Value <> FBlanksChar then
  begin
    if (Value < ' ') then Value := ' ';
    FBlanksChar := Value;
    UpdateMask;
  end;
end;

procedure TC4DCustomDateEdit.UpdateMask;
var
  DateValue: TDateTime;
  OldFormat: string;
begin
  DateValue := GetDate;
  OldFormat := FDateFormat;
  UpdateFormat;
  if (GetDateMask <> EditMask) or (OldFormat <> FDateFormat) then
  begin
    { force update }
    EditMask := '';
    EditMask := GetDateMask;
  end;
  UpdatePopup;
  SetDate(DateValue);
end;

function TC4DCustomDateEdit.FormatSettingsChange(var Message: TMessage): Boolean;
begin
  Result := False;
  if (Message.Msg = WM_WININICHANGE)
    and Application.UpdateFormatSettings then
    UpdateMask;
end;

function TC4DCustomDateEdit.FourDigitYear: Boolean;
begin
  Result := (FYearDigits = dyFour) or ((FYearDigits = dyDefault) ///and
    ///(RxDateUtil.FourDigitYear))
  )

end;

function TC4DCustomDateEdit.GetDateMask: string;
begin
  Result := DefDateMask(FBlanksChar, FourDigitYear);
end;

// Polaris
procedure TC4DCustomDateEdit.SetMinDate(Value: TDateTime);
begin
  if Value <> FMinDate then
  begin
    if (Value <> NullDate) and (FMaxDate <> NullDate) and (Value > FMaxDate)
    then if FDateAutoBetween then SetMaxDate(Value)
    else
      ///raise Exception.CreateFmt(RxLoadStr(SDateMinLimit),[DateToStr(FMaxDate)]);
      //raise Exception.CreateFmt(SDateMinLimit,[DateToStr(FMaxDate)]);
      raise Exception.Create('Não foi possível setar a data mínima');
    FMinDate := Value;
    UpdatePopup;
    if FDateAutoBetween
      then SetDate(Date);
  end;
end;

procedure TC4DCustomDateEdit.SetMaxDate(Value: TDateTime);
begin
  if Value <> FMaxDate then
  begin
    if (Value <> NullDate) and (FMinDate <> NullDate) and (Value < FMinDate)
    then if FDateAutoBetween then SetMinDate(Value)
    else
      ///Exception.CreateFmt(RxLoadStr(SDateMinLimit),[DateToStr(FMinDate)]);
      raise Exception.Create('Não foi possível setar a data máximna');
    FMaxDate := Value;
    UpdatePopup;
    if FDateAutoBetween
      then SetDate(Date);
  end;
end;

function TC4DCustomDateEdit.GetDate: TDateTime;
begin
  if DefaultToday then Result := System.SysUtils.Date
  else Result := NullDate;
  Result := StrToDateFmtDef(FDateFormat, Text, Result);
end;

procedure TC4DCustomDateEdit.ValidateEdit;
begin
  if TextStored
  then CheckValidDate;
end;
// Polaris

procedure TC4DCustomDateEdit.SetDate(Value: TDateTime);
var
  D: TDateTime;
begin
  if not ValidDate(Value) or (Value = NullDate) then
  begin
    if DefaultToday then Value := System.SysUtils.Date
    else Value := NullDate;
  end;
  D := Date;
  TestDateBetween(Value);
  if Value = NullDate then Text := ''
  else Text := FormatDateTime(FDateFormat, Value);
  Modified := D <> Date;
end;

procedure TC4DCustomDateEdit.SetDateAutoBetween(Value: Boolean);
var
  D: TDateTime;
begin
//
  if Value <> FDateAutoBetween then
  begin
    FDateAutoBetween := Value;
    if Value then
    begin
      D := Date;
      TestDateBetween(D);
      if D <> Date then Date := D;
    end;
    Invalidate;
  end;
end;

procedure TC4DCustomDateEdit.TestDateBetween(var Value: TDateTime);
begin
  if FDateAutoBetween then
  begin
    if (FMinDate <> NullDate) and (Value <> NullDate) and (Value < FMinDate)
    then Value := FMinDate;
    if (FMaxDate <> NullDate) and (Value <> NullDate) and (Value > FMaxDate)
    then Value := FMaxDate;
  end;
end;

procedure TC4DCustomDateEdit.ApplyDate(Value: TDateTime);
begin
  SetDate(Value);
  SelectAll;
end;

function TC4DCustomDateEdit.GetDialogTitle: string;
begin
  Result := FTitle; ///
end;

procedure TC4DCustomDateEdit.SetDialogTitle(const Value: string);
begin
  FTitle := Value;
end;

function TC4DCustomDateEdit.IsCustomTitle: Boolean;
begin
  Result := ///(CompareStr(RxLoadStr(SDateDlgTitle), DialogTitle) <> 0) and
    (DialogTitle <> EmptyStr);    // Polaris
end;

procedure TC4DCustomDateEdit.UpdatePopup;
begin
  if FPopup <> nil then SetupPopupCalendar(FPopup, FStartOfWeek,
    FWeekends, FWeekendColor, FCalendarHints, FourDigitYear,
// Polaris
    FMinDate,
    FMaxDate
// Polaris
    );
end;

procedure TC4DCustomDateEdit.SetYearDigits(Value: TYearDigits);
begin
  if FYearDigits <> Value then
  begin
    FYearDigits := Value;
    UpdateMask;
  end;
end;

function TC4DCustomDateEdit.GetPopupColor: TColor;
begin
  if FPopup <> nil then Result := TC4DPopupWindow(FPopup).Color
  else Result := FPopupColor;
end;

procedure TC4DCustomDateEdit.SetPopupColor(Value: TColor);
begin
  if Value <> PopupColor then
  begin
    if FPopup <> nil then TC4DPopupWindow(FPopup).Color := Value;
    FPopupColor := Value;
  end;
end;

function TC4DCustomDateEdit.GetCalendarStyle: TCalendarStyle;
begin
  if FPopup <> nil then
    Result := csPopup
  else
    Result := csDialog;
end;

procedure TC4DCustomDateEdit.SetCalendarStyle(Value: TCalendarStyle);
begin
  if Value <> CalendarStyle then
  begin
    case Value of
      csPopup:
        begin
          if FPopup = nil then
            FPopup := TC4DPopupWindow(CreatePopupCalendar(Self, BiDiMode, FMinDate, FMaxDate));
          TC4DPopupWindow(FPopup).OnCloseUp := PopupCloseUp;
          TC4DPopupWindow(FPopup).Color := FPopupColor;
          UpdatePopup;
        end;
      csDialog:
        begin
          FPopup.Free;
          FPopup := nil;
        end;
    end;
  end;
end;

procedure TC4DCustomDateEdit.SetCalendarHints(Value: TStrings);
begin
  FCalendarHints.Assign(Value);
end;

procedure TC4DCustomDateEdit.CalendarHintsChanged(Sender: TObject);
begin
  TStringList(FCalendarHints).OnChange := nil;
  try
    while (FCalendarHints.Count > 4) do
      FCalendarHints.Delete(FCalendarHints.Count - 1);
  finally
    TStringList(FCalendarHints).OnChange := CalendarHintsChanged;
  end;
  if not (csDesigning in ComponentState) then UpdatePopup;
end;

procedure TC4DCustomDateEdit.SetWeekendColor(Value: TColor);
begin
  if Value <> FWeekendColor then
  begin
    FWeekendColor := Value;
    UpdatePopup;
  end;
end;

procedure TC4DCustomDateEdit.SetWeekends(Value: TDaysOfWeek);
begin
  if Value <> FWeekends then
  begin
    FWeekends := Value;
    UpdatePopup;
  end;
end;

procedure TC4DCustomDateEdit.SetStartOfWeek(Value: TDayOfWeekName);
begin
  if Value <> FStartOfWeek then
  begin
    FStartOfWeek := Value;
    UpdatePopup;
  end;
end;

procedure TC4DCustomDateEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key in [VK_PRIOR, VK_NEXT, VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN,
    VK_ADD, VK_SUBTRACT]) and
    PopupVisible then
  begin
    TC4DPopupWindow(FPopup).KeyDown(Key, Shift);
    Key := 0;
  end
  else if (Shift = []) and DirectInput then
  begin
    case Key of
      VK_ADD:
        begin
          ApplyDate(NvlDate(Date, Now) + 1);
          Key := 0;
        end;
      VK_SUBTRACT:
        begin
          ApplyDate(NvlDate(Date, Now) - 1);
          Key := 0;
        end;
    end;
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TC4DCustomDateEdit.KeyPress(var Key: Char);
begin
  if CharInSet(Key, ['T', 't', 'H', 'h', '+', '-']) and PopupVisible then
  begin
    TC4DPopupWindow(FPopup).KeyPress(Key);
    Key := #0;
  end
  else if DirectInput then
  begin
    case Key of
      'T', 't', 'H', 'h':
        begin
          ApplyDate(Trunc(Now));
          Key := #0;
        end;
      '+', '-':
        begin
          Key := #0;
        end;
    end;
  end;

  inherited KeyPress(Key);
end;

procedure TC4DCustomDateEdit.ButtonClick;
var
  D: TDateTime;
  Action: Boolean;
begin
  inherited ButtonClick;
  if CalendarStyle = csDialog then
  begin
    D := Self.Date;
    Action := SelectDate(Self, D, DialogTitle, FStartOfWeek, FWeekends, // Polaris (Self added)
      FWeekendColor, FCalendarHints, FMinDate, FMaxDate);   // Polaris

    if CanFocus then
      SetFocus;

    if Action then
    begin
      if Assigned(FOnAcceptDate) then FOnAcceptDate(Self, D, Action);
        if Action then
        begin
          Self.Date := D;
          if FFocused then
            inherited SelectAll;
        end;
    end;
  end;
end;


function TC4DCustomDateEdit.AcceptPopup(var Value: Variant): Boolean;
var
  D: TDateTime;
begin
  Result := True;
  if Assigned(FOnAcceptDate) then
  begin

    if VarIsNull(Value) or VarIsEmpty(Value) then D := NullDate
    else
      try
        D := VarToDateTime(Value);
      except
        if DefaultToday then D := System.SysUtils.Date else D := NullDate;
      end;

    FOnAcceptDate(Self, D, Result);

    if Result then Value := VarFromDateTime(D);

  end;
end;


procedure TC4DCustomDateEdit.SetPopupValue(const Value: Variant);
begin
  inherited SetPopupValue(StrToDateFmtDef(FDateFormat, VarToStr(Value),
    System.SysUtils.Date));
end;

procedure TC4DCustomDateEdit.AcceptValue(const Value: Variant);
begin
  if Text <> VarToStr(Value) then
  begin
    Text := Value;
    Modified := True;
    UpdatePopupVisible;
    DoChange;
  end;
end;
//FIM TCustomDateEdit
{$ENDREGION}

{$REGION 'TC4DPopupWindow'}
constructor TC4DPopupWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditor := TWinControl(AOwner);

  ControlStyle := ControlStyle + [csNoDesignVisible, csReplicatable, csAcceptsControls];

  Ctl3D := False;
  ParentCtl3D := False;
  Visible := False;
  Parent := FEditor;
  OnMouseUp := PopupMouseUp;
end;

procedure TC4DPopupWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP or WS_BORDER or WS_CLIPCHILDREN;

    ExStyle := WS_EX_TOOLWINDOW;

    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
  end;
end;

procedure TC4DPopupWindow.WMMouseActivate(var Message: TMessage);
begin
  Message.Result := MA_NOACTIVATE;
end;

function TC4DPopupWindow.GetPopupText: string;
begin
  Result := '';
end;

procedure TC4DPopupWindow.InvalidateEditor;
var
  R: TRect;
begin
  ///
  (*if (FEditor is TCustomComboEdit) then
  begin
    with TCustomComboEdit(FEditor) do
      SetRect(R, 0, 0, ClientWidth - FBtnControl.Width{Polaris - 2}, ClientHeight + 1);
  end
  else R := FEditor.ClientRect;  *)

  R := FEditor.ClientRect;
  InvalidateRect(FEditor.Handle, @R, False);
  UpdateWindow(FEditor.Handle);
end;

procedure TC4DPopupWindow.PopupMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then CloseUp(PtInRect(Self.ClientRect, Point(X, Y)));
end;

procedure TC4DPopupWindow.CloseUp(Accept: Boolean);
begin
  if Assigned(FCloseUp) then FCloseUp(Self, Accept);
end;

procedure TC4DPopupWindow.Hide;
begin
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
  Visible := False;
end;

procedure TC4DPopupWindow.Show(Origin: TPoint);
begin
  SetWindowPos(Handle, HWND_TOP, Origin.X, Origin.Y, 0, 0,
    SWP_NOACTIVATE or SWP_SHOWWINDOW or SWP_NOSIZE);
  Visible := True;
end;
{$ENDREGION}

procedure DestroyLocals; far;
begin
  FileBitmap.Free;
  FileBitmap := nil;
  DateBitmap.Free;
  DateBitmap := nil;
end;

initialization

finalization
  DestroyLocals;

end.
