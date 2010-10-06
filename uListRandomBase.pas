unit uListRandomBase;

interface

uses
  SysUtils, SyncObjs, AcedConsts, AcedContainers, AcedBinary, AcedAlgorithm,
  AcedCrypto;

type
  EListRandomError = class(Exception);

  TListRandomBase = class
  private
    FCount: Integer;
    FItems: TIntegerList;
    FItemIndex: Integer;
    FRaiseError: Boolean;
    FIsFail: Boolean;
    FHMT: HMT;
    //---
    function Mix: Boolean;
  protected
    FOwner: Boolean;
    function NextIndex: Integer;
  public
    constructor Create(AInitialCapacity: Integer);
    destructor Destroy; override;
    //---
    function _Dump(): AnsiString;
    //---
    property Count: Integer read FCount write FCount;
    property RaiseError: Boolean read FRaiseError write FRaiseError;
    property IsFail: Boolean read FIsFail;
  end;

implementation

uses uGlobalVars, uGlobalFunctions, uGlobalConstants;

{ TListRandomBase }

constructor TListRandomBase.Create(AInitialCapacity: Integer);
begin
  FOwner := False;
  FItems := TIntegerList.Create(AInitialCapacity);
  FItemIndex := -1;
  G_RandomInit(FHMT, Random(MaxInt));
end;

destructor TListRandomBase.Destroy;
begin
  FreeAndNil(FItems);
  G_RandomDone(FHMT);
  inherited;
end;

function TListRandomBase.Mix: Boolean;
var j: Integer;
begin
  if FCount>0 then
  begin
    if FCount>1 then
    begin
      if FItems.Count<>FCount then
      begin
        FItems.Clear;
        for j:=0 to FCount-1 do
          FItems.Add(j);
      end;
      G_RandomShuffle(PPointerItemList(FItems.ItemList), FCount, FHMT)
    end;
    FItemIndex := 0;
    Result := True;
  end
  else
  begin
    FItemIndex := -1;
    Result := False;
  end
end;

function TListRandomBase.NextIndex: Integer;
var bol: Boolean;
begin
  Result := -1;
  FIsFail := True;
  //---
  if FCount=1 then
  begin
    FItemIndex := 0;
    Result     := 0;
    FIsFail    := False;
  end
  else
  begin
    bol := (0<=FItemIndex) and (FItemIndex<FCount);
    if not bol then
      bol := Mix();
    if bol then
    begin
      Result := FItems.ItemList^[FItemIndex];
      Inc(FItemIndex);
      FIsFail := False;
    end
    else
    begin
      FItemIndex := -1;
      if RaiseError then
        raise EListRandomError.Create('Error generate random item')
    end;
  end;
end;

function TListRandomBase._Dump: AnsiString;
begin
  Result := Format(
    '{'+CRLF+
    ' FCount: %d'+CRLF+
    ' FItemIndex: %d'+CRLF+
    ' FIsFail: %s'+CRLF+
    ' FRaiseError: %s'+CRLF+
    ' FItems: %s'+CRLF+
    '}'+CRLF,
    [FCount, FItemIndex, BoolToStr2(FIsFail), BoolToStr2(FRaiseError), FItems._Dump()]
  );
end;

end.
