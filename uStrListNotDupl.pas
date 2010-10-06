unit uStrListNotDupl;

interface

uses Windows, Classes, SysUtils, AcedContainers;

type
  TStrListNotDupl = class(TObject)
  private
    FCaseSensitive: Boolean;
    FArray: TArrayList;
    FCount: Integer;
    function GetItem(const Key: string): Pointer;
  public
    constructor Create(ACaseSensitive:Boolean=False);
    destructor Destroy; override;
    function IndexOf(const aStr: string): Integer; overload;
    function IndexOf(const aStr: string; var OIndex:Integer): Integer; overload;
    function Add(const aStr: string):Boolean; overload;
    function Add(const aStr: string; AValue:Pointer):Boolean; overload;
//    function AddValueIfExists(const AStr: string):Pointer;
    function SearchKey(const AKey:string; var AValue:Integer):Boolean;
    procedure AddStrings(const aStrs: TStrings);
    function Remove(const aStr: string):Boolean;
    procedure LoadFromFile(const aFileName:string);
    procedure SaveToFile(const aFileName:string);
    procedure Clear;
    property Count:Integer read FCount;
//    property NotDupl:Integer read FNotDupl write FNotDupl;
    property Items[const Key: string]: Pointer read GetItem;
  end;

implementation

const
  MAX_LIST_SIZE = 25000;


function TStrListNotDupl.Add(const aStr: string):Boolean;
begin
  Result := Add(aStr, nil)
end;
     
function TStrListNotDupl.Add(const AStr: string;
  AValue: Pointer): Boolean;
var sl : TStringAssociationList;
begin
  Result := False;
  if IndexOf(aStr)=-1 then
  begin
    sl := TStringAssociationList(FArray.PeekBack);
    if sl.Count>=MAX_LIST_SIZE then
      FArray.Add(TStringAssociationList.Create(FCaseSensitive, MAX_LIST_SIZE));
    sl.Add(aStr, AValue);
    Inc(FCount);
    Result := True;
  end
end;

function TStrListNotDupl.Remove(const aStr: string):Boolean;
var
  sl : TStringAssociationList;
  oi, i : Integer;
begin
  Result := False;
  i := IndexOf(aStr, oi);
  if i<>-1 then
  begin
    sl := TStringAssociationList(FArray.ItemList^[oi]);
    sl.RemoveAt(i);
    if sl.Count=0 then
      FArray.RemoveAt(oi) {Delete(oi)};
    Dec(FCount);
    Result := True;
  end
end;

procedure TStrListNotDupl.AddStrings(const aStrs: TStrings);
var j:Integer;
begin
  for j:=0 to aStrs.Count-1 do
    Add(aStrs[j])
end;

procedure TStrListNotDupl.Clear;
begin
  FArray.Clear();
  FArray.Add(TStringAssociationList.Create(FCaseSensitive, MAX_LIST_SIZE));  
end;

constructor TStrListNotDupl.Create(ACaseSensitive:Boolean);
begin
  FCount := 0;
  FCaseSensitive := ACaseSensitive;
  FArray := TArrayList.Create(1024);
  FArray.OwnItems := True;
  Clear();
//  FArray.Add(TStringAssociationList.Create(FCaseSensitive, MAX_LIST_SIZE));
end;

destructor TStrListNotDupl.Destroy;
begin
  FArray.Free;
  inherited;
end;

function TStrListNotDupl.GetItem(const Key: string): Pointer;
var i0,i2:Integer;
begin
  i2 := IndexOf(Key, i0);
  if (i0<>-1) and (i2<>-1) then
    Result := TStringAssociationList(FArray.ItemList^[i0]).ValueList^[i2]
  else
    Result := nil;
end;

function TStrListNotDupl.IndexOf(const aStr: string;
  var OIndex: Integer): Integer;
var
  i,j   : Integer;
  aList : TStringAssociationList;
begin
  Result := -1;
  OIndex := -1;
  for i:=0 to FArray.Count-1 do
  begin
    aList := TStringAssociationList(FArray.ItemList^[i]);
    j := aList.IndexOf(aStr);
    if j<>-1 then
    begin
      Result := j;
      OIndex := i;
      exit;
    end;
  end;
end;

function TStrListNotDupl.IndexOf(const aStr: string): Integer;
var oi:Integer;
begin
  Result := IndexOf(aStr, oi)
end;

procedure TStrListNotDupl.LoadFromFile(const aFileName: string);
var
  f : TextFile;
  z : String;
begin
  Clear();
  if FileExists(aFileName) then
  begin
    AssignFile(f, aFileName);
    Reset(f);
    while not Eof(f) do
    begin
      Readln(f, z);
      Add(z);
    end;
    CloseFile(f);
  end;
end;

procedure TStrListNotDupl.SaveToFile(const aFileName: string);
var
  f : TextFile;
  i : Integer;
  j : Integer;
  l : TStringAssociationList;
begin
  AssignFile(f, aFileName);
  Rewrite(f);
  for i:=0 to FArray.Count-1 do
  begin
    l := TStringAssociationList(FArray.ItemList^[i]);
    for j:=0 to l.Count-1 do
    begin
      Writeln(f, l.KeyList^[j]);
    end;
  end;
  CloseFile(f);
end;

function TStrListNotDupl.SearchKey(const AKey: string;
  var AValue: Integer): Boolean;
var
  i,j : Integer;
  lst : TStringAssociationList;
begin
  AValue := -1;
  Result := False;
  for i:=0 to FArray.Count-1 do
  begin
    lst := TStringAssociationList(FArray.ItemList^[i]);
    j := lst.IndexOf(AKey);
    if j<>-1 then
    begin
      Result := True;
      AValue := Integer(lst.ValueList^[j]);
      Exit;
    end;
  end;
end;

end.
