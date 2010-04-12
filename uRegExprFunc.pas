unit uRegExprFunc;

{$DEFINE USE_REGULAR_EXPRESSIONS}

interface

{$IFDEF USE_REGULAR_EXPRESSIONS}

uses SysUtils, Classes,{$IFDEF UNICODE} JclAnsiStrings,{$ENDIF} RegExpr;

function YesRegExpr(const AText, ARegExpr: AnsiString): Boolean; overload;
function YesRegExpr(const AText: AnsiString; ARegExprs: TAnsiStrings): Integer; overload;
function YesRegExpr2(const AText: AnsiString; ARegExprs: TAnsiStrings): Boolean;
function GetMatches(const AText, ARegExpr: AnsiString; AMatches: TAnsiStrings): Boolean;

function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer; var AMatch: AnsiString): Boolean; overload;
function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer): AnsiString; overload;
function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer; AOut: TAnsiStrings): Integer; overload;

function ReplaceMatch(const AText, ARegExpr, AReplaceStr: AnsiString;
  AUseSubstitution: Boolean): AnsiString;

{$ENDIF}

implementation

{$IFDEF USE_REGULAR_EXPRESSIONS}

function YesRegExpr(const AText, ARegExpr: AnsiString): Boolean;
var R: TRegExpr;
begin
  Result := False;
  if ARegExpr='' then
    Exit;
  TRY
    R := TRegExpr.Create;
    try
      R.ModifierStr := 'grsi-mx';
      R.Expression := ARegExpr;
      result := R.Exec(AText);
    finally
      R.Free;
    end;
  EXCEPT
    on E:Exception do
    begin
      if not (E is ERegExpr) then
        raise;
    end;
  END
end;

function YesRegExpr(const AText: AnsiString; ARegExprs: TAnsiStrings): Integer;
var j: Integer;
begin
  Result := -1;
  for j:=0 to ARegExprs.Count-1 do
  begin
    if YesRegExpr(AText, ARegExprs[j]) then
    begin
      Result := j;
      Exit;
    end
  end;
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
  Result := False;
  try
    R := TRegExpr.Create;
    try
      R.ModifierStr := 'grsi-mx';
      R.Expression := ARegExpr;
      if R.Exec(AText) then
      begin
        AMatches.Clear;
        for j:=0 to R.SubExprMatchCount do
          AMatches.Add(R.Match[j]);
        Result := True;
      end;
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

function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer; var AMatch: AnsiString): Boolean;
var R: TRegExpr;
begin
  Result := False;
  TRY
    R := TRegExpr.Create;
    try
      R.ModifierStr := 'grsi-mx';
      R.Expression := ARegExpr;
      if R.Exec(AText) then
      begin
        if R.MatchLen[AMatchIndex]<>-1 then
        begin
          AMatch := R.Match[aMatchIndex];
          Exit(True);
          Result := True;
          Exit;
        end
      end
    finally
      R.Free;
    end;
  EXCEPT
    on E:Exception do
    begin
      if not (E is ERegExpr) then
        raise;
    end;
  END
end;

function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer): AnsiString;
begin
  if not GetMatchByNom(AText, ARegExpr, AMatchIndex, Result) then
    Result := '';
end;

function GetMatchByNom(const AText, ARegExpr: AnsiString;
  AMatchIndex: Integer; AOut: TAnsiStrings): Integer;
var R: TRegExpr;
begin
  Result := 0;
  TRY
    R := TRegExpr.Create;
    try
      R.ModifierStr := 'grsi-mx';
      R.Expression := ARegExpr;
      if R.Exec(AText) and (R.MatchLen[AMatchIndex]<>-1) then
      repeat
        AOut.Add(R.Match[AMatchIndex]);
        Inc(Result);
      until not R.ExecNext;
    finally
      R.Free;
    end;
  EXCEPT
    on E: Exception do
    begin
      if not (E is ERegExpr) then
        raise;
    end;
  END
end;

function ReplaceMatch(const AText, ARegExpr, AReplaceStr: AnsiString;
  AUseSubstitution: Boolean): AnsiString;
var R: TRegExpr;
begin
  Result := '';
  try
    R := TRegExpr.Create;
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
