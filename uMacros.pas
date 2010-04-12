unit uMacros;

{$DEFINE USE_BUILT_MACROS}

{
Using:
ApplyMacros('Random seven num %RND_NUM[7]%.') -> 'Random seven num  0914367.'
ApplyMacros('Random 1 or 2 or 3 num - "%RND_NUM[1-3]%"') -> 'Random 1 or 2 or 3 num - "21"'

Options:
RND_CHAR[]
RND_NUM[]
RND_CHARNUM[]
RND_LOWCHAR[]
RND_HIGHCHAR[]

}

interface

uses Classes, Math, SysUtils, AcedStrings, AcedContainers;

type
  TMacroParam = class(TObject)
  private
    FLocalHost        : AnsiString;
    FMessageID        : AnsiString;
    FCID              : AnsiString;
    FAccountDomain    : AnsiString;
    FFromAddress      : AnsiString;
    FRecipientAddress : AnsiString;
    FCurEncode        : AnsiString;
    FBoundary         : AnsiString;
    FBoundary2        : AnsiString;
    FDate             : AnsiString;
    FHelo             : AnsiString;
    //---
  public
    constructor Create;
    //---
    procedure Clear;
    //---
    property LocalHost        : AnsiString read FLocalHost        write FLocalHost       ;
    property MessageID        : AnsiString read FMessageID        write FMessageID       ;
    property CID              : AnsiString read FCID              write FCID             ;
    property AccountDomain    : AnsiString read FAccountDomain    write FAccountDomain   ;
    property FromAddress      : AnsiString read FFromAddress      write FFromAddress     ;
    property RecipientAddress : AnsiString read FRecipientAddress write FRecipientAddress;
    property CurEncode        : AnsiString read FCurEncode        write FCurEncode       ;
    property Boundary         : AnsiString read FBoundary         write FBoundary        ;
    property Boundary1        : AnsiString read FBoundary         write FBoundary        ;
    property Boundary2        : AnsiString read FBoundary2        write FBoundary2       ;
    property Date             : AnsiString read FDate             write FDate            ;
    property Helo             : AnsiString read FHelo             write FHelo            ;
  end;

  TMacroItem = class(TObject)
  private
    FMacroName : AnsiString;
    FMacroData : TStringList;
    function GetRandomData:AnsiString;
  public
    constructor Create(const AMacroName,AMacroFile:AnsiString);
    destructor Destroy; override;
    //---
    property MacroName:AnsiString read FMacroName write FMacroName;
    property MacroData:AnsiString read GetRandomData;
    //property MacroData:TStringList read FMacroData write FMacroData;
  end;

  TMacros = class(TObject)
  private
    FMacros: TStringAssociationList;
    FLockObj: TMultiReadExclusiveWriteSynchronizer;
    //---
    function FindMacroData(const AMacroName: AnsiString;
      var AOutString: AnsiString): Boolean;
    //---
    function YesMacro(const aStr:AnsiString;var s,l:Integer; aStart:Integer=1):Boolean;
    function ApplyMacros_(const AInString: AnsiString; AParam:TMacroParam; var AOut:AnsiString):Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    //---
    procedure LoadMacros(const AMacroPath:AnsiString);
    function ApplyMacros(const AText:AnsiString; AParam:TMacroParam=nil):AnsiString;
  end;

{$IFDEF USE_BUILT_MACROS}
function ApplyMacros(const AText:AnsiString; AParam:TMacroParam=nil):AnsiString;
procedure MacrosReload;
{$ENDIF}

implementation

uses uGlobalFunctions, uGlobalVars, uRegExprFunc;

{$IFDEF USE_BUILT_MACROS}
var
  BuiltMacros:TMacros;
{$ENDIF}

function CharsPosNot(const AChars:TSetOfChar; const AStr:AnsiString; AStart:Integer=1):Integer;
var j:Integer;
begin
  Result := -1;
  for j:=AStart to Length(AStr) do
  begin
    if not (AStr[j] in AChars) then
    begin
      Result := j;
      Exit;
    end;
  end;
end;

function rnd_str(const AChars:AnsiString; ALength1:Integer=1; ALength2:Integer=-1):AnsiString;
var j,len:Integer;
begin
  if AChars='' then
  begin
    Result := '';
    Exit;
  end;
  Randomize;
  if ALength2=-1 then
    len := ALength1
  else
    len := RandomRange(ALength1, ALength2+1);
  SetLength(Result, len);
  for j:=1 to len do
    Result[j] := AChars[Random(Length(AChars))+1]
end;

function rnd_str2_1(const AText, AChars, ARegExpr:AnsiString):AnsiString;
var
  z : AnsiString;
  l : Integer;
begin
  z := GetMatchByNom(AText, '^'+ARegExpr+'$', 1);
  l := StrToInt(z);
  Result := rnd_str(AChars, l)
end;

function rnd_str2_2(const AText, AChars, ARegExpr:AnsiString):AnsiString;
var
  z1,z2 : AnsiString;
  l1,l2 : Integer;
begin
  z1 := GetMatchByNom(AText, '^'+ARegExpr+'$', 1);
  l1 := StrToInt(z1);
  z2 := GetMatchByNom(AText, '^'+ARegExpr+'$', 2);
  l2 := StrToInt(z2);
  Result := rnd_str(AChars, l1, l2)
end;

function rnd_select(const AText, ARegExpr:AnsiString):AnsiString;
var
  z1 : AnsiString;
  sl : TStringList;
begin
  Result := '';
  z1 := GetMatchByNom(AText, '^'+ARegExpr+'$', 1);
  if z1<>'' then
  begin
    sl := TStringList.Create;
    try
      sl.Delimiter := ',';
      sl.DelimitedText := z1;
      Result := StringsRandom(sl);
    finally
      sl.Free
    end;
  end;
end;


{ TMacroParam }

procedure TMacroParam.Clear;
begin
  FLocalHost        := '';
  FMessageID        := '';
  FCID              := '';
  FAccountDomain    := '';
  FFromAddress      := '';
  FRecipientAddress := '';
  FCurEncode        := '';
  FBoundary         := '';
  FBoundary2        := '';
  FDate             := '';
  FHelo             := 'localhost';
end;

constructor TMacroParam.Create;
begin
  Clear;
end;

{ TMacroItem }

constructor TMacroItem.Create(const AMacroName, AMacroFile: AnsiString);
begin
  FMacroName := AMacroName;
  G_StrToUpper(FMacroName);
  FMacroData := TStringList.Create;
  StringsLoadFromFile(AMacroFile, FMacroData, True);
end;

destructor TMacroItem.Destroy;
begin
  FMacroData.Free;
  inherited;
end;

function TMacroItem.GetRandomData: AnsiString;
begin
  Result := StringsRandom(FMacroData)
end;

{ TMacros }

function TMacros.ApplyMacros(const AText: AnsiString;
  AParam: TMacroParam): AnsiString;
const
  MAX_RECURSION_COUNT = 32;
var
  k,s,l,n : Integer;
  z : AnsiString;
begin
  Result := AText;
  if Length(AText)<4 then
    Exit;
  k := 0;
  n := 1;
  Randomize;
  while YesMacro(Result, s, l, n) do
  begin
    if ApplyMacros_(Copy(Result,s+1,l-2), AParam, z) then
    begin
      Delete(Result, s, l);
      Insert(z, Result, s);
      n := s;
    end
      else
    begin
      n := s + l - 1;
    end;
    //---------------------------------
    Inc(k);
    if k>MAX_RECURSION_COUNT then
      raise Exception.Create('Recursion in Macros');
  end;
end;

function TMacros.ApplyMacros_(const AInString: AnsiString; AParam: TMacroParam;
  var AOut: AnsiString): Boolean;
  
const
  ch_macro = ['A'..'Z','a'..'z','0'..'9','_','-','.','[',']',',','"',''''];

  rnd_char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  rnd_num = '0123456789';
  rnd_charnum = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  rnd_lowchar = 'abcdefghijklmnopqrstuvwxyz';
  rnd_highchar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

const
  RND_CHAR_      = 'RND_CHAR';
  RND_NUM_       = 'RND_NUM';
  RND_CHARNUM_   = 'RND_CHARNUM';
  RND_LOWCHAR_   = 'RND_LOWCHAR';
  RND_HIGHCHAR_  = 'RND_HIGHCHAR';

  D_1 = '\[(\d+)\]';
  D_2 = '\[(\d+)-(\d+)\]';

  RND_CHAR_D_1     = RND_CHAR_     + D_1;
  RND_NUM_D_1      = RND_NUM_      + D_1;
  RND_CHARNUM_D_1  = RND_CHARNUM_  + D_1;
  RND_LOWCHAR_D_1  = RND_LOWCHAR_  + D_1;
  RND_HIGHCHAR_D_1 = RND_HIGHCHAR_ + D_1;

  RND_CHAR_D_2     = RND_CHAR_     + D_2;
  RND_NUM_D_2      = RND_NUM_      + D_2;
  RND_CHARNUM_D_2  = RND_CHARNUM_  + D_2;
  RND_LOWCHAR_D_2  = RND_LOWCHAR_  + D_2;
  RND_HIGHCHAR_D_2 = RND_HIGHCHAR_ + D_2;

  LOCALHOSTNAME_ = 'LOCALHOSTNAME';
  ACCOUNTDOMAIN_ = 'ACCOUNTDOMAIN';
  RECIPIENT_     = 'RECIPIENT';
  SENDER_        = 'SENDER';
  ENCODE_        = 'ENCODE';
  MSGID_         = 'MSGID';
  CID_           = 'CID';
  BOUNDARY_      = 'BOUNDARY';
  BOUNDARY1_     = 'BOUNDARY1';
  BOUNDARY2_     = 'BOUNDARY2';
  DATE_          = 'DATE';
  HELO_          = 'HELO';

  SELECT_    = 'SELECT\[([^\[\]]+)\]';

begin
  Result := True;
  AOut   := '';
//------------------------------------------------------------------------------
// основные макросы

  if G_CompareText(AInString,RND_CHAR_)=0 then
    AOut := rnd_str(rnd_char)

  else if G_CompareText(AInString,RND_NUM_)=0 then
    AOut := rnd_str(rnd_num)

  else if G_CompareText(AInString,RND_CHARNUM_)=0 then
    AOut := rnd_str(rnd_charnum)

  else if G_CompareText(AInString,RND_LOWCHAR_)=0 then
    AOut := rnd_str(rnd_lowchar)

  else if G_CompareText(AInString,RND_HIGHCHAR_)=0 then
    AOut := rnd_str(rnd_highchar)

  {Todo: оптимизировать}
  //-----------------------------
  else if YesRegExpr(AInString, RND_CHAR_D_1)  then
    AOut := rnd_str2_1(AInString, rnd_char, RND_CHAR_D_1)

  else if YesRegExpr(AInString, RND_NUM_D_1)  then
    AOut := rnd_str2_1(AInString, rnd_num, RND_NUM_D_1)

  else if YesRegExpr(AInString, RND_CHARNUM_D_1)  then
    AOut := rnd_str2_1(AInString, rnd_charnum, RND_CHARNUM_D_1)

  else if YesRegExpr(AInString, RND_LOWCHAR_D_1)  then
    AOut := rnd_str2_1(AInString, rnd_lowchar, RND_LOWCHAR_D_1)

  else if YesRegExpr(AInString, RND_HIGHCHAR_D_1)  then
    AOut := rnd_str2_1(AInString, rnd_highchar, RND_HIGHCHAR_D_1)

  //-----------------------------
  else if YesRegExpr(AInString, RND_CHAR_D_2)  then
    AOut := rnd_str2_2(AInString, rnd_char, RND_CHAR_D_2)

  else if YesRegExpr(AInString, RND_NUM_D_2)  then
    AOut := rnd_str2_2(AInString, rnd_num, RND_NUM_D_2)

  else if YesRegExpr(AInString, RND_CHARNUM_D_2)  then
    AOut := rnd_str2_2(AInString, rnd_charnum, RND_CHARNUM_D_2)

  else if YesRegExpr(AInString, RND_LOWCHAR_D_2)  then
    AOut := rnd_str2_2(AInString, rnd_lowchar, RND_LOWCHAR_D_2)

  else if YesRegExpr(AInString, RND_HIGHCHAR_D_2)  then
    AOut := rnd_str2_2(AInString, rnd_highchar, RND_HIGHCHAR_D_2)
  //------------------------
  else if YesRegExpr(AInString, SELECT_)  then
    AOut := rnd_select(AInString, SELECT_)

//------------------------------------------------------------------------------
// макросы из файла (папка \macros\)
  else if FindMacroData(AInString, AOut) then
  begin
    {пусто}
  end
//------------------------------------------------------------------------------
// дополнительные макросы (данные из переменной param)
  else if AParam<>nil then
  begin
    if G_CompareText(AInString,LOCALHOSTNAME_)=0 then
        AOut := AParam.LocalHost

    else if G_CompareText(AInString,ACCOUNTDOMAIN_)=0 then
      AOut := AParam.AccountDomain

    else if G_CompareText(AInString,RECIPIENT_)=0 then
      AOut := AParam.RecipientAddress

    else if G_CompareText(AInString,SENDER_)=0 then
      AOut := AParam.FromAddress

    else if G_CompareText(AInString,ENCODE_)=0 then
      AOut := AParam.CurEncode

    else if G_CompareText(AInString,ENCODE_)=0 then
      AOut := AParam.CurEncode

    else if G_CompareText(AInString,MSGID_)=0 then
      AOut := AParam.MessageID

    else if G_CompareText(AInString,CID_)=0 then
      AOut := AParam.CID

    else if G_CompareText(AInString,BOUNDARY_)=0 then
      AOut := AParam.Boundary

    else if G_CompareText(AInString,BOUNDARY1_)=0 then
      AOut := AParam.Boundary
      
    else if G_CompareText(AInString,BOUNDARY2_)=0 then
      AOut := AParam.Boundary2

    else if G_CompareText(AInString,DATE_)=0 then
      AOut := AParam.Date

    else if G_CompareText(AInString,HELO_)=0 then
      AOut := AParam.Helo

    else
    begin
     Result := False
    end
  end
  else
  begin
   Result := False
  end
end;

constructor TMacros.Create;
begin
  FMacros := TStringAssociationList.Create(False);
  FMacros.OwnValues := True;
  FLockObj := TMultiReadExclusiveWriteSynchronizer.Create;
end;

destructor TMacros.Destroy;
begin
  FreeAndNil(FMacros);
  FreeAndNil(FLockObj);
  inherited;
end;

function TMacros.FindMacroData(const AMacroName: AnsiString;
  var AOutString: AnsiString): Boolean;
var A: TMacroItem;
begin
  Result := False;
  FLockObj.BeginRead;
  try
    A := TMacroItem(FMacros.Items[AMacroName]);
    if Assigned(A) then
    begin
      AOutString := A.MacroData;
      Result := True;
    end;
  finally
    FLockObj.EndRead
  end;
end;

procedure TMacros.LoadMacros(const AMacroPath: AnsiString);
var
  j : Integer;
  s,z: AnsiString;
  sl : TStringList;
  dir : AnsiString;
begin
  dir := IncludeTrailingPathDelimiter(AMacroPath);
  sl := TStringList.Create;
  try
    FindInDir(dir, sl, True, '*.txt');
    FLockObj.BeginWrite;
    try
      FMacros.Clear;
      for j:=0 to sl.Count-1 do
      begin
        z := sl[j];
        s := ChangeFileExt(z, '');
        FMacros.Add(
          s,
          TMacroItem.Create(z, dir+z)
        );
      end;
    finally
      FLockObj.EndWrite;
    end;
  finally
    sl.Free;
  end;
end;

function TMacros.YesMacro(const aStr: AnsiString; var s, l: Integer;
  aStart: Integer): Boolean;
//const
//  ch = ['A'..'Z','a'..'z','0'..'9','_','-','.','[',']'];
var
  p1,p2: Integer;
begin
  Result := False;
  p1 := G_CharPos('%', aStr, aStart);
  p2 := G_CharPos('%', aStr, p1+1);
  if (p1>0) and (p2>0) then
  begin
    s := p1;
    l := p2 - p1 + 1;
    Result := True;
  end
{
  Result := False;
  p1 := G_CharPos('%', aStr, aStart);
  p2 := G_CharPos('%', aStr, p1+1);
  p3 := CharsPosNot(ch, aStr, p1+1);
  if (p1>0) and (p2>0) and (p1<p2) and (p2<=p3) then
  begin
    s := p1;
    l := p2 - p1 + 1;
    Result := True;
  end
  else if (p2>0) and (p3>0) and (p2>p3) then
  begin

  end;
}
end;

{$IFDEF USE_BUILT_MACROS}
function ApplyMacros(const AText:AnsiString; AParam:TMacroParam=nil):AnsiString;
begin
  Result := BuiltMacros.ApplyMacros(AText, AParam)
end;

procedure MacrosReload;
begin
  BuiltMacros.LoadMacros(gDirApp+'macros\');
end;

initialization
  BuiltMacros := TMacros.Create;
  MacrosReload;

finalization
 {$IFDEF DEBUG}
  BuiltMacros.Free;
 {$ENDIF}
 
{$ENDIF}

end.
