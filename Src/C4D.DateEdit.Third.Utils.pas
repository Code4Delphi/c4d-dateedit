unit C4D.DateEdit.Third.Utils;

interface

{$WARN WIDECHAR_REDUCED OFF}

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.Variants,
  System.SysConst,
  System.DateUtils,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Mask,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Buttons,
  Vcl.Forms,
  Vcl.Menus,
  Vcl.Dialogs;

type
  TPopupAlign = (epaRight, epaLeft);
  TGlyphKind = (gkCustom, gkDefault, gkDropDown, gkEllipsis);
  TDayOfWeekName = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);
  TDaysOfWeek = set of TDayOfWeekName;
  TCalendarStyle = (csPopup, csDialog);
  TYearDigits = (dyDefault, dyFour, dyTwo);
  TDateOrder = (doMDY, doDMY, doYMD);
  TSysCharSet = set of Char;
  TCharSet = TSysCharSet;

const
  dcsDefault = csPopup;
  scAltDown = scAlt + vk_Down;
  DefEditBtnWidth = 21;
  NullDate: TDateTime = {-693594} 0;
  DefaultDateOrder = doDMY;
  CenturyOffset: Byte = 60;
  //FileBitmap: TBitmap = nil;
  sFileBmp = 'c4d_calendar'; { Filename and directory editor button glyph }
  sDateBmp = 'c4d_calendar'; { Date editor button glyph }

function NvlDate(DateValue, DefaultValue: TDateTime): TDateTime;
function Min(A, B: LongInt): LongInt;
function Max(A, B: LongInt): LongInt;
function GetDateOrder(const DateFormat: string): TDateOrder;
function DefDateFormat(FourDigitYear: Boolean): string;
function IsEmptyStr(const S: string; const EmptyChars: TCharSet): Boolean;
function MakeStr(C: Char; N: Integer): string;
function MonthFromName(const S: string; MaxLen: Byte): Byte;
function ExpandYear(Year: Integer): Integer;
function IsValidDate(Y, M, D: Word): Boolean;
procedure ScanBlanks(const S: string; var Pos: Integer);
function ScanNumber(const S: string; MaxLength: Integer; var Pos: Integer; var Number: LongInt): Boolean;
function ScanChar(const S: string; var Pos: Integer; Ch: Char): Boolean;
function ScanDate(const S, DateFormat: string; var Pos: Integer; var Y, M, D: Integer): Boolean;
function InternalStrToDate(const DateFormat, S: string; var Date: TDateTime): Boolean;
function ScanDateStr(const Format, S: string; var D, M, Y: Integer): Boolean;
function StrToDateFmt(const DateFormat, S: string): TDateTime;
function DefDateMask(BlanksChar: Char; FourDigitYear: Boolean): string;
function StrToDateFmtDef(const DateFormat, S: string; Default: TDateTime): TDateTime;
function ValidDate(ADate: TDateTime): Boolean;
procedure ExtractMask(const Format, S: string; Ch: Char; Cnt: Integer; var I: Integer; Blank, Default: Integer);

implementation

uses
  C4D.DateEdit.Third.Utils.Dates;

procedure ScanToNumber(const S: string; var Pos: Integer);
begin
  while (Pos <= Length(S)) and not CharInSet(S[Pos], ['0'..'9']) do
  begin
    if CharInSet(S[Pos], LeadBytes) then Inc(Pos);
    Inc(Pos);
  end;
end;

function NvlDate(DateValue, DefaultValue: TDateTime): TDateTime;
begin
  if DateValue = NullDate then Result := DefaultValue
  else Result := DateValue;
end;

function Min(A, B: LongInt): LongInt;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function Max(A, B: LongInt): LongInt;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function GetDateOrder(const DateFormat: string): TDateOrder;
var
  I: Integer;
begin
  I := 1;
  while I <= Length(DateFormat) do
  begin
    case Chr(Ord(DateFormat[I]) and $DF) of
      'E': Result := doYMD;
      'Y': Result := doYMD;
      'M': Result := doMDY;
      'D': Result := doDMY;
    else
      Inc(I);
      Continue;
    end;
    Exit;
  end;
  Result := DefaultDateOrder; { default }
end;

function DefDateFormat(FourDigitYear: Boolean): string;
begin
  if FourDigitYear then
  begin
    case GetDateOrder(FormatSettings.ShortDateFormat) of
      doMDY: Result := 'MM/DD/YYYY';
      doDMY: Result := 'DD/MM/YYYY';
      doYMD: Result := 'YYYY/MM/DD';
    end;
  end
  else
  begin
    case GetDateOrder(FormatSettings.ShortDateFormat) of
      doMDY: Result := 'MM/DD/YY';
      doDMY: Result := 'DD/MM/YY';
      doYMD: Result := 'YY/MM/DD';
    end;
  end;
end;

function IsEmptyStr(const S: string; const EmptyChars: TCharSet): Boolean;
var
  I, SLen: Integer;
begin
  SLen := Length(S);
  I := 1;
  while I <= SLen do
  begin
    if not CharInSet(S[I], EmptyChars) then
    begin
      Result := False;
      Exit;
    end
    else
      Inc(I);
  end;
  Result := True;
end;

function MakeStr(C: Char; N: Integer): string;
begin
  if N < 1 then
    Result := ''
  else
  begin
    Result := StringOfChar(C, N);
  end;
end;

function MonthFromName(const S: string; MaxLen: Byte): Byte;
begin
  if Length(S) > 0 then
    for Result := 1 to 12 do
    begin
      if (Length(FormatSettings.LongMonthNames[Result]) > 0) and
        (AnsiCompareText(Copy(S, 1, MaxLen),
        Copy(FormatSettings.LongMonthNames[Result], 1, MaxLen)) = 0) then Exit;
    end;
  Result := 0;
end;

procedure ExtractMask(const Format, S: string; Ch: Char; Cnt: Integer; var I: Integer; Blank, Default: Integer);
var
  Tmp: string;
  J, L: Integer;
begin
  I := Default;
  Ch := UpCase(Ch);
  L := Length(Format);
  if Length(S) < L then
    L := Length(S)
  else if Length(S) > L then
    Exit;
  J := Pos(MakeStr(Ch, Cnt), AnsiUpperCase(Format));
  if J <= 0 then Exit;
  Tmp := '';
  while (UpCase(Format[J]) = Ch) and (J <= L) do
  begin
    if S[J] <> ' ' then Tmp := Tmp + Char(S[J]);
    Inc(J);
  end;
  if Tmp = '' then
    I := Blank
  else if Cnt > 1 then
  begin
    I := MonthFromName(Tmp, Length(Tmp));
    if I = 0 then I := -1;
  end
  else
    I := StrToIntDef(Tmp, -1);
end;

function ExpandYear(Year: Integer): Integer;
var
  N: LongInt;
begin
  Result := Year;
  if Result < 100 then
  begin
    N := CurrentYear - CenturyOffset;
    Inc(Result, N div 100 * 100);
    if (CenturyOffset > 0) and (Result < N) then
      Inc(Result, 100);
  end;
end;

function IsValidDate(Y, M, D: Word): Boolean;
begin
  Result := (Y >= 1) and (Y <= 9999) and (M >= 1) and (M <= 12) and
    (D >= 1) and (D <= DaysPerMonth(Y, M));
end;

procedure ScanBlanks(const S: string; var Pos: Integer);
var
  I: Integer;
begin
  I := Pos;
  while (I <= Length(S)) and (S[I] = ' ') do
    Inc(I);
  Pos := I;
end;

function ScanNumber(const S: string; MaxLength: Integer; var Pos: Integer; var Number: LongInt): Boolean;
var
  I: Integer;
  N: Word;
begin
  Result := False;
  ScanBlanks(S, Pos);
  I := Pos;
  N := 0;
  while (I <= Length(S)) and (LongInt(I - Pos) < MaxLength) and
    CharInSet(S[I], ['0'..'9']) and (N < 1000) do
  begin
    N := N * 10 + (Ord(S[I]) - Ord('0'));
    Inc(I);
  end;
  if I > Pos then
  begin
    Pos := I;
    Number := N;
    Result := True;
  end;
end;

function ScanChar(const S: string; var Pos: Integer; Ch: Char): Boolean;
begin
  Result := False;
  ScanBlanks(S, Pos);
  if (Pos <= Length(S)) and (S[Pos] = Ch) then
  begin
    Inc(Pos);
    Result := True;
  end;
end;

function ScanDate(const S, DateFormat: string; var Pos: Integer; var Y, M, D: Integer): Boolean;
var
  DateOrder: TDateOrder;
  N1, N2, N3: LongInt;
begin
  Result := False;
  Y := 0; M := 0; D := 0;
  DateOrder := GetDateOrder(DateFormat);

  if FormatSettings.ShortDateFormat[1] = 'g' then { skip over prefix text }
    ScanToNumber(S, Pos);

  if not (ScanNumber(S, MaxInt, Pos, N1) and ScanChar(S, Pos, FormatSettings.DateSeparator) and
    ScanNumber(S, MaxInt, Pos, N2)) then Exit;
  if ScanChar(S, Pos, FormatSettings.DateSeparator) then
  begin
    if not ScanNumber(S, MaxInt, Pos, N3) then Exit;
    case DateOrder of
      doMDY:
        begin Y := N3; M := N1; D := N2; end;
      doDMY:
        begin Y := N3; M := N2; D := N1; end;
      doYMD:
        begin Y := N1; M := N2; D := N3; end;
    end;
    Y := ExpandYear(Y);
  end
  else
  begin
    Y := CurrentYear;
    if DateOrder = doDMY then
    begin
      D := N1; M := N2;
    end
    else
    begin
      M := N1; D := N2;
    end;
  end;
  ScanChar(S, Pos, FormatSettings.DateSeparator);
  ScanBlanks(S, Pos);

  if SysLocale.FarEast and (System.Pos('ddd', FormatSettings.ShortDateFormat) <> 0) then
  begin { ignore trailing text }
    if CharInSet(FormatSettings.ShortTimeFormat[1], ['0'..'9']) then { stop at time digit }
      ScanToNumber(S, Pos)
    else { stop at time prefix }
      repeat
        while (Pos <= Length(S)) and (S[Pos] <> ' ') do
          Inc(Pos);
        ScanBlanks(S, Pos);
      until (Pos > Length(S)) or
        (AnsiCompareText(FormatSettings.TimeAMString, Copy(S, Pos, Length(FormatSettings.TimeAMString))) = 0) or
        (AnsiCompareText(FormatSettings.TimePMString, Copy(S, Pos, Length(FormatSettings.TimePMString))) = 0);
  end;

  Result := IsValidDate(Y, M, D) and (Pos > Length(S));
end;


function ScanDateStr(const Format, S: string; var D, M, Y: Integer): Boolean;
var
  Pos: Integer;
begin
  ExtractMask(Format, S, 'm', 3, M, -1, 0); { short month name? }
  if M = 0 then ExtractMask(Format, S, 'm', 1, M, -1, 0);
  ExtractMask(Format, S, 'd', 1, D, -1, 1);
  ExtractMask(Format, S, 'y', 1, Y, -1, CurrentYear);
  Y := ExpandYear(Y);
  Result := IsValidDate(Y, M, D);
  if not Result then
  begin
    Pos := 1;
    Result := ScanDate(S, Format, Pos, Y, M, D);
  end;
end;

function InternalStrToDate(const DateFormat, S: string; var Date: TDateTime): Boolean;
var
  D, M, Y: Integer;
begin
  if S = '' then
  begin
    Date := NullDate;
    Result := True;
  end
  else
  begin
    Result := ScanDateStr(DateFormat, S, D, M, Y);
    if Result then
    try
      Date := EncodeDate(Y, M, D);
    except
      Result := False;
    end;
  end;
end;

function StrToDateFmt(const DateFormat, S: string): TDateTime;
begin          //AQUI
  if not InternalStrToDate(DateFormat, S, Result) then
    raise EConvertError.CreateFmt(SInvalidDate, [S]);
end;

function DefDateMask(BlanksChar: Char; FourDigitYear: Boolean): string;
begin
  if FourDigitYear then
  begin
    case GetDateOrder(FormatSettings.ShortDateFormat) of
      doMDY, doDMY: Result := '!99/99/9999;1;';
      doYMD: Result := '!9999/99/99;1;';
    end;
  end
  else
  begin
    case GetDateOrder(FormatSettings.ShortDateFormat) of
      doMDY, doDMY: Result := '!99/99/99;1;';
      doYMD: Result := '!99/99/99;1;';
    end;
  end;
  if Result <> '' then Result := Result + BlanksChar;
end;

function StrToDateFmtDef(const DateFormat, S: string; Default: TDateTime): TDateTime;
begin
  if not InternalStrToDate(DateFormat, S, Result) then
    Result := Trunc(Default);
end;

function ValidDate(ADate: TDateTime): Boolean;
var
  Year, Month, Day: Word;
begin
  try
    DecodeDate(ADate, Year, Month, Day);
    Result := IsValidDate(Year, Month, Day);
  except
    Result := False;
  end;
end;

end.
