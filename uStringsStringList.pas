unit uStringsStringList;

interface

uses Classes, SysUtils;

type

  TStringsStringList = class(TStringList)
  private
    function GetStringList(Index: Integer): TStringList;
    procedure SetStringList(Index: Integer; const Value: TStringList);
    //---
  public
    destructor Destroy; override;
    //---
    function AddStringList(const S:AnsiString):TStringList;
    function Add(const S: string): Integer; override;
    //---
    property Objects[Index: Integer]: TStringList read GetStringList write SetStringList;
  end;

implementation

{ TStringsStringList }

function TStringsStringList.Add(const S: string): Integer;
begin
  Result := AddObject(S, TStringList.Create);
end;

function TStringsStringList.AddStringList(const S: AnsiString): TStringList;
begin
  Result := TStringList.Create;
  AddObject(S, Result);
end;

destructor TStringsStringList.Destroy;
var j: Integer;
begin
  for j:=0 to Count-1 do
  begin
    Objects[j].Free;
    inherited Objects[j] := nil;
  end;
  inherited;
end;

function TStringsStringList.GetStringList(Index: Integer): TStringList;
begin
  Result := inherited Objects[index] as TStringList
end;

procedure TStringsStringList.SetStringList(Index: Integer;
  const Value: TStringList);
begin
  inherited Objects[index] := Value
end;

end.
