unit uFakeAnsiStringListToString;

interface

uses
  Classes, SysUtils, uFakeAnsiStringList, AcedStrings;

type
  TFakeAnsiStringListToString = class(TFakeAnsiStringList)
  private
    FStringBuilder: AcedStrings.TStringBuilder;
  protected
    procedure FakeAdd(const AString: AnsiString); override;
    function FakeGetText: AnsiString; override;
  public
    constructor Create(ACapacity: Integer);
    destructor Destroy; override;
  end;



implementation

{ TFakeAnsiStringListToString }

constructor TFakeAnsiStringListToString.Create(ACapacity: Integer);
begin
  inherited Create;
  FStringBuilder := TStringBuilder.Create(ACapacity);
end;

destructor TFakeAnsiStringListToString.Destroy;
begin
  FreeAndNil(FStringBuilder);
  inherited;
end;

procedure TFakeAnsiStringListToString.FakeAdd(const AString: AnsiString);
begin
  FStringBuilder.AppendLine(AString)
end;

function TFakeAnsiStringListToString.FakeGetText: AnsiString;
begin
  Result := FStringBuilder.ToString();
end;

end.
