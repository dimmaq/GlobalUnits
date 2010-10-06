unit uSettingsUStringsList;

interface

{$IFNDEF UNICODE}

uses
  uSettingsAStringsList;

type
  TSettingsUStringsItem = TSettingsAStringsItem;
  TSettingsUStringsList = TSettingsAStringsList;

implementation

{$ELSE}

uses
  Classes, SysUtils, IniFiles, AcedContainers, AcedStrings,
  uAnsiStrings, uGlobalFileIOFunc, uSettingsBaseItem, AnsiStrings;

type
  ESettingsUStringsError = class(Exception);

  TSettingsUStringsItem = class(TSettingsBaseItemB)
  private
    FStrict: Boolean;
    FValue: TUnicodeStringList;
    //---
//    procedure SetValue(const AValue: AnsiString);
//    function GetValue: TAnsiStringList;
    function GetText: UnicodeString;
    procedure SetText(const AText: UnicodeString);
    function GetAnsiText: AnsiString;
    procedure SetAnsiText(const AText: AnsiString);
    function GetCount: Integer;
  protected
    function GetAsAsInt: Int64; override;
    function GetAsAText: AnsiString; override;
    function GetAsBool: Boolean; override;
    function GetAsUText: UnicodeString; override;
    procedure SetAsAText(const Value: AnsiString); override;
    procedure SetAsBool(const Value: Boolean); override;
    procedure SetAsInt(const Value: Int64); override;
    procedure SetAsUText(const Value: UnicodeString); override;
  public
    constructor Create(const AID: Integer; const AName: AnsiString = '';
      const AFileName: TFileName;  AStrict: Boolean);
    destructor Destroy; override;
    //---
    function _Dump: UTF8String; override;
    //---
    procedure AfterConstruction; override;
    procedure Save(ADestination: TAnsiStrings); overload;
    procedure Load(ASource: TAnsiStrings); overload;
    procedure Save(ADestination: TUnicodeStrings); overload;
    procedure Load(ASource: TUnicodeStrings); overload;
    //---
    property Value: TUnicodeStringList read FValue;
    /// <summary>Строгая загрузка - разделитель только CRLF.
    /// В противном случае парсится обычным методом</summary>
    property Strict: Boolean read FStrict write FStrict;
    property Text: UnicodeString read GetAsUText write SetASUText;
    property Count: Integer read GetCount;
  end;

  TSettingsUStringsList = class(TSettingsBaseList)
  public
    procedure Load; override;
    procedure Save; override;
    //---
    function GetValue(const AId: Integer): TSettingsUStringsItem; overload;
    function GetValue(const AName: AnsiString): TSettingsUStringsItem; overload;
  end;

implementation

uses uGlobalFunctions;

{ TSettingsUStringItem }

procedure TSettingsUStringsItem.AfterConstruction;
begin
  inherited;
  if not Assigned(FValue) then
    FValue := TUnicodeStringList.Create;
end;

constructor TSettingsUStringsItem.Create(const AID: Integer;
  const AName: AnsiString; const AFileName: TFileName;
  AStrict: Boolean);
begin
  inherited Create(AID, AName, '', '', AFileName, False);
  //---
  FStrict := FStrict;
  FValue := TUnicodeStringList.Create;
//  FValue.Text := ADefault;
end;

destructor TSettingsUStringsItem.Destroy;
begin
  FreeAndNil(FValue);
  inherited;
end;

function TSettingsUStringsItem.GetCount: Integer;
begin
  Result := FValue.Count
end;

function TSettingsUStringsItem.GetText: UnicodeString;
begin
  FLockObj.Enter;
  use FRwLockObj
  try
    Result := FValue.Text;
    UniqueString(Result);
  finally
    FLockObj.Leave
  end;
end;

procedure TSettingsUStringsItem.SetText(const AText: UnicodeString);
begin
  FLockObj.Enter;
  try
    if FStrict then
      StringsStrictAdd(FValue, AText)
    else
      FValue.Text := AText
  finally
    FLockObj.Leave
  end;
end;

procedure TSettingsUStringsItem.SetAnsiText(const AText: AnsiString);
begin
  SetText(UnicodeString(AText))
end;


function TSettingsUStringsItem.GetAnsiText: AnsiString;
begin
  Result := AnsiString(GetText());
end;

procedure TSettingsUStringsItem.Load(ASource: TUnicodeStrings);
begin
  FLockObj.Enter;
  try
    FValue.Assign(ASource);
  finally
    FLockObj.Leave
  end;
end;

procedure TSettingsUStringsItem.Save(ADestination: TUnicodeStrings);
begin
  FLockObj.Enter;
  try
    ADestination.Assign(FValue);
  finally
    FLockObj.Leave
  end;
end;

procedure TSettingsUStringsItem.Load(ASource: TAnsiStrings);
begin
  FLockObj.Enter;
  try
    StringsAssignAnsiStrings(ASource, FValue);
  finally
    FLockObj.Leave
  end;
end;

procedure TSettingsUStringsItem.Save(ADestination: TAnsiStrings);
begin
  FLockObj.Enter;
  try
    ADestination.Assign(FValue);
  finally
    FLockObj.Leave
  end;
end;

function TSettingsUStringsItem._Dump: UTF8String;
var
  dat: UTF8String;
  val: UTF8String;
  S: AcedStrings.TStringBuilder;
  j: Integer;
begin
  FLockObj.Enter;
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
      val := RawByteString(S.ToString());
    finally
      S.Free;
    end;
  finally
    FLockObj.Leave
  end;
  //---
  dat := inherited _Dump();
  Result := RawByteString(AnsiStrings.Format(RawByteString(dat), [RawByteString(val)]))
end;

{ TSettingsUStringList }

procedure TSettingsUStringsList.Load;
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.FileName<>'' then
      TSettingsUStringsItem(A).Text := UnicodeStringLoadFromFile(A.FileName, True, False, TSettingsUStringsItem(A).Text);
end;

procedure TSettingsUStringsList.Save;
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.FileName<>'' then
      StringsSaveToFile(A.FileName, TSettingsUStringsItem(A).FValue);
end;

function TSettingsUStringsList.GetValue(const AName: AnsiString): TSettingsUStringsItem;
begin
  Result := Search(AName) as TSettingsUStringsItem;
end;

{
function TSettingsStringsList.SetValue(const AName,
  AValue: AnsiString): TSettingsStringsItem;
begin
  Result := Search(AName) as TSettingsStringsItem;
  if Result<>nil then
    Result.Value := AValue
end;

function TSettingsStringsList.SetValue(const AId: Integer;
  const AValue: AnsiString): TSettingsStringsItem;
begin
  Result := Search(AId) as TSettingsStringsItem;
  if Result<>nil then
    Result.Value := AValue
end;
}

function TSettingsUStringsList.GetValue(const AId: Integer): TSettingsUStringsItem;
begin
  Result := Search(AId) as TSettingsUStringsItem;
end;

{$ENDIF}

end.
