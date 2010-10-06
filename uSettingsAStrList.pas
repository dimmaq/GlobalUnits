unit uSettingsAStrList;

interface

uses
  Classes, SysUtils, IniFiles, AcedContainers, AcedStrings, uSettingsBaseItem,
  uGlobalTypes;

type
  ESettingsAStrError = class(Exception);

  TSettingsAStrItem = class(TSettingsBaseItemA)
  private
    FValue: AnsiString;
  protected
    procedure ChangeValue(const AValue: AnsiString); virtual;
    //---
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
    function _Dump: UTF8String; override;
    //---
    property Value: AnsiString read GetAsAText write SetAsAText;
  end;

  TSettingsAStrList = class(TSettingsBaseList)
  public
    procedure IniRead(AIni: TCustomIniFile); override;
    procedure IniWrite(AIni: TCustomIniFile); override;
    procedure Load; override;
    procedure Save; override;
    //---
    function SetValue(const AId: Integer; const AValue: AnsiString): TSettingsAStrItem; overload;
    function GetValue(const AId: Integer; out AValue: AnsiString): TSettingsAStrItem; overload;
    function SetValue(const AName: AnsiString; const AValue: AnsiString): TSettingsAStrItem; overload;
    function GetValue(const AName: AnsiString; out AValue: AnsiString): TSettingsAStrItem; overload;
  end;

implementation

uses uGlobalFunctions, uGlobalFileIOFunc;

{ TSettingsAStrItem }

function TSettingsAStrItem.GetAsAText: AnsiString;
begin
  FLockObj.Enter;
  try
    Result := FValue;
    UniqueString(FValue);
  finally
    FLockObj.Leave
  end;
end;

function TSettingsAStrItem.GetAsBool: Boolean;
var tmp: AnsiString;
begin
  tmp := Value;
  Result := not ((tmp='') or (tmp='0'))
end;

function TSettingsAStrItem.GetAsInt: Int64;
begin
  Result := StrToInt64(Value)
end;

procedure TSettingsAStrItem.SetAsAText(const AValue: AnsiString);
begin
  FLockObj.Enter;
  try
    FValue := AValue;
    UniqueString(FValue);
    ChangeValue(FValue);
  finally
    FLockObj.Leave;
  end;
end;

procedure TSettingsAStrItem.SetAsBool(const AValue: Boolean);
begin
  Value := BoolToStr2(AValue)
end;

procedure TSettingsAStrItem.SetAsInt(const AValue: Int64);
begin
  Value := IntToStr(AValue)
end;



procedure TSettingsAStrItem.ChangeValue(const AValue: AnsiString);
begin
  {Empty}
end;

function TSettingsAStrItem._Dump: UTF8String;
var
  A: UTF8String;
begin
  A := JsonStringSafe(Value);
  A := '"' + A + '"';
  {$IFDEF UNICODE}
    Result := UTF8Encode(Format(string(inherited _Dump()), [string(A)]))
  {$else}
    Result := Format(inherited _Dump(), [A])
  {$ENDIF}
end;



{ TSettingsAStringList }

procedure TSettingsAStrList.IniRead(AIni: TCustomIniFile);
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.IniName<>'' then
    {$IFDEF UNICODE}
      TSettingsAStrItem(A).FValue := AnsiString(AIni.ReadString(A.IniSection, A.IniName, UnicodeString(TSettingsAStrItem(A).FValue)))
    {$ELSE}
      TSettingsAStrItem(A).FValue := AIni.ReadString(A.IniSection, A.IniName, TSettingsAStrItem(A).FValue)
    {$ENDIF}
end;

procedure TSettingsAStrList.IniWrite(AIni: TCustomIniFile);
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.IniName<>'' then
    {$IFDEF UNICODE}
      AIni.WriteString(A.IniSection, A.IniName, UnicodeString(TSettingsAStrItem(A).FValue))
    {$ELSE}
      AIni.WriteString(A.IniSection, A.IniName, TSettingsAStrItem(A).FValue)
    {$ENDIF}
end;

procedure TSettingsAStrList.Load;
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.FileName<>'' then
      TSettingsAStrItem(A).FValue := StringLoadFromFile(A.FileName, True, False, TSettingsAStrItem(A).FValue);
end;

procedure TSettingsAStrList.Save;
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.FileName<>'' then
      StringSaveToFile(A.FileName, TSettingsAStrItem(A).FValue);
end;

function TSettingsAStrList.GetValue(const AName: AnsiString;
  out AValue: AnsiString): TSettingsAStrItem;
begin
  Result := Search(AName) as TSettingsAStrItem;
  if Result<>nil then
    AValue := Result.Value
  else
    AValue := ''
end;

function TSettingsAStrList.SetValue(const AName,
  AValue: AnsiString): TSettingsAStrItem;
begin
  Result := Search(AName) as TSettingsAStrItem;
  if Result<>nil then
    Result.Value := AValue
end;

function TSettingsAStrList.SetValue(const AId: Integer;
  const AValue: AnsiString): TSettingsAStrItem;
begin
  Result := Search(AId) as TSettingsAStrItem;
  if Result<>nil then
    Result.Value := AValue
end;

function TSettingsAStrList.GetValue(const AId: Integer;
  out AValue: AnsiString): TSettingsAStrItem;
begin
  Result := Search(AId) as TSettingsAStrItem;
  if Result<>nil then
    AValue := Result.Value
  else
    AValue := ''
end;

end.
