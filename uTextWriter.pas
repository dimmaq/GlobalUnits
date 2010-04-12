unit uTextWriter;

interface

uses
  Windows, Classes, SysUtils, RTLConsts, uAnsiStrings, AcedStrings;

type
  TTextWriter = class
  private
    FStream: TStream;
    FOwner: Boolean;
    FBuffer: AcedStrings.TStringBuilder;
    FMaxBufSize: Integer;
    FFlushNow: Boolean;
    FAllocBuf: Boolean;
    FUseBuffer: Boolean;
    //---
    procedure _CreateBuffer;
  public
    constructor Create(AStream: TStream; AOwner: Boolean); overload;
    constructor Create(const AFileName: string; ACreateNew: Boolean); overload;
    destructor Destroy; override;
    //---
    procedure Write(const AData: AnsiString);
    procedure WriteStrings(AStrings: TAnsiStrings);
    procedure WriteLn(const AData: AnsiString);
    procedure Flush;
    //---
    property Stream: TStream read FStream;
    property MaxBufferSize: Integer read FMaxBufSize write FMaxBufSize;
    property FlushFile: Boolean read FFlushNow write FFlushNow;
    property AllocBuf: Boolean read FAllocBuf write FAllocBuf;
    property UseBuffer: Boolean read FUseBuffer write FUseBuffer;
  end;

implementation

uses uGlobalVars, uGlobalFunctions;

const
  MAX_BUFFER_SIZE = 16*1024;

{ TTextReader }

constructor TTextWriter.Create(AStream: TStream; AOwner: Boolean);
begin
  FStream := AStream;
  FOwner := AOwner;
  FBuffer := nil;
  FMaxBufSize := MAX_BUFFER_SIZE;
  FUseBuffer := True;
  FFlushNow := False;
  FAllocBuf := True;
end;

constructor TTextWriter.Create(const AFileName: string; ACreateNew: Boolean);
var
  m: DWORD;
  h: THandle;
  f: TFileStream;
begin
  m := IfElse(ACreateNew, CREATE_ALWAYS, OPEN_ALWAYS);
  SetLastError(0);
  h := CreateFile(
    PChar(AFileName),
    GENERIC_WRITE,
    FILE_SHARE_READ,
    nil,
    m,
    FILE_ATTRIBUTE_ARCHIVE,
    0
  );
  if h=INVALID_HANDLE_VALUE then
    raise EFOpenError.CreateResFmt(
      @SFOpenErrorEx,
      [ExpandFileName(AFileName), SysErrorMessage(GetLastError())]
    );

  f := TFileStream.Create(h);
  if not ACreateNew then
    f.Seek(0, soEnd);
  Create(f, True);
end;

destructor TTextWriter.Destroy;
begin
  Flush;
  //---
  FreeAndNil(FBuffer);
  if FOwner then
    FreeAndNil(FStream);
  inherited;
end;

procedure TTextWriter.Flush;
begin
  if Assigned(FBuffer) and (FBuffer.Length>0) then
  begin
    FStream.WriteBuffer(Pointer(FBuffer.Chars)^, FBuffer.Length);
    FBuffer.Clear;
  end;
  //---
  if FFlushNow and (Assigned(FStream)) and (FStream is TFileStream) then
    FlushFileBuffers(TFileStream(FStream).Handle);
end;

procedure TTextWriter.Write(const AData: AnsiString);
begin
  if FUseBuffer then
  begin
    _CreateBuffer;
    FBuffer.Append(AData);
    if FBuffer.Length>=FMaxBufSize then
      Flush
  end
  else
  begin
    FStream.WriteBuffer(Pointer(AData)^, Length(AData));
    Flush;
  end;
end;

procedure TTextWriter.WriteStrings(AStrings: TAnsiStrings);
var j: Integer;
begin
  for j:=0 to AStrings.Count-1 do
    Write(AStrings[j]+CRLF)    
end;

procedure TTextWriter.WriteLn(const AData: AnsiString);
begin
  Write(AData+CRLF)
end;

procedure TTextWriter._CreateBuffer;
begin
  // быделить под буфер чуть больше пам€ти,
  // чтоб не было перераспределени€ при полном заполнении
  if not Assigned(FBuffer) then
    FBuffer := TStringBuilder.Create(
      IfElse(FAllocBuf, FMaxBufSize+256, 0)
    );
end;

end.
