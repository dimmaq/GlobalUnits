unit uListRandomAStrings;

interface


uses
  Classes, SysUtils, uAnsiStrings, uListRandomBase;

type
  TListRandomAStrings = class(TListRandomBase)
  private
    FDefault: AnsiString;
    FAStrings: TAnsiStrings;
    //---
    procedure Update;
  public
    constructor Create(const AAStrings: TAnsiStrings; AOwner: Boolean = False);
    destructor Destroy; override;
    //---
    function Next: AnsiString; overload;
    function Next(var AOut: AnsiString): Boolean; overload;
    //---
    property List: TAnsiStrings read FAStrings;
    property DefaultValue: AnsiString read FDefault write FDefault;
  end;

implementation

//uses uGlobalFunctions, uGlobalVars;

{ TListRandomAStrings }

constructor TListRandomAStrings.Create(const AAStrings: TAnsiStrings;
  AOwner: Boolean);
begin
  inherited Create(AAStrings.Count);
  FAStrings := AAStrings;
  FOwner := AOwner;
end;

destructor TListRandomAStrings.Destroy;
begin
  if FOwner then
    FreeAndNil(FAStrings);
  inherited;
end;

function TListRandomAStrings.Next(var AOut: AnsiString): Boolean;
begin
  AOut := Next();
  Result := not IsFail;
end;

function TListRandomAStrings.Next: AnsiString;
var k: Integer;
begin
  Update;
  k := NextIndex();
  if k<>-1 then
    Result := FAStrings[k]
  else
    Result := FDefault
end;

procedure TListRandomAStrings.Update;
begin
  Count := FAStrings.Count;
end;

end.
