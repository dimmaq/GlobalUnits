unit uGlobalFunctions;

// {$DEFINE USE_REGULAR_EXPRESSIONS}

interface

uses
  Windows, SysUtils, Classes, RTLConsts
  {$IFDEF UNICODE}
    , AnsiStrings, Masks,
  {$ENDIF}
  AcedContainers, AcedStrings, ZLibExGZ, ZLibEx, uAnsiStrings, uGlobalTypes;

{$REGION 'Файловые ф-ции'}
//************************
// *** Файловые ф-ции ***
//---

/// <summary>
/// Загрузка файла в строку Ansi
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ATestFileExist">проверять наличие файла</param>
/// <param name="ARaiseException">вызывать исключение в случае ошибки открытия/чтение файла</param>
/// <param name="ADefault">возвращать строку в случае неудачи</param>
/// <returns>содержимое файла в AnsiString</returns>
function StringLoadFromFile(
  const AFileName: string;
  ATestFileExist: Boolean = False;
  ARaiseException: Boolean = True;
  const ADefault: AnsiString = ''
): AnsiString;

/// <summary>
/// Сохранение строки в файл
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ABuffer">буфер данных</param>
/// <param name="AAppend">добавлять данные в конец файла</param>
/// <param name="ARaiseException">при ошибке вызывать исключение</param>
procedure StringSaveToFile(
  const AFileName: string;
  const ABuffer: AnsiString;
  AAppend: Boolean = False;
  ARaiseException: Boolean = True
);

/// <summary>
/// Загрузка файла в TStrings
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="AStrings">куда загружать</param>
/// <param name="ATestFileExist">проверять наличие файла</param>
/// <param name="AAlwaysClear">очищать AStrings даже если файла нет</param>
/// <param name="AReadByLine">читать файл по строкам TextReader'ом</param>
/// <returns>возвращает AStrings</returns>
function StringsLoadFromFile(
  const AFileName: string;
  AStrings: TAnsiStrings;
  ATestFileExist: Boolean = False;
  AAlwaysClear: Boolean = True;
  AReadByLine: Boolean = False
): TAnsiStrings;

/// <summary>
/// полный размер файла (>2ГБ)
/// </summary>
/// <param name="AFileName">Имя файла</param>
/// <returns>размер файла</returns>
function GetFileSize2(const AFileName: string): Int64;

/// <summary>
/// поиск файлов\директорий
/// </summary>
/// <param name="ADirName">где искать</param>
/// <param name="AStrings">куда записывать найденное</param>
/// <param name="AFindFile">искать файлы или директории</param>
/// <param name="AFindMask">маска поиска</param>
/// <param name="AIncFullPath">записывать в AStrings полный путь к файлу</param>
/// <param name="ARecurs">рекурсивный поиск, т.е. включая поддиректории</param>
/// <param name="AIncFilePath">при AIncFullPath=False и ARecurs=True записывать найденное с поддиректориями</param>
/// <returns>кол-во найденный файлов\директорий</returns>
function FindInDir(const ADirName: string; AStrings: TStrings;
  AFindFile: Boolean = True; const AFindMask: string = '*';
  AIncFullPath: Boolean = False; ARecurs: Boolean = False;
  AIncFilePath: Boolean = False): Integer;
//---
{$ENDREGION}

//---
// *** Строковые ф-ции ***

/// <summary>
/// Возвращает случайную строку из TStrings
/// </summary>
/// <param name="AStrings"></param>
/// <param name="ADefault">возвращает ADefault если AStrings пустой</param>
/// <returns>случайная строка из AStrings</returns>
function StringsRandom(AStrings: TStrings;
    const ADefault: string = ''): string;

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
  AStart: Integer = 1): Integer;

/// <summary>
/// Экранирует спец. символы для JSON
/// </summary>
function JsonStringSafe(const AStr: AnsiString): AnsiString;
//---

//---
// *** Разное ***
function IfElse(B: Boolean; const IfTrue: AnsiString;
  const IfFalse: AnsiString = ''): AnsiString; overload; inline;
{$IFDEF UNICODE}
function IfElse(B: Boolean; const IfTrue: UnicodeString;
  const IfFalse: UnicodeString = ''): UnicodeString; overload; inline;
{$ENDIF}
function IfElse(B: Boolean; const IfTrue,IfFalse: Integer): Integer; overload; inline;

procedure GetMemoryInfo(AStrings: TStrings);
Function IntToStr2(AInt,ALen: Integer): AnsiString;
function BoolToStr2(B, AUseStr: Boolean): ShortString;
function Tick2Text(k: Int64): string;
procedure ShowInformation(const AText: string);
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
function ExtractMailDomain(const AMail: AnsiString): AnsiString; {$IFDEF UNICODE}overload;{$ENDIF}
{$IFDEF UNICODE}
function ExtractMailDomain(const AMail: UnicodeString): UnicodeString; overload;
{$ENDIF}
function StrAppendWDelim(const AText, ANewText: AnsiString;
  const ADelim: AnsiString = ';'): AnsiString; {$IFDEF UNICODE}overload;{$ENDIF}
{$IFDEF UNICODE}
function StrAppendWDelim(const AText, ANewText: UnicodeString;
  const ADelim: UnicodeString = ';'): UnicodeString; overload;
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

implementation

uses
  {$IFDEF USE_REGULAR_EXPRESSIONS}uRegExprFunc,{$ENDIF}
  uGlobalVars,
  uTextReader
  ;

var
  _iTmpFile : Integer = 1;


{$REGION 'Файловые ф-ции'}

function StringLoadFromFile(const AFileName: string;
  ATestFileExist, ARaiseException: Boolean;
  const ADefault: AnsiString): AnsiString;
var
  hFile: THandle;
  sizeFile: Cardinal;
  res: Int64;
begin
  Result := '';
  if not ATestFileExist or FileExists(AFileName) then
  begin
    hFile := CreateFile(PChar(AFileName),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
    if hFile<>INVALID_HANDLE_VALUE then
    begin
      try
        sizeFile := GetFileSize(hFile, nil);
        if sizeFile=0 then
          Exit; //***        
        SetLength(Result, sizeFile);
        res := FileRead(Integer(hFile), Pointer(Result)^, sizeFile);
        if (res>-1) and (res=sizeFile) then
          Exit //***
        else
          if ARaiseException then
            raise EReadError.CreateRes(@SReadError);
      finally
        CloseHandle(hFile);
      end
    end
    else
    begin
      if ARaiseException then
        raise EFOpenError.CreateFmt(
                SFOpenErrorEx,
                [ExpandFileName(AFileName), SysErrorMessage(GetLastError)]
              );
    end;
  end;
  //---
  Result := ADefault;
end;

procedure StringSaveToFile(const AFileName: string; const ABuffer: AnsiString;
  AAppend, ARaiseException: Boolean);
var
  hFile: THandle;
  openMethod: DWORD;
begin
  openMethod := IfElse(AAppend, OPEN_ALWAYS, CREATE_ALWAYS);
  hFile := CreateFile(PChar(AFileName),GENERIC_WRITE,FILE_SHARE_READ,nil,openMethod,FILE_ATTRIBUTE_ARCHIVE,0);
  if hFile<>INVALID_HANDLE_VALUE then
  begin
    try
      if AAppend then
        SetFilePointer(hFile, 0, nil, FILE_END);
      if FileWrite(hFile, Pointer(ABuffer)^, Length(ABuffer))=-1 then
        if ARaiseException then
          raise EWriteError.CreateRes(@SWriteError);
    finally
      CloseHandle(hFile)
    end
  end
  else
  begin
    if ARaiseException then
      raise EFOpenError.CreateFmt(
              SFOpenErrorEx,
              [ExpandFileName(AFileName), SysErrorMessage(GetLastError())]
            );
  end;
end;

function StringsLoadFromFile(const AFileName: string; AStrings: TAnsiStrings;
  ATestFileExist, AAlwaysClear, AReadByLine: Boolean): TAnsiStrings;
var reader: uTextReader.TTextReader;
begin
  Result := AStrings;
  if AAlwaysClear then
    AStrings.Clear;
  //---
  if not ATestFileExist or FileExists(AFileName) then
  begin
    if AReadByLine then
    begin
      reader := uTextReader.TTextReader.Create(AFileName);
      try
        if not AAlwaysClear then
          AStrings.Clear;
        reader.ReadStrings(AStrings);
      finally
        reader.Free
      end
    end
    else
    begin
      if not AAlwaysClear then
        AStrings.Clear;
      AStrings.LoadFromFile(AFileName);
    end;
  end
end;

function GetFileSize2(const AFileName: string): Int64;
var
  d : TWin32FindData;
  h : hwnd;
begin
  Result := 0;
  h := FindFirstFile(PChar(AFileName), d);
  if (h<>INVALID_HANDLE_VALUE) then
  begin
    Result := d.nFileSizeLow or Int64(d.nFileSizeHigh) shl 32;
    Windows.FindClose(h);
  end;
end;

function _FindInDir(const ADirName, ASubDir: string; AStrings: TStrings;
  AFindFile: Boolean; const AFindMask: string;
  AIncFullPath, ARecurs, AIncFilePath: Boolean): Integer;
var
  ssr : TSearchRec;
  {$IFDEF UNICODE}
    MaskCheckObj: Masks.TMask;
  {$ENDIF}

  procedure _Add(const AStr: string);
  begin
    AStrings.Add(AStr);
  end;

  function _MatchesMask(const AFileName: string): Boolean;
  begin
    {$IFDEF UNICODE}
    Result := MaskCheckObj.Matches(AFileName);
    {$ELSE}
    Result := G_ValidateWildText(AFileName, AFindMask);
    {$ENDIF}
  end;

begin
  Result := 0;
  //---
  {$IFDEF UNICODE}
    MaskCheckObj := nil;
  {$ENDIF}
  //---
  if FindFirst(ADirName+ASubDir+'*', faAnyFile, ssr)=0 then
  try
    {$IFDEF UNICODE}
      MaskCheckObj := Masks.TMask.Create(AFindMask);
    {$ENDIF}
    //---
    repeat
      if (ssr.Name<>'..') and (ssr.Name<>'.') then
      begin
        if (AFindFile and ((ssr.Attr and faDirectory)=0)) or
           ((not AFindFile) and (((ssr.Attr and faDirectory)<>0))) then
        begin
          if _MatchesMask(ssr.Name) then
          begin
            Inc(Result);
            if Assigned(AStrings) then
            begin
              if AIncFullPath then
                _Add(ADirName+ASubDir+ssr.Name)
              else
                if AIncFilePath then
                  _Add(ASubDir+ssr.Name)
                else
                  _Add(ssr.Name)
            end;
          end;
        end;
        if ARecurs and ((ssr.Attr and faDirectory)<>0) then
          Result := Result +
            _FindInDir(ADirName, ASubDir+ssr.Name+'\', AStrings, AFindFile,
              AFindMask, AIncFullPath, ARecurs, AIncFilePath)
      end;
    until FindNext(ssr)<>0;
  finally
    SysUtils.FindClose(ssr);
    {$IFDEF UNICODE}
      FreeAndNil(MaskCheckObj);
    {$ENDIF}
  end;
end;
function FindInDir(const ADirName: string; AStrings: TStrings;
  AFindFile: Boolean; const AFindMask: string;
  AIncFullPath, ARecurs, AIncFilePath: Boolean): Integer;
begin
  Result := _FindInDir(
    SysUtils.IncludeTrailingPathDelimiter(ADirName),
    '',
    AStrings,
    AFindFile,
    IfElse(AFindMask='*.*','*',AFindMask),
    AIncFullPath,
    ARecurs,
    AIncFilePath
  );
end;
{$ENDREGION}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------




//------------------------------------------------------------------------------
// *** Строковые ф-ции ***

function StringsRandom(AStrings: TStrings; const ADefault: string): string;
begin
  if AStrings.Count>0 then
    Result := AStrings[Random(AStrings.Count)]
  else
    Result := ADefault
end;

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
  AStart: Integer): Integer;
var j: Integer;
begin
  Result := 0;
  for j:=AStart to Length(AStr) do
  begin
    if AStr[j] in AChars then
    begin
      Result := j;
      Exit;
    end;
  end;
end;

function JsonStringSafe(const AStr: AnsiString): AnsiString;
type
  TUnsafeCharRec = record
    c: AnsiChar;
    s: string[2];
  end;
const
  unsafe_char: array[0..5] of TUnsafeCharRec = (
    (c:'\'; s:'\\'), (c:'"'; s:'\"'), (c:#9; s:'\t'),
    (c:#10; s:'\n'), (c:#12; s:'\f'), (c:#13; s:'\r')
  );
var j: Integer;
begin
  Result := AStr;
  for j:=Low(unsafe_char) to High(unsafe_char) do
    Result := G_ReplaceStr(Result, unsafe_char[j].c, unsafe_char[j].s);
end;

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


function IfElse(B: Boolean; const IfTrue,IfFalse: Integer):Integer;
begin
  if B then
    Result := IfTrue
  else
    Result := IfFalse
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

Function IntToStr2(AInt,ALen: Integer): AnsiString;
begin
  Result := {$IFDEF UNICODE}AnsiStrings.{$ENDIF}Format('%.*d', [ALen, AInt])
end;

{$IFDEF UNICODE}
function IntToStr(X: Integer; Width: Integer = 0): AnsiString;
begin
   Str(X: Width, Result);
end;
{$ENDIF}

function BoolToStr2(B, AUseStr: Boolean): ShortString;
const
  cBoolStrs: array[Boolean] of array[Boolean] of ShortString = (('0', '1'),('False', 'True'));
begin
  Result := cBoolStrs[AUseStr][B];
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


procedure ShowInformation(const AText: string);
begin
  Windows.MessageBox(0, PChar(AText), 'Information', MB_OK or MB_ICONINFORMATION);
end;

procedure ShowError(const AText: string);
begin
  Windows.MessageBox(0, PChar(AText), 'Information', MB_OK or MB_ICONERROR);
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
    Result := StrToIntDef(string(Copy(AAddr, p+1, MaxInt)), ADefPort)
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
var p:Integer;
begin
  p := Pos(':', AAddr);
  if p<>0 then
    Result := StrToIntDef(Copy(AAddr, p+1, MaxInt), ADefPort)
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

function StrAppendWDelim(const AText, ANewText, ADelim: AnsiString): AnsiString;
begin
  if AText='' then
    Result := ANewText
  else if ANewText<>'' then
    Result := AText + ADelim + ANewText
  else
    Result := AText
end;

{$IFDEF UNICODE}
function StrAppendWDelim(const AText, ANewText, ADelim: UnicodeString): UnicodeString;
begin
  if AText='' then
    Result := ANewText
  else if ANewText<>'' then
    Result := AText + ADelim + ANewText
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
  z : AcedStrings.TStringBuilder;
  tag: AnsiString;
begin
  z := AcedStrings.TStringBuilder.Create;
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

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------


end.
