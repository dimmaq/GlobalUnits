unit uSettingsAStringsList;

interface

uses
  Classes, SysUtils, IniFiles, AcedContainers, AcedStrings,
  uAnsiStrings, uGlobalFileIOFunc, uListRandomAStrings,
  uSettingsBaseItem
  {$IFDEF UNICODE}
    , AnsiStrings
  {$ENDIF}
  ;

type
  ESettingsAStringsError = class(Exception);

  TSettingsAStringsItem = class(TSettingsBaseItemB)
  private
    FStrict: Boolean;
    FValue: TAnsiStringList;
    FRandom: TListRandomAStrings;
    //---
    function GetCount: Integer;
    function GetLine(AIndex: Integer): AnsiString;
    procedure SetLine(AIndex: Integer; const AValue: AnsiString);
  protected
    function GetAsInt: Int64; override;
    function GetAsAText: AnsiString; override;
    function GetAsBool: Boolean; override;
    procedure SetAsAText(const AValue: AnsiString); override;
    procedure SetAsBool(const AValue: Boolean); override;
    procedure SetAsInt(const AValue: Int64); override;
    {$IFDEF UNICODE}
      function GetAsUText: UnicodeString; override;
      procedure SetAsUText(const AValue: UnicodeString); override;
    {$ENDIF}
  public
    constructor Create(const AID: Integer; const AName: AnsiString;
      const AFileName: TFileName; AStrict: Boolean);
    destructor Destroy; override;
    //---
    function _Dump: UTF8String; override;
    //---
    procedure AfterConstruction; override;
    procedure Save(ADestination: TAnsiStrings); {$IFDEF UNICODE}overload;{$ENDIF}
    procedure Load(ASource: TAnsiStrings); {$IFDEF UNICODE}overload;{$ENDIF}
    {$IFDEF UNICODE}
      procedure Save(ADestination: TUnicodeStrings); overload;
      procedure Load(ASource: TUnicodeStrings); overload;
    {$ENDIF}
    function GetRandom(const ADefault: AnsiString = ''): AnsiString; overload;
    function GetRandom(out AOut: AnsiString; const ADefault: AnsiString = ''): Boolean; overload;
    //---
    function YesRegExpr(const AText: AnsiString): Integer; overload;
    function YesRegExpr(const AText: AnsiString; out AIndex: Integer): AnsiString; overload;
    function YesRegExpr(const AText: AnsiString; out ARegExpr: AnsiString): Integer; overload;
    //---
    property Value: TAnsiStringList read FValue{ write SetValue};
    /// <summary>Строгая загрузка - разделитель только по CRLF.
    /// В противном случае парсится обычным методом</summary>
    property Strict: Boolean read FStrict write FStrict;
    property Count: Integer read GetCount;
    property Text: AnsiString read GetAsAText write SetAsAText;
    property Lines[AIndex: Integer]: AnsiString read GetLine write SetLine;
  end;

  TSettingsAStringsList = class(TSettingsBaseList)
  public
    procedure Load; override;
    procedure Save; override;
    //---
//    function SetValue(const AId: Integer; const AValue: AnsiString): TSettingsStringsItem; overload;
    function GetValue(const AId: Integer): TSettingsAStringsItem; overload;
//    function SetValue(const AName: AnsiString; const AValue: AnsiString): TSettingsStringsItem; overload;
    function GetValue(const AName: AnsiString): TSettingsAStringsItem; overload;
  end;

implementation

uses uGlobalFunctions, uRegExprFunc;

{ TSettingsAStringItem }

procedure TSettingsAStringsItem.AfterConstruction;
begin
  inherited;
  if not Assigned(FValue) then
    FValue := TAnsiStringList.Create;
end;

constructor TSettingsAStringsItem.Create(const AID: Integer;
  const AName: AnsiString; const AFileName: TFileName;
  AStrict: Boolean);
begin
  inherited Create(AID, AName, '', '', AFileName);
  //---
  FStrict := FStrict;
  FValue := TAnsiStringList.Create;
//  FValue.Text := ADefault;
end;

destructor TSettingsAStringsItem.Destroy;
begin
  FreeAndNil(FValue);
  FreeAndNil(FRandom);
  inherited;
end;

function TSettingsAStringsItem.GetCount: Integer;
begin
  Result := FValue.Count
end;

function TSettingsAStringsItem.GetRandom(out AOut: AnsiString;
  const ADefault: AnsiString): Boolean;
begin
  if FValue.Count<=0 then
  begin
    Result := False;
    AOut := ADefault;
    Exit;
  end;
  //---
  FRwLockObj.BeginWrite;
  try
    if FValue.Count=1 then
    begin
      AOut := FValue[0];
      Result := True;
    end
    else
    begin
      if not Assigned(FRandom) then
      begin
        FRandom := TListRandomAStrings.Create(FValue);
      end;
      FRandom.DefaultValue := ADefault;
      Result := FRandom.Next(AOut);
    end;
    UniqueString(AOut);
  finally
    FRwLockObj.EndWrite
  end;
end;

function TSettingsAStringsItem.GetRandom(const ADefault: AnsiString): AnsiString;
begin
  GetRandom(Result, ADefault)
end;


function TSettingsAStringsItem.GetAsInt: Int64;
begin
  raise ESettingsAStringsError.Create('not GetAsInt()');
end;

function TSettingsAStringsItem.GetAsAText: AnsiString;
begin
  FRwLockObj.BeginRead;
  try
    Result := FValue.Text;
    UniqueString(Result);
  finally
    FRwLockObj.EndRead
  end;
end;

function TSettingsAStringsItem.GetAsBool: Boolean;
begin
  raise ESettingsAStringsError.Create('not GetAsBool()');
end;

{$IFDEF UNICODE}
function TSettingsAStringsItem.GetAsUText: UnicodeString;
begin
  Result := UnicodeString(GetAsAText())
end;
{$ENDIF}

procedure TSettingsAStringsItem.SetAsAText(const AValue: AnsiString);
begin
  FRwLockObj.BeginWrite;
  try
    if FStrict then
      StringsStrictAdd(FValue, AValue)
    else
      FValue.Text := AValue;
  finally
    FRwLockObj.EndWrite
  end;
end;

procedure TSettingsAStringsItem.SetAsBool(const AValue: Boolean);
begin
  Assert(False, Self.ClassName);
end;

procedure TSettingsAStringsItem.SetAsInt(const AValue: Int64);
begin
  Assert(False, Self.ClassName);
end;

{$IFDEF UNICODE}
procedure TSettingsAStringsItem.SetAsUText(const AValue: UnicodeString);
begin
  SetAsAText(AnsiString(AValue))
end;
{$ENDIF}


procedure TSettingsAStringsItem.Load(ASource: TAnsiStrings);
begin
  FRwLockObj.BeginWrite;
  try
    FValue.Assign(ASource);
  finally
    FRwLockObj.EndWrite
  end;
end;

procedure TSettingsAStringsItem.Save(ADestination: TAnsiStrings);
begin
  FRwLockObj.BeginRead;
  try
    ADestination.Assign(FValue);
  finally
    FRwLockObj.EndRead
  end;
end;

{$IFDEF UNICODE}
procedure TSettingsAStringsItem.Load(ASource: TUnicodeStrings);
begin
  FRwLockObj.BeginWrite;
  try
    FValue.Assign(ASource);
  finally
    FRwLockObj.EndWrite
  end;
end;

procedure TSettingsAStringsItem.Save(ADestination: TUnicodeStrings);
begin
  FRwLockObj.BeginRead;
  try
    uAnsiStrings.StringsAssignAnsiStrings(FValue, ADestination)
  finally
    FRwLockObj.EndRead;
  end;
end;

function TSettingsAStringsItem.GetUnicodeText: UnicodeString;
begin
  Result := UnicodeString(GetText())
end;

procedure TSettingsAStringsItem.SetUnicodeText(const AText: UnicodeString);
begin
  SetText(AnsiString(AText))
end;

{$ENDIF}

function TSettingsAStringsItem.YesRegExpr(const AText: AnsiString): Integer;
begin
  FRwLockObj.BeginRead;
  try
    Result := uRegExprFunc.YesRegExpr(AText, FValue);
  finally
    FRwLockObj.EndRead;
  end;
end;

function TSettingsAStringsItem.YesRegExpr(const AText: AnsiString;
  out AIndex: Integer): AnsiString;
begin
  FRwLockObj.BeginRead;
  try
    AIndex := uRegExprFunc.YesRegExpr(AText, FValue);
    if AIndex<>-1 then
      Result := FValue[AIndex]
    else
      Result := '';
  finally
    FRwLockObj.EndRead;
  end;
end;

function TSettingsAStringsItem.YesRegExpr(const AText: AnsiString;
  out ARegExpr: AnsiString): Integer;
begin
  ARegExpr := YesRegExpr(AText, Result)
end;

procedure TSettingsAStringsItem.SetLine(AIndex: Integer;
  const AValue: AnsiString);
begin
  FRwLockObj.BeginRead;
  try
    FValue[AIndex] := AValue;
  finally
    FRwLockObj.EndRead;
  end;
end;

function TSettingsAStringsItem.GetLine(AIndex: Integer): AnsiString;
begin
  FRwLockObj.BeginRead;
  try
    Result := FValue[AIndex]
  finally
    FRwLockObj.EndRead;
  end;
end;

function TSettingsAStringsItem._Dump: UTF8String;
var
  dat: UTF8String;
  val: UTF8String;
  S: AcedStrings.TStringBuilder;
  j: Integer;
begin
  FRwLockObj.BeginRead;
  try
    S := TStringBuilder.Create;
    try
      S.Append('[');
      for j:=0 to FValue.Count-1 do
      begin
        if j>0 then
          S.Append(',');
        S.Append('"').Append(UTF8Encode(JsonStringSafe(FValue[j]))).Append('"');
      end;
      S.Append(']');
      //---
      {$IFDEF UNICODE}
        val := RawByteString(S.ToString());
      {$else}
        val := S.ToString();
      {$ENDIF}
    finally
      S.Free;
    end;
  finally
    FRwLockObj.EndRead;
  end;
  //---
  dat := inherited _Dump();
  {$IFDEF UNICODE}
    Result := RawByteString(AnsiStrings.Format(RawByteString(dat), [RawByteString(val)]))
  {$else}
    Result := Format(dat, [val])
  {$ENDIF}
end;

{ TSettingsUStringList }


procedure TSettingsAStringsList.Load;
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.FileName<>'' then
      TSettingsAStringsItem(A).AsAText := StringLoadFromFile(A.FileName, True);
end;

procedure TSettingsAStringsList.Save;
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.FileName<>'' then
      StringsSaveToFile(A.FileName, TSettingsAStringsItem(A).FValue);
end;

function TSettingsAStringsList.GetValue(const AName: AnsiString): TSettingsAStringsItem;
begin
  Result := Search(AName) as TSettingsAStringsItem;
end;

function TSettingsAStringsList.GetValue(const AId: Integer): TSettingsAStringsItem;
begin
  Result := Search(AId) as TSettingsAStringsItem;
end;

end.
