unit uSettingsBoolList;

interface

uses
  Classes, SysUtils, IniFiles, AcedContainers, AcedStrings, uSettingsBaseItem
  {$IFDEF UNICODE}
    , AnsiStrings
  {$ENDIF}
  ;

type
  ESettingsBoolError = class(Exception);

  TSettingsBoolItem = class(TSettingsBaseItem)
  private
    FValue: Boolean;
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
    property Value: Boolean read FValue write FValue;
  end;

  TSettingsBoolList = class(TSettingsBaseList)
  public
    procedure IniRead(AIni: TCustomIniFile); override;
    procedure IniWrite(AIni: TCustomIniFile); override;
    //---
    function SetValue(const AId: Integer; const AValue: Boolean): TSettingsBoolItem; overload;
    function GetValue(const AId: Integer; out AValue: Boolean): TSettingsBoolItem; overload;
    function SetValue(const AName: AnsiString; const AValue: Boolean): TSettingsBoolItem; overload;
    function GetValue(const AName: AnsiString; out AValue: Boolean): TSettingsBoolItem; overload;
  end;

implementation

uses uGlobalFunctions;

{ TSettingsBoolItem }

function TSettingsBoolItem.GetAsInt: Int64;
begin
  if FValue then
    Result := 1
  else
    Result := 0  
end;

function TSettingsBoolItem.GetAsAText: AnsiString;
begin
  Result := BoolToStr2(FValue)
end;

function TSettingsBoolItem.GetAsBool: Boolean;
begin
  Result := FValue
end;

procedure TSettingsBoolItem.SetAsAText(const AValue: AnsiString);
begin
  FValue := not ((AValue='') or (AValue='0'))
end;

procedure TSettingsBoolItem.SetAsBool(const AValue: Boolean);
begin
  FValue := AValue
end;

procedure TSettingsBoolItem.SetAsInt(const AValue: Int64);
begin
  FValue := AValue<>0;
end;


function TSettingsBoolItem._Dump: UTF8String;
var
  dat: UTF8String;
  val: UTF8String;
begin
  val := UTF8Encode(G_ToLower(BoolToStr2(FValue,True)));
  dat := inherited _Dump();
  {$IFDEF UNICODE}
    Result := RawByteString(AnsiStrings.Format(RawByteString(dat), [RawByteString(val)]))
  {$else}
    Result := Format(dat, [val])
  {$ENDIF}
end;


{ TBoolStringList }

procedure TSettingsBoolList.IniRead(AIni: TCustomIniFile);
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.IniName<>'' then
      TSettingsBoolItem(A).FValue := AIni.ReadBool(A.IniSection, A.IniName, TSettingsBoolItem(A).FValue)
end;

procedure TSettingsBoolList.IniWrite(AIni: TCustomIniFile);
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.IniName<>'' then
      AIni.WriteBool(A.IniSection, A.IniName, TSettingsBoolItem(A).FValue)
end;

function TSettingsBoolList.GetValue(const AName: AnsiString;
  out AValue: Boolean): TSettingsBoolItem;
begin
  Result := Search(AName) as TSettingsBoolItem;
  if Result<>nil then
    AValue := Result.Value
  else
    AValue := False
end;

function TSettingsBoolList.SetValue(const AName: AnsiString;
  const AValue: Boolean): TSettingsBoolItem;
begin
  Result := Search(AName) as TSettingsBoolItem;
  if Result<>nil then
    Result.Value := AValue
end;

function TSettingsBoolList.SetValue(const AId: Integer;
  const AValue: Boolean): TSettingsBoolItem;
begin
  Result := Search(AId) as TSettingsBoolItem;
  if Result<>nil then
    Result.Value := AValue
end;

function TSettingsBoolList.GetValue(const AId: Integer;
  out AValue: Boolean): TSettingsBoolItem;
begin
  Result := Search(AId) as TSettingsBoolItem;
  if Result<>nil then
    AValue := Result.Value
  else
    AValue := False
end;


end.
