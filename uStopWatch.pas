unit uStopWatch;

interface

uses
  Windows, SysUtils, AcedConsts, uGlobalVars, uGlobalConstants, uGlobalFunctions;

const
  StopWatchElapsedDefaultFormat = '%0:s %1:d ms';

type
  EStopWatchError = class(Exception);

  TSWTimeListRec = record
    FT: Int64;
    FD: string;
  end;

  TSWTimeListArray = array of TSWTimeListRec;

  TStopWatch = class(TObject)
  private
    FFR: Int64;
    FT0: Int64;
    FTList: TSWTimeListArray;
    FCount: Integer;
    FSize: Integer;
    FCurThread: THandle;
    FRunning: Boolean;
    procedure _QueryPerformanceCounter(var AOut: Int64); inline;
    function GetSum: Cardinal;
  public
    constructor Create;
    //---
    procedure Clear;
    procedure SetCap(ACount: Integer);
    //---    
    procedure Start(const ADesc: string = '');
    procedure StartNew(const ADesc: string = '');
    procedure Stop;
   //---
    function StopWatch: Integer;
    function StopWatchStr: string;
    function Elapsed(const AFormat: string = StopWatchElapsedDefaultFormat;
      const ADelimiter: string = CRLF; AShowSum: Boolean = False): string;
    //---
    property IsRunning: Boolean read FRunning;
    property Sum: Cardinal read GetSum;
  end;

implementation

{ TStopWatch }

procedure TStopWatch.Clear;
begin
  FT0 := 0;
  FCount := 0;
  FRunning := False;
end;

constructor TStopWatch.Create;
begin
  Clear;
  SetCap(1);
  FCurThread := GetCurrentThread();
  QueryPerformanceFrequency(FFR);
end;

procedure TStopWatch.SetCap(ACount: Integer);
begin
  if Length(FTList)<ACount then
  begin
    FSize := G_NormalizeCapacity(ACount);
    SetLength(FTList, FSize);
  end;
end;

procedure TStopWatch._QueryPerformanceCounter(var AOut: Int64);
var OldMask: DWORD;
begin
  oldMask := SetThreadAffinityMask(FCurThread, 1);
  QueryPerformanceCounter(AOut);
  SetThreadAffinityMask(FCurThread, OldMask);
end;

procedure TStopWatch.Start(const ADesc: string);
var i: Int64;
begin
  if FCount>=FSize then
    raise EStopWatchError.Create('Buffer full. Use .SetCap()');
  _QueryPerformanceCounter(i);
  if FRunning then
  begin
    FTList[FCount-1].FT := i - FT0;
  end;
  FTList[FCount].FD := ADesc;
  FT0 := i;
  Inc(FCount);
  FRunning := True;
end;

procedure TStopWatch.StartNew(const ADesc: string);
begin
  Clear;
  Start(ADesc);
end;

procedure TStopWatch.Stop;
var i: Int64;
begin
  if FRunning then
  begin
    _QueryPerformanceCounter(i);
    FTList[FCount-1].FT := i - FT0;
  end
  else
  begin
    raise EStopWatchError.Create('StopWatch isn''t started');
  end;
  FRunning := False;
end;

function TStopWatch.StopWatch: Integer;
begin
  if FCount=0 then
    raise EStopWatchError.Create('First run Start()');
  if FRunning then
    Stop;
  Result := Round(FTList[FCount-1].FT/FFR*1000);
end;

function TStopWatch.StopWatchStr: string;
begin
  Result := Format('%d ms', [StopWatch()])
end;

function TStopWatch.Elapsed(const AFormat, ADelimiter: string;
  AShowSum: Boolean): string;
var
  j: Integer;
  t: Cardinal;
  k: Cardinal;
  f: string;
begin
  if FRunning then
    Stop;
  Result := '';
  k := 0;
  f := IfElse(AFormat='', StopWatchElapsedDefaultFormat, AFormat);
  for j:=0 to FCount-1 do
  begin
    t := Round(FTList[j].FT / FFR * 1000);
    Result := StrAppendWDelim(
                Result,
                Format(f, [FTList[j].FD, t]),
                ADelimiter
              );
    if AShowSum then
      Inc(k, t);
  end;
  if AShowSum then
    Result := StrAppendWDelim(
                Result,
                Format(f, ['SUM', k]),
                ADelimiter
              );
end;

function TStopWatch.GetSum: Cardinal;
var j: Integer;
begin
  Result := 0;
  for j:=0 to FCount-1 do
    Inc(Result, Round(FTList[j].FT / FFR * 1000));
end;

end.
