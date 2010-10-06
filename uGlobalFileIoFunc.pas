unit uGlobalFileIoFunc;

interface

uses
  Windows, SysUtils, Classes, RTLConsts
  , AcedContainers, AcedStrings, ZLibExGZ, ZLibEx, uAnsiStrings, uGlobalTypes,
  uGlobalConstants
  {$IFDEF UNICODE}
    , AnsiStrings, Masks
  {$ENDIF}
  ;

type
  TFindInDirOpt = (foFindDirs, foFindFiles, foIncFullPath, foRecurs, foIncFilePath);
  TFindInDirOpts = set of TFindInDirOpt;

/// <summary>
/// Открывает файл для чтения
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ARaiseException">в случае ошибки вызвать Exception</param>
/// <returns>Handle открытого файла или INVALID_HANDLE_VALUE в случае ошибки</returns>
function OpenFileRead(const AFileName: TFileName; ARaiseException: Boolean): THandle;

/// <summary>
/// Открывает файл на запись
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="AAppend">добавлять новые данные в конец файла</param>
/// <param name="ARaiseException">в случае ошибки вызвать Exception</param>
/// <returns>Handle открытого файла или INVALID_HANDLE_VALUE в случае ошибки</returns>
function OpenFileWrite(const AFileName: TFileName; AAppend, ARaiseException: Boolean): THandle;

function FileWriteText(AHandle: THandle; const AText: AnsiString; ARaiseException: Boolean): Boolean;

function StringLoadFromFileHandle(const AHandle: THandle; out AOut: AnsiString;
  ARaiseException: Boolean; const ADefault: AnsiString): DWORD;

function StringLoadFromFile(
  const AFileName: string;
  out AOut: AnsiString;
  ATestFileExist: Boolean = False;
  ARaiseException: Boolean = True;
  const ADefault: AnsiString = ''
): DWORD; overload;

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
): AnsiString; overload;

/// <summary>
/// Сохранение строки в файл
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ABuffer">буфер данных</param>
/// <param name="AAppend">добавлять данные в конец файла</param>
/// <param name="ARaiseException">при ошибке вызывать исключение</param>
/// <returns>True - если файнные записыны успешно</returns>
//TODO: добавть параметр для отклбчения ForceDirectory()
//TODO: сдеелать перегрузку с параметрами set of ()
function StringSaveToFile(
  const AFileName: string;
  const ABuffer: AnsiString;
  AAppend: Boolean = False;
  ARaiseException: Boolean = True
): Boolean;

/// <summary>
/// Загрузка файла в TAnsiStrings
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
/// Запись в файла из TAnsiStrings построчно
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="AStrings">что сохранять</param>
/// <param name="AAppend">добалять в конец файта, False - перезависать файл</param>
/// <param name="AUseTextWriter">использовать TextWriter (т.е. буфер)</param>
/// <param name="ARaiseException">в случае ошибки записи вызвать exception</param>
/// <returns>возвращает AStrings</returns>
function StringsSaveToFile(
  const AFileName: string;
  AStrings: TAnsiStrings;
  AAppend: Boolean = False;
  AUseTextWriter: Boolean = False;
  ARaiseException: Boolean = True
): TAnsiStrings; {$IFDEF UNICODE} overload;{$ENDIF}

{$IFDEF UNICODE}
function StringsSaveToFile(
  const AFileName: TFileName;
  AStrings: TUnicodeStrings;
  AAppend: Boolean = False;
  AUseTextWriter: Boolean = False;
  ARaiseException: Boolean = True
): TUnicodeStrings; overload;
{$ENDIF}


/// <summary>
/// полный размер файла (>2ГБ)
/// </summary>
/// <param name="AFileName">Имя файла</param>
/// <returns>размер файла</returns>
function GetFileSize2(const AFileName: string): Int64;

function SafeForceDirectories(const ADirName: TFileName): Boolean;


function FindInDir(const ADirName: string; AStrings: TStrings;
  const AOpts: TFindInDirOpts = [foFindFiles];
  const AFindMask: string = '*'): Integer; overload;
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
  AIncFilePath: Boolean = False): Integer; overload;

{$IFDEF UNICODE}
function FindInDir(const ADirName: string; AStrings: TAnsiStrings;
  AFindFile: Boolean = True; const AFindMask: string = '*';
  AIncFullPath: Boolean = False; ARecurs: Boolean = False;
  AIncFilePath: Boolean = False): Integer; overload;

/// <summary>
/// Загрузка UTF8 файла в UncodeString
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ATestFileExist">проверять наличие файла</param>
/// <param name="ARaiseException">вызывать исключение в случае ошибки открытия/чтение файла</param>
/// <param name="ADefault">возвращать строку в случае неудачи</param>
/// <returns>содержимое файла в UncodeString</returns>
function UnicodeStringLoadFromFile(
  const AFileName: TFileName;
  ATestFileExist: Boolean = False;
  ARaiseException: Boolean = True;
  const ADefault: UnicodeString = ''
): UnicodeString; overload;

/// <summary>
/// Сохранение UnicodeString строки в файл UTF8
/// </summary>
/// <param name="AFileName">имя файла</param>
/// <param name="ABuffer">буфер данных</param>
/// <param name="AAppend">добавлять данные в конец файла</param>
/// <param name="ARaiseException">при ошибке вызывать исключение</param>
/// <returns>True - если файнные записыны успешно</returns>
function UnicodeStringSaveToFile(
  const AFileName: TFileName;
  const ABuffer: UnicodeString;
  AAppend: Boolean = False;
  ARaiseException: Boolean = True
): Boolean;

{$ENDIF}

implementation

uses
  uGlobalVars, uGlobalFunctions, uTextReader, uTextWriter;

function OpenFileReadOrWrite(const AFileName: TFileName;
  AOpenRead, AAppend, ARaiseException: Boolean): THandle;
var
  dwDesiredAccess: DWORD;
  dwCreationDisposition: DWORD;
begin
//  Result := INVALID_HANDLE_VALUE;
  if AOpenRead then
  begin
    dwDesiredAccess := GENERIC_READ;
    dwCreationDisposition := OPEN_EXISTING;
  end
  else
  begin
    dwDesiredAccess := GENERIC_WRITE;
    if AAppend then
      dwCreationDisposition := OPEN_ALWAYS
    else
      dwCreationDisposition := CREATE_ALWAYS
  end;
  //---
  SetLastError(0);
  //---
  Result := CreateFile(
    PChar(AFileName),
    dwDesiredAccess,
    FILE_SHARE_READ,
    nil,
    dwCreationDisposition,
    FILE_ATTRIBUTE_NORMAL,
    0
  );
  if Result<>INVALID_HANDLE_VALUE then
  begin
    if (not AOpenRead) and AAppend then
      SetFilePointer(Result, 0, nil, FILE_END);
  end
  else if ARaiseException then
  begin
    raise EFOpenError.CreateFmt(
            SFOpenErrorEx,
            [
              SysUtils.ExpandFileName(AFileName),
              SysErrorMessage(GetLastError())
            ]
          );
  end;
end;

function OpenFileRead(const AFileName: TFileName; ARaiseException: Boolean): THandle;
begin
  Result := OpenFileReadOrWrite(AFileName, True, False, ARaiseException)
end;

function OpenFileWrite(const AFileName: TFileName; AAppend, ARaiseException: Boolean): THandle;
begin
  Result := OpenFileReadOrWrite(AFileName, False, AAppend, ARaiseException)
end;

function FileWriteText(AHandle: THandle; const AText: AnsiString; ARaiseException: Boolean): Boolean;
begin
  Result := SysUtils.FileWrite(AHandle, Pointer(AText)^, Length(AText)) > -1;
  if (not Result) and (ARaiseException) then
  begin
    raise EWriteError.CreateRes(@SWriteError);
  end
end;

function StringLoadFromFileHandle(const AHandle: THandle; out AOut: AnsiString;
  ARaiseException: Boolean; const ADefault: AnsiString): DWORD;
var
  sizeFile: Cardinal;
  res: Int64;
begin
  AOut := '';
  Result := ERROR_SUCCESS;
  SetLastError(Result);
  sizeFile := GetFileSize(AHandle, nil);
  if sizeFile=0 then
    Exit; //***
  SetLength(AOut, sizeFile);
  res := FileRead(Integer(AHandle), Pointer(AOut)^, sizeFile);
  if (res>-1) and (res=sizeFile) then
    Exit //***
  else
    if ARaiseException then
      raise EReadError.CreateRes(@SReadError);
  //---
  AOut := ADefault;
  Result := GetLastError()
end;


function StringLoadFromFile(const AFileName: string; out AOut: AnsiString;
  ATestFileExist, ARaiseException: Boolean;
  const ADefault: AnsiString): DWORD;
var
  hFile: THandle;
  lasterr: DWORD;
begin
  AOut := '';
  Result := ERROR_SUCCESS;
  SetLastError(Result);
  if not ATestFileExist or FileExists(AFileName) then
  begin
    hFile := OpenFileRead(AFileName, ARaiseException);
    if hFile<>INVALID_HANDLE_VALUE then
    begin
      try
        StringLoadFromFileHandle(hFile, AOut, ARaiseException, ADefault);
        Exit;
      finally
        lasterr := GetLastError();
        CloseHandle(hFile);
        SetLastError(lasterr);
      end
    end
  end
  else
  begin
    SetLastError(ERROR_FILE_NOT_FOUND);
  end;
  //---
  AOut := ADefault;
  Result := GetLastError()
end;

function StringLoadFromFile(const AFileName: string;
  ATestFileExist, ARaiseException: Boolean;
  const ADefault: AnsiString): AnsiString;
begin
  StringLoadFromFile(AFileName, Result, ATestFileExist, ARaiseException, ADefault)
end;

function StringSaveToFile(const AFileName: string; const ABuffer: AnsiString;
  AAppend, ARaiseException: Boolean): Boolean;
var hFile: THandle;
begin
  Result := False;
  if SafeForceDirectories(ExtractFileDir(AFileName)) then
  begin
    hFile := OpenFileWrite(AFileName, AAppend, ARaiseException);
    if hFile<>INVALID_HANDLE_VALUE then
    begin
      try
        Result := FileWriteText(hFile, ABuffer, ARaiseException);
      finally
        CloseHandle(hFile)
      end
    end
  end;
end;

function StringsLoadFromFile(const AFileName: string; AStrings: TAnsiStrings;
  ATestFileExist, AAlwaysClear, AReadByLine: Boolean): TAnsiStrings;
var reader: TAnsiStreamReader;
begin
  Result := AStrings;
  if AAlwaysClear then
    AStrings.Clear;
  //---
  if not ATestFileExist or FileExists(AFileName) then
  begin
    if AReadByLine then
    begin
      reader := TAnsiStreamReader.Create(AFileName);
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

function StringsSaveToFile(const AFileName: string; AStrings: TAnsiStrings;
  AAppend, AUseTextWriter, ARaiseException: Boolean): TAnsiStrings;
var
  hFile: THandle;
  writer: TAnsiStreamWriter;
  j: Integer;
begin
  Result := AStrings;
  if AUseTextWriter then
  begin
    try
      writer := TAnsiStreamWriter.Create(AFileName, not AAppend);
      try
        writer.WriteStrings(AStrings);
      finally
        writer.Free;
      end;
    except
      on E: Exception do
      begin
        if ARaiseException or (not (E is EStreamError)) then
          raise
      end;
    end;
  end
  else
  begin
    hFile := OpenFileWrite(AFileName, AAppend, ARaiseException);
    if hFile<>INVALID_HANDLE_VALUE then
    begin
      try
        for j:=0 to AStrings.Count-1 do
        begin
          if not FileWriteText(hFile, AStrings[j]+CRLF, ARaiseException) then
            Exit;
        end;
      finally
        CloseHandle(hFile)
      end
    end
  end;
end;

{$IFDEF UNICODE}
function StringsSaveToFile(const AFileName: TFileName; AStrings: TUnicodeStrings;
  AAppend, AUseTextWriter, ARaiseException: Boolean): TUnicodeStrings;
var
  hFile: THandle;
  writer: TStreamWriter;
  j: Integer;
  dat: RawByteString;
begin
  Result := AStrings;
  if AUseTextWriter then
  begin
    try
      writer := TStreamWriter.Create(AFileName, not AAppend, TEncoding.UTF8);
      try
        for j:=0 to AStrings.Count-1 do
          writer.WriteLine(AStrings[j]);
      finally
        writer.Free;
      end;
    except
      on E: Exception do
      begin
        if ARaiseException or (not (E is EStreamError)) then
          raise
      end;
    end;
  end
  else
  begin
    hFile := OpenFileWrite(AFileName, AAppend, ARaiseException);
    if hFile<>INVALID_HANDLE_VALUE then
    begin
      try
        for j:=0 to AStrings.Count-1 do
        begin
          dat := UTF8Encode(AStrings[j]+CRLF);
          if not FileWrite(hFile, dat, ARaiseException) then
            Exit;
        end;
      finally
        CloseHandle(hFile)
      end
    end
  end;
end;
{$ENDIF}


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

function _FindInDir(const ADirName, ASubDir: string; AStrings: TObject;
  const AOpts: TFindInDirOpts; const AFindMask: string): Integer;
var
  ssr : TSearchRec;
  {$IFDEF UNICODE}
    MaskCheckObj: Masks.TMask;
    ansi_out: Boolean;
    lAnsiStrings: TAnsiStrings;
  {$ENDIF}
  lStrings: TStrings;

  procedure _Add(const AStr: string);
  begin
    {$IFDEF UNICODE}
      if ansi_out then
        lAnsiStrings.Add(AnsiString(AStr))
      else
        lStrings.Add(AStr)
    {$ELSE}
      lStrings.Add(AStr)
    {$ENDIF}
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
    if AStrings is TAnsiStrings then
    begin
      ansi_out := True;
      lStrings := nil;
      lAnsiStrings := AStrings as TAnsiStrings;
    end
    else if AStrings is TStrings then
    begin
      ansi_out := False;
      lStrings := AStrings as TStrings;
      lAnsiStrings := nil;
    end
    else
    begin
      raise Exception.Create('FindInDir() AStrings param isn''t TStrings object.');
    end;
  {$ELSE}
    lStrings := AStrings as TStrings;
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
        if ((foFindFiles in AOpts) and ((ssr.Attr and faDirectory)=0)) or
           ((foFindDirs in AOpts) and (((ssr.Attr and faDirectory)<>0))) then
        begin
          if _MatchesMask(ssr.Name) then
          begin
            Inc(Result);
            if Assigned(AStrings) then
            begin
              if foIncFullPath in AOpts then
                _Add(ADirName+ASubDir+ssr.Name)
              else
                if foIncFilePath in AOpts then
                  _Add(ASubDir+ssr.Name)
                else
                  _Add(ssr.Name)
            end;
          end;
        end;
        if (foRecurs in AOpts) and ((ssr.Attr and faDirectory)<>0) then
          Result := Result +
            _FindInDir(ADirName, ASubDir+ssr.Name+'\', AStrings, AOpts, AFindMask)
      end;
    until FindNext(ssr)<>0;
  finally
    SysUtils.FindClose(ssr);
    {$IFDEF UNICODE}
      FreeAndNil(MaskCheckObj);
    {$ENDIF}
  end;
end;

{$IFDEF UNICODE}
function FindInDir(const ADirName: string; AStrings: TAnsiStrings;
  AFindFile: Boolean; const AFindMask: string;
  AIncFullPath, ARecurs, AIncFilePath: Boolean): Integer;
var lOpts: TFindInDirOpts;
begin
  lOpts := [];
  if AFindFile then lOpts := lOpts + [foFindFiles]
    else lOpts := lOpts + [foFindDirs];
  if AIncFullPath then lOpts := lOpts + [foIncFullPath];
  if ARecurs then lOpts := lOpts + [foRecurs];
  if AIncFilePath then lOpts := lOpts + [foIncFilePath];
  Result := _FindInDir(
    SysUtils.IncludeTrailingPathDelimiter(ADirName),
    '',
    AStrings,
    lOpts,
    AFindMask
  );
end;

function UnicodeStringLoadFromFile(const AFileName: TFileName;
  ATestFileExist, ARaiseException: Boolean;
  const ADefault: UnicodeString): UnicodeString;
var F: TStreamReader;
begin
  Result := '';
  if not ATestFileExist or FileExists(AFileName) then
  begin
    try
      F := TStreamReader.Create(AFileName, TEncoding.UTF8);
      try
        Result := F.ReadToEnd();
        Exit;
      finally
        F.Free;
      end;
    except
      on E: Exception do
      begin
        if ARaiseException or (not (E is EStreamError)) then
          raise
      end;
    end;
  end;
  //---
  Result := ADefault;
end;

function UnicodeStringSaveToFile(const AFileName: TFileName;
  const ABuffer: UnicodeString; AAppend, ARaiseException: Boolean): Boolean;
var F: TStreamWriter;
begin
  Result := False;
  if SafeForceDirectories(ExtractFileDir(AFileName)) then
  begin
    try
      F := TStreamWriter.Create(AFileName, False, TEncoding.UTF8);
      try
        F.Write(ABuffer);
        Result := True;
      finally
        F.Free;
      end;
    except
      on E: Exception do
      begin
        if ARaiseException or (not (E is EStreamError)) then
          raise
      end;
    end;
  end;
end;

{$ENDIF}


function FindInDir(const ADirName: string; AStrings: TStrings;
  AFindFile: Boolean; const AFindMask: string;
  AIncFullPath, ARecurs, AIncFilePath: Boolean): Integer;
var lOpts: TFindInDirOpts;
begin
  lOpts := [];
  if AFindFile then lOpts := lOpts + [foFindFiles]
    else lOpts := lOpts + [foFindDirs];
  if AIncFullPath then lOpts := lOpts + [foIncFullPath];
  if ARecurs then lOpts := lOpts + [foRecurs];
  if AIncFilePath then lOpts := lOpts + [foIncFilePath];
  Result := _FindInDir(
    SysUtils.IncludeTrailingPathDelimiter(ADirName),
    '',
    AStrings,
    lOpts,
    IfElse(AFindMask='*.*','*',AFindMask)
  );
end;

function FindInDir(const ADirName: string; AStrings: TStrings;
  const AOpts: TFindInDirOpts; const AFindMask: string): Integer;
begin
  Result := _FindInDir(
    SysUtils.IncludeTrailingPathDelimiter(ADirName),
    '',
    AStrings,
    AOpts,
    IfElse(AFindMask='*.*','*',AFindMask)
  );
end;



function SafeForceDirectories(const ADirName: TFileName): Boolean;
var
  Dir: TFileName;
  err: DWORD;
  res: Boolean;
begin
  if ADirName='' then
  begin
    Result := True;
    Exit;
  end;    
  Result := False;
  Dir := ExcludeTrailingPathDelimiter(ADirName);
  if Length(Dir)>=2 then
  begin
    if DirectoryExists(Dir) then
    begin
      Result := True;
      Exit;
    end;
    if SafeForceDirectories(ExtractFileDir(Dir)) then
    begin
      SetLastError(0);
      res := CreateDir(dir);
      err := GetLastError();
      Result := res or (err=ERROR_ALREADY_EXISTS)
    end;
  end;
end;

end.

