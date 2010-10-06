unit uTwoStrList;

interface

uses
  SysUtils, Classes, RTLConsts, AcedStrings, AcedBinary, AcedConsts;

type
  TTwoStrList = class;

  PTwoStrItem = ^TTwoStrItem;
  TTwoStrItem = packed record
    FName: string;
    FValue: string;
  end;

  PTwoStrItems = ^TTwoStrItems;
  TTwoStrItems = array[0..MaxListSize] of TTwoStrItem;
  TTwoStrListSortCompare = function(List: TTwoStrList; Index1, Index2: Integer): Integer;

  TTwoStrList = class(TStrings)
  private
    FItems: PTwoStrItems;
    // кол-во записей в списке
    FCount: Integer;
    // колво записей выделено памяти
    FCapacity: Integer;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    FCaseSensitive: Boolean;
    FDelimiter: string;
    procedure ExchangeItems(Index1, Index2: Integer);
    procedure QuickSort(L, R: Integer; SCompare: TTwoStrListSortCompare);
    procedure SetSorted(Value: Boolean);
    procedure SetCaseSensitive(const Value: Boolean);
    function GetValue(AIndex: Integer): string;
    procedure SetValue(AIndex: Integer; const AValue: string);
    function GetName(AIndex: Integer): string;
    procedure SetName(AIndex: Integer; const AValue: string);
    procedure ParseNameValue(const AText: string; var AName, AValue: string);
  protected
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: string); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetUpdateState(Updating: Boolean); override;
    function CompareStrings(const S1, S2: string): Integer; override;
    procedure InsertItem(Index: Integer; const AName, AValue: string); virtual;
  public
    constructor Create(ACapacity: Integer);
    destructor Destroy; override;
    //---
    function Add(const S: string): Integer; overload; override;
    function Add(const AName, AValue: string;
      AReplaceValue: Boolean = False): Integer; reintroduce; overload;
    function AddObject(const S: string; AObject: TObject): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    function Find(const AName: string; var Index: Integer): Boolean; virtual;
    function IndexOf(const AName: string): Integer; override;
    procedure Insert(Index: Integer; const S: string); overload; override;
    procedure Insert(Index: Integer; const AName, AValue: string); reintroduce; overload;
    procedure InsertObject(Index: Integer; const S: string;
      AObject: TObject); override;
    procedure Sort; virtual;
    procedure CustomSort(Compare: TTwoStrListSortCompare); virtual;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write SetSorted;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    //---
    property Items: PTwoStrItems read FItems;
    property Delimiter: string read FDelimiter write FDelimiter;
    property Names[AIndex: Integer]: string read GetName write SetName;
    property Values[AIndex: Integer]: string read GetValue write SetValue;
  end;

implementation

procedure _ClearOne(var AItem: TTwoStrItem); inline;
begin
  with AItem do begin
    FName := '';
    FValue := '';
  end;
end;

{ TTwoStrList }

constructor TTwoStrList.Create(ACapacity: Integer);
begin
  inherited Create;
  SetCapacity(ACapacity);
  Delimiter := ': ';
end;

destructor TTwoStrList.Destroy;
begin
  Clear();
  FreeMem(FItems, FCapacity * SizeOf(TTwoStrItem));
  //---
  inherited Destroy;
end;

function TTwoStrList.Add(const S: string): Integer;
var A,B: string;
begin
  ParseNameValue(S, A, B);
  Result := Add(A, B);
end;

function TTwoStrList.Add(const AName, AValue: string; AReplaceValue: Boolean): Integer;
begin
  if not Sorted then
    Result := FCount
  else
    if Find(AName, Result) then
      case Duplicates of
        dupIgnore: begin
          if AReplaceValue then
            FItems[Result].FValue := AValue;
          Exit;
        end;
        dupError: Error(@SDuplicateString, 0);
      end;
  InsertItem(Result, AName, AValue);
end;

function TTwoStrList.AddObject(const S: string; AObject: TObject): Integer;
begin
  Result := Add(S)
end;

procedure TTwoStrList.Clear;
var I: Integer;
begin
  if FCount <> 0 then
  begin
    for I := FCount - 1 downto 0 do
      _ClearOne(FItems^[I]);
    FCount := 0;
  end;
end;

procedure TTwoStrList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error(@SListIndexError, Index);
  _ClearOne(FItems^[Index]);
  Dec(FCount);
  if Index < FCount then
    AcedBinary.G_MoveMem(@FItems^[Index + 1], @FItems^[Index],
      (FCount - Index) * SizeOf(TTwoStrItem));
end;

procedure TTwoStrList.Exchange(Index1, Index2: Integer);
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(@SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(@SListIndexError, Index2);

  ExchangeItems(Index1, Index2);

end;

procedure TTwoStrList.ExchangeItems(Index1, Index2: Integer);
var
  Temp: string;
  Item1, Item2: PTwoStrItem;
begin
  Item1 := @FItems^[Index1];
  Item2 := @FItems^[Index2];

  Temp := Item1^.FName;
  Item1^.FName := Item2^.FName;
  Item2^.FName := Temp;

  Temp := Item1^.FValue;
  Item1^.FValue := Item2^.FValue;
  Item2^.FValue := Temp;
end;

function TTwoStrList.Find(const AName: string; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := CompareStrings(FItems^[I].FName, AName);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        if Duplicates <> dupAccept then L := I;
      end;
    end;
  end;
  Index := L;
end;

function TTwoStrList.Get(Index: Integer): string;
begin
  if (Index < 0) or (Index >= FCount) then Error(@SListIndexError, Index);
  with FItems^[Index] do begin
    Result := FName + FDelimiter + FValue;
  end;
end;

function TTwoStrList.GetCount: Integer;
begin
  Result := FCount;
end;

function TTwoStrList.GetName(AIndex: Integer): string;
begin
  if (AIndex < 0) or (AIndex >= FCount) then Error(@SListIndexError, AIndex);
  Result := FItems^[AIndex].FName;
end;

function TTwoStrList.GetObject(Index: Integer): TObject;
begin
  if (Index < 0) or (Index >= FCount) then Error(@SListIndexError, Index);
  Result := nil // FItems^[Index].FObject;
end;

function TTwoStrList.GetValue(AIndex: Integer): string;
begin
  if (AIndex < 0) or (AIndex >= FCount) then Error(@SListIndexError, AIndex);
  Result := FItems^[AIndex].FValue;
end;

function TTwoStrList.IndexOf(const AName: string): Integer;
begin
  if not Sorted then Result := inherited IndexOf(AName) else
    if not Find(AName, Result) then Result := -1;
end;

procedure TTwoStrList.Insert(Index: Integer; const S: string);
begin
  InsertObject(Index, S, nil);
end;

procedure TTwoStrList.InsertObject(Index: Integer; const S: string;
  AObject: TObject);
begin
  if Sorted then Error(@SSortedListError, 0);
  if (Index < 0) or (Index > FCount) then Error(@SListIndexError, Index);
  InsertItem(Index, S, '');
end;

procedure TTwoStrList.Insert(Index: Integer; const AName, AValue: string);
begin
  if Sorted then Error(@SSortedListError, 0);
  if (Index < 0) or (Index > FCount) then Error(@SListIndexError, Index);
  InsertItem(Index, AName, AValue);
end;

procedure TTwoStrList.InsertItem(Index: Integer; const AName, AValue: string);
begin
  if FCount >= FCapacity then
    SetCapacity(G_EnlargeCapacity(FCapacity));
  //---
  if Index < FCount then
    AcedBinary.G_MoveMem(@FItems^[Index], @FItems^[Index + 1],
      (FCount - Index) * SizeOf(TTwoStrItem));
  with FItems^[Index] do
  begin
    Pointer(FName) := nil;
    Pointer(FValue) := nil;
    FName := AName;
    FValue := AValue;
  end;
  Inc(FCount);
end;

procedure TTwoStrList.ParseNameValue(const AText: string; var AName,
  AValue: string);
var p: Integer;
begin
  if FCaseSensitive then
    p := AcedStrings.G_PosStr(FDelimiter, AText)
  else
    p := AcedStrings.G_PosText(FDelimiter, AText);
  if p=0 then
  begin
    AName := AText;
    AValue := ''
  end
  else
  begin
    AName := Copy(AText, 1, p-1);
    AValue :=Copy(AText, p+Length(FDelimiter)+1, MaxInt);
  end
end;

procedure TTwoStrList.Put(Index: Integer; const S: string);
begin
  if Sorted then Error(@SSortedListError, 0);
  if (Index < 0) or (Index >= FCount) then Error(@SListIndexError, Index);
  ParseNameValue(S, FItems^[Index].FName, FItems^[Index].FValue)
end;

procedure TTwoStrList.PutObject(Index: Integer; AObject: TObject);
begin
  if (Index < 0) or (Index >= FCount) then Error(@SListIndexError, Index);

//  FItems^[Index].FObject := AObject;

end;

procedure TTwoStrList.QuickSort(L, R: Integer; SCompare: TTwoStrListSortCompare);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, I, P) < 0 do Inc(I);
      while SCompare(Self, J, P) > 0 do Dec(J);
      if I <= J then
      begin
        ExchangeItems(I, J);
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TTwoStrList.SetCapacity(NewCapacity: Integer);
var
  lNewItems: PTwoStrItems;
begin
  if (NewCapacity <> FCapacity) and (NewCapacity >= FCount) then
  begin
    if NewCapacity > 0 then
    begin
      GetMem(lNewItems, NewCapacity * SizeOf(TTwoStrItem));
      if FCount > 0 then
      begin
        AcedBinary.G_CopyMem(FItems, lNewItems, FCount * SizeOf(TTwoStrItem));
      end;
    end
    else
    begin
      lNewItems := nil;
    end;
    if FCapacity > 0 then
    begin
      FreeMem(FItems);
    end;
    FCapacity := NewCapacity;
    FItems := lNewItems;
  end
end;

procedure TTwoStrList.SetSorted(Value: Boolean);
begin
  if FSorted <> Value then
  begin
    if Value then Sort;
    FSorted := Value;
  end;
end;

procedure TTwoStrList.SetUpdateState(Updating: Boolean);
begin
  // ничегошеньки
end;

procedure TTwoStrList.SetValue(AIndex: Integer; const AValue: string);
begin
  if (AIndex < 0) or (AIndex >= FCount) then Error(@SListIndexError, AIndex);
  FItems^[AIndex].FValue := AValue;
end;

function StringListCompareStrings(List: TTwoStrList; Index1, Index2: Integer): Integer;
begin
  Result := List.CompareStrings(List.FItems^[Index1].FName,
                                List.FItems^[Index2].FName);
end;

procedure TTwoStrList.Sort;
begin
  CustomSort(StringListCompareStrings);
end;

procedure TTwoStrList.CustomSort(Compare: TTwoStrListSortCompare);
begin
  if not Sorted and (FCount > 1) then
  begin
    QuickSort(0, FCount - 1, Compare);
  end;
end;

function TTwoStrList.CompareStrings(const S1, S2: string): Integer;
begin
  if CaseSensitive then
    Result := AcedStrings.G_CompareStr(S1, S2)
  else
    Result := AcedStrings.G_CompareText(S1, S2);
end;

procedure TTwoStrList.SetCaseSensitive(const Value: Boolean);
begin
  if Value <> FCaseSensitive then
  begin
    FCaseSensitive := Value;
    if Sorted then Sort;
  end;
end;


procedure TTwoStrList.SetName(AIndex: Integer; const AValue: string);
begin
  if (AIndex < 0) or (AIndex >= FCount) then Error(@SListIndexError, AIndex);
  FItems^[AIndex].FName := AValue;

end;

end.
