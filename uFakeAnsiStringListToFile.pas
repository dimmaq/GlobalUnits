unit uFakeAnsiStringListToFile;

interface

uses
  Classes, SysUtils, uFakeAnsiStringList, uTextWriter;

type
  TFakeAnsiStringListToFile = class(TFakeAnsiStringList)
  private
    FFile: TAnsiStreamWriter;
  protected
    procedure FakeAdd(const AString: AnsiString); override;
    function FakeGetText: AnsiString; override;
  public
    constructor Create(const AFileName: TFileName);
    destructor Destroy; override;
  end;



implementation

{ TFakeAnsiStringListToFile }

constructor TFakeAnsiStringListToFile.Create(const AFileName: TFileName);
begin
  inherited Create;
  FFile := TAnsiStreamWriter.Create(AFileName, True);
end;

destructor TFakeAnsiStringListToFile.Destroy;
begin
  FreeAndNil(FFile);
  inherited;
end;

procedure TFakeAnsiStringListToFile.FakeAdd(const AString: AnsiString);
begin
  FFile.WriteLine(AString)
end;

function TFakeAnsiStringListToFile.FakeGetText: AnsiString;
begin
  Result := ''
end;

end.
