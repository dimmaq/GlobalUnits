unit uRegExprFunc;

{$DEFINE USE_REGULAR_EXPRESSIONS}

interface

{$IFDEF USE_REGULAR_EXPRESSIONS}

uses
  SysUtils, Classes, RegExpr, uAnsiStrings, Types, uGlobalTypes
  {$IFDEF UNICODE}
    , AnsiStrings
  {$ENDIF}
  ;

function YesRegExpr(const AText, ARegExpr: AnsiString;
  ACaseSensitive: Boolean = False): Boolean; overload;
function YesRegExpr(const AText: AnsiString; ARegExprs: TAnsiStrings): Integer; overload;
function YesRegExpr2(const AText: AnsiString; ARegExprs: TAnsiStrings): Boolean;
function GetMatches(const AText, ARegExpr: AnsiString; AMatches: TAnsiStrings): Boolean; overload;
//function GetMatches(const AText, ARegExpr: AnsiString;
//  var AMatches: TStringDynArray;
//  const AMatchIndexs: array of Byte): Integer; overload;

function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer; var AMatch: AnsiString): Boolean; overload;
function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer): AnsiString; overload;
function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer; AOut: TStrings): Integer; overload;

//function GetMatchByNom(const AText, ARegExpr: AnsiString;
//  var AOut: TAnsiStrings; AOnlySubExpr: Boolean): Integer; overload;

function YesRegExpr(const AText, ARegExpr: AnsiString;
  var AOut: TAnsiStringDynArray; AOnlySubExpr: Boolean): Integer; overload;

function ReplaceMatch(const AText, ARegExpr, AReplaceStr: AnsiString;
  AUseSubstitution: Boolean): AnsiString;

{$ENDIF}

implementation

uses
  uGlobalFunctions;

{$IFDEF USE_REGULAR_EXPRESSIONS}

function _RegExpr_Create(ACaseSensitive: Boolean = False): TRegExpr;
begin
  Result := TRegExpr.Create;
  Result.ModifierStr := IfElse(ACaseSensitive, 'grs-imx', 'grsi-mx');
end;

function _RegExpr_Exec(const A: TRegExpr;
  const AText, ARegExpr: AnsiString): Boolean;
begin
  if (ARegExpr='') or (AText='') then
  begin
    Result := False;
    Exit;
  end;
  //---
  try
//    A.ModifierStr := IfElse(ACaseSensitive, 'grs-imx', 'grsi-mx');
    A.Expression := ARegExpr;
    Result := A.Exec(AText);
    Exit;
  except
    on E: Exception do
      if not (E is ERegExpr) then
        raise;
  end;
  Result := False;
end;

function YesRegExpr(const AText, ARegExpr: AnsiString;
  ACaseSensitive: Boolean): Boolean;
var R: TRegExpr;
begin
  if (ARegExpr='') or (AText='') then
  begin
    Result := False;
    Exit;
  end;
  //---
//  R := TRegExpr.Create;
  R := _RegExpr_Create(ACaseSensitive);
  try
    Result := _RegExpr_Exec(R, AText, ARegExpr)
  finally
    R.Free;
  end;
end;

function YesRegExpr(const AText: AnsiString; ARegExprs: TAnsiStrings): Integer;
var
  R: TRegExpr;
  j: Integer;
begin
  if (ARegExprs.Count<1) or (AText='') then
  begin
    Result := -1;
    Exit;
  end;
  //---
  R := _RegExpr_Create();
  try
    for j:=0 to ARegExprs.Count-1 do
    begin
      if _RegExpr_Exec(R, AText, ARegExprs[j]) then
      begin
        Result := j;
        Exit;
      end
    end;
  finally
    R.Free;
  end;
  Result := -1;
end;

function YesRegExpr2(const AText: AnsiString; ARegExprs: TAnsiStrings): Boolean;
begin
  Result := YesRegExpr(AText, ARegExprs) <> -1;
end;

function GetMatches(const AText, ARegExpr: AnsiString; AMatches: TAnsiStrings): Boolean;
var
  R: TRegExpr;
  j: Integer;
begin
  R := _RegExpr_Create();
  try
    if _RegExpr_Exec(R, AText, ARegExpr) then
    begin
      AMatches.Clear;
      for j:=0 to R.SubExprMatchCount do // именно так - без @Count-1
        AMatches.Add(R.Match[j]);
      Result := True;
      Exit;
    end;
  finally
    R.Free;
  end;
  Result := False;
end;

{
function GetMatches(const AText, ARegExpr: AnsiString;
  var AMatches: TStringDynArray; const AMatchIndexs: array of Byte): Integer;

  function _test(I: Byte): Boolean;
  begin
  
  end;

var
  R: TRegExpr;
  j: Integer;
begin
  Result := 0;
  R := _RegExpr_Create();
  try
    if _RegExpr_Exec(R, AText, ARegExpr) then
    begin
      for j:=0 to R.SubExprMatchCount do // именно так - без @Count-1
        if (Length(AMatchIndexs)=0) or (j in AMatchIndexs) then
        begin
          if Length(AOut)<=Result then
            SetLength(AOut, Result+1);
          AOut[Result] := R.Match[j];
          Inc(Result);
        end;
    end;
  finally
    R.Free;
  end;
end;  }


function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer; var AMatch: AnsiString): Boolean;
var R: TRegExpr;
begin
  R := _RegExpr_Create();
  try
    if _RegExpr_Exec(R, AText, ARegExpr) and (R.MatchLen[AMatchIndex]<>-1) then
    begin
      AMatch := R.Match[aMatchIndex];
      Result := True;
      Exit;
    end
  finally
    R.Free;
  end;
  Result := False;
end;

function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer): AnsiString;
begin
  if not GetMatchByNom(AText, ARegExpr, AMatchIndex, Result) then
    Result := '';
end;

function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer; AOut: TStrings): Integer;
var R: TRegExpr;
begin
  Result := 0;
  R := _RegExpr_Create();
  try
    if _RegExpr_Exec(R, AText, ARegExpr) and (R.MatchLen[AMatchIndex]<>-1) then
    repeat
      AOut.Add(R.Match[AMatchIndex]);
      Inc(Result);
    until not R.ExecNext;
  finally
    R.Free;
  end;
end;
{
function GetMatchByNom(const AText, ARegExpr: AnsiString;
  var AOut: TAnsiStrings; AOnlySubExpr: Boolean): Integer;
var R: TRegExpr;
begin
  Result := 0;
  R := _RegExpr_Create();
  try
    if _RegExpr_Exec(R, AText, ARegExpr) and (R.MatchLen[AMatchIndex]<>-1) then
    repeat
      AOut.Add(R.Match[AMatchIndex]);
      Inc(Result);
    until not R.ExecNext;
  finally
    R.Free;
  end;
end;
}
function YesRegExpr(const AText, ARegExpr: AnsiString;
  var AOut: TAnsiStringDynArray; AOnlySubExpr: Boolean): Integer;
var
  R: TRegExpr;
  j,k,s,l: Integer;
begin
  Result := 0;
  R := _RegExpr_Create();
  try
    if _RegExpr_Exec(R, AText, ARegExpr) then
    begin
      l := R.SubExprMatchCount;
      s := IfElse(AOnlySubExpr, 1, 0);
      k := l - s + 1;
      if Length(AOut)<k then
        SetLength(AOut, k);
      for j:=s to l do
      begin
        AOut[Result] := R.Match[j];
        Inc(Result);
      end;
    end;
  finally
    R.Free;
  end;
end;


function ReplaceMatch(const AText, ARegExpr, AReplaceStr: AnsiString;
  AUseSubstitution: Boolean): AnsiString;
var R: TRegExpr;
begin
  Result := '';
  try
    R := _RegExpr_Create();
    try
      R.ModifierStr := 'grsi-mx';
      R.Expression := ARegExpr;
      Result := R.Replace(AText, AReplaceStr, AUseSubstitution);
    finally
      R.Free;
    end;
  except
    on E: Exception do
    begin
      if not (E is ERegExpr) then
        raise;
    end;
  end
end;

{$ENDIF}

end.
