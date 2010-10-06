unit uMacros;

//TODO: запись промежеточных значений в буфер
//todo: использовать tstringbuilder
//DONE:  генерация FMacroNames один раз
//TODO: подключение модулейв initialization (а надо ли?)

interface

uses
  // родные
  Classes, Math, SysUtils, SyncObjs, Types,
  // мои
  uAnsiStrings, uTwoStrList, uListRandomAStrings, uGlobalTypes,
  // асед
  AcedStrings, AcedContainers, AcedBinary;

type  
  EMacroError = class(Exception);

  TMacroNames = TStringAssociationList;

  TMacroModuleLocal = class;
  TMacros = class;

  TMacroModule = class abstract
  strict private
    FMacroNames: TMacroNames;
    function FindName(const AName: AnsiString; out AId: Integer): Boolean;
  protected
    // дети должны! переопределить метод создания массива имен
    // чтобы оспользовался только один экземпляр массива
    //  для всех объектов
    class function CreateOneMacroNames: TMacroNames; virtual; abstract;
    class procedure FillOneMacroNames(A: TMacroNames); virtual;
    class procedure DestroyOneMacroNames; virtual; abstract;
    class procedure InitMacroNames;
    // Добавляет записи из ASource в массив ADestination
    class procedure AddNames(const ASource: array of TAStrIntRec;
      const ADestination: TMacroNames); static;
    //---
    function ApplyNameMacro(ANameID: Integer; const AParam: AnsiString;
      out AOut: AnsiString): Boolean; virtual;
    function ApplyMacro(const AName, AParam: AnsiString;
      out AOut: AnsiString): Boolean; virtual;
  public
    constructor Create(const AOwner: TMacros);
    destructor Destroy; override;
    //---
    procedure Clear; virtual;
  end;

  TSelectVar = TStringAssociationList;

  TMacroModuleLocal = class abstract(TMacroModule)
  strict private
    const
      _SELECT2_N = 'SELECT2'; _SELECT2_I = 17;
      _SETVAR_N  = 'SETVAR';  _SETVAR_I  = 18;
      _SETVAR2_N = 'SETVAR2'; _SETVAR2_I = 19;
  protected
    FVarList: TTwoStrList;
    FSelectTwoArray: TSelectVar;
    //---
    class procedure FillOneMacroNames(A: TMacroNames); override;
    //---
    function MacroSelect2(const AParam: AnsiString): AnsiString; virtual;
    function MacroSetVar(const AParam: AnsiString): AnsiString; virtual;
    //---
    function ApplyNameMacro(ANameID: Integer; const AParam: AnsiString;
      out AOut: AnsiString): Boolean; override;
    function ApplyMacro(const AName, AParam: AnsiString;
      out AOut: AnsiString): Boolean; override;
  public
    constructor Create;
    destructor Destroy; override;
    //---
    function FindVar(const AName: AnsiString;
      out AValue: AnsiString): Boolean; overload;
    function FindVar(const AName: AnsiString): AnsiString; overload;
    procedure Clear; override;
  end;

  TMacros = class sealed(TObject)
  private
    FModLocal: TMacroModuleLocal;
    FModList: TArrayList;
    FModBase: TMacroModule;
    //---
    class procedure ParseMacro(const AText: AnsiString;
      var AMacroName, AMacroParam: AnsiString); static;
    class function YesMacroNew2(const AStr: AnsiString; out s,l: Integer;
      AStart: Integer): Boolean; static;
    //---
    function _ApplyMacros(const AInString: AnsiString; ALocalMod: TMacroModuleLocal;
      out AOut: AnsiString): Boolean;
  public
    constructor Create(const AMacrosDir: TFileName);
    destructor Destroy; override;
    //---
    procedure AddModule(const A: TMacroModule);
    function ApplyMacros(const AText: AnsiString;
      ALocalMod: TMacroModuleLocal): AnsiString;
    procedure ReLoadMacros(const AMacrosDir: TFileName = '');
    //---
    function _Dump: UTF8String;
    //---
  end;
  
implementation

uses uGlobalFunctions, uGlobalFileIOFunc, uGlobalConstants, uGlobalVars;

type
  TMacroModuleLocalLocked = class sealed(TMacroModuleLocal)
  strict private
    FLock: TCriticalSection;
    class var
      MacroNamesLocalLocked: TMacroNames;
  protected
    class function CreateOneMacroNames: TMacroNames; override;
    class procedure DestroyOneMacroNames; override;
    //---
    function MacroSelect2(const AParam: AnsiString): AnsiString; override;
    function MacroSetVar(const AParam: AnsiString): AnsiString; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TMacroFileList = TStringAssociationList;

  TMacroModuleBase = class sealed(TMacroModule)
  strict private
    const
      _RND_CHAR_N      = 'RND_CHAR';       _RND_CHAR_I      = 11;
      _RND_NUM_N       = 'RND_NUM';        _RND_NUM_I       = 12;
      _RND_CHARNUM_N   = 'RND_CHARNUM';    _RND_CHARNUM_I   = 13;
      _RND_LOWCHAR_N   = 'RND_LOWCHAR';    _RND_LOWCHAR_I   = 14;
      _RND_HIGHCHAR_N  = 'RND_HIGHCHAR';   _RND_HIGHCHAR_I  = 15;
      _SELECT_N        = 'SELECT';         _SELECT_I        = 16;
      _TOLOWER_N       = 'TOLOWER';        _TOLOWER_I       = 51;
      _TOUPPER_N       = 'TOUPPER';        _TOUPPER_I       = 52;
      _NEWLINE_N       = 'NEWLINE';        _NEWLINE_I       = 53;
      _TAB_N           = 'TAB';            _TAB_I           = 54;
    class var
      MacroNamesBase: TMacroNames;
  private
    FLock: TMREWSync;
    FMacroFileList: TMacroFileList;
    FMacroDir: TFileName;
    function FindMacro(const AName: AnsiString;
      var AOut: AnsiString): Boolean;
    //---
    class function MacroSelect0(const AParamStr: AnsiString; AStart: Integer;
      var ANum: Integer): AnsiString; static;
    class function MacroSelect1(const AParamStr: AnsiString): AnsiString; static;
    class function MacroSelect2(const AParamStr: AnsiString;
      const ASelect2Array: TSelectVar): AnsiString; static;
    class function MacroRandomStr(const AChars, AParam: AnsiString): AnsiString; static;
    class function MacroSetVar(const AParam: AnsiString;
      const AArray: TTwoStrList): AnsiString; static;
  protected
    class function CreateOneMacroNames: TMacroNames; override;
    class procedure FillOneMacroNames(A: TMacroNames); override;
    class procedure DestroyOneMacroNames; override;
    //---
    function ApplyNameMacro(ANameID: Integer; const AParam: AnsiString;
      out AOut: AnsiString): Boolean; override;
    function ApplyMacro(const AName, AParam: AnsiString;
      out AOut: AnsiString): Boolean; override;
  public
    constructor Create(const AOwner: TMacros; const AMacrosDir: TFileName);
    destructor Destroy; override;
    //---
    procedure ReLoadMacros(const AMacrosDir: TFileName);
    //---
    property MacroDir: TFileName read FMacroDir;
  end;


const
  cNotMacroChars = [#0..#255] - gCharsEng - gCharsNum -
                     ['_','-','=','.','[',']',',','"','''','|',';',':',#32,#9];
  cMacroNameFirstChar = gCharsEng + gCharsNum;
  cMacroNameLastChar = gCharsEng + gCharsNum + [']'];


procedure MyStuffString(var S: AnsiString; Index, Count: Integer;
  const ASubStr: AnsiString);
var
  L,R,I,M,K: Integer;
  tmp: AnsiString;
begin
  if ASubStr = '' then
  begin
    Delete(S, Index, Count);
    Exit;
  end;
  if S = '' then
  begin
    S := ASubStr;
    Exit;
  end;
  M := Length(S); // исходная длинна
  if Index<1 then
    Index := 1;
  // вставлять в конец
  if Index>=M then
  begin
    S := S + ASubStr;
    Exit;
  end;
  // если удалять не надо
  if Count<1 then
  begin
    Insert(ASubStr, S, Index);
    Exit;
  end;
  //---
  L := System.Length(ASubStr);
  // Count - сколько вырезается
  if (Count > M) or ((Index + Count) > M) then
    Count := M - Index + 1;
  if Count >= M then
  begin
    S := ASubStr;
    Exit;
  end;     
  // I - начало второго фрагмента (который переносить взад или всперед)
  I := Index + Count;
  // сколько надо перенести
  R := M - I + 1;
  // в какую сторону смещается и на сколько
  K := L - Count;
  // создать новую строку
  SetLength(tmp, M + K);
  // перенести первый фрагмент
  if Index>1 then
    G_CopyMem(Pointer(S), Pointer(tmp), Index - 1);
  // буфер надо увеличить - длина нового фрагмента больше вырезаемого
  if K > 0 then
  begin
    // перенести второй фрагмент, если надо
    if R > 0 then
      G_CopyMem(@S[I], @tmp[I + K], R)
  end
  // строка уменьшается
  else if K < 0 then
  begin
    if R > 0 then    
      G_CopyMem(@S[I], @tmp[I + K], R);
  end;
  // скопировать подстроку
  G_CopyMem(Pointer(ASubStr), @tmp[Index], L);
  //---
  // усё
  S := tmp;
end;

{ TMacroModule }

constructor TMacroModule.Create(const AOwner: TMacros);
begin
  if Assigned(AOwner) then
    AOwner.AddModule(Self);
  //---
  FMacroNames := CreateOneMacroNames();
end;

destructor TMacroModule.Destroy;
begin
  //---
  inherited;
end;

class procedure TMacroModule.AddNames(const ASource: array of TAStrIntRec;
  const ADestination: TMacroNames);
var R: TStrIntRec;
begin
  if Length(ASource)>0 then
    for R in ASource do
      ADestination.Add(R.S, Pointer(R.I))
end;

class procedure TMacroModule.InitMacroNames;
begin
  FillOneMacroNames(CreateOneMacroNames());
end;

procedure TMacroModule.Clear;
begin
  // empty
end;

class procedure TMacroModule.FillOneMacroNames(A: TMacroNames);
begin
  // пусто
end;

function TMacroModule.FindName(const AName: AnsiString;
  out AId: Integer): Boolean;
var k: Integer;
begin
  if Assigned(FMacroNames) then
  begin
    k := FMacroNames.IndexOf(AName);
    if k<>-1 then
    begin
      AId := Integer(FMacroNames.ValueList[k]) ;
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function TMacroModule.ApplyNameMacro(ANameID: Integer; const AParam: AnsiString;
  out AOut: AnsiString): Boolean;
begin
  Result := True;
end;

function TMacroModule.ApplyMacro(const AName, AParam: AnsiString;
  out AOut: AnsiString): Boolean;
var k: Integer;
begin
  if FindName(AName, k) then
  begin
    if not ApplyNameMacro(k, AParam, AOut) then
      raise EMacroError.CreateFmt('Unknow macro %d %s[%s]', [k, AName, AParam]);
    Result := True;
    Exit;
  end;
  //---
  Result := False;
end;


{ TMacroModuleLocal }

constructor TMacroModuleLocal.Create;
begin
  inherited Create(nil);
  //---
  FSelectTwoArray := TSelectVar.Create(False);
  //---
  FVarList := TTwoStrList.Create(4);
  FVarList.Sorted := True;
  FVarList.CaseSensitive := False;
  FVarList.Duplicates := dupIgnore;
end;

destructor TMacroModuleLocal.Destroy;
begin
  FreeAndNil(FSelectTwoArray);
  FreeAndNil(FVarList);
  //---
  inherited;
end;

class procedure TMacroModuleLocal.FillOneMacroNames(A: TMacroNames);
const
  N: array[0..2] of TAStrIntRec = (
    (S: _SELECT2_N; I: _SELECT2_I),
    (S: _SETVAR_N;  I: _SETVAR_I),
    (S: _SETVAR2_N;  I: _SETVAR2_I)
  );
begin
  AddNames(N, A);
  inherited FillOneMacroNames(A);
end;

function TMacroModuleLocal.FindVar(const AName: AnsiString): AnsiString;
begin
  if not FindVar(AName, Result) then
    Result := '';  
end;

function TMacroModuleLocal.FindVar(const AName: AnsiString;
  out AValue: AnsiString): Boolean;
var k: Integer;
begin
  if (FVarList.Count > 0) and (AName <> '') then
  begin
    k := FVarList.IndexOf(AName);
    if k<>-1 then
    begin
      AValue := FVarList.Items[k].FValue;
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function TMacroModuleLocal.MacroSelect2(
  const AParam: AnsiString): AnsiString;
begin
  Result := TMacroModuleBase.MacroSelect2(AParam, FSelectTwoArray)
end;

function TMacroModuleLocal.MacroSetVar(const AParam: AnsiString): AnsiString;
begin
  Result := TMacroModuleBase.MacroSetVar(AParam, FVarList)
end;

function TMacroModuleLocal.ApplyNameMacro(ANameID: Integer;
  const AParam: AnsiString; out AOut: AnsiString): Boolean;
begin
  case ANameID of
    _SELECT2_I:
      AOut := MacroSelect2(AParam);
    _SETVAR_I:
      AOut := MacroSetVar(AParam);
    _SETVAR2_I:
      AOut := MacroSetVar(AParam);
    else
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

function TMacroModuleLocal.ApplyMacro(const AName, AParam: AnsiString;
  out AOut: AnsiString): Boolean;
begin
  Result := inherited ApplyMacro(AName, AParam, AOut);
  if Result then
    Exit;
  //---
  Result := FindVar(AName, AOut);
  if Result then
    Exit;
  //---
  Result := False;
end;

procedure TMacroModuleLocal.Clear;
begin
  inherited;
  FSelectTwoArray.Clear();
  FVarList.Clear();
end;



{ TMacroModuleLocalLocked }

constructor TMacroModuleLocalLocked.Create;
begin
  inherited Create();
  FLock := TCriticalSection.Create;
end;

destructor TMacroModuleLocalLocked.Destroy;
begin
  FreeAndNil(FLock);
  inherited;
end;

class function TMacroModuleLocalLocked.CreateOneMacroNames: TMacroNames;
begin
  if not Assigned(MacroNamesLocalLocked) then
    MacroNamesLocalLocked := TMacroNames.Create(False);
  Result := MacroNamesLocalLocked;
end;

class procedure TMacroModuleLocalLocked.DestroyOneMacroNames;
begin
  FreeAndNil(MacroNamesLocalLocked);
end;

function TMacroModuleLocalLocked.MacroSelect2(
  const AParam: AnsiString): AnsiString;
begin
  FLock.Enter;
  try
    Result := inherited MacroSelect2(AParam);
  finally
    FLock.Leave;
  end;
end;

function TMacroModuleLocalLocked.MacroSetVar(
  const AParam: AnsiString): AnsiString;
begin
  FLock.Enter;
  try
    Result := inherited MacroSetVar(AParam);
  finally
    FLock.Leave;
  end;
end;



{ TMacroModuleBase }

constructor TMacroModuleBase.Create(const AOwner: TMacros; const AMacrosDir: TFileName);
begin
  inherited Create(AOwner);
  FLock := TMREWSync.Create;
  FMacroFileList := TMacroFileList.Create(False);
  FMacroFileList.OwnValues := True;
  ReLoadMacros(AMacrosDir);
end;

destructor TMacroModuleBase.Destroy;
begin
  FreeAndNil(FMacroFileList);
  FreeAndNil(FLock);
  inherited;
end;

class function TMacroModuleBase.CreateOneMacroNames: TMacroNames;
begin
  if not Assigned(MacroNamesBase) then
    MacroNamesBase := TMacroNames.Create(False);
  Result := MacroNamesBase;
end;

class procedure TMacroModuleBase.FillOneMacroNames(A: TMacroNames);
const
  N: array[0..9] of TAStrIntRec = (
    (S: _RND_CHAR_N;     I: _RND_CHAR_I),
    (S: _RND_NUM_N;      I: _RND_NUM_I),
    (S: _RND_CHARNUM_N;  I: _RND_CHARNUM_I),
    (S: _RND_LOWCHAR_N;  I: _RND_LOWCHAR_I),
    (S: _RND_HIGHCHAR_N; I: _RND_HIGHCHAR_I),
    (S: _SELECT_N;       I: _SELECT_I),
    (S: _TOLOWER_N;      I: _TOLOWER_I),
    (S: _TOUPPER_N;      I: _TOUPPER_I),
    (S: _NEWLINE_N;      I: _NEWLINE_I),
    (S: _TAB_N;          I: _TAB_I)
  );
begin
  AddNames(N, A);
  inherited FillOneMacroNames(A);
end;

class procedure TMacroModuleBase.DestroyOneMacroNames;
begin
  FreeAndNil(MacroNamesBase);
end;

procedure TMacroModuleBase.ReLoadMacros(const AMacrosDir: TFileName);
var
  fl: TStringList;
  z: TFileName;
  buf: AnsiString;
  rl: TListRandomAStrings;
begin
  if AMacrosDir<>'' then
    FMacroDir := AMacrosDir;  
  //---
  if (FMacroDir<>'') and DirectoryExists(FMacroDir) then
  begin
    fl := TStringList.Create;
    try
      if FindInDir(FMacroDir, fl, [foFindFiles,foIncFullPath], '*.txt')>0 then
      begin
        FLock.BeginWrite;
        try
          FMacroFileList.Clear();
          for z in fl do
          begin
            rl := nil;
            buf := StringLoadFromFile(z);
            if buf<>'' then
            begin
              rl := TListRandomAStrings.Create(TAnsiStringList.Create, True);
              rl.List.Text := buf;
            end;
            FMacroFileList.Add(ChangeFileExt(ExtractFileName(z), ''), rl);
          end;
        finally
          FLock.EndWrite
        end;
      end;
    finally
      fl.Free
    end;
  end;
end;

function TMacroModuleBase.FindMacro(const AName: AnsiString;
  var AOut: AnsiString): Boolean;
var
  A: TListRandomAStrings;
  k: Integer;
begin
  FLock.BeginRead;
  try
    k := FMacroFileList.IndexOf(AName);
    if k<>-1 then
    begin
      A := FMacroFileList.ValueList[k];
      if Assigned(A) then
        AOut := A.Next()
      else
        AOut := '';
      Result := True;
      Exit;
    end;
  finally
    FLock.EndRead
  end;
  Result := False;
end;

class function TMacroModuleBase.MacroRandomStr(const AChars,
  AParam: AnsiString): AnsiString;
var p,k1,k2: Integer;
begin
  p := G_CharPos('-', AParam);
  if p=0 then
  begin
    k1 := StrToIntDef(AParam, 1);
    k2 := -1;
  end
  else
  begin
    k1 := StrToIntDef(Copy(AParam,1,p-1), 1);
    k2 := StrToIntDef(Copy(AParam,p+1,MaxInt), 1);
  end;
  Result := RandomChars(AChars, k1, k2)
end;

class function TMacroModuleBase.MacroSelect0(const AParamStr: AnsiString;
  AStart: Integer; var ANum: Integer): AnsiString;
var
  j, s, l, p: Integer;
begin
  if ANum<1 then
    ANum := Random(G_CountOfChar(AParamStr, '|') + 1) + 1;
  s := AStart;
  j := 1;
  l := Length(AParamStr);
  repeat
    p := G_CharPos('|', AParamStr, s);
    if p=0 then
      p := l + 1;
    if j=ANum then
    begin
      Result := Copy(AParamStr, s, p - s);
      Exit;
    end;
    s := p + 1;
    Inc(j);
  until s>l;
  // сюда попадать не должен
  raise EMacroError.Create('_rnd_select error "'+AParamStr+'"');
end;

class function TMacroModuleBase.MacroSelect1(
  const AParamStr: AnsiString): AnsiString;
var k: Integer;
begin
  k := 0;
  Result := MacroSelect0(AParamStr, 1, k)
end;

class function TMacroModuleBase.MacroSelect2(const AParamStr: AnsiString;
  const ASelect2Array: TSelectVar): AnsiString;
var
  p,s,k: Integer;
  z: AnsiString;
begin
  p := G_CharPos(';', AParamStr);
  if p>0 then
  begin
    s := p + 1;
    z := Trim(Copy(AParamStr, 1, p-1));
    //---
    k := ASelect2Array.IndexOf(z);
    if k=-1 then
      k := ASelect2Array.Add(z, Pointer(-1));
    Result := MacroSelect0(AParamStr, s, Integer(ASelect2Array.ValueList[k]));
  end
  else
  begin
    s := 1;
    k := 0;
    Result := MacroSelect0(AParamStr, s, k);
  end;
end;

class function TMacroModuleBase.MacroSetVar(const AParam: AnsiString;
  const AArray: TTwoStrList): AnsiString;
var
  p: Integer;
  ln,lv: AnsiString;
begin
  p := G_CharPos(';', AParam);
  if p>0 then
  begin
    ln := Copy(AParam, 1, p-1);
    lv := Copy(AParam, p+1, MaxInt);
  end
  else
  begin
    ln := AParam;
    lv := '';
  end;
  AArray.Add(ln, lv, True);
  Result := '';
end;

function TMacroModuleBase.ApplyNameMacro(ANameID: Integer;
  const AParam: AnsiString; out AOut: AnsiString): Boolean;
begin
  case ANameID of
    _RND_CHAR_I:
      AOut := MacroRandomStr(gCharsEngStr, AParam);
    _RND_NUM_I:
      AOut := MacroRandomStr(gCharsNumStr, AParam);
    _RND_CHARNUM_I:
      AOut := MacroRandomStr(gCharsEngNumStr, AParam);
    _RND_LOWCHAR_I:
      AOut := MacroRandomStr(gCharsEngLowStr, AParam);
    _RND_HIGHCHAR_I:
      AOut := MacroRandomStr(gCharsEngHighStr, AParam);
    _SELECT_I:
      AOut := MacroSelect1(AParam);
    _TOLOWER_I:
      AOut := G_ToLower(AParam);
    _TOUPPER_I:
      AOut := G_ToUpper(AParam);
    _NEWLINE_I:
      AOut := CRLF;
    _TAB_I:
      AOut := #9;
    else
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

function TMacroModuleBase.ApplyMacro(const AName, AParam: AnsiString;
  out AOut: AnsiString): Boolean;
begin
  Result := inherited ApplyMacro(AName, AParam, AOut);
  if Result then
    Exit;
  //---
  Result := FindMacro(AName, AOut);
  if Result then
    Exit;
  //---
  Result := False;
end;



{ TMacros }

constructor TMacros.Create(const AMacrosDir: TFileName);
begin
  FModList := TArrayList.Create(3);
  FModList.OwnItems := True;
  //---
  FModBase := TMacroModuleBase.Create(Self, AMacrosDir); // IfEmpty(AMacrosDir, gDirApp+'macros\')
  //---
  FModLocal := TMacroModuleLocalLocked.Create;
  //---
  Randomize();  
end;

destructor TMacros.Destroy;
begin
  FreeAndNil(FModList);
  FreeAndNil(FModLocal);
  inherited;
end;

function TMacros._ApplyMacros(const AInString: AnsiString;
  ALocalMod: TMacroModuleLocal; out AOut: AnsiString): Boolean;
var
  ln,lp: AnsiString;
  j: Integer;
begin
  AOut := '';
  ParseMacro(AInString, ln, lp);
  if ln='' then
  begin
    Result := False;
    Exit;
  end;
  //---
  for j:=0 to FModList.Count-1 do
    if (TObject(FModList[j]) as TMacroModule).ApplyMacro(ln, lp, AOut) then
    begin
      Result := True;
      Exit;
    end;
  //---
  if Assigned(ALocalMod) then
  begin
    Result := ALocalMod.ApplyMacro(ln, lp, AOut);
    if Result then
      Exit;
  end;
  //---
  Result := False
end;

procedure TMacros.AddModule(const A: TMacroModule);
begin
  FModList.Add(A)
end;

(*
class function TMacros.YesMacro(const aStr: AnsiString; var s, l: Integer;
  aStart: Integer): Boolean;
var p1,p2,i1,i2: Integer;
begin
  p1 := G_CharPos('%', aStr, aStart);
  p2 := G_CharPos('%', aStr, p1+1);
  if (p1>0) and (p2>0) then
  begin
    i1 := p1 + 1;
    i2 := p2 - 1;
    if {((i2-1)>i1)} (i2>=i1) and (AStr[i1] in cMacroNameFirstChar) and (AStr[i2] in cMacroNameLastChar) then
    begin
      s := p1;
      l := p2 - p1 + 1;
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;


class function TMacros.YesMacroNew(const AStr: AnsiString; var s, l: Integer;
  AStart, AEnd: Integer): Boolean;
var p1,p2,i1,i2: Integer;
begin
  p2 := G_CharPos('$', AStr, AStart);
  if (0<p2) and (p2<AEnd) then
  begin
    p1 := G_LastCharPos('^', AStr, p2);
    if (AStart<=p1) and (p1<AEnd) then
    begin
      i1 := p1 + 1;
      i2 := p2 - 1;
      if ((i2-1)>i1) and (AStr[i1] in cMacroNameFirstChar) and (AStr[i2] in cMacroNameLastChar) then
      begin
        if CharsPos(cNotMacroChars, AStr, i1, i2)=0 then
        begin
          s := p1;
          l := p2 - p1 + 1;
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
  Result := False;
end;
*)


// Возврашает
// s - начало с % или ^
// l - длина включая % или $
class function TMacros.YesMacroNew2(const AStr: AnsiString; out s, l: Integer;
  AStart: Integer): Boolean;
var p1,p2,p3,i1,i2: Integer;
begin
  s := Length(AStr);
  p2 := G_CharPos('$', AStr, AStart);
  p3 := G_CharPos('%', AStr, AStart);
  if p2=0 then p2 := MaxInt;
  if p3=0 then p3 := MaxInt;
  if (p2<>MaxInt) or (p3<>MaxInt) then
  begin
    if p3<p2 then // %macro[]%
    begin
      p2 := G_CharPos('%', AStr, p3+1);
      p1 := p3;
    end
    else // ^macro[]$
    begin
      p1 := G_LastCharPos('^', AStr, p2);
    end;
    s  := p2;
    //---
    if AStart<=p1 then
    begin
      i1 := p1 + 1;
      i2 := p2 - 1;
      if (i2>=i1) and (AStr[i1] in cMacroNameFirstChar) and (AStr[i2] in cMacroNameLastChar) then
      begin
        if CharsPos(cNotMacroChars, AStr, i1, i2)=0 then
        begin
          s := p1;
          l := p2 - p1 + 1;
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
  Result := False;
end;

class procedure TMacros.ParseMacro(const AText: AnsiString;
  var AMacroName, AMacroParam: AnsiString);
var p1,len: Integer;
begin
  AMacroName := '';
  AMacroParam := '';
  p1 := G_CharPos('[', AText);
  if p1>0 then
  begin
    len := Length(AText);
    if AText[len]=']' then
    begin
      AMacroName := Copy(AText, 1, p1-1);
      AMacroParam := Copy(AText, p1+1, len-p1-1);
    end
  end
  else
  begin
    AMacroName := AText;
  end;
end;

procedure TMacros.ReLoadMacros(const AMacrosDir: TFileName);
begin
  with FModBase as TMacroModuleBase do begin
    ReLoadMacros(AMacrosDir);
  end;
end;

function TMacros.ApplyMacros(const AText: AnsiString;
  ALocalMod: TMacroModuleLocal): AnsiString;
const
  MAX_RECURSION_COUNT = 1000;
var
  k,s,l,n : Integer;
  z : AnsiString;
  lModLol: TMacroModuleLocal;
begin
  Result := AText;
  if Length(AText)<3 then
    Exit;
  //---
  lModLol := TMacroModuleLocal(IfElse(Assigned(ALocalMod), ALocalMod, FModLocal));
  //---
  k := 0;
  n := 1;
  while n < Length(Result) do
  begin
    if YesMacroNew2(Result, s, l, n) then
      if _ApplyMacros(Copy(Result,s+1,l-2), lModLol, z) then
        MyStuffString(Result, s, l, z)
      else
        n := s + l - 1
    else
      n := s + 1;
    //---------------------------------
    Inc(k);
    if k>MAX_RECURSION_COUNT then
      raise EMacroError.Create('Recursion in Macros');
  end;
end;

function TMacros._Dump: UTF8String;
var
  R: TStringBuilder;
begin

  R := TStringBuilder.Create;
  try
    //---
    Result := RawByteString(R.ToString())
  finally
    R.Free;
  end;
end;

initialization
  TMacroModuleLocalLocked.InitMacroNames();
  TMacroModuleBase.InitMacroNames();

finalization
  {$IFDEF DEBUG}
    TMacroModuleBase.DestroyOneMacroNames();
    TMacroModuleLocalLocked.DestroyOneMacroNames();
  {$ENDIF}

end.


