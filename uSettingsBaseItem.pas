unit uSettingsBaseItem;

interface

uses
  SysUtils, Classes, SyncObjs, IniFiles, AcedStrings, AcedContainers,
  uGlobalTypes,
  {$IFDEF UNICODE}
    Generics.Collections
  {$ELSE}
    Contnrs
  {$ENDIF}
  ;

const
  DEFAULT_INI_SECTION = 'Settings';
  GENERID_MASK = Integer(1 shl 30);

type
  ESettingsBaseError = class(Exception);

  TSettingsBaseItem = class
  private
    FID: Integer;
    FName: AnsiString;
    FIniName: string;
    FIniSection: string;
    FFileName: TFileName;
    //---
    function GetIniName: string;
    function GetIniSection: string;
    function GetFileName: TFileName;
  protected
    //---
    function GetAsInt: Int64; virtual; abstract;
    procedure SetAsInt(const AValue: Int64); virtual; abstract;
    function GetAsAText: AnsiString; virtual; abstract;
    procedure SetAsAText(const AValue: AnsiString); virtual; abstract;
    function GetAsBool: Boolean; virtual; abstract;
    procedure SetAsBool(const AValue: Boolean); virtual; abstract;
    {$IFDEF UNICODE}
      function GetAsUText: UnicodeString; virtual; abstract;
      procedure SetAsUText(const AValue: UnicodeString); virtual; abstract;
    {$ENDIF}
  public
    constructor Create(const AID: Integer; const AName: AnsiString;
      const AIniName, AIniSection: string;
      const AFileName: TFileName); overload;
    constructor Create(ACopySource: TSettingsBaseItem); overload;
    destructor Destroy; override; // reintroduce???
    //---
    function _Dump: UTF8String; virtual;
//    function Clone(): TSettingsBaseItem; virtual; abstract;
    //---
    property ID: Integer read FID;
    property Name: AnsiString read FName;
    property IniName: string read GetIniName;
    property IniSection: string read GetIniSection;
    property FileName: TFileName read GetFileName;
    //---
    property AsAText: AnsiString read GetAsAText write SetAsAText;
    {$IFDEF UNICODE}
      property AsText: string read GetAsUText write SetAsUText;
      property AsUText: UnicodeString read GetAsUText write SetAsUText;
    {$ELSE}
      property AsText: string read GetAsAText write SetAsAText;
      property AsUText: UnicodeString read GetAsAText write SetAsAText;
    {$ENDIF}
    property AsInt: Int64 read GetAsInt write SetAsInt;
    property AsBool: Boolean read GetAsBool write SetAsBool;
  end;

  TSettingsBaseItemA = class(TSettingsBaseItem)
  protected
    FLockObj: TCriticalSection;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
  end;
  TSettingsBaseItemB = class(TSettingsBaseItem)
  protected
    FRwLockObj: TMultiReadExclusiveWriteSynchronizer;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
  end;


  TSettingsBaseList = class;

  TSettingsBaseListEnumerator = class
  private
    FIndex: Integer;
    FList: TSettingsBaseList;
  public
    constructor Create(AList: TSettingsBaseList);
    function  GetCurrent: TSettingsBaseItem;
    function  MoveNext: Boolean;
    property Current: TSettingsBaseItem read GetCurrent;
  end;

  TSettingsBaseList = class
  private
    FItems: TIntegerAssociationList;
    FNames: TStringAssociationList;
    FListName: AnsiString;
  public
    constructor Create(const AName: AnsiString);
    destructor Destroy; override;
    function GetEnumerator: TSettingsBaseListEnumerator;
    //---
    function _Dump: UTF8String; virtual;
    //---
    procedure AddItem(AItem: TSettingsBaseItem);
    procedure DelItem(AItem: TSettingsBaseItem);
    function Search(AId: Integer): TSettingsBaseItem; overload;
    function Search(const AName: AnsiString): TSettingsBaseItem; overload;
    function Search(AId: Integer; var AOutItem: TSettingsBaseItem): Boolean; overload;
    function Search(const AName: AnsiString; var AOutItem: TSettingsBaseItem): Boolean; overload;
    procedure IniRead(AIni: TCustomIniFile); virtual;
    procedure IniWrite(AIni: TCustomIniFile); virtual;
    procedure Load; virtual;
    procedure Save; virtual;
    procedure Clear;
//    procedure CopyFrom(const ASource: TSettingsBaseList);
    //---
    property ListName: AnsiString read FListName;
  end;

  TSettingsBaseListList = class;
  
  TSettingsBaseListListEnumerator = class
  private
    FIndex: Integer;
    FList: TSettingsBaseListList;
  public
    constructor Create(AList: TSettingsBaseListList);
    function  GetCurrent: TSettingsBaseList;
    function  MoveNext: Boolean;
    property Current: TSettingsBaseList read GetCurrent;
  end;

  TSettingsBaseListList = class(TList)
  public
    function GetEnumerator: TSettingsBaseListListEnumerator;
    function _Dump(): UTF8String;
  end;


{$IFDEF UNICODE}
  TSettingsSimpleList = TList<TSettingsBaseItem>;
{$ELSE}
  TSettingsSimpleList = class(TList)
  protected
    function GetItem(AIndex: Integer): TSettingsBaseItem;
    procedure SetItem(AIndex: Integer; AItem: TSettingsBaseItem);
  public
    function Add(AItem: TSettingsBaseItem): Integer;
    property Items[AIndex: Integer]: TSettingsBaseItem read GetItem write SetItem; default;
  end;
{$ENDIF}


implementation

uses uGlobalFunctions, uGlobalVars;

{ TSettingsBaseItem }

constructor TSettingsBaseItem.Create(const AID: Integer;
  const AName: AnsiString; const AIniName, AIniSection: string;
   const AFileName: TFileName);
begin
  if AID<=0 then
    raise ESettingsBaseError.Create('ID must be greater than zero');
  if ((AID and GENERID_MASK)<>0) and (AName='') then
    raise ESettingsBaseError.Create('Name must be nonempty');
  //---
  FID := AID;
  FName := AName;
  FIniName := AIniName;
  FIniSection := AIniSection;
  FFileName := AFileName;
  //---
end;

constructor TSettingsBaseItem.Create(ACopySource: TSettingsBaseItem);
begin
  Create(
    ACopySource.FID,
    ACopySource.FName,
    ACopySource.FIniName,
    ACopySource.FIniSection,
    ACopySource.FFileName
  );
end;

destructor TSettingsBaseItem.Destroy;
begin
  inherited;
end;

function TSettingsBaseItem.GetFileName: TFileName;
begin
  Result := IfElse(FFileName='', '', gDirApp+FFileName)
end;

function TSettingsBaseItem.GetIniName: string;
begin
  if FFileName<>'' then
    Result := ''
  else
   if FIniName<>'' then
     Result := FIniName
   else
     if FName<>'' then
       Result := string(FName)
     else
       Result := ''
end;

function TSettingsBaseItem.GetIniSection: string;
begin
  Result := IfElse(FIniSection='', DEFAULT_INI_SECTION, FIniSection);
end;

function TSettingsBaseItem._Dump: UTF8String;
var S: {$IFDEF UNICODE}SysUtils.{$ENDIF}TStringBuilder;
begin
  S := {$IFDEF UNICODE}SysUtils.{$ENDIF}TStringBuilder.Create(1024);
  try
    S.Append('"ID":').Append(FID);
    if FName<>'' then S.AppendFormat(',"Name":"%s"', [FName]);
    S.Append(',"Value":%s');
    if FFileName<>'' then S.AppendFormat(',"FileName":"%s"', [JsonStringSafe(FFileName)]);
    if FIniName<>'' then S.AppendFormat(',"IniName":"%s"', [FIniName]);
    if FIniSection<>'' then S.AppendFormat(',"IniSection":"%s"', [FIniSection]);
    //---
    Result := UTF8Encode(S.ToString());
  finally
    S.Free
  end;
end;

{ TSettingsBaseItemA }

procedure TSettingsBaseItemA.AfterConstruction;
begin
  inherited;
  FLockObj := TCriticalSection.Create
end;

destructor TSettingsBaseItemA.Destroy;
begin
  FreeAndNil(FLockObj);
  inherited;
end;

{ TSettingsBaseItemB }

procedure TSettingsBaseItemB.AfterConstruction;
begin
  inherited;
  FRwLockObj := TMultiReadExclusiveWriteSynchronizer.Create
end;

destructor TSettingsBaseItemB.Destroy;
begin
  FreeAndNil(FRwLockObj);
  inherited;
end;


{ TSettingsBaseListEnumerator }

constructor TSettingsBaseListEnumerator.Create(AList: TSettingsBaseList);
begin
  inherited Create;
  FIndex := -1;
  FList := AList;
end;

function TSettingsBaseListEnumerator.GetCurrent: TSettingsBaseItem;
begin
  Result := TSettingsBaseItem(FList.FItems.ValueList^[FIndex]);
end;

function TSettingsBaseListEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < (FList.FItems.Count - 1);
  if Result then
    Inc(FIndex);
end;


{ TSettingsBaseList }

constructor TSettingsBaseList.Create(const AName: AnsiString);
begin
  FItems := TIntegerAssociationList.Create;
  FItems.OwnValues := True;
  FNames := TStringAssociationList.Create(False);
  FListName := AName;
end;

destructor TSettingsBaseList.Destroy;
begin
  FreeAndNil(FItems);
  FreeAndNil(FNames);
  inherited;
end;

function TSettingsBaseList.GetEnumerator: TSettingsBaseListEnumerator;
begin
  Result := TSettingsBaseListEnumerator.Create(Self);
end;

procedure TSettingsBaseList.IniRead(AIni: TCustomIniFile);
begin
  {Empty}
end;

procedure TSettingsBaseList.IniWrite(AIni: TCustomIniFile);
begin
  {Empty}
end;

procedure TSettingsBaseList.Load;
begin
  {Empty}
end;

procedure TSettingsBaseList.Save;
begin
  {Empty}
end;

procedure TSettingsBaseList.AddItem(AItem: TSettingsBaseItem);
begin
  if Assigned(AItem) then
  begin
    FItems.Add(AItem.ID, AItem);
    if AItem.Name<>'' then
      FNames.Add(AItem.Name, AItem);
  end;
end;

procedure TSettingsBaseList.DelItem(AItem: TSettingsBaseItem);
begin
  if Assigned(AItem) then
  begin        
    FItems.Remove(AItem.ID);
    FNames.Remove(AItem.Name);
  end;
end;

function TSettingsBaseList.Search(AId: Integer): TSettingsBaseItem;
begin
  Result := FItems.Items[AId]
end;

function TSettingsBaseList.Search(const AName: AnsiString): TSettingsBaseItem;
begin
  Result := FNames.Items[AName]
end;

function TSettingsBaseList.Search(AId: Integer;
  var AOutItem: TSettingsBaseItem): Boolean;
begin
  AOutItem := Search(AId);
  Result := Assigned(AOutItem)
end;

function TSettingsBaseList.Search(const AName: AnsiString;
  var AOutItem: TSettingsBaseItem): Boolean;
begin
  AOutItem := Search(AName);
  Result := Assigned(AOutItem)
end;

procedure TSettingsBaseList.Clear;
begin
  FItems.Clear;
  FNames.Clear;
end;

{
procedure TSettingsBaseList.CopyFrom(const ASource: TSettingsBaseList);
var A: TSettingsBaseItem;
begin
  Clear;
  if Assigned(ASource) then
    for A in ASource do
      AddItem(A.Clone());
end;
 }
 
function TSettingsBaseList._Dump: UTF8String;
var
  A: TSettingsBaseItem;
  R: AcedStrings.TStringBuilder;
begin
  if FItems.Count>0 then
  begin
    R := TStringBuilder.Create(64*FItems.Count);
    try
      R.Append('[');
      for A in Self do
      begin
        if R.Length>1 then
          R.Append(',');
        R.Append('{');
        R.Append(RawByteString(A._Dump()));
        R.Append('}');
      end;
      R.Append(']');
      Result := RawByteString(R.ToString());
      Exit;
    finally
      R.Free
    end;
  end;
  Result := '';
end;

{ TSettingsBaseListListEnumerator }

constructor TSettingsBaseListListEnumerator.Create(
  AList: TSettingsBaseListList);
begin
  inherited Create;
  FIndex := -1;
  FList := AList;
end;

function TSettingsBaseListListEnumerator.GetCurrent: TSettingsBaseList;
begin
  Result := TObject(FList[FIndex]) as TSettingsBaseList;
end;

function TSettingsBaseListListEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < (FList.Count - 1);
  if Result then
    Inc(FIndex);
end;

{ TSettingsBaseListList }

function TSettingsBaseListList.GetEnumerator: TSettingsBaseListListEnumerator;
begin
  Result := TSettingsBaseListListEnumerator.Create(Self);
end;

function TSettingsBaseListList._Dump: UTF8String;
var
  z: AnsiString;
  A: TSettingsBaseList;
  S: TAnsiStringBuilder;
begin
  S := TAnsiStringBuilder.Create(1024);
  try
    S.Append('{');
    for A in Self do
    begin
      z := RawByteString(A._Dump());
      if z<>'' then
      begin
        if S.Length>1 then
          S.Append(',');
        S.Append('"').Append(A.ListName).Append('":').Append(z);
      end;
    end;
    if S.Length=1 then
      S.Clear
    else
      S.Append('}');
    //---
    Result := RawByteString(S.ToString());
  finally
    S.Free
  end;
end;

{ TSettingsSimpleList }

function TSettingsSimpleList.Add(AItem: TSettingsBaseItem): Integer;
begin
  Result := inherited Add(AItem);
end;

function TSettingsSimpleList.GetItem(AIndex: Integer): TSettingsBaseItem;
begin
  Result := inherited Items[AIndex];
end;

procedure TSettingsSimpleList.SetItem(AIndex: Integer;
  AItem: TSettingsBaseItem);
begin
  inherited Items[AIndex] := AItem;
end;


end.
