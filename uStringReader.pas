unit uStringReader;

interface

uses
  Classes, SysUtils, Math, AcedStrings;

type
  EAnsiStringReaderError = class(Exception);

  TAnsiStringReader = class
  private
    FString: AnsiString;
    FPos: Integer;
    FLen: Integer;
    //---
  public
    constructor Create(const AString: AnsiString; ALength: Integer = 0);
    //---
    function EOF: Boolean;
    function ReadLn: AnsiString;
    function ReadToEnd: AnsiString;
    //---
    property Pos: Integer read FPos write FPos;
  end;

  {$IFNDEF UNICODE}
    TStringReader = TAnsiStringReader;
  {$ENDIF}

implementation

uses uGlobalVars, uglobalConstants;

{ TStringReader }

constructor TAnsiStringReader.Create(const AString: AnsiString; ALength: Integer);
var L: Integer;
begin
  FString := AString;
  L := Length(FString);
  if (0<ALength) and (ALength<=L) then
  begin
    FLen := ALength
  end
  else
  begin
    {$IFDEF DEBUG}
    if ALength<>0 then
      raise EAnsiStringReaderError.CreateFmt('Not accept ALength=%d param {%d}', [ALength,L]);
    {$ENDIF}
    FLen := L;
  end;
  FPos := 1;
end;

function TAnsiStringReader.EOF: Boolean;
begin
  Result := FPos>FLen
end;

function TAnsiStringReader.ReadLn: AnsiString;
var p: Integer;
begin
  p := G_PosStr(CRLF, FString, FPos);
  if (p>0) and (p<FLen) then
  begin
    Result := Copy(FString, FPos, p - FPos);
    FPos := p + 2;
  end
  else
  begin
    Result := Copy(FString, FPos, FLen-FPos+1 );
    FPos := FLen + 1
  end
end;

function TAnsiStringReader.ReadToEnd: AnsiString;
begin
  Result := Copy(FString, FPos, MaxInt);
  FPos := MaxInt;
end;

end.
