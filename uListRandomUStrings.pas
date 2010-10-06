unit uListRandomUStrings;

interface


uses
  Classes, SysUtils, uAnsiStrings, uListRandomBase;

type
  TListRandomUStrings = class(TListRandomBase)
  private
    FDefault: UnicodeString;
    FUStrings: TUnicodeStrings;
  public
    constructor Create(const AUStrings: TUnicodeStrings; AOwner: Boolean = False);
    destructor Destroy; override;
    //---
    procedure Update;
    function Next: UnicodeString;
    //---
    property List: TUnicodeStrings read FUStrings;
    property DefaultValue: UnicodeString read FDefault write FDefault;
  end;

implementation

{ TListRandomAStrings }

constructor TListRandomUStrings.Create(const AUStrings: TUnicodeStrings;
  AOwner: Boolean);
begin
  inherited Create(AUStrings.Count);
  FUStrings := AUStrings;
  FOwner := AOwner;
end;

destructor TListRandomUStrings.Destroy;
begin
  if FOwner then
    FreeAndNil(FUStrings);
  inherited;
end;

function TListRandomUStrings.Next: UnicodeString;
var k: Integer;
begin
  k := NextIndex();
  if k<>-1 then
    Result := FUStrings[k]
  else
    Result := FDefault
end;

procedure TListRandomUStrings.Update;
begin
  Count := FUStrings.Count;
end;

end.
