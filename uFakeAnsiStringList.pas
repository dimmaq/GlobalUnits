unit uFakeAnsiStringList;

interface

uses
  Classes, SysUtils, uAnsiStrings, AcedStrings;

type
  TFakeAnsiStringList = class(TAnsiStrings)
  private
  protected
    function Get(Index: Integer): AnsiString; override;
    function GetCount: Integer; override;
    function GetTextStr: AnsiString; override;
    //---
    procedure FakeAdd(const AString: AnsiString); virtual; abstract;
    function FakeGetText: AnsiString; virtual; abstract;
  public
    function Add(const S: AnsiString): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: AnsiString); override;
  end;

implementation

{ TFakeAnsiStringList }

function TFakeAnsiStringList.Add(const S: AnsiString): Integer;
begin
  FakeAdd(S);
  Result := 0;
end;

procedure TFakeAnsiStringList.Clear;
begin
end;

procedure TFakeAnsiStringList.Delete(Index: Integer);
begin
  Clear;
end;

function TFakeAnsiStringList.Get(Index: Integer): AnsiString;
begin
  Result := FakeGetText();
end;

function TFakeAnsiStringList.GetCount: Integer;
begin
  Result := 0
end;

function TFakeAnsiStringList.GetTextStr: AnsiString;
begin
  Result := FakeGetText();
end;

procedure TFakeAnsiStringList.Insert(Index: Integer; const S: AnsiString);
begin
  FakeAdd(S);
end;

end.
