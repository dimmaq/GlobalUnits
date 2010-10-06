unit uGlobalVars;

interface

uses SysUtils, Windows, Graphics, uGlobalTypes;

var
  gDirApp: string;
  gDirDump: string;
  gDirLog: string;
  gStartTimeStr: string;

  gAnsiDirApp: AnsiString;
  gAnsiDirDump: AnsiString;
  gAnsiDirLog: AnsiString;
  gAnsiStartTimeStr: AnsiString;

implementation

uses uGlobalFunctions;

function _MakeCharsString(AChars: TSysCharSet): AnsiString;
var
  ch: AnsiChar;
  k: Integer;
begin
  SetLength(Result, 256);
  k := 0;
  for ch:=#0 to #255 do
  begin
    if ch in AChars then
    begin
      Inc(k);
      Result[k] := ch;
    end;
  end;
  SetLength(Result, k);
end;

initialization
  if not SetThreadLocale(1049) then
    {$IFNDEF SILENTMODE}
      ShowError(SysErrorMessage(GetLastError()));
    {$ENDIF}
  //---
  gDirApp := ExtractFilePath(ParamStr(0));
  gStartTimeStr := GetTimeStampStr();
  gDirLog  := gDirApp + 'log\' + gStartTimeStr + '\';
  gDirDump := gDirLog + 'dump\';
  //---
  {$IFDEF UNICODE}
    gAnsiDirApp       := AnsiString(gDirApp);
    gAnsiDirDump      := AnsiString(gDirDump);
    gAnsiDirLog       := AnsiString(gDirLog);
    gAnsiStartTimeStr := AnsiString(gStartTimeStr);
  {$ELSE}
    gAnsiDirApp       := gDirApp;
    gAnsiDirDump      := gDirDump;
    gAnsiDirLog       := gDirLog;
    gAnsiStartTimeStr := gStartTimeStr;
  {$ENDIF}
  //---
  {
  gCharsNumStr      := _MakeCharsString(gCharsNum);
  gCharsEngLowStr   := _MakeCharsString(gCharsEngLow);
  gCharsEngHighStr  := _MakeCharsString(gCharsEngHigh);
  gCharsEngStr      := _MakeCharsString(gCharsEng);
  gFileNameCharsStr := _MakeCharsString(gFileNameChars);
  }
end.
