unit uGlobalSettings;

interface

uses
  Windows, Messages, SysUtils, Classes, IniFiles, ShellAPI,
  AcedStrings, AcedContainers, AcedBinary, uAnsiStrings, uGlobalTypes,
  uSettingsBaseItem,
  uSettingsBoolList,
  uSettingsIntList,
  uSettingsAStrList,
  uSettingsUStrList,
  uSettingsAStringsList,
  uSettingsUStringsList
  {$IFDEF UNICODE}
    , AnsiStrings
  {$ENDIF}
  ;

const
  WM_UPDATE_SETTINGS = 2;
  WM_UPDATE_SETTINGSA = 3;
  WM_UPDATE_FEWSETTINGS = 4;
  WM_UPDATE_FEWSETTINGSA = 5;

type
  TGlobalSettingsBase = class;

  ESettingsSettingsError = class(Exception);

  TSettingsSettingsItem = class(TSettingsBaseItemA)
  private
    FValue: TGlobalSettingsBase;
    //---
//    procedure SetValue(const AValue: TGlobalSettingsBase);
    function GetValue: TGlobalSettingsBase;
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
    destructor Destroy; override;
    //---
    function _Dump: UTF8String; override;
//    function Clone(): TSettingsBaseItem; override;
    //---
    property Value: TGlobalSettingsBase read GetValue{ write SetValue};
  end;

  TSettingsSettingsList = class(TSettingsBaseList)
  public
    procedure IniRead(AIni: TCustomIniFile); override;
    procedure IniWrite(AIni: TCustomIniFile); override;
    //---
//    function SetValue(const AId: Integer;
//      const AValue: TGlobalSettingsBase): TSettingsSettingsItem; overload;
    function GetValue(const AId: Integer;
      out AValue: TGlobalSettingsBase): TSettingsSettingsItem; overload;
//    function SetValue(const AName: AnsiString;
//      const AValue: TGlobalSettingsBase): TSettingsSettingsItem; overload;
    function GetValue(const AName: AnsiString;
      out AValue: TGlobalSettingsBase): TSettingsSettingsItem; overload;
  end;


  EGlobalSettingsError = class(Exception);

  TGlobalSettingsBaseProp = class
  private
    FGenerId: Integer;
    FDontNotify: Boolean;
    FNotifyHandle: THandle;
    FRaiseIfNotFound: Boolean;
    FAddIfNotFound: Boolean;
    //---
    FSearchId: TIntegerAssociationList;
    FSearchName: TStringAssociationList;
  public
    constructor Create;
    destructor Destroy; override;
    //---
//    procedure Clear;
//    procedure CopyFrom(ASource: TGlobalSettingsBaseProp);
    //---
    property DontNotify: Boolean read FDontNotify write FDontNotify default False;
    property NotifyHandle: THandle read FNotifyHandle write FNotifyHandle default INVALID_HANDLE_VALUE;
    property RaiseIfNotFound: Boolean read FRaiseIfNotFound write FRaiseIfNotFound default True;
    property AddIfNotFound: Boolean read FAddIfNotFound write FAddIfNotFound default False;
    //---
    property SearchId: TIntegerAssociationList read FSearchId;
    property SearchName: TStringAssociationList read FSearchName;
  end;

  {$IFDEF UNICODE}
    TSettingsStrItem = TSettingsUStrItem;
    TSettingsStringsItem = TSettingsUStringsItem;
  {$ELSE}
    TSettingsStrItem = TSettingsAStrItem;
    TSettingsStringsItem = TSettingsAStringsItem;
  {$ENDIF}

  TGlobalSettingsBase = class(TObject)
  private
    FProperty: TGlobalSettingsBaseProp;
    FChild: Boolean;
    //---
    FListList: TSettingsBaseListList;
    //---
    FSettingsList: TSettingsSettingsList;
    FBoolList: TSettingsBoolList;
    FAStrList: TSettingsAStrList;
    FUStrList: TSettingsUStrList;
    FIntList: TSettingsIntList;
    FAStringsList: TSettingsAStringsList;
    FUStringsList: TSettingsUStringsList;
    //---
//    procedure _Notify(const AID: Integer);
    procedure _NotifyA(const A: TSettingsBaseItem);
{   перенес в _AddList
    procedure _AddSearch(AItem: TSettingsBaseItem);
    procedure _RemSearch(AItem: TSettingsBaseItem);
}
    function _AddSearchList(const ASearchList: TSettingsBaseList;
      const AListItem: TSettingsBaseItem): TSettingsBaseItem;
    procedure _Clear;
    //---
    //---
    function _NotFoundBool(const AID: Integer; const AValue: Boolean = False): Boolean; overload;
    function _NotFoundBool(const AName: AnsiString; const AValue: Boolean = False): Boolean; overload;
    function _NotFoundAStr(const AID: Integer; const AValue: AnsiString = ''): AnsiString; overload;
    function _NotFoundAStr(const AName: AnsiString; const AValue: AnsiString = ''): AnsiString; overload;
    function _NotFoundUStr(const AID: Integer; const AValue: UnicodeString = ''): UnicodeString; overload;
    function _NotFoundUStr(const AName: AnsiString; const AValue: UnicodeString = ''): UnicodeString; overload;
    function _NotFoundInt(const AID: Integer; out AOut: Int64; const AValue: Int64 = INT_DEFAULT_VALUE): TSettingsIntItem; overload;
    function _NotFoundInt(const AName: AnsiString; out AOut: Int64; const AValue: Int64 = INT_DEFAULT_VALUE): TSettingsIntItem; overload;
    function _NotFoundSettings(const AID: Integer): TGlobalSettingsBase; overload;
    function _NotFoundSettings(const AName: AnsiString): TGlobalSettingsBase; overload;
    function _NotFoundAStrings(const AID: Integer): TSettingsAStringsItem; overload;
    function _NotFoundAStrings(const AName: AnsiString): TSettingsAStringsItem; overload;
    function _NotFoundUStrings(const AID: Integer): TSettingsUStringsItem; overload;
    function _NotFoundUStrings(const AName: AnsiString): TSettingsUStringsItem; overload;
    //---
    function GetBoolByName(const AName: AnsiString): Boolean;
    procedure SetBoolByName(const AName: AnsiString; const Value: Boolean);
    function GetBoolById(AId: Integer): Boolean;
    procedure SetBoolById(AId: Integer; const Value: Boolean);
    //---
    function GetAStrByName(const AName: AnsiString): AnsiString;
    procedure SetAStrByName(const AName: AnsiString; const Value: AnsiString);
    function GetAStrById(AId: Integer): AnsiString;
    procedure SetAStrById(AId: Integer; const Value: AnsiString);
    //---
    function GetUStrByName(const AName: AnsiString): UnicodeString;
    procedure SetUStrByName(const AName: AnsiString; const Value: UnicodeString);
    function GetUStrById(AId: Integer): UnicodeString;
    procedure SetUStrById(AId: Integer; const Value: UnicodeString);
    //---
    function GetIntByName(const AName: AnsiString): Int64;
    procedure SetIntByName(const AName: AnsiString; const Value: Int64);
    function GetIntById(AId: Integer): Int64;
    procedure SetIntById(AId: Integer; const Value: Int64);
    //---
    function GetSettingsByName(const AName: AnsiString): TGlobalSettingsBase;
//    procedure SetSettingsByName(const AName: AnsiString; const Value: TGlobalSettingsBase);
    function GetSettingsById(AId: Integer): TGlobalSettingsBase;
//    procedure SetSettingsById(AId: Integer; const Value: TGlobalSettingsBase);
    //---
    function GetAStringsByName(const AName: AnsiString): TSettingsAStringsItem;
//    procedure SetAStringsByName(const AName: AnsiString; const Value: AnsiString);
    function GetAStringsById(AId: Integer): TSettingsAStringsItem;
//    procedure SetAStringsById(AId: Integer; const Value: AnsiString);
    //---
    function GetUStringsByName(const AName: AnsiString): TSettingsUStringsItem;
//    procedure SetUStringsByName(const AName: AnsiString; const Value: UnicodeString);
    function GetUStringsById(AId: Integer): TSettingsUStringsItem;
    //procedure SetUStringsById(AId: Integer; const Value: UnicodeString);
    //---
    function GetIntItemById(AId: Integer): TSettingsIntItem;
    //---
    function GetDontNotify: Boolean;
    function GetNotifyHandle: THandle;
    function GetRaiseIfNotFound: Boolean;
    function GetAddIfNotFound: Boolean;
    function GetProp: TGlobalSettingsBaseProp;
    procedure SetDontNotify(AValue: Boolean);
    procedure SetNotifyHandle(AValue: THandle);
    procedure SetRaiseIfNotFound(AValue: Boolean);
    procedure SetAddIfNotFound(AValue: Boolean);
    procedure SetProp(AValue: TGlobalSettingsBaseProp);
  protected
    FLockObj: TMultiReadExclusiveWriteSynchronizer;
    //---
    //---
    function _AddBool(const AID: Integer; const AValue: Boolean;
      const AName: AnsiString; const AIniName, AIniSection: string): TSettingsBoolItem;
    function _AddAStr(const AItem: TSettingsAStrItem): TSettingsAStrItem; overload;
    function _AddAStr(const AID: Integer; const AValue: AnsiString;
      const AName: AnsiString; const AIniName, AIniSection: string;
      const AFileName: TFileName): TSettingsAStrItem; overload;
    function _AddUStr(const AID: Integer; const AValue: UnicodeString;
      const AName: AnsiString; const AIniName, AIniSection: string;
      const AFileName: TFileName): TSettingsUStrItem;
    function _AddInt(const AID: Integer; const AValue: Int64;
      const AName: AnsiString; const AIniName, AIniSection: string): TSettingsIntItem;
    function _AddSettings(const AID: Integer; const AName: AnsiString;
       const AIniName, AIniSection: string): TSettingsSettingsItem;
    function _AddAStrings(const AID: Integer; const AValue: AnsiString;
      AStrict: Boolean; const AName: AnsiString;
      const AFileName: TFileName): TSettingsAStringsItem;
    function _AddUStrings(const AID: Integer; const AValue: UnicodeString;
      AStrict: Boolean; const AName: AnsiString;
      const AFileName: TFileName): TSettingsUStringsItem;
    //---
  public
    constructor Create(AOwner: TGlobalSettingsBase = nil);
    destructor Destroy; override;
    //---
    function _Dump(): UTF8String;
    procedure _ShowDump;
    //---
    procedure IniRead(AIni: TCustomIniFile); virtual;
    procedure IniWrite(AIni: TCustomIniFile); virtual;
    procedure Load; virtual;
    procedure Save; virtual;
    procedure LockGlobal;
    procedure UnLockGlobal;
    procedure NotifyChange(AIDs: array of Integer); overload;
    procedure NotifyChangeA(AItemList: array of TSettingsBaseItem); overload;
    function GenerId: Integer;
    procedure Clear;
//    procedure CopyFrom(ASource: TGlobalSettingsBase);
    //---

    //TODO: сделать перегрузку ф-й добавления для Id и Name

    function AddBool(const AID: Integer; const AValue: Boolean;
      const AIniName: string = ''; const AIniSection: string = ''
    ): TSettingsBoolItem; overload;
    function AddBool(const AName: AnsiString; const AValue: Boolean; 
      const AIniName: string = ''; const AIniSection: string = ''
    ): TSettingsBoolItem; overload;

    function AddStr(const AID: Integer; const AValue: string;
      const AIniName: string = ''; const AIniSection: string = '';
      const AFileName: TFileName = ''): TSettingsStrItem; overload;
    function AddStr(const AName: AnsiString; const AValue: string;
      const AIniName: string = ''; const AIniSection: string = '';
      const AFileName: TFileName = ''): TSettingsStrItem; overload;

    function AddAStr(const AID: Integer; const AValue: AnsiString;
      const AIniName: string = ''; const AIniSection: string = '';
      const AFileName: TFileName = ''): TSettingsAStrItem; overload;
    function AddAStr(const AName: AnsiString; const AValue: AnsiString;
      const AIniName: string = ''; const AIniSection: string = '';
      const AFileName: TFileName = ''): TSettingsAStrItem; overload;

    function AddUStr(const AID: Integer; const AValue: UnicodeString;
      const AIniName: string = ''; const AIniSection: string = '';
      const AFileName: TFileName = ''): TSettingsUStrItem; overload;
    function AddUStr(const AName: AnsiString; const AValue: UnicodeString;
      const AIniName: string = ''; const AIniSection: string = '';
      const AFileName: TFileName = ''): TSettingsUStrItem; overload;

    function AddInt(const AID: Integer; const AValue: Int64;
      const AIniName: string = ''; const AIniSection: string = ''
    ): TSettingsIntItem; overload;
    function AddInt(const AName: AnsiString; const AValue: Int64;
      const AIniName: string = ''; const AIniSection: string = ''
    ): TSettingsIntItem; overload;

    function AddSettings(const AID: Integer;
      const AIniName: string = ''; const AIniSection: string = ''
    ): TSettingsSettingsItem; overload;
    function AddSettings(const AName: AnsiString;
      const AIniName: string = ''; const AIniSection: string = ''
    ): TSettingsSettingsItem; overload;

    function AddStrings(const AID: Integer; const AValue: string = '';
      AStrict: Boolean = False; const AFileName: TFileName = ''
    ): TSettingsStringsItem; overload;
    function AddStrings(const AName: AnsiString; const AValue: string = '';
      AStrict: Boolean = False; const AFileName: TFileName = ''
    ): TSettingsStringsItem; overload;

    function AddAStrings(const AID: Integer; const AValue: AnsiString = '';
      AStrict: Boolean = False; const AFileName: TFileName = ''
    ): TSettingsAStringsItem; overload;
    function AddAStrings(const AName: AnsiString; const AValue: AnsiString = '';
      AStrict: Boolean = False; const AFileName: TFileName = ''
    ): TSettingsAStringsItem; overload;

    function AddUStrings(const AID: Integer; const AValue: UnicodeString = '';
      AStrict: Boolean = False; const AFileName: TFileName = ''
    ): TSettingsUStringsItem; overload;
    function AddUStrings(const AName: AnsiString; const AValue: UnicodeString = '';
      AStrict: Boolean = False; const AFileName: TFileName = ''
    ): TSettingsUStringsItem; overload;

    //---
    function Search(AId: Integer): TSettingsBaseItem; overload;
    function Search(const AName: AnsiString): TSettingsBaseItem; overload;
    function Search(AId: Integer; var AOutItem: TSettingsBaseItem): Boolean; overload;
    function Search(const AName: AnsiString; var AOutItem: TSettingsBaseItem): Boolean; overload;
    //---
    property ListList: TSettingsBaseListList read FListList;
    //---
    property DontNotify: Boolean read GetDontNotify write SetDontNotify;
    property NotifyHandle: THandle read GetNotifyHandle write SetNotifyHandle;
    property RaiseIfNotFound: Boolean read GetRaiseIfNotFound write SetRaiseIfNotFound;
    property AddIfNotFound: Boolean read GetAddIfNotFound write SetAddIfNotFound;
    property Prop: TGlobalSettingsBaseProp read GetProp write SetProp;
    //---
    property BoolByName[const AName: AnsiString]: Boolean read GetBoolByName write SetBoolByName;
    property StrByName[const AName: AnsiString]: AnsiString read GetAStrByName write SetAStrByName;
    property AStrByName[const AName: AnsiString]: AnsiString read GetAStrByName write SetAStrByName;
    property UStrByName[const AName: AnsiString]: UnicodeString read GetUStrByName write SetUStrByName;
    property IntByName[const AName: AnsiString]: Int64 read GetIntByName write SetIntByName;
    property SettingsByName[const AName: AnsiString]: TGlobalSettingsBase read GetSettingsByName;
    property AStringsByName[const AName: AnsiString]: TSettingsAStringsItem read GetAStringsByName;// write SetAStringsByName;
    property UStringsByName[const AName: AnsiString]: TSettingsUStringsItem read GetUStringsByName;// write SetUStringsByName;
    //---
    property Bool[AId: Integer]: Boolean read GetBoolById write SetBoolById;
    property Str[AId: Integer]: AnsiString read GetAStrById write SetAStrById;
    property AStr[AId: Integer]: AnsiString read GetAStrById write SetAStrById;
    property UStr[AId: Integer]: UnicodeString read GetUStrById write SetUStrById;
    property Int[AId: Integer]: Int64 read GetIntById write SetIntById;
    property Settings[AId: Integer]: TGlobalSettingsBase read GetSettingsById;
    property AStrings[AId: Integer]: TSettingsAStringsItem read GetAStringsById;// write SetAStrById;
    property UStrings[AId: Integer]: TSettingsUStringsItem read GetUStringsById;// write SetUStrById;
    //---
    property IntItemById[AId: Integer]: TSettingsIntItem read GetIntItemById;
  end;

implementation

uses uGlobalFunctions, uGlobalFileIOFunc, uGlobalVars;


{ TSettingsSettingsItem }

destructor TSettingsSettingsItem.Destroy;
begin
  if Assigned(FValue) then
    FreeAndNil(FValue);
  inherited;
end;

function TSettingsSettingsItem.GetValue: TGlobalSettingsBase;
begin
  FLockObj.Enter;
  try
    if not Assigned(FValue) then
      FValue := TGlobalSettingsBase.Create;
    //---
    Result := FValue;
  finally
    FLockObj.Leave
  end;
end;

function TSettingsSettingsItem.GetAsInt: Int64; begin
  raise ESettingsSettingsError.Create('not GetAsIn()');
end;
function TSettingsSettingsItem.GetAsAText: AnsiString; begin
  raise ESettingsSettingsError.Create('not GetAsAText()');
end;
function TSettingsSettingsItem.GetAsBool: Boolean; begin
  raise ESettingsSettingsError.Create('not GetAsBool()');
end;
procedure TSettingsSettingsItem.SetAsAText(const AValue: AnsiString); begin
  raise ESettingsSettingsError.Create('not SetAsAText()');
end;
procedure TSettingsSettingsItem.SetAsBool(const AValue: Boolean); begin
  raise ESettingsSettingsError.Create('not SetAsBool()');
end;
procedure TSettingsSettingsItem.SetAsInt(const AValue: Int64); begin
  raise ESettingsSettingsError.Create('not SetAsInt()');
end;
{$IFDEF UNICODE}
function TSettingsSettingsItem.GetAsUText: UnicodeString; begin
  raise ESettingsSettingsError.Create('not GetAsUText()');
end;
procedure TSettingsSettingsItem.SetAsUText(const AValue: UnicodeString); begin
  raise ESettingsSettingsError.Create('not SetAsUText()');
end;
{$ENDIF}

{
procedure TSettingsSettingsItem.SetValue(const AValue: TGlobalSettingsBase);
begin
  if AValue<>nil then
  begin
    FLockObj.Enter;
    try
      FreeAndNil(FValue);
      FValue := TGlobalSettingsBase.Create;
      FValue.CopyFrom(AValue);
    finally
      FLockObj.Leave
    end;
  end;
end;
}

function TSettingsSettingsItem._Dump: UTF8String;
var
  dat: UTF8String;
  val: UTF8String;
begin
  val := Value._Dump();
  dat := inherited _Dump();
  {$IFDEF UNICODE}
    Result := RawByteString(AnsiStrings.Format(RawByteString(dat), [RawByteString(val)]))
  {$else}
    Result := Format(dat, [val])
  {$ENDIF}
end;

{ TSettingsSettingsList }

procedure TSettingsSettingsList.IniRead(AIni: TCustomIniFile);
var A: TSettingsBaseItem;
begin
  for A in Self do
    TSettingsSettingsItem(A).Value.IniRead(AIni)
end;

procedure TSettingsSettingsList.IniWrite(AIni: TCustomIniFile);
var A: TSettingsBaseItem;
begin
  for A in Self do
    TSettingsSettingsItem(A).Value.IniWrite(AIni)
end;


function TSettingsSettingsList.GetValue(const AName: AnsiString;
  out AValue: TGlobalSettingsBase): TSettingsSettingsItem;
begin
  Result := Search(AName) as TSettingsSettingsItem;
  if Result<>nil then
    AValue := Result.Value
  else
    AValue := nil
end;

function TSettingsSettingsList.GetValue(const AId: Integer;
  out AValue: TGlobalSettingsBase): TSettingsSettingsItem;
begin
  Result := Search(AId) as TSettingsSettingsItem;
  if Result<>nil then
    AValue := Result.Value
  else
    AValue := nil
end;

{
function TSettingsSettingsList.SetValue(const AId: Integer;
  const AValue: TGlobalSettingsBase): TSettingsSettingsItem;
begin
  Result := Search(AId) as TSettingsSettingsItem;
  if Result<>nil then
    Result.Value := AValue
end;

function TSettingsSettingsList.SetValue(const AName: AnsiString;
  const AValue: TGlobalSettingsBase): TSettingsSettingsItem;
begin
  Result := Search(AName) as TSettingsSettingsItem;
  if Result<>nil then
    Result.Value := AValue
end;
}



{ TGlobalSettingsBaseProp }

{
procedure TGlobalSettingsBaseProp.Clear;
begin
  FSearchId.Clear;
  FSearchName.Clear;
  FGenerId := 0;
end;

procedure TGlobalSettingsBaseProp.CopyFrom(ASource: TGlobalSettingsBaseProp);
begin
  Clear;
  FDontNotify := ASource.FDontNotify;
  FNotifyHandle := ASource.FNotifyHandle;
  FRaiseIfNotFound := ASource.FRaiseIfNotFound;
  FAddIfNotFound := ASource.FAddIfNotFound;
end;
}

constructor TGlobalSettingsBaseProp.Create;
begin
  FSearchId   := TIntegerAssociationList.Create;
  FSearchName := TStringAssociationList.Create(False);
end;

destructor TGlobalSettingsBaseProp.Destroy;
begin
  FreeAndNil(FSearchName);
  FreeAndNil(FSearchId);
  inherited;
end;

{ TGlobalSettings }

constructor TGlobalSettingsBase.Create(AOwner: TGlobalSettingsBase);
begin
  if Assigned(AOwner) then
  begin
    FChild := True;
    FProperty := AOwner.FProperty;
  end
  else
  begin
    FChild := False;
    FProperty := TGlobalSettingsBaseProp.Create;
  end;
  //---
  FLockObj := TMultiReadExclusiveWriteSynchronizer.Create;
  //---
  FBoolList     := TSettingsBoolList.Create('Bools');
  FAStrList     := TSettingsAStrList.Create('AStrs');
  FUStrList     := TSettingsUStrList.Create('UStrs');
  FIntList      := TSettingsIntList.Create('Ints');
  FAStringsList := TSettingsAStringsList.Create('AStrings');
  FUStringsList := TSettingsUStringsList.Create('UStrings');
  FSettingsList := TSettingsSettingsList.Create('Settings');
  //---
  FListList := TSettingsBaseListList.Create;
  FListList.Add(FBoolList);
  FListList.Add(FAStrList);
  FListList.Add(FUStrList);
  FListList.Add(FIntList);
  FListList.Add(FAStringsList);
  FListList.Add(FUStringsList);
  FListList.Add(FSettingsList);
end;

destructor TGlobalSettingsBase.Destroy;
begin
  {$IFDEF DEBUG}
  FreeAndNil(FSettingsList);
  FreeAndNil(FUStringsList);
  FreeAndNil(FAStringsList);
  FreeAndNil(FBoolList);
  FreeAndNil(FAStrList);
  FreeAndNil(FUStrList);
  FreeAndNil(FIntList);
  FreeAndNil(FListList);
  FreeAndNil(FLockObj);
  if not FChild then
    FreeAndNil(FProperty);
  {$ENDIF}
  inherited;
end;


procedure TGlobalSettingsBase._Clear;
var A: TSettingsBaseList;
begin
//  FProperty.Clear;
  for A in FListList do
    A.Clear;
end;

procedure TGlobalSettingsBase.Clear;
begin
  FLockObj.BeginWrite;
  try
    _Clear;
  finally
    FLockObj.EndWrite;
  end;
end;
{
procedure TGlobalSettingsBase.CopyFrom(ASource: TGlobalSettingsBase);

  procedure __addsearchitems(AList: TSettingsBaseList);
  var A: TSettingsBaseItem;
  begin
    for A in AList do
      _AddSearch(A);      
  end;

var
  A: TSettingsBaseList;
  B: TSettingsBaseList;
  j: Integer;
  n: Boolean;
begin
  if Assigned(ASource) then
  begin
    FLockObj.BeginWrite;
    try
      _Clear;
      //---
      FProperty.CopyFrom(ASource.FProperty);
      n := FProperty.DontNotify;
      FProperty.DontNotify := True;
      //---
      Assert(ASource.FListList.Count = FListList.Count);
      for j:=0 to FListList.Count-1 do
      begin
        A := FListList[j];
        B := ASource.FListList[j];
        A.CopyFrom(B);
      end;
      //---
      for A in FListList do
        __addsearchitems(A);
      //---
      FProperty.DontNotify := n;
    finally
      FLockObj.EndWrite;
    end;
  end
end;
}
procedure TGlobalSettingsBase.IniRead(AIni: TCustomIniFile);
var A: TSettingsBaseList;
begin
  for A in FListList do
    A.IniRead(AIni)
end;

procedure TGlobalSettingsBase.IniWrite(AIni: TCustomIniFile);
var A: TSettingsBaseList;
begin
  for A in FListList do
    A.IniWrite(AIni)
end;

procedure TGlobalSettingsBase.Load;
var A: TSettingsBaseList;
begin
  for A in FListList do
    A.Load();
end;

procedure TGlobalSettingsBase.Save;
var A: TSettingsBaseList;
begin
  for A in FListList do
    A.Save();
end;

procedure TGlobalSettingsBase.LockGlobal;
begin
  FLockObj.BeginWrite;
end;

procedure TGlobalSettingsBase.UnLockGlobal;
begin
  FLockObj.EndWrite;
end;

{
не используется - procedure TGlobalSettingsBase._Notify(const AID: Integer);
begin
  if (not DontNotify) and (NotifyHandle<>INVALID_HANDLE_VALUE) then
    PostMessage(NotifyHandle, WM_USER, WM_UPDATE_SETTINGS, AID)
end;
}

procedure TGlobalSettingsBase._NotifyA(const A: TSettingsBaseItem);
begin
  if (not DontNotify) and (NotifyHandle<>INVALID_HANDLE_VALUE) then
    PostMessage(NotifyHandle, WM_USER, WM_UPDATE_SETTINGSA, Integer(A))
end;

procedure TGlobalSettingsBase.NotifyChange(AIDs: array of Integer);
var
  L: TIntegerList;
  j: Integer;
begin
  if (not DontNotify) and (NotifyHandle<>INVALID_HANDLE_VALUE) then
  begin
    L := TIntegerList.Create(Length(AIDs));
    for j:=Low(AIDs) to High(AIDs) do
      L.Add(AIDs[j]);
    //---
    PostMessage(NotifyHandle, WM_USER, WM_UPDATE_FEWSETTINGS, Integer(L))
  end;              
end;

procedure TGlobalSettingsBase.NotifyChangeA(AItemList: array of TSettingsBaseItem);
var
  j: Integer;
  L: TSettingsSimpleList;
begin
  if (not DontNotify) and (NotifyHandle<>INVALID_HANDLE_VALUE) then
  begin
    L := TSettingsSimpleList.Create;
    L.Capacity := Length(AItemList);
    for j:=Low(AItemList) to High(AItemList) do
      L.Add(AItemList[j]);
    //---
    PostMessage(NotifyHandle, WM_USER, WM_UPDATE_FEWSETTINGSA, Integer(L))
  end;
end;

function TGlobalSettingsBase.GenerId: Integer;
begin
  Result := InterlockedIncrement(FProperty.FGenerId);
  Result := Result or GENERID_MASK;
end;

function TGlobalSettingsBase._AddSearchList(const ASearchList: TSettingsBaseList;
  const AListItem: TSettingsBaseItem): TSettingsBaseItem;

  procedure _AddSearch(AItem: TSettingsBaseItem);
  var lExistsItem: TSettingsBaseItem;
  begin
    if Assigned(AItem) then
    begin
      lExistsItem := FProperty.SearchId.Items[AItem.Id];
      if not Assigned(lExistsItem) then
      begin
        FProperty.SearchId.Add(AItem.Id, AItem);
        if AItem.Name<>'' then
          FProperty.SearchName.Add(AItem.Name, AItem);
        //---
        _NotifyA(AItem);
      end
        else
      begin
        raise EGlobalSettingsError.CreateFmt(
          'Can''t add settings item - id #%d already exists.'#13#10+
            'Exists Item:'#13#10+
            '%s'#13#10+
            'New Item:'#13#10+
            '%s',
          [AItem.Id, AItem._Dump(), lExistsItem._Dump()]
        );
      end;
    end
  end;

  procedure _RemSearch(AItem: TSettingsBaseItem);
  begin
    if Assigned(AItem) then
    begin
      FProperty.SearchId.Remove(AItem.Id);
      FProperty.SearchName.Remove(AItem.Name);
    end
  end;

begin
  Result := AListItem;
  FLockObj.BeginWrite;
  try
    try
      _AddSearch(Result);
      ASearchList.AddItem(Result);
    except
      _RemSearch(Result);
      ASearchList.DelItem(Result);
      FreeAndNil(Result);
      raise;
    end;
  finally
    FLockObj.EndWrite
  end;
end;



procedure TGlobalSettingsBase._ShowDump;
var f: TFileName;
begin
  f := gDirApp + 'globset.json';
  StringSaveToFile(f, RawByteString(_Dump()));
  ShellExecute(0, 'open', PChar(f), nil, nil, SW_SHOWNORMAL)
end;

function TGlobalSettingsBase._Dump: UTF8String;
begin
  Result := FListList._Dump()
end;




function TGlobalSettingsBase._AddBool(const AID: Integer; const AValue: Boolean;
  const AName: AnsiString; const AIniName, AIniSection: string): TSettingsBoolItem;
begin
  Result := TSettingsBoolItem.Create(AID, AName, AIniName, AIniSection, '');
  Result.Value := AValue;
  Result := _AddSearchList(FBoolList, Result) as TSettingsBoolItem;
end;

function TGlobalSettingsBase._AddInt(const AID: Integer; const AValue: Int64;
  const AName: AnsiString; const AIniName, AIniSection: string): TSettingsIntItem;
begin
  Result := TSettingsIntItem.Create(AID, AName, AIniName, AIniSection, '');
  Result.Value := AValue;
  Result := _AddSearchList(FIntList, Result) as TSettingsIntItem;
end;

function TGlobalSettingsBase._AddAStr(const AItem: TSettingsAStrItem): TSettingsAStrItem;
begin
  Result := _AddSearchList(FAStrList, AItem) as TSettingsAStrItem;
end;

function TGlobalSettingsBase._AddAStr(const AID: Integer;
  const AValue, AName: AnsiString; const AIniName, AIniSection: string;
  const AFileName: TFileName): TSettingsAStrItem;
begin
  Result := TSettingsAStrItem.Create(AID, AName, AIniName, AIniSection, AFileName);
  Result.Value := AValue;
  Result := _AddAStr(Result);
end;

function TGlobalSettingsBase._AddUStr(const AID: Integer; const AValue: UnicodeString;
  const AName: AnsiString; const AIniName, AIniSection: string;
  const AFileName: TFileName): TSettingsUStrItem;
begin
  Result := TSettingsUStrItem.Create(AID, AName, AIniName, AIniSection, AFileName);
  Result.Value := AValue;
  Result := _AddSearchList(FUStrList, Result) as TSettingsUStrItem;
end;

function TGlobalSettingsBase._AddAStrings(const AID: Integer;
  const AValue: AnsiString; AStrict: Boolean; const AName: AnsiString;
  const AFileName: TFileName): TSettingsAStringsItem;
begin
  Result := TSettingsAStringsItem.Create(AID, AName, AFileName, AStrict);
  if AValue<>'' then
    Result.Text := AValue;
  Result := _AddSearchList(FAStringsList, Result) as TSettingsAStringsItem;
end;

function TGlobalSettingsBase._AddUStrings(const AID: Integer;
  const AValue: UnicodeString; AStrict: Boolean; const AName: AnsiString;
  const AFileName: TFileName): TSettingsUStringsItem;
begin
  Result := TSettingsUStringsItem.Create(AID, AName, AFileName, AStrict);
  if AValue<>'' then
    Result.Text := AValue;
  Result := _AddSearchList(FUStringsList, Result) as TSettingsUStringsItem;
end;

function TGlobalSettingsBase._AddSettings(const AID: Integer; const AName: AnsiString;
  const AIniName, AIniSection: string): TSettingsSettingsItem;
begin
  Result := TSettingsSettingsItem.Create(AID, AName, AIniName, AIniSection, '');
  Result.FValue := TGlobalSettingsBase.Create(Self);
  Result := _AddSearchList(FSettingsList, Result) as TSettingsSettingsItem;
end;




function TGlobalSettingsBase._NotFoundBool(const AName: AnsiString;
  const AValue: Boolean): Boolean;
begin
  Result := AValue;
  if AddIfNotFound then
    _AddBool(GenerId(), AValue, AName, '', '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Name #%s not found in %s', [AName, FBoolList.ListName]);
end;

function TGlobalSettingsBase._NotFoundBool(const AID: Integer;
  const AValue: Boolean): Boolean;
begin
  Result := AValue;
  if AddIfNotFound then
    _AddBool(AId, AValue, '', '', '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Id #%d not found in %s', [AId, FBoolList.ListName])
end;

function TGlobalSettingsBase._NotFoundInt(const AName: AnsiString; out AOut: Int64;
  const AValue: Int64): TSettingsIntItem;
begin
  AOut := AValue;
  Result := nil;
  if AddIfNotFound then
    Result := _AddInt(GenerId(), AValue, AName, '', '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Name #%s not found in %s', [AName, FIntList.ListName]);
end;

function TGlobalSettingsBase._NotFoundInt(const AID: Integer; out AOut: Int64;
  const AValue: Int64): TSettingsIntItem;
begin
  AOut := AValue;
  Result := nil;
  if AddIfNotFound then
    Result := _AddInt(AId, AValue, '', '', '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Id #%d not found in %s', [AId, FIntList.ListName])
end;

function TGlobalSettingsBase._NotFoundAStr(const AID: Integer;
  const AValue: AnsiString): AnsiString;
begin
  Result := AValue;
  if AddIfNotFound then
    _AddAStr(AId, AValue, '', '', '', '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Id #%d not found in %s', [AId, FAStrList.ListName])
end;

function TGlobalSettingsBase._NotFoundAStr(const AName, AValue: AnsiString): AnsiString;
begin
  Result := AValue;
  if AddIfNotFound then
    _AddAStr(GenerId(), AValue, AName, '', '', '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Name #%s not found in %s', [AName, FAStrList.ListName])
  else
    Result := ''
end;

function TGlobalSettingsBase._NotFoundUStr(const AID: Integer;
  const AValue: UnicodeString): UnicodeString;
begin
  Result := AValue;
  if AddIfNotFound then
    _AddUStr(AId, AValue, '', '', '', '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Id #%d not found in %s', [AId, FUStrList.ListName])
  else
    Result := ''
end;

function TGlobalSettingsBase._NotFoundUStr(const AName: AnsiString;
  const AValue: UnicodeString): UnicodeString;
begin
  Result := AValue;
  if AddIfNotFound then
    _AddUStr(GenerId(), AValue, AName, '', '', '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Name #%s not found in %s', [AName, FUStrList.ListName])
  else
    Result := ''
end;

function TGlobalSettingsBase._NotFoundSettings(const AID: Integer): TGlobalSettingsBase;
begin
  if AddIfNotFound then
    Result := _AddSettings(AId, '', '', '').Value
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Id #%d not found in %s', [AId, FSettingsList.ListName])
  else
    Result := nil
end;

function TGlobalSettingsBase._NotFoundSettings(const AName: AnsiString): TGlobalSettingsBase;
begin
  if AddIfNotFound then
    Result := _AddSettings(GenerId(), AName, '', '').Value
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Name #%s not found in %s', [AName, FSettingsList.ListName])
  else
    Result := nil
end;

function TGlobalSettingsBase._NotFoundAStrings(const AID: Integer): TSettingsAStringsItem;
begin
  if AddIfNotFound then
    Result := _AddAStrings(AId, '', False, '', '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Id #%d not found in %s', [AId, FAStringsList.ListName])
  else
    Result := nil
end;

function TGlobalSettingsBase._NotFoundAStrings(const AName: AnsiString): TSettingsAStringsItem;
begin
  if AddIfNotFound then
    Result := _AddAStrings(GenerId(), '', False, AName, '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Name #%s not found in %s', [AName, FAStringsList.ListName])
  else
    Result := nil
end;

function TGlobalSettingsBase._NotFoundUStrings(const AID: Integer): TSettingsUStringsItem;
begin
  if AddIfNotFound then
    Result := _AddUStrings(AId, '', False, '', '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Id #%d not found in %s', [AId, FUStringsList.ListName])
  else
    Result := nil
end;

function TGlobalSettingsBase._NotFoundUStrings(const AName: AnsiString): TSettingsUStringsItem;
begin
  if AddIfNotFound then
    Result := _AddUStrings(GenerId(), '', False, AName, '')
  else if RaiseIfNotFound then
    raise EGlobalSettingsError.CreateFmt('Name #%s not found in %s', [AName, FUStringsList.ListName])
  else
    Result := nil
end;




function TGlobalSettingsBase.AddBool(const AID: Integer; const AValue: Boolean;
  const AIniName, AIniSection: string): TSettingsBoolItem;
begin
  Result := _AddBool(AId, AValue, '', AIniName, AIniSection);
end;
function TGlobalSettingsBase.AddBool(const AName: AnsiString; const AValue: Boolean;
  const AIniName, AIniSection: string): TSettingsBoolItem;
begin
  Result := _AddBool(GenerId(), AValue, AName, AIniName, AIniSection);
end;

function TGlobalSettingsBase.AddInt(const AID: Integer; const AValue: Int64;
  const AIniName, AIniSection: string): TSettingsIntItem;
begin
  Result := _AddInt(AId, AValue, '', AIniName, AIniSection);
end;
function TGlobalSettingsBase.AddInt(const AName: AnsiString; const AValue: Int64;
  const AIniName, AIniSection: string): TSettingsIntItem;
begin
  Result := _AddInt(GenerId(), AValue, AName, AIniName, AIniSection);
end;

function TGlobalSettingsBase.AddStr(const AID: Integer; const AValue: string;
  const AIniName, AIniSection: string; const AFileName: TFileName): TSettingsStrItem;
begin
  {$IFDEF UNICODE}
    Result := _AddUStr(AId, AValue, '', AIniName, AIniSection, AFileName);
  {$ELSE}
    Result := _AddAStr(AId, AValue, '', AIniName, AIniSection, AFileName);
  {$ENDIF}
end;
function TGlobalSettingsBase.AddStr(const AName: AnsiString; const AValue: string;
  const AIniName, AIniSection: string; const AFileName: TFileName): TSettingsStrItem;
begin
  {$IFDEF UNICODE}
    Result := _AddUStr(GenerId(), AValue, AName, AIniName, AIniSection, AFileName);
  {$ELSE}
    Result := _AddAStr(GenerId(), AValue, AName, AIniName, AIniSection, AFileName);
  {$ENDIF}
end;

function TGlobalSettingsBase.AddAStr(const AID: Integer; const AValue: AnsiString;
  const AIniName, AIniSection: string; const AFileName: TFileName): TSettingsAStrItem;
begin
  Result := _AddAStr(AId, AValue, '', AIniName, AIniSection, AFileName);
end;
function TGlobalSettingsBase.AddAStr(const AName: AnsiString; const AValue: AnsiString;
  const AIniName, AIniSection: string; const AFileName: TFileName): TSettingsAStrItem;
begin
  Result := _AddAStr(GenerId(), AValue, AName, AIniName, AIniSection, AFileName);
end;

function TGlobalSettingsBase.AddUStr(const AID: Integer; const AValue: UnicodeString;
  const AIniName, AIniSection: string; const AFileName: TFileName): TSettingsUStrItem;
begin
  Result := _AddUStr(AId, AValue, '', AIniName, AIniSection, AFileName);
end;
function TGlobalSettingsBase.AddUStr(const AName: AnsiString; const AValue: UnicodeString;
  const AIniName, AIniSection: string; const AFileName: TFileName): TSettingsUStrItem;
begin
  Result := _AddUStr(GenerId(), AValue, AName, AIniName, AIniSection, AFileName);
end;

function TGlobalSettingsBase.AddStrings(const AID: Integer; const AValue: string;
  AStrict: Boolean; const AFileName: TFileName): TSettingsStringsItem;
begin
  {$IFDEF UNICODE}
    Result := _AddUStrings(AId, AValue, AStrict, '', AFileName);
  {$ELSE}
    Result := _AddAStrings(AId, AValue, AStrict, '', AFileName);
  {$ENDIF}
end;
function TGlobalSettingsBase.AddStrings(const AName: AnsiString; const AValue: string;
  AStrict: Boolean; const AFileName: TFileName): TSettingsStringsItem;
begin
  {$IFDEF UNICODE}
    Result := _AddUStrings(GenerId(), AValue, AStrict, AName, AFileName);
  {$ELSE}
    Result := _AddAStrings(GenerId(), AValue, AStrict, AName, AFileName);
  {$ENDIF}
end;

function TGlobalSettingsBase.AddAStrings(const AID: Integer; const AValue: AnsiString;
  AStrict: Boolean; const AFileName: TFileName): TSettingsAStringsItem;
begin
  Result := _AddAStrings(AId, AValue, AStrict, '', AFileName);
end;
function TGlobalSettingsBase.AddAStrings(const AName: AnsiString; const AValue: AnsiString;
  AStrict: Boolean; const AFileName: TFileName): TSettingsAStringsItem;
begin
  Result := _AddAStrings(GenerId(), AValue, AStrict, AName, AFileName);
end;

function TGlobalSettingsBase.AddUStrings(const AID: Integer; const AValue: UnicodeString;
  AStrict: Boolean; const AFileName: TFileName): TSettingsUStringsItem;
begin
  Result := _AddUStrings(AId, AValue, AStrict, '', AFileName);
end;
function TGlobalSettingsBase.AddUStrings(const AName: AnsiString; const AValue: UnicodeString;
  AStrict: Boolean; const AFileName: TFileName): TSettingsUStringsItem;
begin
  Result := _AddUStrings(GenerId(), AValue, AStrict, AName, AFileName);
end;

function TGlobalSettingsBase.AddSettings(const AID: Integer;
  const AIniName, AIniSection: string): TSettingsSettingsItem;
begin
  Result := _AddSettings(AId, '', AIniName, AIniSection);
end;
function TGlobalSettingsBase.AddSettings(const AName: AnsiString;
  const AIniName, AIniSection: string): TSettingsSettingsItem;
begin
  Result := _AddSettings(GenerId(), AName, AIniName, AIniSection);
end;



function TGlobalSettingsBase.GetBoolById(AId: Integer): Boolean;
begin
  FLockObj.BeginRead;
  try
    if FBoolList.GetValue(AId, Result) = nil then
      Result := _NotFoundBool(AId)
  finally
    FLockObj.EndRead;
  end;
end;

function TGlobalSettingsBase.GetBoolByName(const AName: AnsiString): Boolean;
begin
  FLockObj.BeginRead;
  try
    if FBoolList.GetValue(AName, Result) = nil then
      Result := _NotFoundBool(AName)
  finally
    FLockObj.EndRead;
  end;
end;

function TGlobalSettingsBase.GetIntById(AId: Integer): Int64;
var A: TSettingsIntItem;
begin
  A := GetIntItemById(AId);
  if Assigned(A) then
    Result := A.Value
  else
    Result := INT_DEFAULT_VALUE
end;

function TGlobalSettingsBase.GetIntByName(const AName: AnsiString): Int64;
var tmp: Int64;
begin
  FLockObj.BeginRead;
  try
    if FIntList.GetValue(AName, Result) = nil then
      _NotFoundInt(AName, tmp)
  finally
    FLockObj.EndRead;
  end;
end;

function TGlobalSettingsBase.GetAStrById(AId: Integer): AnsiString;
begin
  FLockObj.BeginRead;
  try
    if FAStrList.GetValue(AId, Result) = nil then
      Result := _NotFoundAStr(AId)
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.GetAStrByName(const AName: AnsiString): AnsiString;
begin
  FLockObj.BeginRead;
  try
    if FAStrList.GetValue(AName, Result) = nil then
    begin
      Result := _NotFoundAStr(AName);
    end;
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.GetUStrById(AId: Integer): UnicodeString;
begin
  FLockObj.BeginRead;
  try
    if FUStrList.GetValue(AId, Result) = nil then
      Result := _NotFoundUStr(AId)
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.GetUStrByName(const AName: AnsiString): UnicodeString;
begin
  FLockObj.BeginRead;
  try
    if FUStrList.GetValue(AName, Result) = nil then
      Result := _NotFoundUStr(AName)
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.GetAStringsById(AId: Integer): TSettingsAStringsItem;
begin
  FLockObj.BeginRead;
  try
    Result := FAStringsList.GetValue(AId);
    if not Assigned(Result) then
      Result := _NotFoundAStrings(AId)
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.GetAStringsByName(const AName: AnsiString): TSettingsAStringsItem;
begin
  FLockObj.BeginRead;
  try
    Result := FAStringsList.GetValue(AName);
    if not Assigned(Result) then
      Result := _NotFoundAStrings(AName)
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.GetUStringsById(AId: Integer): TSettingsUStringsItem;
begin
  FLockObj.BeginRead;
  try
    Result := FUStringsList.GetValue(AId);
    if not Assigned(Result) then
      Result := _NotFoundUStrings(AId)
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.GetUStringsByName(const AName: AnsiString): TSettingsUStringsItem;
begin
  FLockObj.BeginRead;
  try
    Result := FUStringsList.GetValue(AName);
    if not Assigned(Result) then
      Result := _NotFoundUStrings(AName)
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.GetSettingsById(AId: Integer): TGlobalSettingsBase;
begin
  FLockObj.BeginRead;
  try
    if FSettingsList.GetValue(AId, Result) = nil then
      Result := _NotFoundSettings(AId)
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.GetSettingsByName(
  const AName: AnsiString): TGlobalSettingsBase;
begin
  FLockObj.BeginRead;
  try
    if FSettingsList.GetValue(AName, Result) = nil then
      Result := _NotFoundSettings(AName)
  finally
    FLockObj.EndRead;
  end
end;




procedure TGlobalSettingsBase.SetBoolById(AId: Integer; const Value: Boolean);
var A: TSettingsBaseItem;
begin
  FLockObj.BeginRead;
  try
    A := FBoolList.SetValue(AId, Value);
    if Assigned(A) then
      _NotifyA(A)
    else
      _NotFoundBool(AId, Value)
  finally
    FLockObj.EndRead;
  end
end;

procedure TGlobalSettingsBase.SetBoolByName(const AName: AnsiString;
  const Value: Boolean);
var A: TSettingsBaseItem;
begin
  FLockObj.BeginRead;
  try
    A := FBoolList.SetValue(AName, Value);
    if Assigned(A) then
      _NotifyA(A)
    else
      _NotFoundBool(AName, Value)
  finally
    FLockObj.EndRead;
  end
end;

procedure TGlobalSettingsBase.SetIntById(AId: Integer; const Value: Int64);
var A: TSettingsBaseItem;
  tmp: Int64;
begin
  FLockObj.BeginRead;
  try
    A := FIntList.SetValue(AId, Value);
    if Assigned(A) then
      _NotifyA(A)
    else
      _NotFoundInt(AId, tmp, Value)
  finally
    FLockObj.EndRead;
  end
end;

procedure TGlobalSettingsBase.SetIntByName(const AName: AnsiString;
  const Value: Int64);
var A: TSettingsBaseItem;
  tmp: Int64;
begin
  FLockObj.BeginRead;
  try
    A := FIntList.SetValue(AName, Value);
    if Assigned(A) then
      _NotifyA(A)
    else
      _NotFoundInt(AName, tmp, Value)
  finally
    FLockObj.EndRead;
  end
end;

procedure TGlobalSettingsBase.SetAStrById(AId: Integer; const Value: AnsiString);
var A: TSettingsBaseItem;
begin
  FLockObj.BeginRead;
  try
    A := FAStrList.SetValue(AId, Value);
    if Assigned(A) then
      _NotifyA(A)
    else
      _NotFoundAStr(AId, Value)
  finally
    FLockObj.EndRead;
  end
end;

procedure TGlobalSettingsBase.SetAStrByName(const AName, Value: AnsiString);
var A: TSettingsBaseItem;
begin
  FLockObj.BeginRead;
  try
    A := FAStrList.SetValue(AName, Value);
    if Assigned(A) then
      _NotifyA(A)
    else
      _NotFoundAStr(AName, Value)
  finally
    FLockObj.EndRead;
  end
end;

procedure TGlobalSettingsBase.SetUStrByName(const AName: AnsiString; const Value: UnicodeString);
var A: TSettingsBaseItem;
begin
  FLockObj.BeginRead;
  try
    A := FUStrList.SetValue(AName, Value);
    if Assigned(A) then
      _NotifyA(A)
    else
      _NotFoundUStr(AName, Value)
  finally
    FLockObj.EndRead;
  end
end;

procedure TGlobalSettingsBase.SetUStrById(AId: Integer; const Value: UnicodeString);
var A: TSettingsBaseItem;
begin
  FLockObj.BeginRead;
  try
    A := FUStrList.SetValue(AId, Value);
    if Assigned(A) then
      _NotifyA(A)
    else
      _NotFoundUStr(AId, Value)
  finally
    FLockObj.EndRead;
  end
end;



function TGlobalSettingsBase.GetIntItemById(AId: Integer): TSettingsIntItem;
var tmp: Int64;
begin
  FLockObj.BeginRead;
  try
    Result := FIntList.Search(AId) as TSettingsIntItem;
    if Result = nil then
      Result := _NotFoundInt(AId, tmp)
  finally
    FLockObj.EndRead;
  end;
end;




function TGlobalSettingsBase.Search(AId: Integer): TSettingsBaseItem;
begin
  FLockObj.BeginRead;
  try
    Result := FProperty.SearchId.Items[AId]
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.Search(AId: Integer;
  var AOutItem: TSettingsBaseItem): Boolean;
begin
  AOutItem := Search(AID);
  Result := Assigned(AOutItem)
end;

function TGlobalSettingsBase.Search(const AName: AnsiString): TSettingsBaseItem;
begin
  FLockObj.BeginRead;
  try
    Result := FProperty.SearchName.Items[AName]
  finally
    FLockObj.EndRead;
  end
end;

function TGlobalSettingsBase.Search(const AName: AnsiString;
  var AOutItem: TSettingsBaseItem): Boolean;
begin
  AOutItem := Search(AName);
  Result := Assigned(AOutItem)
end;




function TGlobalSettingsBase.GetDontNotify: Boolean;
begin
  Result := FProperty.DontNotify;
end;

function TGlobalSettingsBase.GetNotifyHandle: THandle;
begin
  Result := FProperty.NotifyHandle;
end;

function TGlobalSettingsBase.GetRaiseIfNotFound: Boolean;
begin
  Result := FProperty.RaiseIfNotFound;
end;

function TGlobalSettingsBase.GetAddIfNotFound: Boolean;
begin
  Result := FProperty.AddIfNotFound;
end;

procedure TGlobalSettingsBase.SetDontNotify(AValue: Boolean);
begin
  FProperty.DontNotify := AValue
end;

procedure TGlobalSettingsBase.SetNotifyHandle(AValue: THandle);
begin
  FProperty.NotifyHandle := AValue
end;

procedure TGlobalSettingsBase.SetRaiseIfNotFound(AValue: Boolean);
begin
  FProperty.RaiseIfNotFound := AValue
end;


procedure TGlobalSettingsBase.SetAddIfNotFound(AValue: Boolean);
begin
  FProperty.AddIfNotFound := AValue
end;

function TGlobalSettingsBase.GetProp: TGlobalSettingsBaseProp;
begin
  Result := FProperty
end;

procedure TGlobalSettingsBase.SetProp(AValue: TGlobalSettingsBaseProp);
begin
  if AValue<>nil then
  begin
    FreeAndNil(FProperty);
    FProperty := AValue;
  end;
end;


end.
