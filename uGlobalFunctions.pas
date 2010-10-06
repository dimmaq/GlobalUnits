unit uGlobalFunctions;

// {$DEFINE USE_REGULAR_EXPRESSIONS}

interface

uses
  Windows, SysUtils, Classes, RTLConsts, Math,
  ZLibExGZ, ZLibEx,
  AcedContainers, AcedStrings, uAnsiStrings, AcedCommon,
  uGlobalTypes, uGlobalConstants
  {$IFDEF UNICODE}
    , AnsiStrings, Masks
  {$ENDIF}
  ;


function GetTimeStampStr: AnsiString;

/// <summary>
/// Возвращает случайную строку из TStrings
/// </summary>
/// <param name="AStrings"></param>
/// <param name="ADefault">возвращает ADefault если AStrings пустой</param>
/// <returns>случайная строка из AStrings</returns>
function StringsRandom(AStrings: TStrings;
    const ADefault: string = ''): string; {$IFDEF UNICODE} overload;{$ENDIF}

{$IFDEF UNICODE}
function StringsRandom(AStrings: TAnsiStrings;
  const ADefault: AnsiString = ''): AnsiString; overload;
{$ENDIF}

/// <summary>
/// Перемешивает TStrings
/// </summary>
function RandomStrings(AStrings: TStrings): TStrings;

/// <summary>
/// Поиск первого символа из множества в строке
/// </summary>
/// <param name="AChars">множество искомых символов</param>
/// <param name="AStr">где искать</param>
/// <param name="AStart">с кокого символа начинать поиск</param>
/// <returns>индекс символа в строке</returns>
function CharsPos(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart: Integer = 1; AEnd: Integer = MaxInt): Integer;

function CharsPosNot(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart: Integer = 1; AEnd: Integer = MaxInt): Integer;

function CharsPosLeftNot(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart: Integer = MaxInt; AEnd: Integer = 1): Integer;

function RandomChars(const AChars: AnsiString; ALength1: Integer = 1;
  ALength2: Integer = -1): AnsiString;

/// <summary>
/// Экранирует спец. символы для JSON
/// </summary>
function JsonStringSafe(const AStr: RawByteString): RawByteString;{$IFDEF UNICODE} overload;{$ENDIF}
{$IFDEF UNICODE}
function JsonStringSafe(const AStr: UnicodeString): UnicodeString; overload;
{$ENDIF}


//---

//---
// *** Разное ***
function IfElse(B: Boolean; const IfTrue: AnsiString;
  const IfFalse: AnsiString = ''): AnsiString; overload; inline;
{$IFDEF UNICODE}
function IfElse(B: Boolean; const IfTrue: UnicodeString;
  const IfFalse: UnicodeString = ''): UnicodeString; overload; inline;
{$ENDIF}
function IfElse(B: Boolean; IfTrue,IfFalse: Integer): Integer; overload; inline;
function IfElse(B: Boolean; IfTrue,IfFalse: Pointer): Pointer; overload; inline;
function IfElse(B: Boolean; IfTrue,IfFalse: TObject): TObject; overload; inline;
function IfElse(B: Boolean; IfTrue,IfFalse: AnsiChar): AnsiChar; overload; inline;
{$IFDEF UNICODE}
function IfElse(B: Boolean; IfTrue,IfFalse: Char): Char; overload; inline;
{$ENDIF}


/// <summary>
/// Если A не пустое, возврашает его,
///  в противном случае возвращает B
/// </summary>
function IfEmpty(const A, B: AnsiString): AnsiString; inline;

procedure GetMemoryInfo(AStrings: TStrings);
function IntToBin(Value: LongWord): AnsiString;
Function IntToStr2(AInt, ALen: Integer): string;
Function IntToAnsiStr2(AInt, ALen: Integer): AnsiString;
function BoolToStr2(const AValue: Boolean; const AUseStr: Boolean = False): ShortString;
function Tick2Text(k: Int64): string;
procedure ShowInformation(const AText: string;
  const ACaption: string = 'Information');
procedure ShowError(const AText: string);
function GetTmpFileName(const APrefix: string = '';
  const APostfix: string = '';
  const AExt: string = ''): string;
//---
function AddrGetHost(const AAddr: AnsiString): AnsiString; {$IFDEF UNICODE}overload;{$ENDIF}
function AddrGetPort(const AAddr: AnsiString; ADefPort: Word): Integer; overload;
function AddrGetPort(const AAddr: AnsiString; ADefPort: AnsiString): AnsiString; overload;
{$IFDEF UNICODE}
function AddrGetHost(const AAddr: UnicodeString): UnicodeString; overload;
function AddrGetPort(const AAddr: UnicodeString; ADefPort: Word): Integer; overload;
function AddrGetPort(const AAddr: UnicodeString; ADefPort: UnicodeString): UnicodeString; overload;
{$ENDIF}
//---
function FileVersion(AFileName: string): string;
function ExtractMailName(const AMail: AnsiString): AnsiString;
function ExtractMailDomain(const AMail: AnsiString): AnsiString; {$IFDEF UNICODE}overload;{$ENDIF}
{$IFDEF UNICODE}
function ExtractMailDomain(const AMail: UnicodeString): UnicodeString; overload;
{$ENDIF}
function StrAppendWDelim(const AText, ANewText: AnsiString;
  const ADelim: AnsiString = ';'; const APrefix: AnsiString = '';
  const APostfix: AnsiString = ''): AnsiString; {$IFDEF UNICODE}overload;{$ENDIF}
{$IFDEF UNICODE}
function StrAppendWDelim(const AText, ANewText: UnicodeString;
  const ADelim: UnicodeString = ';'; const APrefix: UnicodeString = '';
  const APostfix: UnicodeString = ''): UnicodeString; overload;
{$ENDIF}

{$IFDEF USE_REGULAR_EXPRESSIONS}
function IsIP(const AStr: AnsiString; AOut: TAnsiStrings = nil): Boolean;
function IsIPPort(const AStr: AnsiString; AOut: TAnsiStrings = nil): Boolean;
function GetCollectorFile(const AAddr: AnsiString): AnsiString;
{$ENDIF}

function HtmlSpecCharsDecode(const AText: AnsiString): AnsiString;
function FindAllEml(const AText: AnsiString; AOut: TAnsiStrings): Integer;
procedure HtmlTagsDelete(var AText: AnsiString);
function HtmlTagsDelete2(const AText: AnsiString): AnsiString;
function GZipEncode(var ABuffer: AnsiString): Boolean;

function _ReplaceCRLF(const AText: string): string;
function Err2Str(const E: Exception): string;

// кодирование строки в base64 блоками по 57 символов (на выходе 56*4/3==76)
function Base64Encode(const ASourceText: AnsiString): AnsiString;
// форматированный base64 в текст
function Base64Decode(const ABase64Text: AnsiString): AnsiString;
function QPEncode(const ASourceText: AnsiString): AnsiString;
function QPDecode(const AQPText: AnsiString): AnsiString;

implementation

uses
  SysConst,
  {$IFDEF USE_REGULAR_EXPRESSIONS}uRegExprFunc,{$ENDIF}
  uGlobalVars, uAnsiStringUtils
  ;

var
  _iTmpFile : Integer = 1;

//------------------------------------------------------------------------------
// *** Строковые ф-ции ***

function GetTimeStampStr: AnsiString;
begin
  Result := FormatDateTime('yyyymmddhhnnsszzz', Now())
end;

function StringsRandom(AStrings: TStrings; const ADefault: string): string;
begin
  if AStrings.Count>0 then
    Result := AStrings[Random(AStrings.Count)]
  else
    Result := ADefault
end;

{$IFDEF UNICODE}
function StringsRandom(AStrings: TAnsiStrings; const ADefault: AnsiString): AnsiString;
begin
  Result := AStrings.GetRandom(ADefault)
end;
{$ENDIF}

function RandomStrings(AStrings:TStrings):TStrings;
var
  r,l,j: Integer;
  s: string;
  o: TObject;
begin
  Result := AStrings;
  Randomize;
  l := AStrings.Count;
  for j:=0 to (l-1) do
  begin
    r := Random(l);
    //---
    s := AStrings[r];
    o := AStrings.Objects[r];
    //---
    AStrings[r] := AStrings[j];
    AStrings.Objects[r] := AStrings.Objects[j];
    //---
    AStrings[j] := s;
    AStrings.Objects[j] := o;
  end;        
end;

function CharsPos(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart, AEnd: Integer): Integer;
var
  j,m: Integer;
  p: PAnsiChar;
begin
  if AStr<>'' then
  begin
    m := Min(Length(AStr),AEnd);
    j := AStart;
    p := @AStr[j];
    while j<=m do
    begin
      if p^ in AChars then
      begin
        Result := j;
        Exit;
      end;
      Inc(p);
      Inc(j);
    end;
  end;
  Result := 0;
end;

function CharsPosNot(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart, AEnd: Integer): Integer;
var
  j,m: Integer;
  p: PAnsiChar;
begin
  if AStr<>'' then
  begin
    m := Min(Length(AStr),AEnd);
    j := AStart;
    p := @AStr[j];
    while j<=m do
    begin
      if not (p^ in AChars) then
      begin
        Result := j;
        Exit;
      end;
      Inc(p);
      Inc(j);
    end;
  end;
  Result := 0;
end;

function CharsPosLeftNot(const AChars: TSysCharSet; const AStr: AnsiString;
  AStart, AEnd: Integer): Integer;
var
  j,m: Integer;
  p: PAnsiChar;
begin
  if (AStr<>'') and (0<=AStart) and (AStart<=Length(AStr)) then
  begin
    m := Max(1, AEnd);
    j := AStart;
    p := @AStr[j];
    while j>=m do
    begin
      if not (p^ in AChars) then
      begin
        Result := j;
        Exit;
      end;
      Dec(p);
      Dec(j);
    end;
  end;
  Result := 0;
end;

function RandomChars(const AChars: AnsiString; ALength1: Integer;
  ALength2: Integer): AnsiString;
var j,len:Integer;
begin
  if AChars='' then
  begin
    Result := '';
    Exit;
  end;
  if ALength2=-1 then
    len := ALength1
  else
    len := RandomRange(ALength1, ALength2+1);
  SetLength(Result, len);
  for j:=1 to len do
    Result[j] := AChars[Random(Length(AChars))+1]
end;

function JsonStringSafe(const AStr: RawByteString): RawByteString;
type
  TUnsafeJsonCharRec = record
    c: AnsiChar;
    s: string[2];
  end;
const
  UnSafeJsonChar: array[0..5] of TUnsafeJsonCharRec = (
    (c:'\'; s:'\\'), (c:'"'; s:'\"'), (c:#9; s:'\t'),
    (c:#10; s:'\n'), (c:#12; s:'\f'), (c:#13; s:'\r')
  );
var j: Integer;
begin
  Result := AStr;
  for j:=Low(UnSafeJsonChar) to High(UnSafeJsonChar) do
    Result := G_ReplaceStr(Result, UnSafeJsonChar[j].c, UnSafeJsonChar[j].s);
end;

{$IFDEF UNICODE}
function JsonStringSafe(const AStr: UnicodeString): UnicodeString;
type
  TUnsafeJsonCharRec = record
    c: Char;
    s: UnicodeString;
  end;
const
  UnSafeJsonChar: array[0..5] of TUnsafeJsonCharRec = (
    (c:'\'; s:'\\'), (c:'"'; s:'\"'), (c:#9; s:'\t'),
    (c:#10; s:'\n'), (c:#12; s:'\f'), (c:#13; s:'\r')
  );
var j: Integer;
begin
  Result := AStr;
  for j:=Low(UnSafeJsonChar) to High(UnSafeJsonChar) do
    Result := SysUtils.StringReplace(Result, UnSafeJsonChar[j].c, UnSafeJsonChar[j].s, [rfReplaceAll]);
end;
{$ENDIF}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
// *** Разное ***

function IfElse(B: Boolean; const IfTrue,IfFalse: AnsiString):AnsiString;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;

{$IFDEF UNICODE}
function IfElse(B: Boolean; const IfTrue: UnicodeString;
  const IfFalse: UnicodeString = ''): UnicodeString; overload; inline;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;
{$ENDIF}


function IfElse(B: Boolean; IfTrue,IfFalse: Integer): Integer;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;

function IfElse(B: Boolean; IfTrue,IfFalse: Pointer): Pointer;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;

function IfElse(B: Boolean; IfTrue,IfFalse: TObject): TObject;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;

function IfElse(B: Boolean; IfTrue,IfFalse: AnsiChar): AnsiChar;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;
{$IFDEF UNICODE}
function IfElse(B: Boolean; IfTrue,IfFalse: Char): Char;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
end;
{$ENDIF}


function IfEmpty(const A, B: AnsiString): AnsiString;
begin
  if A<>'' then
    Result := A
  else
    Result := B
end;

procedure GetMemoryInfo(AStrings: TStrings);

  function FormatBytesSize(ABytes: Int64): string;
  var
    s : String;
    b : Extended;
  begin
    b := ABytes;
    if (b < 1024 - 200) then
    begin
      b := b;
      s := 'B';
    end
    else
      if (b < 1024 * (1024 - 200)) then
      begin
        b := b / 1024;
        s := 'kB';
      end
      else
        if (b < 1024 * 1024 * (1024 - 200)) then
        begin
          b := b / (1024 * 1024);
          s := 'MB';
        end
        else
        begin
          b := b / (1024 * 1024 * 1024);
          s := 'GB';
        end;

    Result := SysUtils.FormatFloat('###,###,##0.#', b) + ' ' + s + ' (' + SysUtils.IntToStr(ABytes) + ' B)';
  end;


var
 mem_status : TMemoryStatus;
 free_block_list : TIntegerList;
 base_addr : PByte;
 mem_info : TMemoryBasicInformation;
 res : DWORD;
 j,k : Integer;
begin
  mem_status.dwLength := SizeOf(mem_status);
  GlobalMemoryStatus(mem_status);
  //---
  with mem_status, AStrings do
  begin
    Add('Available Physical Memory = ' + FormatBytesSize(dwAvailPhys));
    Add('Total Physical Memory = ' + FormatBytesSize(dwTotalPhys));
    Add('Available Virtual Memory = ' + FormatBytesSize(dwAvailVirtual));
    Add('Total Virtual Memory = ' + FormatBytesSize(dwTotalVirtual));
  end;
  free_block_list := TIntegerList.Create(16);
  try
    free_block_list.MaintainSorted := True;
    //---
    ZeroMemory(@mem_info, SizeOf(mem_info));
    base_addr := nil;
    res := VirtualQuery(base_addr, mem_info, sizeof(mem_info));
    while res = sizeof(mem_info) do
    begin
      if mem_info.State=MEM_FREE then
      begin
        free_block_list.Add(mem_info.RegionSize);
      end;
      Inc(base_addr, mem_info.RegionSize);
      res := VirtualQuery(base_addr, mem_info, sizeof(mem_info));
    end;
    k := 1;
    for j:=(free_block_list.Count-1) downto 0 do
    begin
      with AStrings do
      begin
        Add('Largest Free Block #' + SysUtils.IntToStr(k) + ' = ' + FormatBytesSize(Cardinal(free_block_list[j])));
      end;
      //---
      if k>=3 then
        Break;
      Inc(k);
    end;
  finally
    free_block_list.Free;
  end;

end;

function IntToBin(Value: LongWord): AnsiString;
var i: Integer;
begin
  SetLength(Result, 32);
  for i := 1 to 32 do begin
    if ((Value shl (i-1)) shr 31) = 0 then begin
      Result[i] := '0'  {do not localize}
    end else begin
      Result[i] := '1'; {do not localize}
    end;
  end;
end;

Function IntToAnsiStr2(AInt, ALen: Integer): AnsiString;
begin
  Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%.*d', [ALen, AInt])
end;

Function IntToStr2(AInt, ALen: Integer): string;
begin
  Result := SysUtils.Format('%.*d', [ALen, AInt])
end;


function BoolToStr2(const AValue: Boolean; const AUseStr: Boolean): ShortString;
const
  cBoolStrs: array[Boolean] of array[Boolean] of ShortString = (
    ('0', '1'),
    ('False', 'True')
  );
begin
  Result := cBoolStrs[AUseStr][AValue];
end;

function Tick2Text(k: Int64): string;
var h,m,s,l:Integer;
begin
  if k>0 then
  begin
    l := Round(k/1000);
    h := l div 3600;
    m := (l - h*3600) div 60;
    s := l - h*3600 - m*60;
    Result := '';
    if h<>0 then
      Result := SysUtils.IntToStr(h)+' час '+SysUtils.IntToStr(m)+' мин '
    else if m<>0 then
      Result := SysUtils.IntToStr(m)+' мин ';
    Result := Result + SysUtils.IntToStr(s) + ' сек';
  end
  else
  begin
    Result := '';
  end;
end;

procedure ShowInformation(const AText, ACaption: string);
begin
  Windows.MessageBox(0, PChar(AText), PChar(ACaption), MB_OK or MB_ICONINFORMATION);
end;

procedure ShowError(const AText: string);
begin
  Windows.MessageBox(0, PChar(AText), nil, MB_OK or MB_ICONERROR);
end;

function GetTmpFileName(const APrefix, APostfix, AExt: string): string;
begin
  Result := APrefix + SysUtils.IntToStr(InterlockedIncrement(_iTmpFile)) + APostfix + AExt
end;

// разбивка строки address:port
function AddrGetHost(const AAddr: AnsiString): AnsiString;
var p:Integer;
begin
  p := G_CharPos(':', AAddr);
  if p<>0 then
    Result := Copy(AAddr, 1, p-1)
  else
    Result := AAddr;
end;
function AddrGetPort(const AAddr: AnsiString; ADefPort: Word): Integer;
var p:Integer;
begin
  p := G_CharPos(':', AAddr);
  if p<>0 then
    Result := AnsiStrToIntDef(Copy(AAddr, p+1, MaxInt), ADefPort)
  else
    Result := ADefPort;
end;
function AddrGetPort(const AAddr: AnsiString; ADefPort: AnsiString): AnsiString;
var p:Integer;
begin
  p := G_CharPos(':', AAddr);
  if p<>0 then
    Result := Copy(AAddr, p+1, MaxInt)
  else
    Result := ADefPort;
end;

{$IFDEF UNICODE}
function AddrGetHost(const AAddr: UnicodeString): UnicodeString;
var p:Integer;
begin
  p := Pos(':', AAddr);
  if p<>0 then
    Result := Copy(AAddr, 1, p-1)
  else
    Result := AAddr;
end;
function AddrGetPort(const AAddr: UnicodeString; ADefPort: Word): Integer;
var p: Integer;
begin
  p := Pos(':', AAddr);
  if p<>0 then
    Result := SysUtils.StrToIntDef(Copy(AAddr, p+1, MaxInt), ADefPort)
  else
    Result := ADefPort;
end;
function AddrGetPort(const AAddr: UnicodeString; ADefPort: UnicodeString): UnicodeString;
var p:Integer;
begin
  p := Pos(':', AAddr);
  if p<>0 then
    Result := Copy(AAddr, p+1, MaxInt)
  else
    Result := ADefPort;
end;
{$ENDIF}


//---
function FileVersion(AFileName: string): string;
var
  sName: string;
  P: Pointer;
  Value: Pointer;
  Len: UINT;
  GetTranslationString: string;
  FValid: Boolean;
  FSize: DWORD;
  FHandle: DWORD;
  FBuffer: PChar;
begin
  Result := '';
  FBuffer := nil;
  FSize := 0;
  try
    FSize := GetFileVersionInfoSize(PChar(AFileName), FHandle);
    if FSize > 0 then
    begin
      GetMem(FBuffer, FSize);
      FValid := GetFileVersionInfo(PChar(AFileName), FHandle, FSize, FBuffer);
      if FValid then
      begin
        VerQueryValue(FBuffer, '\VarFileInfo\Translation', p, Len);
        GetTranslationString := IntToHex(MakeLong(HiWord(Longint(P^)), LoWord(Longint(P^))), 8);
        sName := '\StringFileInfo\' + GetTranslationString + '\FileVersion';
        if VerQueryValue(FBuffer, PChar(sName), Value, Len) then
          SetString(Result, PChar(Value), Len);
      end;
    end;
  finally
    if FBuffer<>nil then
      FreeMem(FBuffer, FSize);
  end;
end;

function ExtractMailDomain(const AMail: AnsiString): AnsiString;
var p: Integer;
begin
  p := G_CharPos('@', AMail);
  if p>0 then
    Result := Copy(AMail, p+1, MaxInt)
  else
    Result := ''
end;

function ExtractMailName(const AMail: AnsiString): AnsiString;
var p: Integer;
begin
  p := G_CharPos('@', AMail);
  if p>0 then
    Result := Copy(AMail, 1, p-1)
  else
    Result := AMail
end;

{$IFDEF UNICODE}
function ExtractMailDomain(const AMail: UnicodeString): UnicodeString;
var p:Integer;
begin
  p := Pos('@', AMail);
  if p>0 then
    Result := Copy(AMail, p+1, MaxInt)
  else
    Result := ''
end;
{$ENDIF}

function StrAppendWDelim(const AText, ANewText, ADelim,
  APrefix, APostfix: AnsiString): AnsiString;
begin
  if ANewText<>'' then
    if AText='' then
      Result := APrefix + ANewText + APostfix
    else
      Result := AText + ADelim + APrefix + ANewText + APostfix
  else
    Result := AText
end;

{$IFDEF UNICODE}
function StrAppendWDelim(const AText, ANewText, ADelim,
  APrefix, APostfix: UnicodeString): UnicodeString;
begin
  if AText='' then
    Result := APrefix + ANewText + APostfix
  else if ANewText<>'' then
    Result := AText + ADelim + APrefix + ANewText + APostfix
  else
    Result := AText
end;
{$ENDIF}


{$IFDEF USE_REGULAR_EXPRESSIONS}
function IsIP(const AStr: AnsiString; AOut: TAnsiStrings): Boolean;
const
  c_dd = '(\d{1,3})';
  c_ip = '^'+c_dd+'\.'+c_dd+'\.'+c_dd+'\.'+c_dd+'$';
begin
  if Assigned(AOut) then
    Result := uRegExprFunc.GetMatches(AStr, c_ip, AOut)
  else
    Result := uRegExprFunc.YesRegExpr(AStr, c_ip);
end;

function IsIPPort(const AStr: AnsiString; AOut: TAnsiStrings): Boolean;
const
  c_dd = '(\d{1,3})';
  c_port = '(\d{1,5})';
  c_ipport = '^('+c_dd+'\.'+c_dd+'\.'+c_dd+'\.'+c_dd+'):'+c_port+'$';
begin
  if Assigned(AOut) then
    Result := uRegExprFunc.GetMatches(AStr, c_ipport, AOut)
  else
    Result := uRegExprFunc.YesRegExpr(AStr, c_ipport);
end;

function GetCollectorFile(const AAddr: AnsiString): AnsiString;
var sl: TAnsiStringList;
begin
  Result := '';
  sl := TAnsiStringList.Create;
  try
    if IsIP(AAddr, sl) then
    begin
      Result := sl[1] + '\' + sl[2] + '\' + AAddr
    end
    else if IsIPPort(AAddr, sl) then
    begin
      Result := Format('%s\%s\%s.%s',[sl[2],sl[3],sl[1],sl[6]])
    end
      else
    begin
      Result := AAddr;
      {
      d1 := Copy(AMX, 1, 3);
      d2 := Copy(AMX, 4, 3);
      if d1='' then d1 := 'xxx';
      if d2='' then d2 := 'xxx';
      Result := d1 + '\' + d2 + '\' + AMX
      }
    end;
    
  finally
    sl.Free;
  end;
end;
{$ENDIF}

function HtmlSpecCharsDecode(const AText: AnsiString):AnsiString;
type
  TSpecStrRec = record
    a: string[6];
    b: string[1];
  end;
const
  SpecStrArray: array[0..5] of TSpecStrRec = (
    (a:'&apos;'; b:''''),
    (a:'&#039;'; b:''''),
    (a:'&quot;'; b:'"'),
    (a:'&gt;';   b:'>'),
    (a:'&lt;';   b:'<'),
    (a:'&amp;';  b:'&')
  );
var
  A: TSpecStrRec;
  j: Integer;
begin
  Result := AText;
  for j:=Low(SpecStrArray) to High(SpecStrArray) do
  begin
    A := SpecStrArray[j];
    Result := G_ReplaceStr(Result, A.a, A.b);
  end;
end;

function FindAllEml(const AText: AnsiString; AOut: TAnsiStrings): Integer;
(*
^[-a-z0-9!#$%&'*+/=?^_`{|}~]+(\.[-a-z0-9!#$%&'*+/=?^_`{|}~]+)*@([a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?\.)*(aero|arpa|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|[a-z][a-z])$

*)
const
(*
  nam1 : set of AnsiChar = ['a'..'z', 'A'..'Z', '0'..'9', '-', '!', '#', '$', '%', '&', '''', '*', '+', '/', '=', '?', '^', '_', '`', '{', '|', '}', '~'];
  nam2 : set of AnsiChar = ['a'..'z', 'A'..'Z', '0'..'9', '-', '!', '#', '$', '%', '&', '''', '*', '+', '/', '=', '?', '^', '_', '`', '{', '|', '}', '~', '.'];
*)
  nam1 : set of AnsiChar = ['a'..'z', 'A'..'Z', '0'..'9', '-', '''', '+', '^', '_',
                            '`', '{', '}', '~', '$'];
  nam2 : set of AnsiChar = ['a'..'z', 'A'..'Z', '0'..'9', '-', '''', '+', '^', '_',
                            '`', '{', '}', '~', '$', '.'];

  dom1 : set of AnsiChar = ['a'..'z', 'A'..'Z', '0'..'9'];
  dom2 : set of AnsiChar = ['a'..'z', 'A'..'Z', '0'..'9', '-', '.'];

var
  j,p,k,l,i,m,k2,n2: Integer;
  nam,dom: AnsiString;
begin
  Result := 0;
  p := 1;
  k := Length(AText);
  while p>0 do
  begin
    p := G_CharPos('@', AText, p);
    if p>0 then
    begin
      nam := '';
      dom := '';
      n2 := 0;
      for j:=(p-1) downto 1 do
      begin
        if (AText[j] in nam1) then
          n2 := j
        else if not (AText[j] in nam2) then
        begin
          Break;
        end;
      end;
      //---
      k2 := 0;
      for j:=(p+1) to k do
      begin
        if (AText[j] in dom1) then
          k2 := j
        else if not (AText[j] in dom2) then
        begin
          Break;
        end
      end;
      if (n2<>0) and (k2<>0) then
      begin
        nam := Copy(AText, n2, p-n2);
        dom := Copy(AText, p+1, k2-p);
        //---
        n2 := G_LastPosStr('..', nam);
        if n2>0 then
          Delete(nam, 1, n2+1);
        //---
        k2 := G_PosStr('..', dom);
        if k2>0 then
          Delete(dom, k2, MaxInt);
        //---
        k2 := 0;
        l := Length(dom);
        for j:=l downto 1 do
          if dom[j] in gCharsEng then
          begin
            k2 := j;
            Break;
          end;
        if k2<l then
          if k2=0 then
            dom := ''
          else
            Delete(dom, k2+1, MaxInt);
        //---
        if (nam<>'') and (dom<>'') then
        begin
          k2 := G_LastCharPos('.', dom);
          if k2>0 then
          begin
            l := Length(dom);
            m := l - k2;
            if (1<m) and (m<10) then
            begin
              i := 0;
              for j:=(k2+1) to l do
                if not (dom[j] in gCharsEng) then
                begin
                  i := 1;
                  Break;
                end;
              if i=0 then
              begin
                AOut.Add(nam+'@'+dom);
                Inc(Result)
              end
            end
          end
        end
      end;
      //---
      p := p + 1;
    end;
  end;
end;

procedure HtmlTagsDelete(var AText: AnsiString);
const
  not_tag_char = [#0..#255] - gCharsEng;
  block_tag : array[0..3] of AnsiString = (
    'table',
    'div',
    'p',
    'li'
  );

  function _is_block_tag(const AText: AnsiString): Boolean;
  var j: Integer;
  begin
    Result := False;
    for j:=Low(block_tag) to High(block_tag) do
      if G_CompareStr(block_tag[j], AText)=0 then
      begin
        Result := True;
        Exit;
      end
  end;

var
  n,k,l,p : Integer;
  z : TAnsiStringBuilder;
  tag: AnsiString;
begin
  z := TAnsiStringBuilder.Create;
  try
    n := 1;
  //  k := Length(aStr);
    while n>0 do
    begin
      k := G_CharPos('<', AText, n);
      if k>0 then
      begin
        l := k - n;
        if l>0 then
          z.Append(Copy(AText, n, l));
        n := G_CharPos('>', AText, k) + 1;
        if n=1 then // не найдено ">"
        begin
          z.Append(Copy(AText, k, MaxInt));
          Break;
        end
        else
        begin // проверить имя тега
          tag := Copy(AText, k+1, n-k-2);
          if tag<>'' then
          begin
            if tag[1]='/' then
              Delete(tag, 1, 1);
            if tag<>'' then
            begin
              p := CharsPos(not_tag_char, tag);
              if p>0 then
                Delete(tag, p, MaxInt);
              if tag<>'' then
              begin
                if _is_block_tag(G_ToLower(tag)) then
                  z.Append(CR);
              end
            end
          end
        end
      end
        else
      begin // не найдено "<"
        z.Append(Copy(AText, n, MaxInt));
        Break;
      end;
    end;
    //---
    AText := z.ToString;
  finally
    z.Free
  end;
end;

function HtmlTagsDelete2(const AText: AnsiString): AnsiString;
begin
  Result := AText;
  HtmlTagsDelete(Result)
end;

function GZipEncode(var ABuffer: AnsiString): Boolean;
begin
  Result := False;
  try
    if Copy(ABuffer,1,4)=#$1F#$8B#$08#$00 then
    begin
      ABuffer := GZDecompressStr(ABuffer);
      Result := True;
    end;
  except
    on E:EZDecompressionError do
    begin
      //***
    end
    else
    begin
      raise
    end;
  end;
end;


function _ReplaceCRLF(const AText: string): string;
begin
  Result := AText;
  G_Compact(Result);
end;

function Err2Str(const E: Exception): string;
begin
  Result := E.ClassName + ' ' + _ReplaceCRLF(E.Message)
end;



// base64 mime
// кодирование строки в base64 блоками по 57 символов
function Base64Encode(const ASourceText: AnsiString): AnsiString;
var
  l,k,j,i : Integer;
begin
  l := Length(ASourceText);
                         {  кол-во букв * 4/3  }   {     кол-во строк * 2     }
  SetString(Result, nil, (((l + 2) div 3) shl 2) + (((l+56) div 57) shl 1));
  k := 1; j := 1;
  while k<=l do
  begin
    i := Min(57,l-k+1);
    IntBase64Encode(@ASourceText[k], @Result[j], i);
    Inc(j, ((i+2) div 3) shl 2);
    Result[j]   := #13;
    Result[j+1] := #10;
    Inc(j, 2);
    Inc(k, 57);
  end;

end;

function Base64Decode(const ABase64Text: AnsiString): AnsiString;
var
  L,N,K: Integer;
  S: TAnsiStringBuilder;
  z: AnsiString;
begin
  N := 1;
  L := Length(ABase64Text);
  S := TAnsiStringBuilder.Create((L div 4) * 3);
  try
    repeat
      K := G_PosStr(CRLF, ABase64Text, N);
      if k>0 then z := Copy(ABase64Text, N, K-N)
             else z := Copy(ABase64Text, N, MaxInt);
      S.Append(G_Base64Decode(z));
      N := K + 2;
    until (K=0) or (N>=L);
    //---
    Result := S.ToString();
  finally
    S.Free;
  end;
end;

function _QP_Decode(oBuf, iBuf: PAnsiChar; len: Integer): Integer;
const
  CR = 13; LF = 10;

const
  xx = $7F;
  QP_DTable: array[0..$FF] of Byte = (
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    $0,$1,$2,$3, $4,$5,$6,$7, $8,$9,xx,xx, xx,xx,xx,xx,
    xx,$A,$B,$C, $D,$E,$F,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,$A,$B,$C, $D,$E,$F,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx,
    xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx, xx,xx,xx,xx
);  

  function isXdigit(x: Byte): Boolean;
  begin
    // RFC 1521: uppercase letters must be used when sending
    // hex data, though a robust implementation may choose to
    // recognize lowercase letters on receipt.
    //
    isXdigit := AnsiChar(x) in ['0'..'9','A'..'F','a'..'f']
  end;

VAR encoded: Boolean;
    i, j: Integer;
    c1, c2: Byte;
    c: AnsiChar;

begin
  i := 0;
  j := 0;

  encoded := FALSE; // used to handle the last hex triplet
  while i < len do
  begin
    c := iBuf[i];
    if c = '=' then // found either a hex triplet: =HEx,
    begin           // or a soft line break
      if i < (len-2) then
      begin
        c1 := Byte(iBuf[i+1]);
        c2 := Byte(iBuf[i+2]);

        if isXdigit(c1) AND isXdigit(c2) then
        begin
          oBuf[j] := AnsiChar((QP_DTable[c1] SHL 4) OR QP_DTable[c2]);
          Inc(i, 2);
          Inc(j);
        end
        else if (c1 = CR) AND (c2 = LF) then  // soft break
          Inc(i, 2);
      end;
      encoded := TRUE;
    end
    else begin
      // MIME ignores trailing spaces and tab characters unless
      // the line is terminated with a hex triplet: =09 or =20.
      // Therefore, we check the encoded flag, and if it is false
      // then we try to remove the trailing spaces.
      //
      if ((c = Chr(CR)) OR (c = Chr(LF))) AND NOT encoded then
      begin
        while (j > 0) AND (oBuf[j-1] in [#9, #32]) do Dec(j);
      end;
      oBuf[j] := c;
      Inc(j);
      encoded := FALSE;
    end;
    Inc(i);
  end;
  _QP_Decode := j
end;

function QPDecode(const AQPText: AnsiString): AnsiString;
begin
  SetLength(Result, Length(AQPText));
  SetLength(Result, _QP_Decode(PAnsiChar(Result), PAnsiChar(AQPText), Length(AQPText)))
end;

function _Qp_Encode(outC, inBeg, inEnd: PAnsiChar): PAnsiChar;
CONST cBasisHex: ARRAY [0..15] of AnsiChar =
  ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

CONST _CR = #13; _LF = #10;
CONST cLineLen = 72;
VAR itsLinePos: Integer;
    itsPrevCh, c: AnsiChar;
    lastSpace: PAnsiChar;
begin
  itsLinePos := 0;
  itsPrevCh  := #0;

  lastSpace := Nil;

  while (inBeg <> inEnd) do
  begin
    c := inBeg^;

    // line-breaks
    if (c = _CR) OR (c = _LF) then
    begin
      if (itsPrevCh = ' ') {OR (itsPrevCh = #9)} then
      begin
        Dec(outC);
        outC^ := '=';
        Inc(outC);
        outC^ := cBasisHex[Byte(itsPrevCh) SHR 4];
        Inc(outC);
        outC^ := cBasisHex[Byte(itsPrevCh) AND $0F];
        Inc(outC);
      end;
      outC^ := c;
      Inc(outC);
      itsLinePos := 0;
      itsPrevCh := c;
      lastSpace := Nil;
    end
    else
      if (c in [{#9, }#32..#60, #62..#126])
         // Following line is to avoid single periods alone on lines,
         // which messes up some dumb SMTP implementations, sigh...
         AND NOT ((itsLinePos = 0) AND (c = '.')) then
         begin
            itsPrevCh := c;
            outC^ := c;
            Inc(outC);
            Inc(itsLinePos);

            if ((c = ' ') {OR (c = #9)}) AND (itsLinePos > cLineLen/2) then
              lastSpace := outC;
         end
         else begin
            outC^ := '=';
            Inc(outC);
            outC^ := cBasisHex[Byte(c) SHR 4];
            Inc(outC);
            outC^ := cBasisHex[Byte(c) AND $0F];
            Inc(outC);
            Inc(itsLinePos, 3);
            itsPrevCh := 'A'; // close enough
         end;

    if (itsLinePos > cLineLen) then
    begin

      if lastSpace <> Nil then
      begin
        itsLinePos := outC - lastSpace;
        Move(lastSpace^, (lastSpace+3)^, outC - lastSpace);
        lastSpace^ := '=';
        Inc(lastSpace);
        lastSpace^ := _CR;
        Inc(lastSpace);
        lastSpace^ := _LF;
        Inc(outC, 3);
        lastSpace := Nil;
      end
      else begin
        outC^ := '=';
        Inc(outC);
        outC^ := _CR;
        Inc(outC);
        outC^ := _LF;
        Inc(outC);
        itsPrevCh := _LF;
        itsLinePos := 0;
      end;
    end;
    Inc(inBeg);
  end;

  if (itsLinePos <> 0) then
  begin
    outC^ := '=';
    Inc(outC);
    outC^ := _CR;
    Inc(outC);
    outC^ := _LF;
    Inc(outC);
  end;

  Result := outC;
end;

function QPEncode(const ASourceText: AnsiString): AnsiString;
var x: PAnsiChar;
begin
  SetLength(Result, 3 * Length(ASourceText));
  x  := _Qp_Encode(PAnsiChar(Result), PAnsiChar(ASourceText), PAnsiChar(ASourceText) + Length(ASourceText));
  SetLength(Result, x - PChar(Result));
end;

end.


