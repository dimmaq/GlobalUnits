unit uAnsiStrings;

interface

{$IFNDEF UNICODE}
uses
  Classes;

type
    TAnsiAnsiStrings = TAnsiStrings;
    TAnsiAnsiStringList = TAnsiStringList;

implementation

{$ELSE UNICODE}

uses
  Windows, SysUtils, Classes, AnsiStrings;

type
  TAnsiStrings = class;

{ TAnsiStrings class }

  TAnsiStringsEnumerator = class
  private
    FIndex: Integer;
    FAnsiStrings: TAnsiStrings;
  public
    constructor Create(AAnsiStrings: TAnsiStrings);
    function GetCurrent: AnsiString; inline;
    function MoveNext: Boolean;
    property Current: AnsiString read GetCurrent;
  end;

  TAnsiStrings = class(TPersistent)
  private
    FDefined: TStringsDefined;
    FDelimiter: AnsiChar;
    FLineBreak: AnsiString;
    FQuoteChar: AnsiChar;
    FNameValueSeparator: AnsiChar;
    FStrictDelimiter: Boolean;
    FUpdateCount: Integer;
    function GetCommaText: AnsiString;
    function GetDelimitedText: AnsiString;
    function GetName(Index: Integer): AnsiString;
    function GetValue(const Name: AnsiString): AnsiString;
    procedure ReadData(Reader: TReader);
    procedure SetCommaText(const Value: AnsiString);
    procedure SetDelimitedText(const Value: AnsiString);
    procedure SetValue(const Name, Value: AnsiString);
    procedure WriteData(Writer: TWriter);
    function GetDelimiter: AnsiChar;
    procedure SetDelimiter(const Value: AnsiChar);
    function GetLineBreak: AnsiString;
    procedure SetLineBreak(const Value: AnsiString);
    function GetQuoteChar: AnsiChar;
    procedure SetQuoteChar(const Value: AnsiChar);
    function GetNameValueSeparator: AnsiChar;
    procedure SetNameValueSeparator(const Value: AnsiChar);
    function GetStrictDelimiter: Boolean;
    procedure SetStrictDelimiter(const Value: Boolean);
    function GetValueFromIndex(Index: Integer): AnsiString;
    procedure SetValueFromIndex(Index: Integer; const Value: AnsiString);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure Error(const Msg: string; Data: Integer); overload;
    procedure Error(Msg: PResStringRec; Data: Integer); overload;
    function ExtractName(const S: AnsiString): AnsiString;
    function Get(Index: Integer): AnsiString; virtual; abstract;
    function GetCapacity: Integer; virtual;
    function GetCount: Integer; virtual; abstract;
    function GetObject(Index: Integer): TObject; virtual;
    function GetTextStr: AnsiString; virtual;
    procedure Put(Index: Integer; const S: AnsiString); virtual;
    procedure PutObject(Index: Integer; AObject: TObject); virtual;
    procedure SetCapacity(NewCapacity: Integer); virtual;
    procedure SetTextStr(const Value: AnsiString); virtual;
    procedure SetUpdateState(Updating: Boolean); virtual;
    property UpdateCount: Integer read FUpdateCount;
    function CompareAnsiStrings(const S1, S2: AnsiString): Integer; virtual;
  public
    destructor Destroy; override;
    function Add(const S: AnsiString): Integer; virtual;
    function AddObject(const S: AnsiString; AObject: TObject): Integer; virtual;
    procedure Append(const S: AnsiString);
    procedure AddAnsiStrings(AnsiStrings: TAnsiStrings); virtual;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Clear; virtual; abstract;
    procedure Delete(Index: Integer); virtual; abstract;
    procedure EndUpdate;
    function Equals(AnsiStrings: TAnsiStrings): Boolean; reintroduce;
    procedure Exchange(Index1, Index2: Integer); virtual;
    function GetEnumerator: TAnsiStringsEnumerator;
    function GetText: PAnsiChar; virtual;
    function IndexOf(const S: AnsiString): Integer; virtual;
    function IndexOfName(const Name: AnsiString): Integer; virtual;
    function IndexOfObject(AObject: TObject): Integer; virtual;
    procedure Insert(Index: Integer; const S: AnsiString); virtual; abstract;
    procedure InsertObject(Index: Integer; const S: AnsiString;
      AObject: TObject); virtual;
    procedure LoadFromFile(const FileName: string); overload; virtual;
    procedure LoadFromFile(const FileName: string; Encoding: TEncoding); overload; virtual;
    procedure LoadFromStream(Stream: TStream); overload; virtual;
    procedure LoadFromStream(Stream: TStream; Encoding: TEncoding); overload; virtual;
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    procedure SaveToFile(const FileName: string); overload; virtual;
    procedure SaveToFile(const FileName: string; Encoding: TEncoding); overload; virtual;
    procedure SaveToStream(Stream: TStream); overload; virtual;
    procedure SaveToStream(Stream: TStream; Encoding: TEncoding); overload; virtual;
    procedure SetText(Text: PAnsiChar); virtual;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property CommaText: AnsiString read GetCommaText write SetCommaText;
    property Count: Integer read GetCount;
    property Delimiter: AnsiChar read GetDelimiter write SetDelimiter;
    property DelimitedText: AnsiString read GetDelimitedText write SetDelimitedText;
    property LineBreak: AnsiString read GetLineBreak write SetLineBreak;
    property Names[Index: Integer]: AnsiString read GetName;
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    property QuoteChar: AnsiChar read GetQuoteChar write SetQuoteChar;
    property Values[const Name: AnsiString]: AnsiString read GetValue write SetValue;
    property ValueFromIndex[Index: Integer]: AnsiString read GetValueFromIndex write SetValueFromIndex;
    property NameValueSeparator: AnsiChar read GetNameValueSeparator write SetNameValueSeparator;
    property StrictDelimiter: Boolean read GetStrictDelimiter write SetStrictDelimiter;
    property AnsiStrings[Index: Integer]: AnsiString read Get write Put; default;
    property Text: AnsiString read GetTextStr write SetTextStr;
  end;

{ TAnsiStringList class }

  TAnsiStringList = class;

  PAnsiStringItem = ^TAnsiStringItem;
  TAnsiStringItem = record
    FAnsiString: AnsiString;
    FObject: TObject;
  end;

  PAnsiStringItemList = ^TAnsiStringItemList;
  TAnsiStringItemList = array[0..MaxListSize] of TAnsiStringItem;
  TAnsiStringListSortCompare = function(List: TAnsiStringList; Index1, Index2: Integer): Integer;

  TAnsiStringList = class(TAnsiStrings)
  private
    FList: PAnsiStringItemList;
    FCount: Integer;
    FCapacity: Integer;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    FCaseSensitive: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    FOwnsObject: Boolean;
    procedure ExchangeItems(Index1, Index2: Integer);
    procedure Grow;
    procedure QuickSort(L, R: Integer; SCompare: TAnsiStringListSortCompare);
    procedure SetSorted(Value: Boolean);
    procedure SetCaseSensitive(const Value: Boolean);
  protected
    procedure Changed; virtual;
    procedure Changing; virtual;
    function Get(Index: Integer): AnsiString; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: AnsiString); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetUpdateState(Updating: Boolean); override;
    function CompareAnsiStrings(const S1, S2: AnsiString): Integer; override;
    procedure InsertItem(Index: Integer; const S: AnsiString; AObject: TObject); virtual;
  public
    constructor Create; overload;
    constructor Create(OwnsObjects: Boolean); overload;
    destructor Destroy; override;
    function Add(const S: AnsiString): Integer; override;
    function AddObject(const S: AnsiString; AObject: TObject): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    function Find(const S: AnsiString; var Index: Integer): Boolean; virtual;
    function IndexOf(const S: AnsiString): Integer; override;
    procedure Insert(Index: Integer; const S: AnsiString); override;
    procedure InsertObject(Index: Integer; const S: AnsiString;
      AObject: TObject); override;
    procedure Sort; virtual;
    procedure CustomSort(Compare: TAnsiStringListSortCompare); virtual;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write SetSorted;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OwnsObjects: Boolean read FOwnsObject write FOwnsObject;
  end;

implementation

uses RTLConsts, SysConst, Types;

{ TStringsEnumerator }

constructor TAnsiStringsEnumerator.Create(AAnsiStrings: TAnsiStrings);
begin
  inherited Create;
  FIndex := -1;
  FAnsiStrings := AAnsiStrings;
end;

function TAnsiStringsEnumerator.GetCurrent: AnsiString;
begin
  Result := FAnsiStrings[FIndex];
end;

function TAnsiStringsEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FAnsiStrings.Count - 1;
  if Result then
    Inc(FIndex);
end;

{ TAnsiStrings }

destructor TAnsiStrings.Destroy;
begin
  inherited Destroy;
end;

function TAnsiStrings.Add(const S: AnsiString): Integer;
begin
  Result := GetCount;
  Insert(Result, S);
end;

function TAnsiStrings.AddObject(const S: AnsiString; AObject: TObject): Integer;
begin
  Result := Add(S);
  PutObject(Result, AObject);
end;

procedure TAnsiStrings.Append(const S: AnsiString);
begin
  Add(S);
end;

procedure TAnsiStrings.AddAnsiStrings(AnsiStrings: TAnsiStrings);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to AnsiStrings.Count - 1 do
      AddObject(AnsiStrings[I], AnsiStrings.Objects[I]);
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.Assign(Source: TPersistent);
begin
  if Source is TAnsiStrings then
  begin
    BeginUpdate;
    try
      Clear;
      FDefined := TAnsiStrings(Source).FDefined;
      FNameValueSeparator := TAnsiStrings(Source).FNameValueSeparator;
      FQuoteChar := TAnsiStrings(Source).FQuoteChar;
      FDelimiter := TAnsiStrings(Source).FDelimiter;
      FLineBreak := TAnsiStrings(Source).FLineBreak;
      FStrictDelimiter := TAnsiStrings(Source).FStrictDelimiter;
      AddAnsiStrings(TAnsiStrings(Source));
    finally
      EndUpdate;
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

procedure TAnsiStrings.BeginUpdate;
begin
  if FUpdateCount = 0 then SetUpdateState(True);
  Inc(FUpdateCount);
end;

procedure TAnsiStrings.DefineProperties(Filer: TFiler);

  function DoWrite: Boolean;
  begin
    if Filer.Ancestor <> nil then
    begin
      Result := True;
      if Filer.Ancestor is TAnsiStrings then
        Result := not Equals(TAnsiStrings(Filer.Ancestor))
    end
    else Result := Count > 0;
  end;

begin
  Filer.DefineProperty('AnsiStrings', ReadData, WriteData, DoWrite);
end;

procedure TAnsiStrings.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then SetUpdateState(False);
end;

function TAnsiStrings.Equals(AnsiStrings: TAnsiStrings): Boolean;
var
  I, Count: Integer;
begin
  Result := False;
  Count := GetCount;
  if Count <> AnsiStrings.GetCount then Exit;
  for I := 0 to Count - 1 do if Get(I) <> AnsiStrings.Get(I) then Exit;
  Result := True;
end;

procedure TAnsiStrings.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EStringListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

procedure TAnsiStrings.Error(Msg: PResStringRec; Data: Integer);
begin
  Error(LoadResString(Msg), Data);
end;

procedure TAnsiStrings.Exchange(Index1, Index2: Integer);
var
  TempObject: TObject;
  TempAnsiString: AnsiString;
begin
  BeginUpdate;
  try
    TempAnsiString := AnsiStrings[Index1];
    TempObject := Objects[Index1];
    AnsiStrings[Index1] := AnsiStrings[Index2];
    Objects[Index1] := Objects[Index2];
    AnsiStrings[Index2] := TempAnsiString;
    Objects[Index2] := TempObject;
  finally
    EndUpdate;
  end;
end;

function TAnsiStrings.ExtractName(const S: AnsiString): AnsiString;
var
  P: Integer;
begin
  Result := S;
  P := AnsiPos(NameValueSeparator, Result);
  if P <> 0 then
    SetLength(Result, P-1) else
    SetLength(Result, 0);
end;

function TAnsiStrings.GetCapacity: Integer;
begin  // descendents may optionally override/replace this default implementation
  Result := Count;
end;

function TAnsiStrings.GetCommaText: AnsiString;
var
  LOldDefined: TStringsDefined;
  LOldDelimiter: AnsiChar;
  LOldQuoteChar: AnsiChar;
begin
  LOldDefined := FDefined;
  LOldDelimiter := FDelimiter;
  LOldQuoteChar := FQuoteChar;
  Delimiter := ',';
  QuoteChar := '"';
  try
    Result := GetDelimitedText;
  finally
    FDelimiter := LOldDelimiter;
    FQuoteChar := LOldQuoteChar;
    FDefined := LOldDefined;
  end;
end;

function TAnsiStrings.GetDelimitedText: AnsiString;
var
  S: AnsiString;
  P: PAnsiChar;
  I, Count: Integer;
  LDelimiters: TSysCharSet;
begin
  Count := GetCount;
  if (Count = 1) and (Get(0) = '') then
    Result := QuoteChar + QuoteChar
  else
  begin
    Result := '';
    LDelimiters := [AnsiChar(#0), AnsiChar(QuoteChar), AnsiChar(Delimiter)];
    if not StrictDelimiter then
      LDelimiters := LDelimiters + [AnsiChar(#1)..AnsiChar(' ')];
    for I := 0 to Count - 1 do
    begin
      S := Get(I);
      P := PAnsiChar(S);
      while not (P^ in LDelimiters) do
        Inc(P);
      if (P^ <> #0) then S := AnsiQuotedStr(S, QuoteChar);
      Result := Result + S + Delimiter;
    end;
    System.Delete(Result, Length(Result), 1);
  end;
end;

function TAnsiStrings.GetEnumerator: TAnsiStringsEnumerator;
begin
  Result := TAnsiStringsEnumerator.Create(Self);
end;

function TAnsiStrings.GetName(Index: Integer): AnsiString;
begin
  Result := ExtractName(Get(Index));
end;

function TAnsiStrings.GetObject(Index: Integer): TObject;
begin
  Result := nil;
end;

function TAnsiStrings.GetText: PAnsiChar;
begin
  Result := StrNew(PAnsiChar(GetTextStr));
end;

function TAnsiStrings.GetTextStr: AnsiString;
var
  I, L, Size, Count: Integer;
  P: PAnsiChar;
  S, LB: AnsiString;
begin
  Count := GetCount;
  Size := 0;
  LB := LineBreak;
  for I := 0 to Count - 1 do Inc(Size, Length(Get(I)) + Length(LB));
  SetString(Result, nil, Size);
  P := Pointer(Result);
  for I := 0 to Count - 1 do
  begin
    S := Get(I);
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(Pointer(S)^, P^, L * SizeOf(AnsiChar));
      Inc(P, L);
    end;
    L := Length(LB);
    if L <> 0 then
    begin
      System.Move(Pointer(LB)^, P^, L * SizeOf(AnsiChar));
      Inc(P, L);
    end;
  end;
end;

function TAnsiStrings.GetValue(const Name: AnsiString): AnsiString;
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if I >= 0 then
    Result := Copy(Get(I), Length(Name) + 2, MaxInt) else
    Result := '';
end;

function TAnsiStrings.IndexOf(const S: AnsiString): Integer;
begin
  for Result := 0 to GetCount - 1 do
    if CompareAnsiStrings(Get(Result), S) = 0 then Exit;
  Result := -1;
end;

function TAnsiStrings.IndexOfName(const Name: AnsiString): Integer;
var
  P: Integer;
  S: AnsiString;
begin
  for Result := 0 to GetCount - 1 do
  begin
    S := Get(Result);
    P := AnsiPos(NameValueSeparator, S);
    if (P <> 0) and (CompareAnsiStrings(Copy(S, 1, P - 1), Name) = 0) then Exit;
  end;
  Result := -1;
end;

function TAnsiStrings.IndexOfObject(AObject: TObject): Integer;
begin
  for Result := 0 to GetCount - 1 do
    if GetObject(Result) = AObject then Exit;
  Result := -1;
end;

procedure TAnsiStrings.InsertObject(Index: Integer; const S: AnsiString; AObject: TObject);
begin
  Insert(Index, S);
  PutObject(Index, AObject);
end;

procedure TAnsiStrings.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TAnsiStrings.LoadFromFile(const FileName: string; Encoding: TEncoding);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream, Encoding);
  finally
    Stream.Free;
  end;
end;

procedure TAnsiStrings.LoadFromStream(Stream: TStream);
begin
  LoadFromStream(Stream, nil);
end;

procedure TAnsiStrings.LoadFromStream(Stream: TStream; Encoding: TEncoding);
var
  Size: Integer;
  Buffer: TBytes;
  AnsiBuffer: TBytes;
  StrBuffer: AnsiString;
begin
  BeginUpdate;
  try
    Size := Stream.Size - Stream.Position;
    if Assigned(Encoding) then
    begin
      SetLength(Buffer, Size);
      Stream.Read(Buffer[0], Size);
      AnsiBuffer := TEncoding.Convert(Encoding, TEncoding.Default, Buffer);

      SetLength(StrBuffer, Length(AnsiBuffer));
      if StrBuffer<>'' then
        System.Move(AnsiBuffer[0], StrBuffer[1], Length(AnsiBuffer));
    end
    else
    begin
      SetLength(StrBuffer, Size);
      Stream.Read(StrBuffer[1], Size);
    end;
    SetTextStr(StrBuffer);
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.Move(CurIndex, NewIndex: Integer);
var
  TempObject: TObject;
  TempAnsiString: AnsiString;
begin
  if CurIndex <> NewIndex then
  begin
    BeginUpdate;
    try
      TempAnsiString := Get(CurIndex);
      TempObject := GetObject(CurIndex);
      Delete(CurIndex);
      InsertObject(NewIndex, TempAnsiString, TempObject);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TAnsiStrings.Put(Index: Integer; const S: AnsiString);
var
  TempObject: TObject;
begin
  TempObject := GetObject(Index);
  Delete(Index);
  InsertObject(Index, S, TempObject);
end;

procedure TAnsiStrings.PutObject(Index: Integer; AObject: TObject);
begin
end;

procedure TAnsiStrings.ReadData(Reader: TReader);
begin
  Reader.ReadListBegin;
  BeginUpdate;
  try
    Clear;
    while not Reader.EndOfList do Add(AnsiString(Reader.ReadString));
  finally
    EndUpdate;
  end;
  Reader.ReadListEnd;
end;

procedure TAnsiStrings.SaveToFile(const FileName: string);
begin
  SaveToFile(FileName, nil);
end;

procedure TAnsiStrings.SaveToFile(const FileName: string; Encoding: TEncoding);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream, Encoding);
  finally
    Stream.Free;
  end;
end;

procedure TAnsiStrings.SaveToStream(Stream: TStream);
begin
  SaveToStream(Stream, nil);
end;

procedure TAnsiStrings.SaveToStream(Stream: TStream; Encoding: TEncoding);
var
  Buffer, Preamble: TBytes;
  AnsiBuffer: TBytes;
  StrBuffer: AnsiString;
begin
  StrBuffer := GetTextStr();
  if Assigned(Encoding) then
  begin
    AnsiBuffer := BytesOf(StrBuffer);
    Buffer := TEncoding.Convert(TEncoding.Default, Encoding, AnsiBuffer);
    Preamble := Encoding.GetPreamble;
    if Length(Preamble) > 0 then
      Stream.WriteBuffer(Preamble[0], Length(Preamble));
    Stream.WriteBuffer(Buffer[0], Length(Buffer));
  end
  else
  begin
    if Count>0 then
    begin
      Stream.WriteBuffer(StrBuffer[1], Length(StrBuffer));
    end;
  end;
end;

procedure TAnsiStrings.SetCapacity(NewCapacity: Integer);
begin
  // do nothing - descendents may optionally implement this method
end;

procedure TAnsiStrings.SetCommaText(const Value: AnsiString);
begin
  Delimiter := ',';
  QuoteChar := '"';
  SetDelimitedText(Value);
end;

procedure TAnsiStrings.SetText(Text: PAnsiChar);
begin
  SetTextStr(Text);
end;

procedure TAnsiStrings.SetTextStr(const Value: AnsiString);
var
  P, Start, LB: PAnsiChar;
  S: AnsiString;
  LineBreakLen: Integer;
begin
  BeginUpdate;
  try
    Clear;
    P := Pointer(Value);
    if P <> nil then
      if CompareStr(LineBreak, sLineBreak) = 0 then
      begin
        // This is a lot faster than using StrPos/AnsiStrPos when
        // LineBreak is the default (#13#10)
        while P^ <> #0 do
        begin
          Start := P;
          while not (P^ in [#0, #10, #13]) do Inc(P);
          SetString(S, Start, P - Start);
          Add(S);
          if P^ = #13 then Inc(P);
          if P^ = #10 then Inc(P);
        end;
      end
      else
      begin
        LineBreakLen := Length(LineBreak);
        while P^ <> #0 do
        begin
          Start := P;
          LB := AnsiStrPos(P, PAnsiChar(LineBreak));
          while (P^ <> #0) and (P <> LB) do Inc(P);
          SetString(S, Start, P - Start);
          Add(S);
          if P = LB then
            Inc(P, LineBreakLen);
        end;
      end;
  finally
    EndUpdate;
  end;
end;

procedure TAnsiStrings.SetUpdateState(Updating: Boolean);
begin
end;

procedure TAnsiStrings.SetValue(const Name, Value: AnsiString);
var
  I: Integer;
begin
  I := IndexOfName(Name);
  if Value <> '' then
  begin
    if I < 0 then I := Add('');
    Put(I, Name + NameValueSeparator + Value);
  end else
  begin
    if I >= 0 then Delete(I);
  end;
end;

procedure TAnsiStrings.WriteData(Writer: TWriter);
var
  I: Integer;
begin
  Writer.WriteListBegin;
  for I := 0 to Count - 1 do Writer.WriteString(string(Get(I)));
  Writer.WriteListEnd;
end;

procedure TAnsiStrings.SetDelimitedText(const Value: AnsiString);
var
  P, P1: PAnsiChar;
  S: AnsiString;
begin
  BeginUpdate;
  try
    Clear;
    P := PAnsiChar(Value);
    if not StrictDelimiter then
      while (P^ in [#1..' ']) do
        Inc(P);
    while P^ <> #0 do
    begin
      if P^ = QuoteChar then
        S := AnsiExtractQuotedStr(P, QuoteChar)
      else
      begin
        P1 := P;
        while ((not FStrictDelimiter and (P^ > ' ')) or
              (FStrictDelimiter and (P^ <> #0))) and (P^ <> Delimiter) do
          Inc(P);
        SetString(S, P1, P - P1);
      end;
      Add(S);
      if not FStrictDelimiter then
        while (P^ in [#1..' ']) do
          Inc(P);

      if P^ = Delimiter then
      begin
        P1 := P;
        Inc(P1);
        if P1^ = #0 then
          Add('');
        repeat
          Inc(P);
        until not (not FStrictDelimiter and (P^ in [#1..' ']));
      end;
    end;
  finally
    EndUpdate;
  end;
end;

function TAnsiStrings.GetDelimiter: AnsiChar;
begin
  if not (sdDelimiter in FDefined) then
    Delimiter := ',';
  Result := FDelimiter;
end;

function TAnsiStrings.GetLineBreak: AnsiString;
begin
  if not (sdLineBreak in FDefined) then
    LineBreak := sLineBreak;
  Result := FLineBreak;
end;

function TAnsiStrings.GetQuoteChar: AnsiChar;
begin
  if not (sdQuoteChar in FDefined) then
    QuoteChar := '"';
  Result := FQuoteChar;
end;

function TAnsiStrings.GetStrictDelimiter: Boolean;
begin
  if not (sdStrictDelimiter in FDefined) then
    StrictDelimiter := False;
  Result := FStrictDelimiter;
end;

procedure TAnsiStrings.SetDelimiter(const Value: AnsiChar);
begin
  if (FDelimiter <> Value) or not (sdDelimiter in FDefined) then
  begin
    Include(FDefined, sdDelimiter);
    FDelimiter := Value;
  end
end;

procedure TAnsiStrings.SetLineBreak(const Value: AnsiString);
begin
  if (FLineBreak <> Value) or not (sdLineBreak in FDefined) then
  begin
    Include(FDefined, sdLineBreak);
    FLineBreak := Value;
  end
end;

procedure TAnsiStrings.SetQuoteChar(const Value: AnsiChar);
begin
  if (FQuoteChar <> Value) or not (sdQuoteChar in FDefined) then
  begin
    Include(FDefined, sdQuoteChar);
    FQuoteChar := Value;
  end
end;

procedure TAnsiStrings.SetStrictDelimiter(const Value: Boolean);
begin
  if (FStrictDelimiter <> Value) or not (sdStrictDelimiter in FDefined) then
  begin
    Include(FDefined, sdStrictDelimiter);
    FStrictDelimiter := Value;
  end
end;

function TAnsiStrings.CompareAnsiStrings(const S1, S2: AnsiString): Integer;
begin
  Result := AnsiCompareText(S1, S2);
end;

function TAnsiStrings.GetNameValueSeparator: AnsiChar;
begin
  if not (sdNameValueSeparator in FDefined) then
    NameValueSeparator := '=';
  Result := FNameValueSeparator;
end;

procedure TAnsiStrings.SetNameValueSeparator(const Value: AnsiChar);
begin
  if (FNameValueSeparator <> Value) or not (sdNameValueSeparator in FDefined) then
  begin
    Include(FDefined, sdNameValueSeparator);
    FNameValueSeparator := Value;
  end
end;

function TAnsiStrings.GetValueFromIndex(Index: Integer): AnsiString;
var
  Len: Integer;
begin
  if Index >= 0 then
  begin
    Len := Length(Names[Index]);
    if Len > 0 then
      Result := Copy(Get(Index), Len + 2, MaxInt)
    else
      Result := '';
  end
  else
    Result := '';
end;

procedure TAnsiStrings.SetValueFromIndex(Index: Integer; const Value: AnsiString);
begin
  if Value <> '' then
  begin
    if Index < 0 then Index := Add('');
    Put(Index, Names[Index] + NameValueSeparator + Value);
  end
  else
    if Index >= 0 then Delete(Index);
end;

{ TAnsiStringList }

destructor TAnsiStringList.Destroy;
var
  I: Integer;
begin
  FOnChange := nil;
  FOnChanging := nil;

  // In the event that we own the Objects make sure to free them all when we
  // destroy the AnsiStringlist.
  if OwnsObjects then
  begin
    for I := 0 to FCount - 1 do
      GetObject(I).Free;
  end;

  inherited Destroy;
  if FCount <> 0 then Finalize(FList^[0], FCount);
  FCount := 0;
  SetCapacity(0);
end;

function TAnsiStringList.Add(const S: AnsiString): Integer;
begin
  Result := AddObject(S, nil);
end;

function TAnsiStringList.AddObject(const S: AnsiString; AObject: TObject): Integer;
begin
  if not Sorted then
    Result := FCount
  else
    if Find(S, Result) then
      case Duplicates of
        dupIgnore: Exit;
        dupError: Error(@SDuplicateString, 0);
      end;
  InsertItem(Result, S, AObject);
end;

procedure TAnsiStringList.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TAnsiStringList.Changing;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure TAnsiStringList.Clear;
var
  I: Integer;
  Obj: TObject;
begin
  if FCount <> 0 then
  begin
    Changing;

    //Free all objects in the event that this list owns its objects
    if OwnsObjects then
    begin
      for I := 0 to FCount - 1 do
      begin
        Obj := GetObject(I);
        Obj.Free;
      end;
    end;

    Finalize(FList^[0], FCount);
    FCount := 0;
    SetCapacity(0);
    Changed;
  end;
end;

procedure TAnsiStringList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error(@SListIndexError, Index);
  Changing;
  // If this list owns its objects then free the associated TObject with this index
  if OwnsObjects then
    GetObject(Index).Free;
  Finalize(FList^[Index]);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(TAnsiStringItem));
  Changed;
end;

procedure TAnsiStringList.Exchange(Index1, Index2: Integer);
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(@SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(@SListIndexError, Index2);
  Changing;
  ExchangeItems(Index1, Index2);
  Changed;
end;

procedure TAnsiStringList.ExchangeItems(Index1, Index2: Integer);
var
  Temp: Pointer;
  Item1, Item2: PAnsiStringItem;
begin
  Item1 := @FList^[Index1];
  Item2 := @FList^[Index2];
  Temp := Pointer(Item1^.FAnsiString);
  Pointer(Item1^.FAnsiString) := Pointer(Item2^.FAnsiString);
  Pointer(Item2^.FAnsiString) := Temp;
  Temp := Item1^.FObject;
  Item1^.FObject := Item2^.FObject;
  Item2^.FObject := Temp;
end;

function TAnsiStringList.Find(const S: AnsiString; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := CompareAnsiStrings(FList^[I].FAnsiString, S);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        if Duplicates <> dupAccept then L := I;
      end;
    end;
  end;
  Index := L;
end;

function TAnsiStringList.Get(Index: Integer): AnsiString;
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Result := FList^[Index].FAnsiString;
end;

function TAnsiStringList.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TAnsiStringList.GetCount: Integer;
begin
  Result := FCount;
end;

function TAnsiStringList.GetObject(Index: Integer): TObject;
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Result := FList^[Index].FObject;
end;

procedure TAnsiStringList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TAnsiStringList.IndexOf(const S: AnsiString): Integer;
begin
  if not Sorted then Result := inherited IndexOf(S) else
    if not Find(S, Result) then Result := -1;
end;

procedure TAnsiStringList.Insert(Index: Integer; const S: AnsiString);
begin
  InsertObject(Index, S, nil);
end;

procedure TAnsiStringList.InsertObject(Index: Integer; const S: AnsiString;
  AObject: TObject);
begin
  if Sorted then Error(@SSortedListError, 0);
  if (Index < 0) or (Index > FCount) then Error(@SListIndexError, Index);
  InsertItem(Index, S, AObject);
end;

procedure TAnsiStringList.InsertItem(Index: Integer; const S: AnsiString; AObject: TObject);
begin
  Changing;
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(TAnsiStringItem));
  with FList^[Index] do
  begin
    Pointer(FAnsiString) := nil;
    FObject := AObject;
    FAnsiString := S;
  end;
  Inc(FCount);
  Changed;
end;

procedure TAnsiStringList.Put(Index: Integer; const S: AnsiString);
begin
  if Sorted then Error(@SSortedListError, 0);
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Changing;
  FList^[Index].FAnsiString := S;
  Changed;
end;

procedure TAnsiStringList.PutObject(Index: Integer; AObject: TObject);
begin
  if Cardinal(Index) >= Cardinal(FCount) then
    Error(@SListIndexError, Index);
  Changing;
  FList^[Index].FObject := AObject;
  Changed;
end;

procedure TAnsiStringList.QuickSort(L, R: Integer; SCompare: TAnsiStringListSortCompare);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, I, P) < 0 do Inc(I);
      while SCompare(Self, J, P) > 0 do Dec(J);
      if I <= J then
      begin
        if I <> J then
          ExchangeItems(I, J);
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TAnsiStringList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(@SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(TAnsiStringItem));
    FCapacity := NewCapacity;
  end;
end;

procedure TAnsiStringList.SetSorted(Value: Boolean);
begin
  if FSorted <> Value then
  begin
    if Value then Sort;
    FSorted := Value;
  end;
end;

procedure TAnsiStringList.SetUpdateState(Updating: Boolean);
begin
  if Updating then Changing else Changed;
end;

function AnsiStringListCompareAnsiStrings(List: TAnsiStringList; Index1, Index2: Integer): Integer;
begin
  Result := List.CompareAnsiStrings(List.FList^[Index1].FAnsiString,
                                List.FList^[Index2].FAnsiString);
end;

procedure TAnsiStringList.Sort;
begin
  CustomSort(AnsiStringListCompareAnsiStrings);
end;

procedure TAnsiStringList.CustomSort(Compare: TAnsiStringListSortCompare);
begin
  if not Sorted and (FCount > 1) then
  begin
    Changing;
    QuickSort(0, FCount - 1, Compare);
    Changed;
  end;
end;

function TAnsiStringList.CompareAnsiStrings(const S1, S2: AnsiString): Integer;
begin
  if CaseSensitive then
    Result := AnsiCompareStr(S1, S2)
  else
    Result := AnsiCompareText(S1, S2);
end;

constructor TAnsiStringList.Create;
begin
  inherited Create;
end;

constructor TAnsiStringList.Create(OwnsObjects: Boolean);
begin
  inherited Create;
  FOwnsObject := OwnsObjects;
end;

procedure TAnsiStringList.SetCaseSensitive(const Value: Boolean);
begin
  if Value <> FCaseSensitive then
  begin
    FCaseSensitive := Value;
    if Sorted then
    begin
      // Calling Sort won't sort the list because CustomSort will
      // only sort the list if it's not already sorted
      Sorted := False;
      Sorted := True;
    end;
  end;
end;

{$ENDIF UNICODE}

end.
