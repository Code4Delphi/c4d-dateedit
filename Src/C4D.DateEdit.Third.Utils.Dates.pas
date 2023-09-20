unit C4D.DateEdit.Third.Utils.Dates;

{$WARNINGS OFF}
{$HINTS OFF}

interface

uses
  System.SysUtils,
  System.SysConst,
  System.DateUtils,
  C4D.DateEdit.Third.Utils;

function DateIsFeriado(data: TDate): Boolean;
//function IsFeriado(T:TDate):Boolean;

function CurrentYear: Word; inline;
function IsLeapYear(AYear: Integer): Boolean; inline;
function DaysPerMonth(AYear, AMonth: Integer): Integer;
function FirstDayOfPrevMonth: TDateTime; inline;
function LastDayOfPrevMonth: TDateTime; inline;
function FirstDayOfNextMonth: TDateTime; inline;
function ExtractDay(ADate: TDateTime): Word; inline;
function ExtractMonth(ADate: TDateTime): Word; inline;
function ExtractYear(ADate: TDateTime): Word; inline;
function IncDate(ADate: TDateTime; Days, Months, Years: Integer): TDateTime; inline;
function IncDay(ADate: TDateTime; Delta: Integer): TDateTime; inline;
function IncMonth(ADate: TDateTime; Delta: Integer): TDateTime; inline;
function IncYear(ADate: TDateTime; Delta: Integer): TDateTime; inline;
function ValidDate(ADate: TDateTime): Boolean;
procedure DateDiff(Date1, Date2: TDateTime; var Days, Months, Years: Word); inline;
function MonthsBetween(Date1, Date2: TDateTime): Double; inline;
function DaysInPeriod(Date1, Date2: TDateTime): LongInt; inline;
  { Count days between Date1 and Date2 + 1, so if Date1 = Date2 result = 1 }
function DaysBetween(Date1, Date2: TDateTime): LongInt; inline;
  { The same as previous but if Date2 < Date1 result = 0 }

function IncTime(ATime: TDateTime; Hours, Minutes, Seconds, MSecs: Integer): TDateTime; inline;
function IncHour(ATime: TDateTime; Delta: Integer): TDateTime; inline;
function IncMinute(ATime: TDateTime; Delta: Integer): TDateTime; inline;
function IncSecond(ATime: TDateTime; Delta: Integer): TDateTime; inline;
function IncMSec(ATime: TDateTime; Delta: Integer): TDateTime; inline;
function CutTime(ADate: TDateTime): TDateTime; inline; { Set time to 00:00:00:00 }

//type
//  TDateOrder = (doMDY, doDMY, doYMD);
//  TDayOfWeekName = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);
//  TDaysOfWeek = set of TDayOfWeekName;

{ String to date conversions }
function GetDateOrder(const DateFormat: string): TDateOrder; inline;
function MonthFromName(const S: string; MaxLen: Byte): Byte; inline;
function StrToDateDef(const S: string; Default: TDateTime): TDateTime;
function StrToDateFmt(const DateFormat, S: string): TDateTime;
function StrToDateFmtDef(const DateFormat, S: string; Default: TDateTime): TDateTime;
function DefDateFormat(FourDigitYear: Boolean): string; inline;
function DefDateMask(BlanksChar: Char; FourDigitYear: Boolean): string; inline;


function FormatLongDate(Value: TDateTime): string; inline;
function FormatLongDateTime(Value: TDateTime): string; inline;


function IsEasterMonday(const ADate: TDateTime): Boolean;

const
  DefaultDateOrder = doDMY;


var
  FourDigitYear: Boolean;

const
  CenturyOffset: Byte = 60;
  NullDate: TDateTime = {-693594} 0;


implementation

uses
  Windows,
  Consts; // Polaris

function BuscaPascoa(ano: Word): TDate;
var
  n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12: Integer;
  mes, dia: Word;
begin
  n1 := ano mod 19;
  n2 := trunc(ano/100);
  n3 := ano mod 100;
  n4 := trunc(n2/4);
  n5 := n2 mod 4;
  n6 := trunc((n2 + 8)/25);
  n7 := trunc((n2-n6 + 1)/3);
  n8 := (19*n1 + n2-n4-n7 + 15) mod 30;
  n9 := trunc(n3/4);
  n10 := n3 mod 4;
  n11 := (32 + 2*n5 + 2*n9-n8-n10) mod 7;
  n12 := trunc((n1 + 11*n8 + 22*n11)/451);

  mes := trunc((n8 + n11-7*n12 + 114)/31);
  dia := (n8 + n11-7*n12 + 114) mod 31;

  Result := IncDay(StrToDateTime(IntToStr(dia) + '/' + IntToStr(mes) + '/' + IntToStr(ano)),1);
end;

function DateIsFeriado(data: TDate): Boolean;
var
  dia, mes, ano: Word;
  pascoa, carnaval, paixao, corpus: TDate;
begin
  Result := False;

  dia := DayOf(data);
  mes := MonthOf(data);

  // feriados fixos
  if((dia = 1) and(mes = 1)) or
    ((dia = 21)and(mes = 4)) or
    ((dia = 1) and(mes = 5)) or
    ((dia = 7) and(mes = 9)) or
    ((dia = 12)and(mes = 10))or
    ((dia = 2) and(mes = 11))or
    ((dia = 15)and(mes = 11))or
    ((dia = 25)and(mes = 12))
  then
  begin
    Result := True;
    Exit;
  end;

  ano := YearOf(data);

  // feriados móveis
  pascoa := BuscaPascoa(ano);
  carnaval := IncDay(pascoa, -47);
  paixao := IncDay(pascoa, -2);
  corpus := IncDay(pascoa, 60);

  if(data = pascoa)or
    (data = carnaval)or
    (data = paixao)or
    (data = corpus)
  then
  begin
    Result := True;
    Exit;
  end;
end;

(*function IsFeriado(T:TDate):Boolean;
  function EasterSunday(Year: Integer): TDateTime;
  {vypocet Velikonocnich svatku}
  var
    A, B, C, D, F, G: Double;
    E: Integer;
  begin
    A := Year mod 19;
    B := Year mod 4;
    C := Year mod 7;
    F := 19 * A + 24;
    D := F - (Int(F / 30) * 30);
    G := (5 + 2 * B + 4 * C + 6 * D);
    E := Trunc((G - (Int(G / 7) * 7)) + D + 22);
    if E <= 31 then Result := EncodeDate(Year, 3, E) else
    begin
      if E - 31 >= 26 then E := 19 else Dec(E, 31);
      Result := EncodeDate(Year, 4, E);
    end;
  end;
Var D,M:Integer;
Begin
  Result := True;
  If T = (EasterSunday(ExtractYear(T))+1) Then Exit; //Pondìlí velikonoèní //pohyblivy svatek
  D := ExtractDay(T);
  M := ExtractMonth(T);
  If (D=1) and (M=1) Then Exit; // Nový rok
  If (D=1) and (M=5) Then Exit; //1. kvìten Svátek práce
  If (D=8) and (M=5) Then Exit; //8. kvìten Den osvobození od fašismu
  If (D=5) and (M=7) Then Exit; //5. èervenec Den slovanských vìrozvìstù Cyrila a Metodìje
  If (D=6) and (M=7) Then Exit; //6. èervenec Mistr Jan Hus
  If (D=28) and (M=9) Then Exit; //28. záøí Den èeské státnosti
  If (D=28) and (M=10) Then Exit; //28. øíjna Den vzniku samostatného Èeskoslovenska
  If (D=17) and (M=11) Then Exit; //17. listopadu Den boje za svobodu a demokracii
  If (D=24) and (M=12) Then Exit; //24. prosinec Štìdrý den
  If (D=25) and (M=12) Then Exit; //25. prosinec 1. svátek vánoèní
  If (D=26) and (M=12) Then Exit; //26. prosinec 2. svátek vánoèní
  Result := False;
end;*)

function IsLeapYear(AYear: Integer): Boolean;
begin
  Result := (AYear mod 4 = 0) and ((AYear mod 100 <> 0) or (AYear mod 400 = 0));
end;

function DaysPerMonth(AYear, AMonth: Integer): Integer;
const
  DaysInMonth: array[1..12] of Integer =
  (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
  Result := DaysInMonth[AMonth];
  if (AMonth = 2) and IsLeapYear(AYear) then Inc(Result); { leap-year Feb is special }
end;

function FirstDayOfNextMonth: TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(Date, Year, Month, Day);
  Day := 1;
  if Month < 12 then
    Inc(Month)
  else
  begin
    Inc(Year);
    Month := 1;
  end;
  Result := EncodeDate(Year, Month, Day);
end;

function FirstDayOfPrevMonth: TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(Date, Year, Month, Day);
  Day := 1;
  if Month > 1 then
    Dec(Month)
  else
  begin
    Dec(Year);
    Month := 12;
  end;
  Result := EncodeDate(Year, Month, Day);
end;

function LastDayOfPrevMonth: TDateTime;
var
  D: TDateTime;
  Year, Month, Day: Word;
begin
  D := FirstDayOfPrevMonth;
  DecodeDate(D, Year, Month, Day);
  Day := DaysPerMonth(Year, Month);
  Result := EncodeDate(Year, Month, Day);
end;

function ExtractDay(ADate: TDateTime): Word;
var
  M, Y: Word;
begin
  DecodeDate(ADate, Y, M, Result);
end;

function ExtractMonth(ADate: TDateTime): Word;
var
  D, Y: Word;
begin
  DecodeDate(ADate, Y, Result, D);
end;

function ExtractYear(ADate: TDateTime): Word;
var
  D, M: Word;
begin
  DecodeDate(ADate, Result, M, D);
end;

function IncDate(ADate: TDateTime; Days, Months, Years: Integer): TDateTime;
var
  D, M, Y: Word;
  Day, Month, Year: LongInt;
begin
  DecodeDate(ADate, Y, M, D);
  Year := Y; Month := M; Day := D;
  Inc(Year, Years);
  Inc(Year, Months div 12);
  Inc(Month, Months mod 12);
  if Month < 1 then
  begin
    Inc(Month, 12);
    Dec(Year);
  end
  else if Month > 12 then
  begin
    Dec(Month, 12);
    Inc(Year);
  end;
  if Day > DaysPerMonth(Year, Month) then Day := DaysPerMonth(Year, Month);
  Result := EncodeDate(Year, Month, Day) + Days + Frac(ADate);
end;

procedure DateDiff(Date1, Date2: TDateTime; var Days, Months, Years: Word);
{ Corrected by Anatoly A. Sanko (2:450/73) }
var
  DtSwap: TDateTime;
  Day1, Day2, Month1, Month2, Year1, Year2: Word;
begin
  if Date1 > Date2 then
  begin
    DtSwap := Date1;
    Date1 := Date2;
    Date2 := DtSwap;
  end;
  DecodeDate(Date1, Year1, Month1, Day1);
  DecodeDate(Date2, Year2, Month2, Day2);
  Years := Year2 - Year1;
  Months := 0;
  Days := 0;
  if Month2 < Month1 then
  begin
    Inc(Months, 12);
    Dec(Years);
  end;
  Inc(Months, Month2 - Month1);
  if Day2 < Day1 then
  begin
    Inc(Days, DaysPerMonth(Year1, Month1));
    if Months = 0 then
    begin
      Dec(Years);
      Months := 11;
    end
    else
      Dec(Months);
  end;
  Inc(Days, Day2 - Day1);
end;

function IncDay(ADate: TDateTime; Delta: Integer): TDateTime;
begin
  Result := ADate + Delta;
end;

function IncMonth(ADate: TDateTime; Delta: Integer): TDateTime;
begin
  Result := IncDate(ADate, 0, Delta, 0);
end;

function IncYear(ADate: TDateTime; Delta: Integer): TDateTime;
begin
  Result := IncDate(ADate, 0, 0, Delta);
end;

function MonthsBetween(Date1, Date2: TDateTime): Double;
var
  D, M, Y: Word;
begin
  DateDiff(Date1, Date2, D, M, Y);
  Result := 12 * Y + M;
  if (D > 1) and (D < 7) then
    Result := Result + 0.25
  else if (D >= 7) and (D < 15) then
    Result := Result + 0.5
  else if (D >= 15) and (D < 21) then
    Result := Result + 0.75
  else if (D >= 21) then
    Result := Result + 1;
end;

function IsValidDate(Y, M, D: Word): Boolean;
begin
  Result := (Y >= 1) and (Y <= 9999) and (M >= 1) and (M <= 12) and
    (D >= 1) and (D <= DaysPerMonth(Y, M));
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

function DaysInPeriod(Date1, Date2: TDateTime): LongInt;
begin
  if ValidDate(Date1) and ValidDate(Date2) then
    Result := Abs(Trunc(Date2) - Trunc(Date1)) + 1
  else
    Result := 0;
end;

function DaysBetween(Date1, Date2: TDateTime): LongInt;
begin
  Result := Trunc(Date2) - Trunc(Date1) + 1;
  if Result < 0 then Result := 0;
end;

function IncTime(ATime: TDateTime; Hours, Minutes, Seconds,
  MSecs: Integer): TDateTime;
begin
  Result := ATime + (Hours div 24) + (((Hours mod 24) * 3600000 +
    Minutes * 60000 + Seconds * 1000 + MSecs) / MSecsPerDay);
  if Result < 0 then Result := Result + 1;
end;

function IncHour(ATime: TDateTime; Delta: Integer): TDateTime;
begin
  Result := IncTime(ATime, Delta, 0, 0, 0);
end;

function IncMinute(ATime: TDateTime; Delta: Integer): TDateTime;
begin
  Result := IncTime(ATime, 0, Delta, 0, 0);
end;

function IncSecond(ATime: TDateTime; Delta: Integer): TDateTime;
begin
  Result := IncTime(ATime, 0, 0, Delta, 0);
end;

function IncMSec(ATime: TDateTime; Delta: Integer): TDateTime;
begin
  Result := IncTime(ATime, 0, 0, 0, Delta);
end;

function CutTime(ADate: TDateTime): TDateTime;
begin
  Result := Trunc(ADate);
end;

function CurrentYear: Word;

var
  SystemTime: TSystemTime;
begin
  GetLocalTime(SystemTime);
  Result := SystemTime.wYear;
end;

{ String to date conversions. Copied from SYSUTILS.PAS unit. }

procedure ScanBlanks(const S: string; var Pos: Integer);
var
  I: Integer;
begin
  I := Pos;
  while (I <= Length(S)) and (S[I] = ' ') do
    Inc(I);
  Pos := I;
end;

function ScanNumber(const S: string; MaxLength: Integer; var Pos: Integer;
  var Number: LongInt): Boolean;
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

procedure ScanToNumber(const S: string; var Pos: Integer);
begin
  while (Pos <= Length(S)) and not CharInSet(S[Pos], ['0'..'9']) do
  begin
    if CharInSet(S[Pos], LeadBytes) then Inc(Pos);
    Inc(Pos);
  end;
end;

function GetDateOrder(const DateFormat: string): TDateOrder;
var
  I: Integer;
begin
  Result := DefaultDateOrder;
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

function ScanDate(const S, DateFormat: string; var Pos: Integer;
  var Y, M, D: Integer): Boolean;
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

procedure ExtractMask(const Format, S: string; Ch: Char; Cnt: Integer;
  var I: Integer; Blank, Default: Integer);
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

function InternalStrToDate(const DateFormat, S: string;
  var Date: TDateTime): Boolean;
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
begin     //aqui
  if not InternalStrToDate(DateFormat, S, Result) then
    raise EConvertError.CreateFmt(SInvalidDate, [S]);
end;

function StrToDateDef(const S: string; Default: TDateTime): TDateTime;
begin
  if not InternalStrToDate(FormatSettings.ShortDateFormat, S, Result) then
    Result := Trunc(Default);
end;

function StrToDateFmtDef(const DateFormat, S: string; Default: TDateTime): TDateTime;
begin
  if not InternalStrToDate(DateFormat, S, Result) then
    Result := Trunc(Default);
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



function FormatLongDate(Value: TDateTime): string;
var
  Buffer: array[0..1023] of Char;
  SystemTime: TSystemTime;
begin
  DateTimeToSystemTime(Value, SystemTime);

  SetString(Result, Buffer, GetDateFormat(GetThreadLocale, DATE_LONGDATE,
    @SystemTime, nil, Buffer,Length(Buffer) - 1));
  Result := TrimRight(Result);
end;

function FormatLongDateTime(Value: TDateTime): string;
begin
  if Value <> NullDate then
    Result := FormatLongDate(Value) + FormatDateTime(' tt', Value)
  else
    Result := '';
end;

function IsEasterMonday(const ADate: TDateTime): Boolean;

function GetEasterMonday(const Year: Integer): TDateTime;
  var
    i: Integer;
    r1, r2, r3, r4, r5, r6: Double;
  begin {GetEasterMonday}
    r1 := Year mod 19;
    r2 := Year mod 4;
    r3 := Year mod 7;
    r5 := 19 * r1 + 24;
    r4 := r5 - (Int(r5 / 30) * 30);
    r6 := (5 + 2 * r2 + 4 * r3 + 6 * r4);
    i := Trunc((r6 - (Int(r6 / 7) * 7)) + r4 + 22);

    if i <= 31 then
      Result := EncodeDate(Year, 3, i) + 1
    else
    begin
      if i - 31 >= 26 then
        i := 19
      else
        Dec(i, 31);
      Result := EncodeDate(Year, 4, i) + 1;
    end;
  end; {GetEasterMonday}
begin
  Result := GetEasterMonday(ExtractYear(ADate)) = Trunc(ADate);
end;


initialization
  FourDigitYear := Pos('YYYY', AnsiUpperCase(FormatSettings.ShortDateFormat)) > 0;

end.
