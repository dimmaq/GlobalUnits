unit uHeaderList;

{$DEFINE USEINLINE}

interface

uses
  Classes, uAnsiStrings;

type
  THeaderList = class(TAnsiStringList)
  protected
    FNameValueSeparator : AnsiString;
    FUnfoldLines : Boolean;
    FFoldLines : Boolean;
    FFoldLinesLength : Integer;
    //
    {This deletes lines which were folded}
    Procedure DeleteFoldedLines(Index : Integer);
    {This folds one line into several lines}
    function FoldLine(AString : AnsiString) : TAnsiStrings;
    {Folds lines and inserts them into a position, Index}
    procedure FoldAndInsert(AString : AnsiString; Index : Integer);
    {Name property get method}
    function GetName(Index: Integer): AnsiString;
    {Value property get method}
    function GetValue(const AName: AnsiString): AnsiString;
    {Value property get method}
    function GetParam(const AName, AParam: AnsiString): AnsiString;
    {Value property set method}
    procedure SetValue(const AName, AValue: AnsiString);
    {Value property set method}
    procedure SetParam(const AName, AParam, AValue: AnsiString);
    {Gets a value from a AnsiString}
    function GetValueFromLine(ALine : Integer) : AnsiString;
    Function GetNameFromLine(ALine : Integer) : AnsiString;
  public
    { This method extracts "name=value" strings from the ASrc TAnsiStrings and adds
      them to this list using our delimiter defined in NameValueSeparator. }
    procedure AddStdValues(ASrc: TAnsiStrings);
    { This method adds a single name/value pair to this list using our delimiter
      defined in NameValueSeparator. }
    procedure AddValue(const AName, AValue: AnsiString); // allows duplicates
    { This method extracts all of the values from this list and puts them in the
      ADest TAnsiStrings as "name=value" strings.}
    procedure ConvertToStdValues(ADest: TAnsiStrings);
    constructor Create;
    { This method, given a name specified by AName, extracts all of the values
      for that name and puts them in a new AnsiString list (just the values) one
      per line in the ADest TIdStrings.}
    procedure Extract(const AName: AnsiString; ADest: TAnsiStrings);
    { This property works almost exactly as Borland's IndexOfName except it
      uses our delimiter defined in NameValueSeparator }
    function IndexOfName(const AName: AnsiString): Integer; reintroduce;
    { This property works almost exactly as Borland's Names except it uses
      our delimiter defined in NameValueSeparator }
    property Names[Index: Integer]: AnsiString read GetName;
    { This property works almost exactly as Borland's Values except it uses
      our delimiter defined in NameValueSeparator }
    property Values[const Name: AnsiString]: AnsiString read GetValue write SetValue;
    property Params[const Name, Param: AnsiString]: AnsiString read GetParam write SetParam;
    { This is the separator we need to separate the name from the value }
    property NameValueSeparator : AnsiString read FNameValueSeparator
      write FNameValueSeparator;
    { Should we unfold lines so that continuation header data is returned as
    well}
    property UnfoldLines : Boolean read FUnfoldLines write FUnfoldLines;
    { Should we fold lines we the Values(x) property is set with an
    assignment }
    property FoldLines : Boolean read FFoldLines write FFoldLines;
    { The Wrap position for our folded lines }
    property FoldLength : Integer read FFoldLinesLength write FFoldLinesLength;
  end;

implementation

uses
  SysUtils, AcedStrings, uGlobalFunctions
  {$IFDEF UNICODE}
    , AnsiStrings
  {$ENDIF}
//  ,IdGlobal, IdGlobalProtocols
  ;

const
  LF = #10;
  CR = #13;
  EOL = CR + LF;
  TAB = #9;
  CHAR32 = #32;
  LWS = TAB + CHAR32;
  LWS2 = [#9, #32];
  token_specials = '()<>@,;:\"/[]?='; {do not localize}

function CharPosInSet(const AString: AnsiString; const ACharPos: Integer;
  const ASet: AnsiString): Integer; {$IFDEF USEINLINE}inline;{$ENDIF}
var
  LChar: AnsiChar;
  I: Integer;
begin
  Result := 0;
  if (0<ACharPos) and (ACharPos <= Length(AString)) then
  begin
    LChar := AString[ACharPos];
    for I := 1 to Length(ASet) do
    begin
      if ASet[I] = LChar then
      begin
        Result := I;
        Exit
      end
    end
  end
end;

function CharIsInSet(const AString: AnsiString; const ACharPos: Integer;
  const ASet: AnsiString): Boolean; {$IFDEF USEINLINE}inline;{$ENDIF}
begin
  Result := CharPosInSet(AString, ACharPos, ASet) > 0;
end;

function CharIsInSet2(const AString: AnsiString; const ACharPos: Integer;
  const ASet: TSysCharSet): Boolean; {$IFDEF USEINLINE}inline;{$ENDIF}
begin
  if (0<ACharPos) and (ACharPos <= Length(AString)) then
  begin
    Result := AString[ACharPos] in ASet;
  end
  else
  begin
    Result := False;
  end;
end;

function TextIsSame(const A1, A2: AnsiString): Boolean;
{$IFDEF USEINLINE}inline;{$ENDIF}
begin
  {$IFDEF DOTNET}
  Result := System.String.Compare(A1, A2, True) = 0;
  {$ELSE}
  Result := G_CompareText(A1, A2) = 0;
  {$ENDIF}
end;

{This is taken from Borland's SysUtils and modified for our folding}    {Do not Localize}
function IndyWrapText(const ALine, ABreakStr, ABreakChars : AnsiString;
  MaxCol: Integer): AnsiString;
const
  QuoteChars = '"';    {Do not Localize}
var
  LCol, LPos: Integer;
  LLinePos, LLineLen: Integer;
  LBreakLen, LBreakPos: Integer;
  LQuoteChar, LCurChar: AnsiChar;
  LExistingBreak: Boolean;
begin
  LCol := 1;
  LPos := 1;
  LLinePos := 1;
  LBreakPos := 0;
  LQuoteChar := ' ';    {Do not Localize}
  LExistingBreak := False;
  LLineLen := Length(ALine);
  LBreakLen := Length(ABreakStr);
  Result := '';    {Do not Localize}
  while LPos <= LLineLen do begin
    LCurChar := ALine[LPos];
    if IsLeadChar(LCurChar) then begin
      Inc(LPos);
      Inc(LCol);
    end else begin //if CurChar in LeadBytes then
      if LCurChar = ABreakStr[1] then begin
        if LQuoteChar = ' ' then begin   {Do not Localize}
          LExistingBreak := TextIsSame(ABreakStr, Copy(ALine, LPos, LBreakLen));
          if LExistingBreak then begin
            Inc(LPos, LBreakLen-1);
            LBreakPos := LPos;
          end; //if ExistingBreak then
        end // if QuoteChar = ' ' then    {Do not Localize}
      end else begin// if CurChar = BreakStr[1] then
        if CharIsInSet(LCurChar, 1, ABreakChars) then begin
          if LQuoteChar = ' ' then begin   {Do not Localize}
            LBreakPos := LPos;
          end;
        end else begin // if CurChar in BreakChars then
          if CharIsInSet(LCurChar, 1, QuoteChars) then begin
            if LCurChar = LQuoteChar then begin
              LQuoteChar := ' ';    {Do not Localize}
            end else begin
              if LQuoteChar = ' ' then begin   {Do not Localize}
                LQuoteChar := LCurChar;
              end;
            end;
          end;
        end;
      end;
    end;
    Inc(LPos);
    Inc(LCol);
    if not (CharIsInSet(LQuoteChar, 1, QuoteChars)) and
       (LExistingBreak or
      ((LCol > MaxCol) and (LBreakPos > LLinePos))) then begin
      LCol := LPos - LBreakPos;
      Result := Result + Copy(ALine, LLinePos, LBreakPos - LLinePos + 1);
      if not (CharIsInSet(LCurChar, 1, QuoteChars)) then begin
        while (LPos <= LLineLen) and (CharIsInSet(ALine, LPos, ABreakChars + #13+#10)) do begin
          Inc(LPos);
        end;
        if not LExistingBreak and (LPos < LLineLen) then begin
          Result := Result + ABreakStr;
        end;
      end;
      Inc(LBreakPos);
      LLinePos := LBreakPos;
      LExistingBreak := False;
    end; //if not
  end; //while Pos <= LineLen do
  Result := Result + Copy(ALine, LLinePos, MaxInt);
end;

const
  IdFetchDelimDefault = ' ';    {Do not Localize}
  IdFetchDeleteDefault = True;
  IdFetchCaseSensitiveDefault = True;

function FetchCaseInsensitive(var AInput: AnsiString;
  const ADelim: AnsiString = IdFetchDelimDefault;
  const ADelete: Boolean = IdFetchDeleteDefault): AnsiString;
{$IFDEF USEINLINE}inline;{$ENDIF}
var
  LPos: Integer;
begin
  LPos := G_PosStr(ADelim, AInput);
  if LPos = 0 then begin
    Result := AInput;
    if ADelete then begin
      AInput := '';    {Do not Localize}
    end;
  end else begin
    Result := Copy(AInput, 1, LPos - 1);
    if ADelete then begin
      //faster than Delete(AInput, 1, LPos + Length(ADelim) - 1); because the
      //remaining part is larger than the deleted
      AInput := Copy(AInput, LPos + Length(ADelim), MaxInt);
    end;
  end;
end;

function Fetch(var AInput: AnsiString; const ADelim: AnsiString = IdFetchDelimDefault;
  const ADelete: Boolean = IdFetchDeleteDefault;
  const ACaseSensitive: Boolean = IdFetchCaseSensitiveDefault): AnsiString;
{$IFDEF USEINLINE}inline;{$ENDIF}
var
  LPos: Integer;
begin
  if ACaseSensitive then begin
    LPos := G_PosStr(ADelim, AInput);
    if LPos = 0 then begin
      Result := AInput;
      if ADelete then begin
        AInput := '';    {Do not Localize}
      end;
    end
    else begin
      Result := Copy(AInput, 1, LPos - 1);
      if ADelete then begin
        //slower Delete(AInput, 1, LPos + Length(ADelim) - 1); because the
        //remaining part is larger than the deleted
        AInput := Copy(AInput, LPos + Length(ADelim), MaxInt);
      end;
    end;
  end else begin
    Result := FetchCaseInsensitive(AInput, ADelim, ADelete);
  end;
end;

function TextStartsWith(const S, SubS: AnsiString): Boolean;
var
  LLen: Integer;
//  P1, P2: PAnsiChar;
begin
  LLen := Length(SubS);
  Result := LLen <= Length(S);
  if Result then
  begin
    Result := G_CompareTextL(S, SubS, LLen) = 0
  end;
end;

function IndyMax(const AValueOne, AValueTwo: Int64): Int64;
{$IFDEF USEINLINE}inline;{$ENDIF} overload;
begin
  if AValueOne < AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IndyMax(const AValueOne, AValueTwo: LongInt): LongInt;
{$IFDEF USEINLINE}inline;{$ENDIF} overload;
begin
  if AValueOne < AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IndyMax(const AValueOne, AValueTwo: Word): Word;
{$IFDEF USEINLINE}inline;{$ENDIF} overload;
begin
  if AValueOne < AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IndyMin(const AValueOne, AValueTwo: LongInt): LongInt;
{$IFDEF USEINLINE}inline;{$ENDIF} overload;
begin
  if AValueOne > AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IndyMin(const AValueOne, AValueTwo: Int64): Int64;
{$IFDEF USEINLINE}inline;{$ENDIF} overload;
begin
  if AValueOne > AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IndyMin(const AValueOne, AValueTwo: Word): Word;
{$IFDEF USEINLINE}inline;{$ENDIF} overload;
begin
  if AValueOne > AValueTwo then begin
    Result := AValueTwo;
  end else begin
    Result := AValueOne;
  end;
end;

function IndyLength(const ABuffer: AnsiString; const ALength: Integer = -1; const AIndex: Integer = 1): Integer;
{$IFDEF USEINLINE}inline;{$ENDIF}
var
  LAvailable: Integer;
begin
  Assert(AIndex >= 1);
  LAvailable := IndyMax(Length(ABuffer)-AIndex+1, 0);
  if ALength < 0 then begin
    Result := LAvailable;
  end else begin
    Result := IndyMin(LAvailable, ALength);
  end;
end;

function FindFirstOf(const AFind, AText: AnsiString;
  const ALength: Integer = -1; const AStartPos: Integer = 1): Integer;
var
  I, LLength, LPos: Integer;
begin
  Result := 0;
  if Length(AFind) > 0 then begin
    LLength := IndyLength(AText, ALength, AStartPos);
    if LLength > 0 then begin
      for I := 0 to LLength-1 do begin
        LPos := AStartPos + I;
        if G_PosStr(AText[LPos], AFind) <> 0 then begin
          Result := LPos;
          Exit;
        end;
      end;
    end;
  end;
end;

procedure SplitHeaderSubItems(AHeaderLine: AnsiString; AItems: TAnsiStrings);
var
  LName, LValue: AnsiString;
  I: Integer;

  function FetchQuotedString(var VHeaderLine: AnsiString): AnsiString;
  begin
    Result := '';
    Delete(VHeaderLine, 1, 1);
    I := 1;
    while I <= Length(VHeaderLine) do
    begin
      if VHeaderLine[I] = '\' then begin
        if I < Length(VHeaderLine) then begin
          Delete(VHeaderLine, I, 1);
        end;
      end
      else if VHeaderLine[I] = '"' then begin
        Result := Copy(VHeaderLine, 1, I-1);
        VHeaderLine := Copy(VHeaderLine, I+1, MaxInt);
        Break;
      end;
      Inc(I);
    end;
    Fetch(VHeaderLine, ';');
  end;

begin
  Fetch(AHeaderLine, ';'); { do not localize}
  while AHeaderLine <> '' do
  begin
    AHeaderLine := TrimLeft(AHeaderLine);
    if AHeaderLine = '' then begin
      Exit;
    end;
    LName := Trim(Fetch(AHeaderLine, '=')); {do not localize}
    AHeaderLine := TrimLeft(AHeaderLine);
    if TextStartsWith(AHeaderLine, '"') then {do not localize}
    begin
      LValue := FetchQuotedString(AHeaderLine);
    end else
    begin
      I := FindFirstOf(' ' + token_specials, AHeaderLine);
      if I <> 0 then
      begin
        LValue := Copy(AHeaderLine, 1, I-1);
        if AHeaderLine[I] = ';' then begin {do not localize}
          Inc(I);
        end;
        Delete(AHeaderLine, 1, I-1);
      end else
      begin
        LValue := AHeaderLine;
        AHeaderLine := '';
      end;
    end;
    if (LName <> '') and (LValue <> '') then begin
      AItems.Add(LName + '=' + LValue);
    end;
  end;
end;

function ExtractHeaderSubItem(const AHeaderLine, ASubItem: AnsiString): AnsiString;
var
  LItems: TAnsiStringList;
  {$IFNDEF VCL6ORABOVE}
  I: Integer;
  LTmp: AnsiString;
  {$ENDIF}
begin
  Result := '';
  LItems := TAnsiStringList.Create;
  try
    SplitHeaderSubItems(AHeaderLine, LItems);
    {$IFDEF VCL6ORABOVE}
    LItems.CaseSensitive := False;
    Result := LItems.Values[ASubItem];
    {$ELSE}
    for I := 0 to LItems.Count-1 do
    begin
      if TextIsSame(LItems.Names[I], ASubItem) then
      begin
        LTmp := LItems.Strings[I];
        Result := Copy(LTmp, G_CharPos('=', LTmp)+1, MaxInt); {do not localize}
        Break;
      end;
    end;
    {$ENDIF}
  finally
    LItems.Free;
  end;
end;

function ExtractHeaderItem(const AHeaderLine: AnsiString): AnsiString;
var s: AnsiString;
begin
  // Store in s and not Result because of Fetch semantics
  s := AHeaderLine;
  Result := Trim(Fetch(s, ';')); {do not localize}
end;

function ReplaceHeaderSubItem(const AHeaderLine, ASubItem, AValue: AnsiString): AnsiString;
var
  LItems: TAnsiStringList;
  I: Integer;
  LTmp: AnsiString;

  function QuoteString(const S: AnsiString): AnsiString;
  var
    I: Integer;
    LQuotesNeeded: Boolean;
  begin
    Result := '';
    LQuotesNeeded := False;
    for I := 1 to Length(S) do begin
      if CharIsInSet(S, I, token_specials) then begin
        Result := Result + '\'; {do not localize}
        LQuotesNeeded := True;
      end;
      Result := Result + S[I];
    end;
    if LQuotesNeeded then begin
      Result := '"' + Result + '"';
    end;
  end;

begin
  Result := '';
  LItems := TAnsiStringList.Create;
  try
    SplitHeaderSubItems(AHeaderLine, LItems);
    LItems.CaseSensitive := False;
    LItems.Values[ASubItem] := Trim(AValue);
    Result := ExtractHeaderItem(AHeaderLine);
    if Result <> '' then begin
      for I := 0 to LItems.Count-1 do begin
        LTmp := LItems.Strings[I];

        Result := Result + '; ' + LItems.Names[I] + '=' + QuoteString(Copy(LTmp, {$IFDEF UNICODE}AnsiStrings.{$ENDIF}PosEx('=', LTmp)+1, MaxInt)); {do not localize}
      end;
    end;
  finally
    LItems.Free;
  end;
end;

{ THeaderList }

procedure THeaderList.AddStdValues(ASrc: TAnsiStrings);
var
  i: integer;
begin
  for i := 0 to ASrc.Count - 1 do begin
    Add({$IFDEF UNICODE}AnsiStrings.{$ENDIF}StringReplace(ASrc[i], '=', NameValueSeparator, []));    {Do not Localize}




  end;
end;

procedure THeaderList.AddValue(const AName, AValue: AnsiString);
var
  I: Integer;
begin
  if (AName <> '') and (AValue <> '') then begin  {Do not Localize}
    I := Add('');    {Do not Localize}
    if FFoldLines then begin
      FoldAndInsert(AName + FNameValueSeparator + AValue, I);
    end else begin
      Put(I, AName + FNameValueSeparator + AValue);
    end;
  end;
end;

procedure THeaderList.ConvertToStdValues(ADest: TAnsiStrings);
var
  i: LongInt;
begin
  for i := 0 to Count - 1 do begin
    ADest.Add(AnsiStrings.StringReplace(Strings[i], NameValueSeparator, '=', []));    {Do not Localize}
  end;
end;

constructor THeaderList.Create;
begin
  inherited Create;
  FNameValueSeparator := ': ';    {Do not Localize}
  FUnfoldLines := True;
  FFoldLines := True;
  { 78 was specified by a message draft available at
    http://www.imc.org/draft-ietf-drums-msg-fmt }
  FFoldLinesLength := 78;
end;

procedure THeaderList.DeleteFoldedLines(Index: Integer);
begin
  Inc(Index);  {skip the current line}
  if Index < Count then begin
    while (Index < Count) and  CharIsInSet2(Get(Index), 1, LWS2) do begin {Do not Localize}
      Delete(Index);
    end;
  end;
end;

procedure THeaderList.Extract(const AName: AnsiString; ADest: TAnsiStrings);
var
  idx : LongInt;
begin
  if Assigned(ADest) then begin
    for idx := 0 to Count - 1 do
    begin
      if G_CompareText(AName, GetNameFromLine(idx))=0 then
      begin
        ADest.Add(GetValueFromLine(idx));
      end;
    end;
  end;
end;

procedure THeaderList.FoldAndInsert(AString : AnsiString; Index: Integer);
var
  LStrs : TAnsiStrings;
  idx : LongInt;
begin
  LStrs := FoldLine(AString);
  try
    idx := LStrs.Count - 1;
    Put(Index, LStrs[idx]);
    {We decrement by one because we put the last AnsiString into the HeaderList}
    Dec(idx);
    while idx > -1 do
    begin
      Insert(Index, LStrs[idx]);
      Dec(idx);
    end;
  finally
    FreeAndNil(LStrs);
  end;  //finally
end;

function THeaderList.FoldLine(AString : AnsiString): TAnsiStrings;
var
  s : AnsiString;
begin
  Result := TAnsiStringList.Create;
  try
    {we specify a space so that starts a folded line}
    s := IndyWrapText(AString, EOL+' ', LWS+',', FFoldLinesLength);    {Do not Localize}
    while s <> '' do begin  {Do not Localize}
      Result.Add(TrimRight(Fetch(s, EOL)));
    end; // while s <> '' do    {Do not Localize}
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function THeaderList.GetName(Index: Integer): AnsiString;
var
  P: Integer;
begin
  Result := Get(Index);
  P := G_PosStr(FNameValueSeparator, Result);
  if P <> 0 then begin
    SetLength(Result, P - 1);
  end else begin
    SetLength(Result, 0);
  end;
end;

function THeaderList.GetNameFromLine(ALine: Integer): AnsiString;
var
  p : Integer;
begin
  Result := Get(ALine);

  {We trim right to remove space to accomodate header errors such as

  Message-ID:<asdf@fdfs
  }
  P := G_PosStr(TrimRight(FNameValueSeparator), Result);

  Result := Copy(Result, 1, P - 1);
end;

function THeaderList.GetValue(const AName: AnsiString): AnsiString;
begin
  Result := GetValueFromLine(IndexOfName(AName));
end;

function THeaderList.GetValueFromLine(ALine: Integer): AnsiString;
var
  LLine, LSep: AnsiString;
  P: Integer;
begin
  if (ALine >= 0) and (ALine < Count) then begin
    LLine := Get(ALine);

    {We trim right to remove space to accomodate header errors such as

    Message-ID:<asdf@fdfs
    }
    LSep := TrimRight(FNameValueSeparator);
    P := G_PosStr(LSep, LLine);

    Result := TrimLeft(Copy(LLine, P + Length(LSep), MaxInt));
    if FUnfoldLines then begin
      repeat
        Inc(ALine);
        if ALine = Count then begin
          Break;
        end;
        LLine := Get(ALine);
        // s[1] is safe since header lines cannot be empty as that causes then end of the header block
        if not CharIsInSet2(LLine, 1, LWS2) then begin
          Break;
        end;
        Result := Trim(Result) + ' ' + Trim(LLine); {Do not Localize}
      until False;
    end;
    // User may be fetching an folded line diretly.
    Result := Trim(Result);
  end else begin
    Result := ''; {Do not Localize}
  end;
end;

function THeaderList.GetParam(const AName, AParam: AnsiString): AnsiString;
var
  s: AnsiString;
begin
  s := Values[AName];
  if s <> '' then begin
    Result := ExtractHeaderSubItem(s, AParam);
  end else begin
    Result := '';
  end;
end;

function THeaderList.IndexOfName(const AName: AnsiString): Integer;
var
  i: LongInt;
begin
  Result := -1;
  for i := 0 to Count - 1 do begin
    if TextIsSame(GetNameFromLine(i), AName) then begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure THeaderList.SetValue(const AName, AValue: AnsiString);
var
  I: Integer;
begin
  I := IndexOfName(AName);
  if AValue <> '' then begin  {Do not Localize}
    if I < 0 then begin
      I := Add('');    {Do not Localize}
    end;
    if FFoldLines then begin
      DeleteFoldedLines(I);
      FoldAndInsert(AName + FNameValueSeparator + AValue, I);
    end else begin
      Put(I, AName + FNameValueSeparator + AValue);
    end;
  end
  else if I >= 0 then begin
    if FFoldLines then begin
      DeleteFoldedLines(I);
    end;
    Delete(I);
  end;
end;

procedure THeaderList.SetParam(const AName, AParam, AValue: AnsiString);
begin
  Values[AName] := ReplaceHeaderSubItem(Values[AName], AParam, AValue);
end;

end.
