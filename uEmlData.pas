unit uEmlData;

interface

uses
  SysUtils, Classes, Contnrs, RTLConsts, AcedStrings, // RegExpr,
  AcedCommon, AcedContainers, uStringReader, uAnsiStrings
  {$IFDEF UNICODE}
    , AnsiStrings, uHeaderList
  {$else}
    , IdHeaderList
  {$ENDIF}
  ;

type
  EEmlDataError = class(Exception);

  TEmlHeaderList = {$IFDEF UNICODE}THeaderList{$ELSE}TIdHeaderList{$ENDIF};

  TEmlData = class
  private
    FHeader : TEmlHeaderList;
    FBody : TStringBuilder;
    FPart : TArrayList;
    FBoundaryList: TAnsiStringList;
    //---
    function GetPart(const Index:Integer): TEmlData;
    function GetPartsCount: Integer;
    function GetPartBoundary: AnsiString;
    procedure SetPartBoundary(const aBoundary:AnsiString);
    function GetTextStr: AnsiString;
    procedure SetTextStr(const Value: AnsiString);
    function GetContentType: AnsiString;
    procedure SetContentType(const AStr:AnsiString);
    function GetContentTypeCharSet: AnsiString;
    procedure SetContentTypeCharSet(const AStr:AnsiString);
    function GetContentTransferEncoding: AnsiString;
    procedure SetContentTransferEncoding(const AStr:AnsiString);
    //---
    function _ProcessHeader(AString: TAnsiStringReader): Integer;
    function _ProcessBody(AString: TAnsiStringReader; AIsPart: Boolean): Integer;
    function _ProcessMessage(AString: TAnsiStringReader; AIsPart: Boolean): Integer;
    procedure ProcessMessage(const AText: AnsiString);
    function GetBody: AnsiString;
    procedure SetBody(const Value: AnsiString);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(AEmlData: TEmlData);
    //---
    procedure LoadFromFile(const AFileName: TFileName);
    procedure LoadFromStrings(AStrings: TAnsiStrings); {$IFDEF UNICODE}overload;{$ENDIF}
    {$IFDEF UNICODE}
    procedure LoadFromStrings(AStrings: TUnicodeStrings); overload;
    {$ENDIF}
    procedure SaveToFile(const AFileName: TFileName);
    procedure SaveToStrings(AStrings: TAnsiStrings; AClear: Boolean = True); {$IFDEF UNICODE}overload;{$ENDIF}
    {$IFDEF UNICODE}
    procedure SaveToStrings(AStrings: TUnicodeStrings; AClear: Boolean = True); overload;
    {$ENDIF}
    function PartCreateAdd(AItem: TEmlData = nil): TEmlData;
    //---
    property Text: AnsiString read GetTextStr write SetTextStr;
    property Header: TEmlHeaderList read FHeader;
    property Body: AnsiString read GetBody write SetBody;
    property PartsCount: Integer read GetPartsCount;
    property Parts[const Index: Integer]: TEmlData read GetPart;
    property PartBoundary: AnsiString read GetPartBoundary write SetPartBoundary;
    property BoundaryList: TAnsiStringList read FBoundaryList;

    property ContentType: AnsiString
      read GetContentType write SetContentType;
    property ContentTypeCharSet: AnsiString
      read GetContentTypeCharSet write SetContentTypeCharSet;
    property ContentTransferEncoding: AnsiString
      read GetContentTransferEncoding write SetContentTransferEncoding;
  end;

implementation

uses
  uGlobalFunctions, uGlobalFileIOFunc, uGlobalVars, //uRegExprFunc,
  uGlobalConstants,
  uFakeAnsiStringListToString, uFakeAnsiStringListToFile;

function _Header_AttrValue(const AHeaderValue, AAttrName: AnsiString;
  out AStart, ALength: Integer): Boolean;
var
  p,k,n,l: Integer;
  z: AnsiString;

  function _skeep_space(ALeft: Boolean = False): Integer;
  begin
    if ALeft then Result := CharsPosLeftNot(gCharsSpace, AHeaderValue, p)
      else Result := CharsPosNot(gCharsSpace, AHeaderValue, p)
  end;

  function _next1: Integer;
  begin
    Result := G_CharPos(';', AHeaderValue, n);
  end;

begin
//  text/html; charset="windows-1251" ; 111=222
  l := Length(AHeaderValue);
  n := 1;
  p := _next1();
  while (p<l) and (p>0) do
  begin
    Inc(p);
    n := _skeep_space();
    if n=0 then
      Break;
    //---
    p := G_CharPos('=', AHeaderValue, n);
    if p>0 then
    begin
      Dec(p);
      k := _skeep_space(True);
      Inc(p);
      z := Copy(AHeaderValue, n, k - n + 1);
      if G_CompareText(z, AAttrName) = 0 then
      begin
        Inc(p);
        n := _skeep_space();
        if n>0 then
        begin
          p := G_CharPos(';', AHeaderValue, n);
          if p>0 then Dec(p)
            else p := l;
          k := _skeep_space(True);
          if (AHeaderValue[n] = '"') and (AHeaderValue[k] = '"') then
          begin
            Dec(k);
            Inc(n)
          end;
          AStart  := n;
          ALength := k - n + 1;
          Result  := True;
          Exit;
        end;
      end;
    end;
    p := _next1();
  end;
  Result := False;
end;


function Header_AttrValueGet(const AHeaderValue, AAttrName: AnsiString): AnsiString;
var n,l: Integer;
begin
  if _Header_AttrValue(AHeaderValue, AAttrName, n, l) then
  begin
    Result := Copy(AHeaderValue, n, l);
    Exit;
  end;
  Result := '';
end;

function Header_AttrValueSet(const AHeaderValue, AAttrName, AAttrValue: AnsiString;
  AAppend: Boolean): AnsiString;
var n,l: Integer;
begin
  if _Header_AttrValue(AHeaderValue, AAttrName, n, l) then
    Result := Copy(AHeaderValue, 1, n - 1) +
      AAttrValue + Copy(AHeaderValue, n + l, MaxInt)
  else if AAppend then
    Result := AHeaderValue + '; '#13#10#9 + AAttrName + '="' + AAttrValue + '"'
  else
    Result := AHeaderValue
end;




{ TEmlData }

constructor TEmlData.Create;
begin
  FHeader := TEmlHeaderList.Create;
  //------------------------------------
  // Вылк. ф-ции [Un]FoldLines
  // загрузка идет через Strings_Text()
  // переносы #9 #32 учитываются
  //
  FHeader.FoldLines   := False;
  FHeader.UnfoldLines := False;
  FHeader.FoldLength  := MaxInt;

  FBody := TStringBuilder.Create;
  FPart := TArrayList.Create;
  FPart.OwnItems := True;

  FBoundaryList := TAnsiStringList.Create;
end;

destructor TEmlData.Destroy;
begin
  FreeAndNil(FHeader);
  FreeAndNil(FBody);
  FreeAndNil(FPart);
  FreeAndNil(FBoundaryList);
  inherited;
end;

procedure TEmlData.Assign(AEmlData: TEmlData);
var
  j : Integer;
  LEmlData : TEmlData;
begin
  Clear;
  FHeader.AddStrings(AEmlData.Header);
  FBody.CopyFrom(AEmlData.FBody);
  FBoundaryList.Assign(AEmlData.FBoundaryList);
  for j:=0 to AEmlData.PartsCount-1 do
  begin
    LEmlData := TEmlData.Create;
    LEmlData.Assign(AEmlData.Parts[j]);
    PartCreateAdd(LEmlData)
  end;
end;

procedure TEmlData.Clear;
begin
  FHeader.Clear;
  FBody.Clear;
  FPart.Clear;
  FBoundaryList.Clear;
end;

procedure TEmlData.SetBody(const Value: AnsiString);
begin
  FBody.Clear;
  FBody.Append(Value);
end;

function TEmlData.GetBody: AnsiString;
begin
  Result := FBody.ToString
end;

function TEmlData.GetContentTransferEncoding: AnsiString;
begin
  Result := FHeader.Values['Content-Transfer-Encoding']    
end;

function TEmlData.GetContentType: AnsiString;
begin
  Result := FHeader.Values['Content-Type']
end;

function TEmlData.GetContentTypeCharSet: AnsiString;
begin
  Result := Header_AttrValueGet(ContentType, 'charset')
end;

function TEmlData.GetPart(const Index: Integer): TEmlData;
begin
  if (0<=Index) and (Index<FPart.Count) then
    result := TEmlData(FPart.ItemList[Index])
  else
    raise EEmlDataError.Create(SListIndexError);
end;

function TEmlData.GetPartBoundary: AnsiString;
begin
  Result := Header_AttrValueGet(ContentType, 'boundary')
end;

procedure TEmlData.SaveToFile(const AFileName: TFileName);
var lFile: TFakeAnsiStringListToFile;
begin
  lFile := TFakeAnsiStringListToFile.Create(AFileName);
  try
    SaveToStrings(lFile);
  finally
    lFile.Free
  end;
end;

{$IFDEF UNICODE}
procedure TEmlData.SaveToStrings(AStrings: TUnicodeStrings; AClear: Boolean);
begin
  StringsStrictAdd(AStrings, Text);
end;
{$ENDIF}

procedure TEmlData.SaveToStrings(AStrings: TAnsiStrings; AClear: Boolean);
var
  i: Integer;
  z: AnsiString;
begin
  if aClear then
    aStrings.Clear;
  aStrings.AddStrings(FHeader);
  aStrings.Add('');
  if FBody.Length>0 then
  begin
    z := FBody.ToString();
    if z='' then
      z := CRLF;
    ;
    StringsStrictAdd(aStrings, z);
  end;
  for i:=0 to FPart.Count-1 do
  begin
    aStrings.Add(FBoundaryList[i]);
    TEmlData(FPart.ItemList[i]).SaveToStrings(aStrings, False);
    if i=(FPart.Count-1) then
    begin
      aStrings.Add(FBoundaryList[i+1]);
      aStrings.Add('');
    end;
  end;
end;

procedure TEmlData.SetContentTransferEncoding(const AStr: AnsiString);
begin
  FHeader.Values['Content-Transfer-Encoding'] := AStr
end;

procedure TEmlData.SetContentType(const AStr: AnsiString);
begin
  FHeader.Values['Content-Type'] := AStr
end;

procedure TEmlData.SetContentTypeCharSet(const AStr: AnsiString);
begin
  ContentType := Header_AttrValueSet(ContentType, 'charset', AStr, True)
end;

procedure TEmlData.SetPartBoundary(const ABoundary: AnsiString);
var
  j,p: Integer;
  s,z: AnsiString;
begin
  ContentType := Header_AttrValueSet(ContentType, 'boundary', ABoundary, True);
  //---
  for j:=0 to FBoundaryList.Count-1 do
  begin
//    z := GetMatchByNom(FBoundaryList[j],'\s*$',0);
    z := '';
    s := FBoundaryList[j];
    p := CharsPosLeftNot([#0..#32], s);
    if p>0 then z := Copy(s, p + 1, MaxInt);    
    if j=(FBoundaryList.Count-1) then
      FBoundaryList[j] := '--' + ABoundary + '--' + z
    else
      FBoundaryList[j] := '--' + ABoundary + z;
  end;

end;

procedure TEmlData.SetTextStr(const Value: AnsiString);
begin
  ProcessMessage(Value);
end;

// возвращает размер части
function TEmlData._ProcessBody(AString: TAnsiStringReader; AIsPart: Boolean): Integer;
var
  E: TEmlData;
  Z: AnsiString;
  L: Integer;
  S: Integer;
  N: Integer;
  b: Boolean;
begin
  FBody.Clear;
  //---
  S := AString.Pos;
  N := S;
  if G_PosText('multipart/', FHeader.Values['Content-Type'])=0 then
  begin
    while not AString.eof() do
    begin
      Z := AString.ReadLn();
      if AIsPart and (G_PosStr('--',Z)=1) and (Length(Z)>6) then
      begin
        AString.Pos := N;
        Break
      end
      else
      begin
        FBody.AppendLine(Z)
      end;
      N := AString.Pos;
    end;
  end
  else
  begin
    b := True;
    while not AString.eof() do
    begin
      Z := AString.ReadLn();
      L := Length(Z);
      N := AString.Pos;
      if (G_PosStr('--',Z)=1) and (L>6)  then
      begin
        b := False;
        FBoundaryList.Add(Z);
        G_TrimRight(Z);
        L := Length(Z);
        if (Z[L]='-') and (Z[L-1]='-') then
        begin
          Break;
        end;
        E := TEmlData.Create;
        FPart.Add(E);
        E._ProcessMessage(AString, True);
      end
      else if b then
      begin
        FBody.AppendLine(Z)
      end;
    end
  end;
  Result := N - S;
end;

// возвращает размер части
function TEmlData._ProcessHeader(AString: TAnsiStringReader): Integer;
var
  start: Integer;
  z: AnsiString;
  k: Integer;
begin
  FHeader.Clear;
  start := AString.Pos;
  //---
  while not AString.EOF do
  begin
    z := AString.ReadLn;
    if z='' then
      break;
    if (z[1] in [#9,#32]) and (FHeader.Count>0) then
    begin
      k := FHeader.Count-1;
      FHeader[k] := FHeader[k] + CRLF + z;
      Continue;
    end
    else
    begin
      FHeader.Add(z);
    end;
  end;
  Result := AString.Pos - start;
end;

function TEmlData._ProcessMessage(AString: TAnsiStringReader; AIsPart: Boolean): Integer;
var size: Integer;
begin
  Clear;
  Result := 0;
  //---
  size := _ProcessHeader(AString); // размер заголовка + разделителя CRLF
  Inc(Result, size);
  size := _ProcessBody(AString, AIsPart);
  Inc(Result, size);
  //---
  if (FPart.Count>0) and (FBoundaryList.Count<>(FPart.Count+1)) then
    raise EEmlDataError.Create('Error parse eml data');
end;

function TEmlData.GetPartsCount: Integer;
begin
  result := FPart.Count;
end;

function TEmlData.GetTextStr: AnsiString;
var lStr: TFakeAnsiStringListToString;
begin
  lStr := TFakeAnsiStringListToString.Create(1024);
  try
    SaveToStrings(lStr);
    Result := lStr.Text;
  finally
    lStr.Free;
  end;
end;

procedure TEmlData.LoadFromFile(const AFileName: TFileName);
begin
  ProcessMessage(StringLoadFromFile(AFileName))
end;

{$IFDEF UNICODE}
procedure TEmlData.LoadFromStrings(AStrings: TUnicodeStrings);
begin
  SetTextStr(AnsiString(AStrings.Text));
end;
{$ENDIF}

procedure TEmlData.LoadFromStrings(AStrings: TAnsiStrings);
begin
  SetTextStr(AStrings.Text);
end;

function TEmlData.PartCreateAdd(AItem: TEmlData): TEmlData;
begin
  if not Assigned(AItem) then
    AItem := TEmlData.Create;
  FPart.Add(AItem);
  Result := AItem;
end;

procedure TEmlData.ProcessMessage(const AText: AnsiString);
var r: TAnsiStringReader;
begin
  r := TAnsiStringReader.Create(AText);
  try
    _ProcessMessage(r, False);
  finally
    r.Free
  end;
end;

end.
