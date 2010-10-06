unit uStringIntegerList;

interface

uses Classes, SysUtils, uGlobalTypes;

type
  TStrIntListSortTyp = (ST_NOSORT, ST_INT12, ST_INT21, ST_STR12, ST_STR21);

  TStringIntegerList = class(TStringList)
  private
    FSaveSeparator: AnsiChar;
//    FSortTyp: TStrIntListSortTyp;
    //---
    function GetInt(Index: Integer): Integer;
    procedure PutInt(Index: Integer; const Value: Integer);
  protected
//    function CompareStrings(const S1, S2: AnsiString): Integer; override;
    function CompareStrings(const S1, S2: string): Integer; override;
  public
    constructor Create; overload;
    constructor Create(const AInit: array of TStrIntRec); overload;
    //---
    function Add(const S: AnsiString): Integer; overload; override;
    function Add(const S: AnsiString; I: Integer): Integer; reintroduce; overload;
    procedure LoadFromArray(const A: array of TStrIntRec);
    procedure LoadFormFile(const AFileName: string);// override;
    procedure SaveToFile(const AFileName: string); override;
//    procedure Sort(ATyp: TStrIntListSortTyp); overload; reintroduce;
    function FindInt(const S: string; out I: Integer): Boolean;
    //---
    property Int[Index: Integer]: Integer read GetInt write PutInt;
    property SaveSeparator: AnsiChar read FSaveSeparator write FSaveSeparator default #9;
  end;

  TStrIntList = TStringIntegerList;

implementation

uses AcedStrings;
                  {
function _StrListSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := 0;
  case TStringIntegerList(List).FSortTyp of
    ST_NOSORT : Result := 0;

    ST_INT12 : Result := Integer(List.Objects[Index1]) - Integer(List.Objects[Index2]);

    ST_INT21 : Result := Integer(List.Objects[Index1]) - Integer(List.Objects[Index1]);

    ST_STR12 : Result := G_CompareText(List[Index1], List[Index2]);

    ST_STR21 : Result := G_CompareText(List[Index2], List[Index2]);
  end
end;

   }
{ TStringIntegerList }

constructor TStringIntegerList.Create;
begin
  Create([])
end;

constructor TStringIntegerList.Create(const AInit: array of TStrIntRec);
begin
  inherited Create;
  LoadFromArray(AInit)
end;

function TStringIntegerList.Add(const S: AnsiString; I: Integer): Integer;
begin
  Result := AddObject(S, TObject(I))
end;

function TStringIntegerList.FindInt(const S: string; out I: Integer): Boolean;
var j: Integer;
begin
  j := IndexOf(S);
  if j<>-1 then
  begin
    I := Self.Int[j];
    Result := True;
    Exit
  end;
  Result := False;
end;

{
function TStringIntegerList.CompareStrings(const S1, S2: AnsiString): Integer;
begin
  Result := 0;
  case Self.FSortTyp of
    ST_STR12 : Result := G_CompareText(S1, S2);
    ST_STR21 : Result := G_CompareText(S2, S1);
  end;
end;
}
function TStringIntegerList.CompareStrings(const S1, S2: string): Integer;
begin
  if CaseSensitive then
    Result := G_CompareStr(S1, S2)
  else
    Result := G_CompareText(S1, S2);
end;


function TStringIntegerList.Add(const S: AnsiString): Integer;
begin
  result := inherited Add(S)
end;

function TStringIntegerList.GetInt(Index: Integer): Integer;
begin
  Result := Integer(Objects[Index]);
end;

procedure TStringIntegerList.PutInt(Index: Integer; const Value: Integer);
begin
  Objects[Index] := TObject(Value);
end;

procedure TStringIntegerList.LoadFormFile(const AFileName: AnsiString);
var
  f: TextFile;
  z: AnsiString;
  s: AnsiString;
  k: Integer;
  p: Integer;
begin
  Clear;
  AssignFile(f, AFileName);
  try
    Reset(f);
    //---
    while not Eof(f) do
    begin
      Readln(f, z);
      s := z;
      //---
      k := 0;
      p := G_CharPos(FSaveSeparator, z);
      if (p>0) and TryStrToInt(Copy(z,1,p-1), k) then
        s := Copy(z, p+1, MaxInt);
      Add(s, k);
    end;
  finally
    CloseFile(f);
  end;
end;

procedure TStringIntegerList.LoadFromArray(const A: array of TStrIntRec);
var R: TStrIntRec;
begin
  for R in A do
    Add(R.S, R.I)
end;

procedure TStringIntegerList.SaveToFile(const AFileName: AnsiString);
const
  BUF_SIZE = 8 * 1024; 
var
  f: TextFile;
  j: Integer;
  z: TStringBuilder;

  procedure _write_buf();
  begin
    Write(f, z.ToString);
    z.Clear;
  end;

begin
  AssignFile(f, AFileName);
  z := TStringBuilder.Create;
  try
    Rewrite(f);
    //---
    for j:=0 to Count-1 do
    begin
      z.Append(GetInt(j)).Append(FSaveSeparator).AppendLine(Strings[j]);
      if z.Length>=BUF_SIZE then
        _write_buf();
    end;
    if z.Length>0 then
      _write_buf();
  finally
    CloseFile(f);
    z.Free;
  end;
end;

{
procedure TStringIntegerList.Sort(ATyp: TStrIntListSortTyp);
begin
  FSortTyp := ATyp;
  CustomSort(_StrListSortCompare);
end;
}

end.
