unit C4D.DateEdit.Third.PickDate;

{$WARNINGS OFF}
{$HINTS OFF}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.Variants,
  System.StrUtils,
  Vcl.Controls,
  System.SysUtils,
  Vcl.Graphics,
  C4D.DateEdit.Third.Utils,
  C4D.DateEdit.Third.Utils.Dates;

function SelectDate(Sender: TWinControl; var Date: TDateTime; const DlgCaption: TCaption;
  AStartOfWeek: TDayOfWeekName; AWeekends: TDaysOfWeek;
  AWeekendColor: TColor; BtnHints: TStrings;
  MinDate: TDateTime = 0;
  MaxDate: TDateTime = 0 // Polaris
  ): Boolean;
function SelectDateStr(Sender: TWinControl; var StrDate: string; const DlgCaption: TCaption;
  AStartOfWeek: TDayOfWeekName; AWeekends: TDaysOfWeek;
  AWeekendColor: TColor; BtnHints: TStrings;
  MinDate: TDateTime = 0;
  MaxDate: TDateTime = 0
  ): Boolean; // Polaris
function PopupDate(var Date: TDateTime; Edit: TWinControl;
  MinDate: TDateTime = 0;
  MaxDate: TDateTime = 0
  ): Boolean;

{ Popup calendar }

function CreatePopupCalendar(AOwner: TComponent;
  ABiDiMode: TBiDiMode = bdLeftToRight;
  MinDate: TDateTime = 0;
  MaxDate: TDateTime = 0
  ): TWinControl;
procedure SetupPopupCalendar(PopupCalendar: TWinControl;
  AStartOfWeek: TDayOfWeekName; AWeekends: TDaysOfWeek;
  AWeekendColor: TColor; BtnHints: TStrings; FourDigitYear: Boolean;
  MinDate: TDateTime = 0;
  MaxDate: TDateTime = 0
  );

const
  PopupCalendarSize: TPoint = (X: 187; Y: 124);

implementation

uses
  Consts, Forms, Buttons, StdCtrls, Grids, ExtCtrls, C4D.DateEdit;

{.$R *.RES}

const
  SBtnGlyphs: array[0..3] of PChar = ('c4d_prev', 'c4d_prev1', 'c4d_next1', 'c4d_next2');
  BTN_HINT: array[0..3] of PChar = ('Voltar 1 ano', 'Voltar 1 mês', 'Avançar 1 mês', 'Avançar 1 ano');
  BTN_CAPTION: array[0..3] of PChar = ('|<', '<', '>', '>|');

procedure FontSetDefault(AFont: TFont);
var
  NonClientMetrics: TNonClientMetrics;
begin
  NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
  if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
    AFont.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont)
  else

    with AFont do
    begin
      Color := clWindowText;
      Name := 'Tahoma';
      Size := 8;
      Style := [];
    end;
end;

{ TC4DRxTimerSpeedButton }

type
  TC4DRxTimerSpeedButton = class(TSpeedButton)
  public
    constructor Create(AOwner: TComponent); override;
  published
    //property AllowTimer default True;
    //property Style default bsWin31;
  end;

constructor TC4DRxTimerSpeedButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //Style := bsWin31;
  //AllowTimer := True;

  //ControlStyle := ControlStyle + [csReplicatable];
  ShowHint := True;
  Font.Size := 6;
  Font.Name := 'Tahoma';
end;

{ TC4DRxCalendar }

{ TC4DRxCalendar implementation copied from Borland CALENDAR.PAS sample unit
  and modified }

type
  TDayOfWeek = 0..6;

  TC4DRxCalendar = class(TCustomGrid)
  private
//>Polaris
    FMinDate,
      FMaxDate: TDateTime;
//<Polaris
    FDate: TDateTime;
    FMonthOffset: Integer;
    FOnChange: TNotifyEvent;
    FReadOnly: Boolean;
    FStartOfWeek: TDayOfWeekName;
    FUpdating: Boolean;
    FUseCurrentDate: Boolean;
    FWeekends: TDaysOfWeek;
    FWeekendColor: TColor;
    function GetCellText(ACol, ARow: Integer): string;
    function GetDateElement(Index: Integer): Integer;
    procedure SetCalendarDate(Value: TDateTime);
    procedure SetDateElement(Index: Integer; Value: Integer);
    procedure SetStartOfWeek(Value: TDayOfWeekName);
    procedure SetUseCurrentDate(Value: Boolean);
    procedure SetWeekendColor(Value: TColor);
    procedure SetWeekends(Value: TDaysOfWeek);
    function IsWeekend(ACol, ARow: Integer): Boolean;
    procedure CalendarUpdate(DayOnly: Boolean);
    function StoreCalendarDate: Boolean;

//>Polaris
    procedure SetMinDate(Value: TDateTime);
    procedure SetMaxDate(Value: TDateTime);
//<Polaris
  protected
//>Polaris
    function GetCellDate(ACol, ARow: Integer): TDateTime;
    function CellInRange(ACol, ARow: Integer): Boolean;
    function DateInRange(ADate: TDateTime): Boolean;
//<Polaris
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Change; dynamic;
    procedure ChangeMonth(Delta: Integer);
    procedure Click; override;
    function DaysThisMonth: Integer;
    procedure DrawCell(ACol, ARow: LongInt; ARect: TRect; AState: TGridDrawState); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function SelectCell(ACol, ARow: LongInt): Boolean; override;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  public
    constructor Create(AOwner: TComponent); override;
    procedure NextMonth;
    procedure NextYear;
    procedure PrevMonth;
    procedure PrevYear;
    procedure UpdateCalendar; virtual;
    property CellText[ACol, ARow: Integer]: string read GetCellText;
  published
    property CalendarDate: TDateTime read FDate write SetCalendarDate
      stored StoreCalendarDate;
    property Day: Integer index 3 read GetDateElement write SetDateElement stored False;
    property Month: Integer index 2 read GetDateElement write SetDateElement stored False;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property StartOfWeek: TDayOfWeekName read FStartOfWeek write SetStartOfWeek default Mon;
    property UseCurrentDate: Boolean read FUseCurrentDate write SetUseCurrentDate default True;
    property WeekendColor: TColor read FWeekendColor write SetWeekendColor default clRed;
    property Weekends: TDaysOfWeek read FWeekends write SetWeekends default [Sun];
    property Year: Integer index 1 read GetDateElement write SetDateElement stored False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property MinDate: TDateTime read FMinDate write SetMinDate stored False;
    property MaxDate: TDateTime read FMaxDate write SetMaxDate stored False;
  end;

constructor TC4DRxCalendar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
//>Polaris
  FMinDate := NullDate;
  FMaxDate := NullDate;
//<Polaris
  FUseCurrentDate := True;
  FStartOfWeek := Mon;
  FWeekends := [Sun];
  FWeekendColor := clRed;
  FixedCols := 0;
  FixedRows := 1;
  ColCount := 7;
  RowCount := 7;
  ScrollBars := ssNone;
  Options := Options - [goRangeSelect] + [goDrawFocusSelected];
  ControlStyle := ControlStyle + [csFramed];
  FDate := Date;
  UpdateCalendar;
end;

procedure TC4DRxCalendar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_BORDER;

  Params.ExStyle := Params.ExStyle and not WS_EX_CLIENTEDGE;

  AddBiDiModeExStyle(Params.ExStyle);
end;

procedure TC4DRxCalendar.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TC4DRxCalendar.Click;
var
  TheCellText: string;
begin
  inherited Click;
  TheCellText := CellText[Col, Row];
  if (TheCellText <> '') then Day := StrToInt(TheCellText);
end;

function TC4DRxCalendar.DaysThisMonth: Integer;
begin
  Result := DaysPerMonth(Year, Month);
end;

procedure TC4DRxCalendar.DrawCell(ACol, ARow: LongInt; ARect: TRect; AState: TGridDrawState);
var
  TheText: string;
//>Polaris

  procedure DefaultDraw;
  begin
    if TheText <> EmptySTr then
      with ARect, Canvas do
      begin
        Brush.Style := bsClear;
        TextRect(ARect, Left + (Right - Left - TextWidth(TheText)) div 2,
          Top + (Bottom - Top - TextHeight(TheText)) div 2, TheText);
      end;
  end;

  procedure PoleDraw;
  begin
    with ARect, Canvas do
    begin
      if (ARow > 0) and ((FMinDate <> NulLDate) or (FMaxDate <> NulLDate)) then
      begin
        if not CellInRange(ACol, ARow) then
        begin
          if TheText <> EmptyStr then
          begin
            Font.Color := clBtnFace;
            if Color = clBtnFace then
            begin
              Font.Color := clBtnHighlight;
              TextRect(ARect, Left + (Right - Left - TextWidth(TheText)) div 2 + 1,
                Top + (Bottom - Top - TextHeight(TheText)) div 2 + 1, TheText);
              Font.Color := clBtnShadow;
            end;
          end;
        end;
      end;
      DefaultDraw;
    end;
  end;

  function IsNumber(S: string): Boolean;
  var
    I: Integer;
  begin
    Result := TryStrToInt(S, I);
  end;
//<Polaris
begin
  TheText := CellText[ACol, ARow];
  with ARect, Canvas do
  begin
    if IsNumber(TheText) then
      if IsFeriado(EncodeDate(Year, Month, StrToInt(TheText))) then
        Font.Color := clBlue;

    if IsWeekend(ACol, ARow) and not (gdSelected in AState) then
      Font.Color := WeekendColor;

    PoleDraw;
{
      TextRect(ARect, Left + (Right - Left - TextWidth(TheText)) div 2,
        Top + (Bottom - Top - TextHeight(TheText)) div 2, TheText);

}
  end;
end;

function TC4DRxCalendar.GetCellText(ACol, ARow: Integer): string;
var
  DayNum: Integer;
begin
  if ARow = 0 then { day names at tops of columns }
    Result := FormatSettings.ShortDayNames[(Ord(StartOfWeek) + ACol) mod 7 + 1]
  else
  begin
    DayNum := FMonthOffset + ACol + (ARow - 1) * 7;
    if (DayNum < 1) or (DayNum > DaysThisMonth) then
      Result := ''
    else
      Result := IntToStr(DayNum);
  end;
end;

//>Polaris

procedure TC4DRxCalendar.SetMinDate(Value: TDateTime);
begin
  if FMinDate <> Value then
  begin
    FMinDate := Value;
    if (FDate < FMinDate) then
      SetCalendarDate(FMinDate)
        ;
//    else
    UpdateCalendar;
  end;
end;

procedure TC4DRxCalendar.SetMaxDate(Value: TDateTime);
begin
  if FMaxDate <> Value then
  begin
    FMaxDate := Value;
    if (FDate > FMaxDate) then
      SetCalendarDate(FMaxDate)
        ;
//    else
    UpdateCalendar;
  end;
end;

function TC4DRxCalendar.GetCellDate(ACol, ARow: Integer): TDateTime;
var
  DayNum: Integer;
begin
  Result := NullDate;
  if (ARow > 0) and (GetCellText(ACol, ARow) <> EmptyStr) then
  begin
    DayNum := FMonthOffset + ACol + (ARow - 1) * 7;
    if (DayNum < 1) or (DayNum > DaysThisMonth) then
      Result := NullDate
    else
      Result := EncodeDate(GetDateElement(1), GetDateElement(2), DayNum);
  end;
end;

function TC4DRxCalendar.CellInRange(ACol, ARow: Integer): Boolean;
begin
  if (Row < 1) {or ((FMinDate = NullDate) and (FMaxDate = NullDate))} then
    Result := True
  else
    Result := DateInRange(GetCellDate(ACol, ARow));
end;

function TC4DRxCalendar.DateInRange(ADate: TDateTime): Boolean;
begin
  if ((FMinDate = NullDate) and (FMaxDate = NullDate)) or (ADate = NullDate) then
    Result := True
  else
  begin
    Result := False;
    if (ADate = NullDate) then
      Result := True
    else if (FMinDate <> NullDate) and (FMaxDate <> NullDate) then
      Result := (ADate >= FMinDate) and (ADate <= FMaxDate)
    else if FMinDate <> NullDate then
      Result := ADate >= FMinDate
    else if FMaxDate <> NullDate then
      Result := ADate <= FMaxDate
  end;
end;
//<Polaris

procedure TC4DRxCalendar.KeyDown(var Key: Word; Shift: TShiftState);
//>Polaris
var
  OldDay: Integer;
//<Polaris
begin
  OldDay := Day;
  if Shift = [] then
    case Key of
      VK_LEFT, VK_SUBTRACT:
        begin
          if (Day > 1) then
            Day := Day - 1
          else
            CalendarDate := CalendarDate - 1;
          if not DateInRange(FDate) then Day := OldDay;
          Exit;
        end;
      VK_RIGHT, VK_ADD:
        begin
          if (Day < DaysThisMonth) then
            Day := Day + 1
          else
            CalendarDate := CalendarDate + 1;
          if not DateInRange(FDate) then Day := OldDay;
          Exit;
        end
    end;
  inherited KeyDown(Key, Shift);
end;

procedure TC4DRxCalendar.KeyPress(var Key: Char);
begin
  if CharInSet(Key, ['T', 't']) then
  begin
    CalendarDate := Trunc(Now);
    Key := #0;
  end;
  inherited KeyPress(Key);
end;

function TC4DRxCalendar.SelectCell(ACol, ARow: LongInt): Boolean;
begin
  if ((not FUpdating) and FReadOnly) or (CellText[ACol, ARow] = '')
//>Polaris
  or not CellInRange(ACol, ARow)
{//<Polaris} then
    Result := False
  else
    Result := inherited SelectCell(ACol, ARow);
end;

procedure TC4DRxCalendar.SetCalendarDate(Value: TDateTime);
begin
//  if FDate <> Value then begin
  if (FMinDate <> NullDate) and (Value < FMinDate) then
    Value := FMinDate
  else if (FMaxDate <> NullDate) and (Value > FMaxDate) then
    Value := FMaxDate;
  FDate := Value;
  UpdateCalendar;
  Change;
//  end;
end;

function TC4DRxCalendar.StoreCalendarDate: Boolean;
begin
  Result := not FUseCurrentDate;
end;

function TC4DRxCalendar.GetDateElement(Index: Integer): Integer;
var
  AYear, AMonth, ADay: Word;
begin
  DecodeDate(FDate, AYear, AMonth, ADay);
  case Index of
    1: Result := AYear;
    2: Result := AMonth;
    3: Result := ADay;
  else
    Result := -1;
  end;
end;

procedure TC4DRxCalendar.SetDateElement(Index: Integer; Value: Integer);
var
  iValue: Word;
  TYear, TMonth, TDay: Word;
  AYear, AMonth, ADay: Word;
//>Polaris
  TmpDate: TDateTime;
//<Polaris
begin
  if Value > 0 then
  begin
    DecodeDate(FDate, AYear, AMonth, ADay);
    iValue := Value;
    case Index of
      1:
        begin
//>Polaris
          if FMinDate <> NullDate then
          begin
            DecodeDate(FMinDate, TYear, TMonth, TDay);
            if Value < TYear then Value := TYear;
            if (Value = TYear) and (AMonth < TMonth) then AMonth := TMonth;
            if (Value = TYear) and (AMonth = TMonth) and (ADay < TDay) then ADay := TDay;
          end;
          if FMaxDate <> NullDate then
          begin
            DecodeDate(FMaxDate, TYear, TMonth, TDay);
            if Value > TYear then Value := TYear;
            if (Value = TYear) and (AMonth > TMonth) then AMonth := TMonth;
            if (Value = TYear) and (AMonth = TMonth) and (ADay > TDay) then ADay := TDay;
          end;
//<Polaris
          if AYear <> Value then
            AYear := Value
          else
            Exit;
        end;
      2: if (Value <= 12) and (Value <> AMonth) then
        begin
//>Polaris
          if FMinDate <> NullDate then
          begin
            DecodeDate(FMinDate, TYear, TMonth, TDay);
            if (AYear = TYear) and (Value < TMonth) then Value := TMonth;
            if (Value = TYear) and (AMonth = TMonth) and (ADay < TDay) then ADay := TDay;
          end;
          if FMaxDate <> NullDate then
          begin
            DecodeDate(FMaxDate, TYear, TMonth, TDay);
            if (AYear = TYear) and (Value > TMonth) then Value := TMonth;
            if (Value = TYear) and (AMonth = TMonth) and (ADay > TDay) then ADay := TDay;
          end;
//<Polaris

          AMonth := Value;
          if ADay > DaysPerMonth(Year, Value) then
            ADay := DaysPerMonth(Year, Value);
//>Polaris
{
          TmpDate := EncodeDate(AYear, AMonth, ADay);
          if (FMinDate <> NullDate) and (TmpDate < FMinDate) then DecodeDate(FMinDate, TYear, TMonth, ADay);
          if (FMaxDate <> NullDate) and (TmpDate > FMaxDate) then DecodeDate(FMaxDate, TYear, TMonth, ADay)
}
//<Polaris
        end
        else
          Exit;
      3: if (Value <= DaysThisMonth) and (Value <> ADay) then
        begin
//>Polaris
          TmpDate := EncodeDate(AYear, AMonth, Value);
          if (FMinDate <> NullDate) and (TmpDate < FMinDate) then DecodeDate(FMinDate, TYear, TMonth, iValue);
          if (FMaxDate <> NullDate) and (TmpDate > FMaxDate) then DecodeDate(FMaxDate, TYear, TMonth, iValue);
//<Polaris
          ADay := iValue
        end
        else
          Exit;
    else
      Exit;
    end;
    FDate := EncodeDate(AYear, AMonth, ADay);
    FUseCurrentDate := False;
    CalendarUpdate(Index = 3);
    Change;
  end;
end;

procedure TC4DRxCalendar.SetWeekendColor(Value: TColor);
begin
  if Value <> FWeekendColor then
  begin
    FWeekendColor := Value;
    Invalidate;
  end;
end;

procedure TC4DRxCalendar.SetWeekends(Value: TDaysOfWeek);
begin
  if Value <> FWeekends then
  begin
    FWeekends := Value;
    UpdateCalendar;
  end;
end;

function TC4DRxCalendar.IsWeekend(ACol, ARow: Integer): Boolean;
begin
  Result := TDayOfWeekName((Integer(StartOfWeek) + ACol) mod 7) in FWeekends;
end;

procedure TC4DRxCalendar.SetStartOfWeek(Value: TDayOfWeekName);
begin
  if Value <> FStartOfWeek then
  begin
    FStartOfWeek := Value;
    UpdateCalendar;
  end;
end;

procedure TC4DRxCalendar.SetUseCurrentDate(Value: Boolean);
begin
  if Value <> FUseCurrentDate then
  begin
    FUseCurrentDate := Value;
    if Value then
    begin
      FDate := Date; { use the current date, then }
      UpdateCalendar;
    end;
  end;
end;

{ Given a value of 1 or -1, moves to Next or Prev month accordingly }

procedure TC4DRxCalendar.ChangeMonth(Delta: Integer);
var
  AYear, AMonth, ADay: Word;
  NewDate: TDateTime;
  CurDay: Integer;
begin
  DecodeDate(FDate, AYear, AMonth, ADay);
  CurDay := ADay;
  if Delta > 0 then
    ADay := DaysPerMonth(AYear, AMonth)
  else
    ADay := 1;
  NewDate := EncodeDate(AYear, AMonth, ADay);
  NewDate := NewDate + Delta;
  DecodeDate(NewDate, AYear, AMonth, ADay);
  if DaysPerMonth(AYear, AMonth) > CurDay then
    ADay := CurDay
  else
    ADay := DaysPerMonth(AYear, AMonth);
  CalendarDate := EncodeDate(AYear, AMonth, ADay);
end;

procedure TC4DRxCalendar.PrevMonth;
begin
  ChangeMonth(-1);
end;

procedure TC4DRxCalendar.NextMonth;
begin
  ChangeMonth(1);
end;

procedure TC4DRxCalendar.NextYear;
begin
  if IsLeapYear(Year) and (Month = 2) and (Day = 29) then Day := 28;
  Year := Year + 1;
end;

procedure TC4DRxCalendar.PrevYear;
begin
  if IsLeapYear(Year) and (Month = 2) and (Day = 29) then Day := 28;
  Year := Year - 1;
end;

procedure TC4DRxCalendar.CalendarUpdate(DayOnly: Boolean);
var
  AYear, AMonth, ADay: Word;
  FirstDate: TDateTime;
begin
  FUpdating := True;
  try
    DecodeDate(FDate, AYear, AMonth, ADay);
    FirstDate := EncodeDate(AYear, AMonth, 1);
    FMonthOffset := 2 - ((DayOfWeek(FirstDate) - Ord(StartOfWeek) + 7) mod 7);
      { day of week for 1st of month }
    if FMonthOffset = 2 then FMonthOffset := -5;
    MoveColRow((ADay - FMonthOffset) mod 7, (ADay - FMonthOffset) div 7 + 1,
      False, False);
    if DayOnly then
      Update
    else
      Invalidate;
  finally
    FUpdating := False;
  end;
end;

procedure TC4DRxCalendar.UpdateCalendar;
begin
  CalendarUpdate(False);
end;

procedure TC4DRxCalendar.WMSize(var Message: TWMSize);
var
  GridLinesH, GridLinesW: Integer;
begin
  GridLinesH := 6 * GridLineWidth;
  if (goVertLine in Options) or (goFixedVertLine in Options) then
    GridLinesW := 6 * GridLineWidth
  else
    GridLinesW := 0;
  DefaultColWidth := (Message.Width - GridLinesW) div 7;
  DefaultRowHeight := (Message.Height - GridLinesH) div 7;
end;

{ TLocCalendar }

type
  TLocCalendar = class(TC4DRxCalendar)
  private
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var Message: TMessage); message CM_PARENTCOLORCHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DrawCell(ACol, ARow: LongInt; ARect: TRect; AState: TGridDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure MouseToCell(X, Y: Integer; var ACol, ARow: LongInt);
    property GridLineWidth;
    property DefaultColWidth;
    property DefaultRowHeight;
  end;

constructor TLocCalendar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks];

  ControlStyle := ControlStyle + [csReplicatable];

  Ctl3D := False;
  Enabled := False;
  BorderStyle := Forms.bsNone;
  ParentColor := True;
  CalendarDate := Trunc(Now);
  UseCurrentDate := False;
  FixedColor := Self.Color;
  Options := [goFixedHorzLine];
  TabStop := False;
end;

procedure TLocCalendar.CMParentColorChanged(var Message: TMessage);
begin
  inherited;
  if ParentColor then FixedColor := Self.Color;
end;

procedure TLocCalendar.CMEnabledChanged(var Message: TMessage);
begin
  if HandleAllocated and not (csDesigning in ComponentState) then
    EnableWindow(Handle, True);
end;

procedure TLocCalendar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not (WS_BORDER or WS_TABSTOP or WS_DISABLED);
end;

procedure TLocCalendar.MouseToCell(X, Y: Integer; var ACol, ARow: LongInt);
var
  Coord: TGridCoord;
begin
  Coord := MouseCoord(X, Y);
  ACol := Coord.X;
  ARow := Coord.Y;
end;

procedure TLocCalendar.DrawCell(ACol, ARow: LongInt; ARect: TRect;
  AState: TGridDrawState);
var
  D, M, Y: Word;
begin
  inherited DrawCell(ACol, ARow, ARect, AState);
  DecodeDate(CalendarDate, Y, M, D);
  D := StrToIntDef(CellText[ACol, ARow], 0);
  if (D > 0) and (D <= DaysPerMonth(Y, M)) then
  begin
    if (EncodeDate(Y, M, D) = System.SysUtils.Date) then
      Frame3D(Canvas, ARect, clBtnShadow, clBtnHighlight, 1);
  end;
end;

{ TPopupCalendar }

type
  TPopupCalendar = class(TC4DPopupWindow)
  private
    FCalendar: TC4DRxCalendar;
    FTitleLabel: TLabel;
    FFourDigitYear: Boolean;
    FBtns: array[0..3] of TSpeedButton;
    procedure CalendarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PrevMonthBtnClick(Sender: TObject);
    procedure NextMonthBtnClick(Sender: TObject);
    procedure PrevYearBtnClick(Sender: TObject);
    procedure NextYearBtnClick(Sender: TObject);
    procedure CalendarChange(Sender: TObject);
    procedure TopPanelDblClick(Sender: TObject);
//>Polaris
//    function GetDate(Index: Integer): TDate;
    procedure SetDate(Index: Integer; Value: TDateTime);
//<Polaris
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

    function GetValue: Variant; override;
    procedure SetValue(const Value: Variant); override;

//>Polaris
    procedure CheckButton;
//<Polaris
  public
    constructor Create(AOwner: TComponent); override;
//>Polaris
    procedure Invalidate; override;
    procedure Update; override;
    property MinDate: TDateTime index 0 {read GetDate} write SetDate;
    property MaxDate: TDateTime index 1 {read GetDate} write SetDate;

//<Polaris
  end;

function CreatePopupCalendar(AOwner: TComponent;
  ABiDiMode: TBiDiMode = bdLeftToRight;
  MinDate: TDateTime = 0;
  MaxDate: TDateTime = 0
  ): TWinControl;
begin
  Result := TPopupCalendar.Create(AOwner);
  if (AOwner <> nil) and not (csDesigning in AOwner.ComponentState) and
    (Screen.PixelsPerInch <> 96) then
  begin { scale to screen res }
    Result.ScaleBy(Screen.PixelsPerInch, 96);
    { The ScaleBy method does not scale the font well, so set the
      font back to the original info. }
    TPopupCalendar(Result).FCalendar.ParentFont := True;
    TPopupCalendar(Result).FCalendar.MinDate := MinDate;
    TPopupCalendar(Result).FCalendar.MaxDate := MaxDate;
    FontSetDefault(TPopupCalendar(Result).Font);
    Result.BiDiMode := ABiDiMode;
  end;
end;

procedure SetupPopupCalendar(PopupCalendar: TWinControl;
  AStartOfWeek: TDayOfWeekName; AWeekends: TDaysOfWeek;
  AWeekendColor: TColor; BtnHints: TStrings; FourDigitYear: Boolean;
  MinDate: TDateTime;
  MaxDate: TDateTime
  );
var
  I: Integer;
begin
  if (PopupCalendar = nil) or not (PopupCalendar is TPopupCalendar) then
    Exit;
// Polaris
  if not (csDesigning in PopupCalendar.Owner.ComponentState) then
  begin
    TPopupCalendar(PopupCalendar).SetDate(0, MinDate);
    TPopupCalendar(PopupCalendar).SetDate(1, MaxDate);
  end;
// Polaris
//  TPopupCalendar(PopupCalendar).MaxDate := MaxDate;

  TPopupCalendar(PopupCalendar).FFourDigitYear := FourDigitYear;
  if TPopupCalendar(PopupCalendar).FCalendar <> nil then
  begin
    with TPopupCalendar(PopupCalendar).FCalendar do
    begin
      StartOfWeek := AStartOfWeek;
      WeekendColor := AWeekendColor;
      Weekends := AWeekends;
    end;
    if (BtnHints <> nil) then
      for I := 0 to Min(BtnHints.Count - 1, 3) do
      begin
        if BtnHints[I] <> '' then
          TPopupCalendar(PopupCalendar).FBtns[I].Hint := BtnHints[I];
      end;
  end;
end;

constructor TPopupCalendar.Create(AOwner: TComponent);
const
  BTN_SIZE = 20;
  PN_RODAPE_HEIGHT = 20;
var
  Control, BackPanel: TWinControl;
  LPnRodape: TWinControl;
begin
  inherited Create(AOwner);
  FFourDigitYear := FourDigitYear;
  Height := Max(PopupCalendarSize.Y, 120 + PN_RODAPE_HEIGHT);
  Width := Max(PopupCalendarSize.X, 180);
  Color := clBtnFace;
  FontSetDefault(Font);
  if AOwner is TControl then
    ShowHint := TControl(AOwner).ShowHint
  else
    ShowHint := True;
  if (csDesigning in ComponentState) then
    Exit;

  BackPanel := TPanel.Create(Self);
  with BackPanel as TPanel do
  begin
    Parent := Self;
    Align := alClient;
    ParentColor := True;
    ControlStyle := ControlStyle + [csReplicatable];
  end;

  Control := TPanel.Create(Self);
  with Control as TPanel do
  begin
    Parent := BackPanel;
    Align := alTop;
    Width := Self.Width - 4;
    Height := 22; //18;
    BevelOuter := bvNone;
    ParentColor := True;
    ControlStyle := ControlStyle + [csReplicatable];
  end;

  FCalendar := TLocCalendar.Create(Self);
  with TLocCalendar(FCalendar) do
  begin
    Parent := BackPanel;
    Align := alClient;
    OnChange := CalendarChange;
    OnMouseUp := CalendarMouseUp;
  end;

  //**
  LPnRodape := TPanel.Create(Self);
  with LPnRodape as TPanel do
  begin
    Parent := BackPanel;
    Align := alBottom;
    Width := Self.Width - 4;
    Height := PN_RODAPE_HEIGHT;
    BevelOuter := bvNone;
    ParentColor := True;
    ControlStyle := ControlStyle + [csReplicatable];
    Caption := 'Hoje: ' + DateToStr(Date);
  end;
  //**

  FBtns[0] := TC4DRxTimerSpeedButton.Create(Self);
  with FBtns[0] do
  begin
    Parent := Control;
    SetBounds(-1, -1, BTN_SIZE, BTN_SIZE);
    //Glyph.Handle := LoadBitmap(hInstance, SBtnGlyphs[0]);
    OnClick := PrevYearBtnClick;
    Hint := BTN_HINT[0];
    Caption := BTN_CAPTION[0];
  end;

  FBtns[1] := TC4DRxTimerSpeedButton.Create(Self);
  with FBtns[1] do
  begin
    Parent := Control;
    SetBounds(BTN_SIZE - 2, -1, BTN_SIZE, BTN_SIZE);
    //Glyph.Handle := LoadBitmap(hInstance, SBtnGlyphs[1]);
    OnClick := PrevMonthBtnClick;
    Hint := BTN_HINT[1];
    Caption :=BTN_CAPTION[1];
  end;

  FTitleLabel := TLabel.Create(Self);
  with FTitleLabel do
  begin
    Parent := Control;
    AutoSize := False;
    Alignment := taCenter;
    SetBounds(BTN_SIZE * 2 + 1, 1, Control.Width - 4 * BTN_SIZE - 2, BTN_SIZE); //14
    Transparent := True;
    OnDblClick := TopPanelDblClick;
    ControlStyle := ControlStyle + [csReplicatable];
  end;

  FBtns[2] := TC4DRxTimerSpeedButton.Create(Self);
  with FBtns[2] do
  begin
    Parent := Control;
    SetBounds(Control.Width - 2 * BTN_SIZE + 2, -1, BTN_SIZE, BTN_SIZE);
    //Glyph.Handle := LoadBitmap(hInstance, SBtnGlyphs[2]);
    OnClick := NextMonthBtnClick;
    Hint := BTN_HINT[2];
    Caption := BTN_CAPTION[2];
  end;

  FBtns[3] := TC4DRxTimerSpeedButton.Create(Self);
  with FBtns[3] do
  begin
    Parent := Control;
    SetBounds(Control.Width - BTN_SIZE + 1, -1, BTN_SIZE, BTN_SIZE);
    //Glyph.Handle := LoadBitmap(hInstance, SBtnGlyphs[3]);
    OnClick := NextYearBtnClick;
    Hint := BTN_HINT[3];
    Caption := BTN_CAPTION[3];
  end;

  CheckButton;
end;

//>Polaris

procedure TPopupCalendar.CheckButton;
var
//  CurDate: TDate;
  AYear, AMonth, ADay: Word;
begin
  if not Assigned(FCalendar) then Exit;
//  CurDate := TLocCalendar(FCalendar).CalendarDate;
  if TLocCalendar(FCalendar).MinDate = NullDate then
    for AYear := 0 to 1 do
      FBtns[AYear].Enabled := True
  else
  begin
    DecodeDate(TLocCalendar(FCalendar).MinDate, AYear, AMonth, ADay);
    FBtns[0].Enabled := TLocCalendar(FCalendar).Year > AYear;
    FBtns[1].Enabled := (TLocCalendar(FCalendar).Year > AYear) or ((TLocCalendar(FCalendar).Year = AYear) and (TLocCalendar(FCalendar).Month > AMonth));
  end;
  if TLocCalendar(FCalendar).MaxDate = NullDate then
    for AYear := 2 to 3 do
      FBtns[AYear].Enabled := True
  else
  begin
    DecodeDate(TLocCalendar(FCalendar).MaxDate, AYear, AMonth, ADay);
    FBtns[2].Enabled := (TLocCalendar(FCalendar).Year < AYear) or ((TLocCalendar(FCalendar).Year = AYear) and (TLocCalendar(FCalendar).Month < AMonth));
    FBtns[3].Enabled := TLocCalendar(FCalendar).Year < AYear;
  end;
end;

procedure TPopupCalendar.Invalidate;
begin
  CheckButton;
  inherited Invalidate;
end;

procedure TPopupCalendar.Update;
begin
  CheckButton;
  inherited Update;
end;

{
function TPopupCalendar.GetDate(Index: Integer): TDateTime;
begin
  FCalendar.Min
  case Index of
  0: Result := TLocCalendar(FCalendar).FMinDate;
  1: Result := TLocCalendar(FCalendar).FMaxDate;
  else Result := NullDate;
  end;
end;
}

procedure TPopupCalendar.SetDate(Index: Integer; Value: TDateTime);
begin
  case Index of
    0: TLocCalendar(FCalendar).FMinDate := Value;
    1: TLocCalendar(FCalendar).FMaxDate := Value;
  end;
end;

//<Polaris

procedure TPopupCalendar.CalendarMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Col, Row: LongInt;
begin
  if (Button = mbLeft) and (Shift = []) then
  begin
    TLocCalendar(FCalendar).MouseToCell(X, Y, Col, Row);
    if (Row > 0) and (FCalendar.CellText[Col, Row] <> '') then
      CloseUp(True);
  end;
end;

procedure TPopupCalendar.TopPanelDblClick(Sender: TObject);
begin
  FCalendar.CalendarDate := Trunc(Now);
end;

procedure TPopupCalendar.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if FCalendar <> nil then
    case Key of
      VK_NEXT:
        begin
          if ssCtrl in Shift then
            FCalendar.NextYear
          else
            FCalendar.NextMonth;
        end;
      VK_PRIOR:
        begin
          if ssCtrl in Shift then
            FCalendar.PrevYear
          else
            FCalendar.PrevMonth;
        end;
    else
      TLocCalendar(FCalendar).KeyDown(Key, Shift);
    end;
end;

procedure TPopupCalendar.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (FCalendar <> nil) and (Key <> #0) then
    FCalendar.KeyPress(Key);
end;


function TPopupCalendar.GetValue: Variant;
begin
  if (csDesigning in ComponentState) then
    Result := VarFromDateTime(System.SysUtils.Date)
  else
    Result := VarFromDateTime(FCalendar.CalendarDate);
end;

procedure TPopupCalendar.SetValue(const Value: Variant);
begin
  if not (csDesigning in ComponentState) then
  begin
    try
      if (Trim(ReplaceStr(VarToStr(Value), FormatSettings.DateSeparator, '')) = '') or
        VarIsNull(Value) or VarIsEmpty(Value) then
        FCalendar.CalendarDate := VarToDateTime(System.SysUtils.Date)
      else
        FCalendar.CalendarDate := VarToDateTime(Value);
      CalendarChange(nil);
    except
      FCalendar.CalendarDate := VarToDateTime(System.SysUtils.Date);
    end;
  end;
end;

procedure TPopupCalendar.PrevYearBtnClick(Sender: TObject);
begin
  FCalendar.PrevYear;
end;

procedure TPopupCalendar.NextYearBtnClick(Sender: TObject);
begin
  FCalendar.NextYear;
end;

procedure TPopupCalendar.PrevMonthBtnClick(Sender: TObject);
begin
  FCalendar.PrevMonth;
end;

procedure TPopupCalendar.NextMonthBtnClick(Sender: TObject);
begin
  FCalendar.NextMonth;
end;

procedure TPopupCalendar.CalendarChange(Sender: TObject);
begin
  FTitleLabel.Caption := FormatDateTime('MMMM, YYYY', FCalendar.CalendarDate);
  CheckButton;
end;

{ TSelectDateDlg }

type
  TSelectDateDlg = class(TForm)
    Calendar: TC4DRxCalendar;
    TitleLabel: TLabel;
    procedure PrevMonthBtnClick(Sender: TObject);
    procedure NextMonthBtnClick(Sender: TObject);
    procedure PrevYearBtnClick(Sender: TObject);
    procedure NextYearBtnClick(Sender: TObject);
    procedure CalendarChange(Sender: TObject);
    procedure CalendarDblClick(Sender: TObject);
    procedure TopPanelDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FBtns: array[0..3] of TSpeedButton;
    procedure SetDate(Date: TDateTime);
    procedure CheckButton;
    function GetDate: TDateTime;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property Date: TDateTime read GetDate write SetDate;
  end;

constructor TSelectDateDlg.Create(AOwner: TComponent);
const
  SDateDlgTitle = 'Selecione uma Data';
var
  Control: TWinControl;
begin
  inherited CreateNew(AOwner);
  Caption := SDateDlgTitle;

  BorderStyle := bsToolWindow;

  BorderIcons := [biSystemMenu];
  ClientHeight := 158; // Polaris
  ClientWidth := 222;
  FontSetDefault(Font);
  Color := clBtnFace;
  Position := poScreenCenter;
  ShowHint := True;
  KeyPreview := True;

  Control := TPanel.Create(Self);
  with Control as TPanel do
  begin
    Parent := Self;
    SetBounds(0, 0, 222, 22);
    Align := alTop;
    BevelInner := bvLowered;
    ParentColor := True;
    ParentFont := True;
  end;

  TitleLabel := TLabel.Create(Self);
  with TitleLabel do
  begin
    Parent := Control;
    SetBounds(35, 4, 152, 14);
    Alignment := taCenter;
    AutoSize := False;
    Caption := '';
    ParentFont := True;
    Font.Color := clBlue;
    Font.Style := [fsBold];
    Transparent := True;
    OnDblClick := TopPanelDblClick;
  end;

  FBtns[0] := TC4DRxTimerSpeedButton.Create(Self);
  with FBtns[0] do
  begin
    Parent := Control;
    SetBounds(3, 3, 16, 16);
    //Glyph.Handle := LoadBitmap(hInstance, SBtnGlyphs[0]);
    OnClick := PrevYearBtnClick;
    Hint := BTN_HINT[0];
    Caption := BTN_CAPTION[0];
  end;

  FBtns[1] := TC4DRxTimerSpeedButton.Create(Self);
  with FBtns[1] do
  begin
    Parent := Control;
    SetBounds(18, 3, 16, 16);
    //Glyph.Handle := LoadBitmap(hInstance, SBtnGlyphs[1]);
    OnClick := PrevMonthBtnClick;
    Hint := BTN_HINT[1];
    Caption := BTN_CAPTION[1];
  end;

  FBtns[2] := TC4DRxTimerSpeedButton.Create(Self);
  with FBtns[2] do
  begin
    Parent := Control;
    SetBounds(188, 3, 16, 16);
    //Glyph.Handle := LoadBitmap(hInstance, SBtnGlyphs[2]);
    OnClick := NextMonthBtnClick;
    Hint := BTN_HINT[2];
    Caption := BTN_CAPTION[2];
  end;

  FBtns[3] := TC4DRxTimerSpeedButton.Create(Self);
  with FBtns[3] do
  begin
    Parent := Control;
    SetBounds(203, 3, 16, 16);
    //Glyph.Handle := LoadBitmap(hInstance, SBtnGlyphs[3]);
    OnClick := NextYearBtnClick;
    Hint := BTN_HINT[3];
    Caption := BTN_CAPTION[3];
  end;

  Control := TPanel.Create(Self);
  with Control as TPanel do
  begin
    Parent := Self;
    SetBounds(0, 133, 222, 25); // Polaris
    Align := alBottom;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    ParentFont := True;
    ParentColor := True;
  end;

{  with TButton.Create(Self) do begin
    Parent := Control;
    SetBounds(0, 0, 112, 21);
    Caption := RxLoadStr(SOKButton);
    ModalResult := mrOk;
  end;

  with TButton.Create(Self) do begin
    Parent := Control;
    SetBounds(111, 0, 111, 21);
    Caption := RxLoadStr(SCancelButton);
    ModalResult := mrCancel;
    Cancel := True;
  end; }// Polaris

  with TBitBtn.Create(Self) do
  begin // Polaris
    Parent := Control;
    SetBounds(0, 0, 111, 25);
    Kind := bkOk;
  end;

  with TBitBtn.Create(Self) do
  begin // Polaris
    Parent := Control;
    SetBounds(111, 0, 111, 25);
    Kind := bkCancel;
  end;

  Control := TPanel.Create(Self);
  with Control as TPanel do
  begin
    Parent := Self;
    SetBounds(0, 22, 222, 111);
    Align := alClient;
    BevelInner := bvLowered;
    ParentFont := True;
    ParentColor := True;
  end;

  Calendar := TC4DRxCalendar.Create(Self);
  with Calendar do
  begin
    Parent := Control;
    Align := alClient;
    ParentFont := True;
    SetBounds(2, 2, 218, 113);
    Color := clWhite;
    TabOrder := 0;
    UseCurrentDate := False;
    OnChange := CalendarChange;
    OnDblClick := CalendarDblClick;
  end;

  OnKeyDown := FormKeyDown;
  Calendar.CalendarDate := Trunc(Now);
  ActiveControl := Calendar;
end;

procedure TSelectDateDlg.SetDate(Date: TDateTime);
begin
  if Date = NullDate then Date := System.SysUtils.Date;
  try
    Calendar.CalendarDate := Date;
    CalendarChange(nil);
  except
    Calendar.CalendarDate := System.SysUtils.Date;
  end;
end;

function TSelectDateDlg.GetDate: TDateTime;
begin
  Result := Calendar.CalendarDate;
end;

procedure TSelectDateDlg.TopPanelDblClick(Sender: TObject);
begin
  SetDate(Trunc(Now));
end;

procedure TSelectDateDlg.PrevYearBtnClick(Sender: TObject);
begin
  Calendar.PrevYear;
end;

procedure TSelectDateDlg.NextYearBtnClick(Sender: TObject);
begin
  Calendar.NextYear;
end;

procedure TSelectDateDlg.PrevMonthBtnClick(Sender: TObject);
begin
  Calendar.PrevMonth;
end;

procedure TSelectDateDlg.NextMonthBtnClick(Sender: TObject);
begin
  Calendar.NextMonth;
end;

//>Polaris

procedure TSelectDateDlg.CheckButton;
var
//  CurDate: TDate;
  AYear, AMonth, ADay: Word;
begin
  if not Assigned(Calendar) then Exit;
//  CurDate := Calendar.CalendarDate;
  if Calendar.MinDate = NullDate then
    for AYear := 0 to 1 do
      FBtns[AYear].Enabled := True
  else
  begin
    DecodeDate(Calendar.MinDate, AYear, AMonth, ADay);
    FBtns[0].Enabled := Calendar.Year > AYear;
    FBtns[1].Enabled := (Calendar.Year > AYear) or ((Calendar.Year = AYear) and (Calendar.Month > AMonth));
  end;
  if Calendar.MaxDate = NullDate then
    for AYear := 2 to 3 do
      FBtns[AYear].Enabled := True
  else
  begin
    DecodeDate(Calendar.MaxDate, AYear, AMonth, ADay);
    FBtns[2].Enabled := (Calendar.Year < AYear) or ((Calendar.Year = AYear) and (Calendar.Month < AMonth));
    FBtns[3].Enabled := Calendar.Year < AYear;
  end;
end;
//<Polaris

procedure TSelectDateDlg.CalendarChange(Sender: TObject);
begin
  TitleLabel.Caption := FormatDateTime('MMMM, YYYY', Calendar.CalendarDate);
//Polaris
  CheckButton;
end;

procedure TSelectDateDlg.CalendarDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TSelectDateDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: ModalResult := mrOk;
    VK_ESCAPE: ModalResult := mrCancel;
    VK_NEXT:
      begin
        if ssCtrl in Shift then
          Calendar.NextYear
        else
          Calendar.NextMonth;
        TitleLabel.Update;
        CheckButton;
      end;
    VK_PRIOR:
      begin
        if ssCtrl in Shift then
          Calendar.PrevYear
        else
          Calendar.PrevMonth;
        TitleLabel.Update;
        CheckButton;
      end;
    VK_TAB:
      begin
        if Shift = [ssShift] then
          Calendar.PrevMonth
        else
          Calendar.NextMonth;
        TitleLabel.Update;
        CheckButton;
      end;
  end; {case}
end;

{ SelectDate routines }

function CreateDateDialog(const DlgCaption: TCaption;
  MinDate: TDateTime;
  MaxDate: TDateTime
  ): TSelectDateDlg;
begin
  Result := TSelectDateDlg.Create(Application);
  try
    if DlgCaption <> '' then Result.Caption := DlgCaption;
    Result.Calendar.MinDate := MinDate;
    Result.Calendar.MaxDate := MaxDate;
    if Screen.PixelsPerInch <> 96 then
    begin { scale to screen res }
      Result.ScaleBy(Screen.PixelsPerInch, 96);
      { The ScaleBy method does not scale the font well, so set the
        font back to the original info. }
      Result.Calendar.ParentFont := True;
      FontSetDefault(Result.Font);
      Result.Left := (Screen.Width div 2) - (Result.Width div 2);
      Result.Top := (Screen.Height div 2) - (Result.Height div 2);
    end;
  except
    Result.Free;

    raise;
  end;
end;

function PopupDate(var Date: TDateTime; Edit: TWinControl;
  MinDate: TDateTime;
  MaxDate: TDateTime
  ): Boolean;
var
  D: TSelectDateDlg;
  P: TPoint;
  W, H, X, Y: Integer;
begin
  Result := False;
  D := CreateDateDialog('', MinDate, MaxDate);
  try
    D.BorderIcons := [];
    D.HandleNeeded;
    D.Position := poDesigned;
    W := D.Width;
    H := D.Height;
    P := (Edit.ClientOrigin);
    Y := P.Y + Edit.Height - 1;
    if (Y + H) > Screen.Height then Y := P.Y - H + 1;
    if Y < 0 then Y := P.Y + Edit.Height - 1;
    X := (P.X + Edit.Width) - W;
    if X < 0 then X := P.X;
    D.Left := X;
    D.Top := Y;
    D.Date := Date;
    if D.ShowModal = mrOk then
    begin
      Date := D.Date;
      Result := True;
    end;
  finally
    D.Free;
  end;
end;

function SelectDate(Sender: TWinControl; var Date: TDateTime; const DlgCaption: TCaption;
  AStartOfWeek: TDayOfWeekName; AWeekends: TDaysOfWeek;
  AWeekendColor: TColor; BtnHints: TStrings;
  MinDate: TDateTime;
  MaxDate: TDateTime
  ): Boolean;
var
  D: TSelectDateDlg;
  I: Integer;
  P: TPoint; // Polaris
begin
  Result := False;
  D := CreateDateDialog(DlgCaption, MinDate, MaxDate);
  try
    // Polaris for Popup position
    if Assigned(Sender) then
      with D do
      begin
        Position := poDesigned;
        P := (Sender.ClientOrigin);
        Top := P.Y + Sender.Height - 1;
        if (Top + Height) > Screen.Height then Top := P.Y - Height + 1;
        if Top < 0 then Top := P.Y + Sender.Height - 1;
        Left := (P.X + Sender.Width) - Width;
        if (Left + Width) > Screen.Width then Left := Screen.Width - Width;
        if Left < 0 then Left := Max(P.X, 0);
      end;

    D.Date := Date;
    with D.Calendar do
    begin
      StartOfWeek := AStartOfWeek;
      Weekends := AWeekends;
      WeekendColor := AWeekendColor;
    end;
    if (BtnHints <> nil) then
      for I := 0 to Min(BtnHints.Count - 1, 3) do
      begin
        if BtnHints[I] <> '' then
          D.FBtns[I].Hint := BtnHints[I];
      end;
    if D.ShowModal = mrOk then
    begin
      Date := D.Date;
      Result := True;
    end;
  finally
    D.Free;
  end;
end;

function SelectDateStr(Sender: TWinControl; var StrDate: string; const DlgCaption: TCaption;
  AStartOfWeek: TDayOfWeekName; AWeekends: TDaysOfWeek;
  AWeekendColor: TColor; BtnHints: TStrings;
  MinDate: TDateTime;
  MaxDate: TDateTime
  ): Boolean;
var
  DateValue: TDateTime;
begin
  if StrDate <> '' then
  begin
    try
      DateValue := StrToDateFmt(FormatSettings.ShortDateFormat, StrDate);
    except
      DateValue := Date;
    end;
  end
  else
    DateValue := Date;
  Result := SelectDate(Sender, DateValue, DlgCaption, AStartOfWeek, AWeekends,
    AWeekendColor, BtnHints, MinDate, MaxDate); // Polaris
  if Result then StrDate := FormatDateTime(FormatSettings.ShortDateFormat, DateValue);
end;

end.
