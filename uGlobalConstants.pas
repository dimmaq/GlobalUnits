unit uGlobalConstants;

interface

uses Graphics;

const
  CR = AnsiChar(#13);
  LF = AnsiChar(#10);
  CRLF = #13#10;
const
  _CRLF: ShortString = #13#10;

const
  gCharsNum = ['0'..'9'];
  gCharsEngLow = ['a'..'z'];
  gCharsEngHigh = ['A'..'Z'];
  gCharsEng = gCharsEngLow + gCharsEngHigh;
  gFileNameChars = gCharsNum + gCharsEng + ['@','-','_','.'];
  gCharsSpace = [#9, #10, #13, #32];


const
  gCharsNumStr      = '0123456789';
  gCharsEngLowStr   = 'abcdefghijklmnopqrstuvwxyz';
  gCharsEngHighStr  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  gCharsEngStr      = gCharsEngLowStr + gCharsEngHighStr;
  gCharsEngNumStr   = gCharsEngStr + gCharsNumStr;
  gFileNameCharsStr = gCharsNumStr + gCharsEngStr + '@-_.';
  gCharsHexStr      = '0123456789ABCDEF';

const
  gDisableColor: array[False..True] of TColor = (
   clBtnFace,
   clWindow
  );


const
  csSPECIALS = ['(', ')', '[', ']', '<', '>', ':', ';', '.', ',', '@', '\', '"'];  {Do not Localize}
  csNeedEncode = [#0..#31, #127..#255] + csSPECIALS;
  csReqQuote = csNeedEncode + ['?', '=', '_'];   {Do not Localize}


implementation

end.
