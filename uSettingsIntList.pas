unit uSettingsIntList;

interface

uses
  Classes, SysUtils, IniFiles, AcedContainers, AcedStrings, uSettingsBaseItem
  {$IFDEF UNICODE}
    , AnsiStrings
  {$ENDIF}
  ;

const
  INT_DEFAULT_VALUE = 0;

type
  ESettingsIntError = class(Exception);

  TSettingsIntItem = class(TSettingsBaseItemA)
  private
    FValue: Int64;
    //---
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
    function Increment(A: Integer = 1): Int64;
    function Decrement: Int64;
    //---
    property Value: Int64 read GetAsInt write SetAsInt;
  end;

  TSettingsIntList = class(TSettingsBaseList)
  public
    procedure IniRead(AIni: TCustomIniFile); override;
    procedure IniWrite(AIni: TCustomIniFile); override;
    //---
    function SetValue(const AId: Integer; const AValue: Int64): TSettingsIntItem; overload;
    function GetValue(const AId: Integer; out AValue: Int64): TSettingsIntItem; overload;
    function SetValue(const AName: AnsiString; const AValue: Int64): TSettingsIntItem; overload;
    function GetValue(const AName: AnsiString; out AValue: Int64): TSettingsIntItem; overload;
  end;

implementation

{ TSettingsIntItem }
 
function TSettingsIntItem.GetAsInt: Int64;
begin
  FLockObj.Enter;
  try
    Result := FValue;
  finally
    FLockObj.Leave
  end;
end;

function TSettingsIntItem.GetAsAText: AnsiString;
begin
  Result := IntToStr(Value)
end;

function TSettingsIntItem.GetAsBool: Boolean;
begin
  Result := Value<>0
end;

procedure TSettingsIntItem.SetAsAText(const AValue: AnsiString);
begin
  Value := StrToInt64(AValue)
end;

procedure TSettingsIntItem.SetAsBool(const AValue: Boolean);
begin
  if AValue then
    Value := 1
  else
    Value := 0
end;

procedure TSettingsIntItem.SetAsInt(const AValue: Int64);
begin
  FLockObj.Enter;
  try
    FValue := AValue
  finally
    FLockObj.Leave
  end
end;


function TSettingsIntItem.Decrement: Int64;
begin
  FLockObj.Enter;
  try
    Dec(FValue);
    Result := FValue;
  finally
    FLockObj.Leave
  end; 
end;

function TSettingsIntItem.Increment(A: Integer): Int64;
begin
  FLockObj.Enter;
  try
    Inc(FValue, A);
    Result := FValue;
  finally
    FLockObj.Leave
  end;      
end;


function TSettingsIntItem._Dump: UTF8String;
var
  dat: UTF8String;
  val: UTF8String;
begin
  val := UTF8Encode(IntToStr(Value));
  dat := inherited _Dump();
  {$IFDEF UNICODE}
    Result := RawByteString(AnsiStrings.Format(RawByteString(dat), [RawByteString(val)]))
  {$else}
    Result := Format(dat, [val])
  {$ENDIF}
end;

{ TIntStringList }

procedure TSettingsIntList.IniRead(AIni: TCustomIniFile);
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.IniName<>'' then
      TSettingsIntItem(A).FValue := StrToInt64Def(
        AIni.ReadString(A.IniSection, A.IniName, ''),
        TSettingsIntItem(A).FValue
      );
end;

procedure TSettingsIntList.IniWrite(AIni: TCustomIniFile);
var A: TSettingsBaseItem;
begin
  for A in Self do
    if A.IniName<>'' then
      AIni.WriteString(A.IniSection, A.IniName, IntToStr(TSettingsIntItem(A).FValue))
end;

function TSettingsIntList.GetValue(const AName: AnsiString;
  out AValue: Int64): TSettingsIntItem;
begin
  Result := Search(AName) as TSettingsIntItem;
  if Result<>nil then
    AValue := Result.Value
  else
    AValue := INT_DEFAULT_VALUE
end;

function TSettingsIntList.SetValue(const AName: AnsiString;
  const AValue: Int64): TSettingsIntItem;
begin
  Result := Search(AName) as TSettingsIntItem;
  if Result<>nil then
    Result.Value := AValue
end;

function TSettingsIntList.SetValue(const AId: Integer;
  const AValue: Int64): TSettingsIntItem;
begin
  Result := Search(AId) as TSettingsIntItem;
  if Result<>nil then
    Result.Value := AValue
end;

function TSettingsIntList.GetValue(const AId: Integer;
  out AValue: Int64): TSettingsIntItem;
begin
  Result := Search(AId) as TSettingsIntItem;
  if Result<>nil then
    AValue := Result.Value
  else
    AValue := INT_DEFAULT_VALUE
end;

end.
