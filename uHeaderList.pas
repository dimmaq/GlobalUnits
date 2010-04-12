unit uHeaderList;

interface

uses
  Classes, uAnsiStrings
  {$IFDEF UNICODE}
    , AnsiStrings
  {$ENDIF}
  ;

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
  IdGlobal,
  IdGlobalProtocols, SysUtils, AcedStrings;

{ TIdHeaderList }

procedure THeaderList.AddStdValues(ASrc: TAnsiStrings);
var
  i: integer;
begin
  for i := 0 to ASrc.Count - 1 do begin
    Add(StringReplace(ASrc[i], '=', NameValueSeparator, []));    {Do not Localize}
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
    ADest.Add(ReplaceOnlyFirst(Strings[i], NameValueSeparator, '='));    {Do not Localize}
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
    while (Index < Count) and CharIsInSet(Get(Index), 1, LWS) do begin {Do not Localize}
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
      if TextIsSame(AName, GetNameFromLine(idx)) then begin
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
  Result := TStringList.Create;
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
  P := IndyPos(FNameValueSeparator, Result);
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
  P := IndyPos(TrimRight(FNameValueSeparator), Result);

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
    P := IndyPos(LSep, LLine);

    Result := TrimLeft(Copy(LLine, P + Length(LSep), MaxInt));
    if FUnfoldLines then begin
      repeat
        Inc(ALine);
        if ALine = Count then begin
          Break;
        end;
        LLine := Get(ALine);
        // s[1] is safe since header lines cannot be empty as that causes then end of the header block
        if not CharIsInSet(LLine, 1, LWS) then begin
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
