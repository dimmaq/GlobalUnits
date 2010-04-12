unit uTextReader;

interface

uses
  Classes, SysUtils, Math, AcedStrings, uAnsiStrings;

type
  TTextReader = class
  private
    FStream: TStream;
    FStreamSize: Integer;
    FStreamPos: Integer;
    FOwner: Boolean;
    FBuffer: PAnsiChar;
    FDefBufSize: Integer;
    FBufferSize: Integer;
    FBufferPos: Integer;
    FLastLine: AcedStrings.TStringBuilder;
    FBol1: Boolean;
    //---
    procedure _ReadBuffer;
    procedure _NewBuffer(ABufSize: Integer);
  public
    constructor Create(AStream: TStream; AOwner: Boolean); overload;
    constructor Create(const AFileName: string); overload;
    destructor Destroy; override;
    //---
    function EOF: Boolean;
    function ReadLn: AnsiString;
    function ReadStrings(AStrings: TAnsiStrings): Integer;
    //---
    property BufSize: Integer read FDefBufSize write FDefBufSize;
  end;

implementation

const
  DEF_BUF_SIZE = 1*1024;

{ TTextReader }

constructor TTextReader.Create(AStream: TStream; AOwner: Boolean);
begin
  FStream := AStream;
  FOwner := AOwner;
  FStream.Position := 0;
  FStreamPos := 0;
  FStreamSize := AStream.Size;
  FDefBufSize := DEF_BUF_SIZE;
  FBufferSize := FDefBufSize;
  FBufferPos := MaxInt;
  FBuffer := nil;
  FLastLine := nil;
  FBol1 := False;
end;

constructor TTextReader.Create(const AFileName: string);
var stream: TStream;
begin
  stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  Create(stream, True);
end;

destructor TTextReader.Destroy;
begin
  FreeMem(FBuffer);
  FreeAndNil(FLastLine);
  if FOwner then
    FreeAndNil(FStream);
  inherited;
end;

function TTextReader.EOF: Boolean;
begin
  Result := (FBufferSize=0) or
            (((FStreamSize-FStreamPos)=0) and (FBufferPos>FBufferSize))
end;

function TTextReader.ReadLn: AnsiString;
var
  P: PAnsiChar;
  S: PAnsiChar;
begin
  Result := '';
  if Assigned(FLastLine) then
    FLastLine.Clear;
  while FBufferSize>0 do
  begin
    if FBufferPos>FBufferSize then
      _ReadBuffer;
    //---
    P := FBuffer;
    Inc(P, FBufferPos);
    if FBol1 and (P^ in [#10, #13]) then
    begin
      Inc(P);
      FBol1 := False;
    end;
    S := P;
    // поиск конца строки
    while not (P^ in [#0, #10, #13]) do Inc(P);
    // конец буфера
    if P^=#0 then
    begin
      if not Assigned(FLastLine) then
        FLastLine := AcedStrings.TStringBuilder.Create;
      FLastLine.Append(Pointer(S), P-S);
      FBufferPos := P - FBuffer;
      Inc(FBufferPos);
    end
    else
    // конец строки
    begin
      if (Assigned(FLastLine)) and (FLastLine.Length>0) then
        Result := FLastLine.Append(Pointer(S), P-S).ToString()
      else
        SetString(Result, S, P - S);
      if P^ = #13 then
      begin
        Inc(P);
        FBol1 := P^ = #0;
      end
      else if P^ = #10 then
      begin
        Inc(P);
        FBol1 := P^ = #0;
      end
      else if P^ = #0 then
        Inc(P);
      FBufferPos := P - FBuffer;
      Exit; //***
    end
  end;
  Result := FLastLine.ToString
end;

function TTextReader.ReadStrings(AStrings: TAnsiStrings): Integer;
{$IFDEF UNICODE}
var use_ansi: Boolean;
{$ENDIF}
begin
  Result := 0;
  //---
  {$IFDEF UNICODE}
    use_ansi := AStrings is TAnsiStringList;
  {$ENDIF}
  //---
  while not EOF do
  begin
    {$IFDEF UNICODE}
      if use_ansi then
        TAnsiStringList(AStrings).Add(ReadLn)
      else
        AStrings.Add(ReadLn);
    {$ELSE}
      AStrings.Add(ReadLn);
    {$ENDIF}
    Inc(Result)
  end;
end;

procedure TTextReader._NewBuffer(ABufSize: Integer);
var p: PAnsiChar;
begin
  if FBuffer=nil then
    GetMem(FBuffer, ABufSize+4);
  p := FBuffer;
  Inc(p, ABufSize);
  PInteger(p)^ := 0;
end;

procedure TTextReader._ReadBuffer;
var k: Integer;
begin
  FBufferSize := Min(FDefBufSize, FStreamSize - FStreamPos);
  _NewBuffer(FBufferSize);
  k := FStream.Read(FBuffer^, FBufferSize);
  FStreamPos := FStream.Seek(0, soCurrent);
  FBufferPos := 0;
  if FBufferSize<>k then
  begin
    FBufferSize := k;
    _NewBuffer(FBufferSize)
  end
end;

end.
