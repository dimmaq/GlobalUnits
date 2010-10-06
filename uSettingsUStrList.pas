unit uSettingsUStrList;

interface

{$IFNDEF UNICODE}

uses
  uSettingsAStrList;

type
  TSettingsUStrItem = TSettingsAStrItem;
  TSettingsUStrList = TSettingsAStrList;

{$ELSE}

uses
  Classes, SysUtils, IniFiles, AcedContainers, AcedStrings, uSettingsBaseItem,
  AnsiStrings;

type
  ESettingsUStrError = class(Exception);

  TSettingsUStrItem = class(TSettingsBaseItemA)
  private
    FValue: UnicodeString;
    //---
    procedure SetValue(const AValue: TUString);
    function GetValue: TUString;
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
    function _Dump: UTF8String; override;
//    function Clone(): TSettingsBaseItem; override;
    //---
    property Value: UnicodeString read GetAsUText write SetAsUText;
  end;

  TSettingsUStrList = class(TSettingsBaseList)
  public
    procedure IniRead(AIni: TIniFile); override;
    procedure IniWrite(AIni: TIniFile); override;
    procedure Load; override;
    procedure Save; override;
    //---
    function SetValue(const AId: Integer; const AValue: TUString): TSettingsUStrItem; overload;
    function GetValue(const AId: Integer; out AValue: TUString): TSettingsUStrItem; overload;
    function SetValue(const AName: AnsiString; const AValue: TUString): TSettingsUStrItem; overload;
    function GetValue(const AName: AnsiString; out AValue: TUString): TSettingsUStrItem; overload;
  end;

{$ENDIF}

implementation

{$IFDEF UNICODE}

uses
  uGlobalFunctions, uGlobalFileIOFunc;

{ TSettingsAStringItem }

{
function TSettingsStringItem.Clone: TSettingsBaseItem;
begin
  FLockObj.Enter;
  try
    Result := TSettingsStringItem.Create(Self);
    TSettingsStringItem(Result).FValue := Self.FValue;
    UniqueString(TSettingsStringItem(Result).FValue);
  finally
    FLockObj.Leave
  end;
end;
}

function TSettingsUStrItem.GetValue: TUString;
begin
  FLockObj.Enter;    use FRwLockObj
  try
    Result := FValue;
    UniqueString(FValue);
  finally
    FLockObj.Leave
  end;
end;

procedure TSettingsUStrItem.SetValue(const AValue: TUString);
begin
  FLockObj.Enter;
  try
    FValue := AValue;
    UniqueString(FValue);
  finally
    FLockObj.Leave
  end;
end;


function TSettingsUStrItem._Dump: UTF8String;
var A: UTF8String;
begin
  A := '"' + JsonStringSafe(UTF8Encode(Value)) + '"';
  Result := RawByteString(AnsiStrings.Format(RawByteString(inherited _Dump()), [RawByteString(A)]))
end;

{ TSettingsAStringList }

procedure TSettingsUStrList.IniRead(AIni: TIniFile);
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.IniName<>'' then
      TSettingsUStrItem(A).FValue := AIni.ReadString(A.IniSection, A.IniName, TSettingsUStrItem(A).FValue)
end;

procedure TSettingsUStrList.IniWrite(AIni: TIniFile);
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.IniName<>'' then
      AIni.WriteString(A.IniSection, A.IniName, TSettingsUStrItem(A).FValue)
end;

procedure TSettingsUStrList.Load;
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.FileName<>'' then
      TSettingsUStrItem(A).FValue := UnicodeStringLoadFromFile(A.FileName, True, False, TSettingsUStrItem(A).FValue);
end;

procedure TSettingsUStrList.Save;
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.FileName<>'' then
      UnicodeStringSaveToFile(A.FileName, TSettingsUStrItem(A).FValue);
end;

function TSettingsUStrList.GetValue(const AName: AnsiString;
  out AValue: TUString): TSettingsUStrItem;
begin
  Result := Search(AName) as TSettingsUStrItem;
  if Result<>nil then
    AValue := Result.Value
  else
    AValue := ''
end;

function TSettingsUStrList.SetValue(const AName: AnsiString;
  const AValue: TUString): TSettingsUStrItem;
begin
  Result := Search(AName) as TSettingsUStrItem;
  if Result<>nil then
    Result.Value := AValue
end;

function TSettingsUStrList.SetValue(const AId: Integer;
  const AValue: TUString): TSettingsUStrItem;
begin
  Result := Search(AId) as TSettingsUStrItem;
  if Result<>nil then
    Result.Value := AValue
end;

function TSettingsUStrList.GetValue(const AId: Integer;
  out AValue: TUString): TSettingsUStrItem;
begin
  Result := Search(AId) as TSettingsUStrItem;
  if Result<>nil then
    AValue := Result.Value
  else
    AValue := ''
end;

{$ENDIF}

end.
