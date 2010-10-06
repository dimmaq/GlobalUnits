unit uGlobalTypes;

interface

type
  TAnsiStringDynArray = array of AnsiString;

  TAStrIntRec = record
    S: AnsiString;
    I: Integer;
  end;

  TAStrIntArray = array of TAStrIntRec;

{$IFDEF UNICODE}
  TStrIntRec = record
    S: string;
    I: Integer;
  end;
{$ELSE}
  TStrIntRec = TAStrIntRec;
{$ENDIF}




  {$IFNDEF UNICODE}
    RawByteString = AnsiString;
    UnicodeString = AnsiString;
    TCharArray = array of Char; {SysUtils}
  {$ENDIF}

implementation

end.
