unit uGlobalVars;

interface

uses SysUtils, Graphics, uGlobalTypes;

const
  CR = #13;
  LF = #10;
  CRLF = #13#10;


const
  gCharsNum = ['0'..'9'];
  gCharsEngLow = ['a'..'z'];
  gCharsEngHigh = ['A'..'Z'];
  gCharsEng = gCharsEngLow + gCharsEngHigh;

  gFileNameChars = gCharsNum + gCharsEng + ['@','-','_','.'];

const
  gDisableColor: array[False..True] of TColor = (
   clBtnFace,
   clWindow
  );

var
  gDirApp: string;
  gDirDump: string;
  gDirLog: string;
  gStartTimeStr: string;

  {$IFDEF UNICODE}
  gAnsiDirApp: AnsiString;
  gAnsiDirDump: AnsiString;
  gAnsiDirLog: AnsiString;
  gAnsiStartTimeStr: AnsiString;
  {$ENDIF}

implementation

initialization
  gDirApp := ExtractFilePath(ParamStr(0));
  gStartTimeStr := FormatDateTime('yyyymmddhhnnsszzz', Now());
  gDirLog  := gDirApp + 'log\' + gStartTimeStr + '\';
  gDirDump := gDirLog + 'dump\';

  {$IFDEF UNICODE}
  gAnsiDirApp       := AnsiString(gDirApp);
  gAnsiDirDump      := AnsiString(gDirDump);
  gAnsiDirLog       := AnsiString(gDirLog);
  gAnsiStartTimeStr := AnsiString(gStartTimeStr);
  {$ENDIF}

end.
