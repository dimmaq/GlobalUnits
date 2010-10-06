unit uRELog2;

interface

uses
  Windows, Messages, SysUtils, RichEdit, ExtCtrls, Graphics, ComCtrls, SyncObjs,
  AcedStrings, AcedConsts, uconst, uTextWriter
  {$IFDEF UNICODE}
    , AnsiStrings
  {$ENDIF}
  ;

const
  RELOG2_UPDATE_INTERVAL = 1000; // ms

type
  TReLog2BufferRec = record
    RText: string;
    RColor: TColor;
  end;
  TReLog2BufferArr = array of TReLog2BufferRec;

  TReLog2Buffer = class
  private
    FArray: TReLog2BufferArr;
    FCount: Integer;
    procedure Add(const AText: string; AColor: TColor);
  end;       

  TRELog2 = class(TObject)
  private
    FRichEdit : TRichEdit;
    FShowDate : Boolean;
    FShowYear : Boolean;
    FShowTime : Boolean;
    FShowMs : Boolean;
    FSaveFile : Boolean;
    FFileName : TFileName;
    FReplaceCRLF : Boolean;
    FMaxLine : Integer;
    FAutoScroll: Boolean;
    //---
    FLockBuffer: TCriticalSection;
    FTextBuffer: TReLog2Buffer;
    FUpdateTimer: TTimer;
    //---
    FLockFile : TCriticalSection;
    FFileWriter: TAnsiStreamWriter;
    //---
    procedure UpdateTimerProc(Sender: TObject);
    function GetBufferLen: Integer;
  public
    constructor Create(RichEdit: TRichEdit = nil);
    destructor Destroy; override;
    //----------------
    function FormatStr(const AText: AnsiString): AnsiString;
    procedure Write2RE(const AText: AnsiString; AColor: TColor);
    procedure AppendStrToFile(const AText: AnsiString);
    procedure AddLog(const AText: AnsiString);
    procedure AddError(const AText: AnsiString);
    //--------------------------------
    property RichEdit: TRichEdit read FRichEdit write FRichEdit;
    property ShowDate: Boolean read FShowDate write FShowDate;
    property ShowYear: Boolean read FShowYear write FShowYear;
    property ShowTime: Boolean read FShowTime write FShowTime;
    property ShowMs: Boolean read FShowMs write FShowMs;
    property SaveFile: Boolean read FSaveFile write FSaveFile;
    property FileName: TFileName read FFileName write FFileName;
    property ReplaceCRLF: Boolean read FReplaceCRLF write FReplaceCRLF;
    property MaxLine: Integer read FMaxLine write FMaxLine;
    property AutoScroll: Boolean read FAutoScroll write FAutoScroll;
    property BufferLen: Integer read GetBufferLen;
  end;

implementation

uses uGlobalFunctions;

{ TReLog2Buffer }

procedure TReLog2Buffer.Add(const AText: string; AColor: TColor);
begin
  if (FCount>0) and (FArray[FCount-1].RColor=AColor) then
  begin
    with FArray[FCount-1] do
      RText := RText + AText;
  end
  else
  begin
    if FCount>=Length(FArray) then
      SetLength(FArray, G_EnlargeCapacity(FCount));
    with FArray[FCount] do begin
      RText := AText;
      RColor := AColor
    end;
    Inc(FCount);
  end;
end;


{ TRELog2 }

constructor TRELog2.Create(RichEdit: TRichEdit);
begin
  FRichEdit := RichEdit;

  FShowDate    := True;
  FShowYear    := True;
  FShowTime    := True;
  FShowMs      := False;
  FSaveFile    := False;
  FFileName    := '';
  FReplaceCRLF := True;
  FMaxLine     := MAXWORD div 4;
  FAutoScroll  := True;
  //---
  FLockBuffer  := TCriticalSection.Create;
  FTextBuffer  := TReLog2Buffer.Create;
  FUpdateTimer := TTimer.Create(nil);
  with FUpdateTimer do begin
    Interval := RELOG2_UPDATE_INTERVAL;
    OnTimer  := UpdateTimerProc;
    Enabled  := True;
  end;
  //---
  FLockFile := TCriticalSection.Create;
  FFileWriter := nil;
end;

destructor TRELog2.Destroy;
begin
  FreeAndNil(FUpdateTimer);
  FreeAndNil(FLockBuffer);
  FreeAndNil(FTextBuffer);
  FreeAndNil(FFileWriter);
  FreeAndNil(FLockFile);
  inherited;
end;

function TRELog2.FormatStr(const AText: AnsiString): AnsiString;

  function _2str2(A: Word): AnsiString;
  begin
    if A<10 then
      Result := '0'+IntToStr(A)
    else
      Result := IntToStr(A)  
  end;
  function _2str3(A: Word): AnsiString;
  begin
    if A<10 then
      Result := '00'+IntToStr(A)
    else if A<100 then
      Result := '0'+IntToStr(A)
    else
      Result := IntToStr(A)
  end;
var
  lSysTime: TSystemTime;
  lTmp,lDate,lYear,lTime,lMs,lDel: AnsiString;
begin
  Result := '';
  lTmp   := '';
  if FShowDate or FShowTime then
  begin
    lDate := '';
    lYear := '';
    lTime := '';
    lMs   := '';
    lDel  := '';
    GetLocalTime(lSysTime);
    if FShowDate then
    begin
      lDate := _2str2(lSysTime.wDay)+'.'+_2str2(lSysTime.wMonth);
      if FShowYear then
        lYear := '.'+IntToStr(lSysTime.wYear);
    end;
    //---
    if FShowTime then
    begin
      lTime := _2str2(lSysTime.wHour)+':'+_2str2(lSysTime.wMinute)+':'+_2str2(lSysTime.wSecond);
      if FShowMs then
        lMs := ':'+_2str3(lSysTime.wMilliseconds);
    end;
    //---
    if (lDate<>'') and (lTime<>'') then
      lDel := ' - ';
    //---
    lTmp := '[ ' + lDate + lYear + lDel + lTime + lMs + ' ]   ';
  end;
  //---
  if FReplaceCRLF then
    Result := lTmp + _ReplaceCRLF(AText)
  else
    Result := lTmp + AText;
end;

function TRELog2.GetBufferLen: Integer;
begin
  Result := FTextBuffer.FCount
end;

procedure TRELog2.AddError(const aText: AnsiString);
begin
  Write2RE(FormatStr(aText), clRed);
end;

procedure TRELog2.AddLog(const aText: AnsiString);
begin
  Write2RE(FormatStr(aText), clBlack);
end;

procedure TRELog2.AppendStrToFile(const AText: AnsiString);
begin
  if FSaveFile and (FFileName<>'') then
  begin
    FLockFile.Enter;
    try
      if not Assigned(FFileWriter) then
        FFileWriter := TAnsiStreamWriter.Create(FFileName, False);
      //---
      FFileWriter.Write(AText);
    finally
      FLockFile.Leave;
    end;
  end
end;

procedure TRELog2.Write2RE(const AText: AnsiString; AColor: TColor);
begin
  if not Assigned(FRichEdit) then
    Exit;
  FLockBuffer.Enter;
  try
    FTextBuffer.Add(AText, AColor);
  finally
    FLockBuffer.Leave
  end;
end;

procedure TRELog2.UpdateTimerProc(Sender: TObject);
var
  k: Integer;
  j: Integer;
  lSel: TCharRange;
begin
  if FTextBuffer.FCount>0 then
  begin
    if FRichEdit.Lines.Count>=FMaxLine then
      FRichEdit.Lines.Clear;
    //---
    k := FRichEdit.GetTextLen;
    lSel.cpMin := k; lSel.cpMax := k;
    FRichEdit.Perform(EM_EXSETSEL, 0, Longint(@lSel));
    //---
    FLockBuffer.Enter;
    try
      for j:=0 to FTextBuffer.FCount-1 do
      begin
        with FTextBuffer.FArray[j], FRichEdit do begin
          SelAttributes.Color := RColor;
          FRichEdit.Perform(EM_REPLACESEL, 0, Longint(PChar(RText)));
        end;
      end;
      FTextBuffer.FCount := 0;
    finally
      FLockBuffer.Leave
    end;
    if FAutoScroll then
      FRichEdit.Perform(EM_SCROLl, SB_PAGEDOWN	, 0);
    //---  
  end;
end;


end.
