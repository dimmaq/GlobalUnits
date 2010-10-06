unit uHtmlFunc;

interface

uses
  Sysutils, Classes, Math, Types, AcedStrings, AcedConsts;

type
  TFilterFunc = function(var AStr: AnsiString): Boolean of object;

//function FindNextHref(const n: AnsiString; var start: Integer): AnsiString;
procedure FindAllLinks(const AHtmlText: AnsiString; const AOut: TStrings;
  AFilter: TFilterFunc = nil);
function GetHtmlBase(const AHtmlText: AnsiString): AnsiString;

procedure UrlDelAnchor(var AURL: AnsiString);
function CleverEncodeURL(const AURL: AnsiString): AnsiString;
function GetAbsoluteLink(const ABaseURL, AURL:AnsiString):AnsiString;

implementation

uses uGlobalFunctions, uGlobalTypes;

function FindNextHref(const n: AnsiString; var start: Integer): AnsiString;
var
  p1,p2 : integer;
  ch    : char;
  s     : AnsiString;
begin
  s  := '';
  p1 := G_PosText('href=', n, start);
//  p2 := 0;
  if p1>0 then
  begin
    Inc(p1,5);
    if p1<Length(n) then
    begin
      ch := n[p1];
      Inc(p1);
      case ch of
        '''' : p2 := G_CharPos('''', n, p1);
        '"'  : p2 := G_CharPos('"', n, p1);
          else
            begin
              p2 := CharsPos([#32,#9,#10,#13,'>'], n, p1);
              Dec(p1);
            end;
      end;
      if p2>0 then
      begin
        s := Copy(n, p1, p2-p1);
      end;
    end
    else
    begin
      p1 := 0;
    end;
  end;
  start  := p1;
  Result := s;
end;

procedure UrlDelAnchor(var AURL: AnsiString);
var p: Integer;
begin
  p := G_LastCharPos('#', AURL);
  if p>0 then
    Delete(AURL, p, MaxInt)
end;

function HtmlSpecialCharsDecode(const AHtmlText: AnsiString): AnsiString;
begin
  Result := G_ReplaceStr(AHtmlText,   '&apos;', '''');
  Result := G_ReplaceStr(Result, '&#039;', '''');
  Result := G_ReplaceStr(Result, '&quot;', '"');
  Result := G_ReplaceStr(Result, '&gt;', '>');
  Result := G_ReplaceStr(Result, '&lt;', '<');
  Result := G_ReplaceStr(Result, '&amp;', '&');
end;

function CleverEncodeURL(const AURL: AnsiString): AnsiString;
const
  cUnsafeChars =  [#0..#32,'"','''','<','>','^','`','{','}',#127..#255];
var
  j: Integer;
  z: AnsiString;
  lUnsafeChars : TSysCharSet;
(*  "   #   %   &   '   *   ,   :   ;   <   >   ?   [   ^   `   {   |   }  <пробел>
   %22 %23 %25 %26 %27 %2a %2c %3a %3b %3c %3e %3f %5b %5e %60 %7b %7c %7d   +[3]   *)
begin
  lUnsafeChars := cUnsafeChars;
  z := HtmlSpecialCharsDecode(AURL);

  if CharsPos(lUnsafeChars, z)>0 then
  begin
    lUnsafeChars := cUnsafeChars + ['%'];
    Result := '';
    for j:=1 to Length(z) do
    begin
      if (z[j] in LUnsafeChars) then
        Result := Result + '%' + IntToHex(Ord(z[j]), 2)
      else
        Result := Result + z[j]
    end;
  end
    else
  begin
    Result := z;
  end;
end;


procedure UrlParsePath(AUrl: AnsiString; var AOut: TAnsiStringDynArray; var ACount: Integer);

  procedure _add_part(const APart: AnsiString);
  begin
    if Length(AOut)=ACount then
      SetLength(AOut, ACount+8);
    AOut[ACount] := APart;
    Int(ACount);
  end;

var p,p2: Integer;
begin
  repeat
    p := G_CharPos('/', AUrl, 2);
    p2 := G_CharPos('?', AUrl, 1);
    if p<>0 then
    begin
      if (p2<>0) and (p2<p) then
      begin
        _add_part(AUrl);
        p := 0;
      end
        else
      begin
        _add_part(Copy(AUrl, 1, p-1));
        Delete(AUrl, 1, p-1)
      end;
    end
      else
    begin
      _add_part(AUrl)
    end;
  until p=0;
end;

function GetAbsoluteLink(const ABaseURL, AURL:AnsiString):AnsiString;
var
  sl1 : TAnsiStringDynArray; // base
  sl2 : TAnsiStringDynArray; // url
  cv1 : Integer; // длина массива sl1
  cv2 : Integer;
  z0  : AnsiString; // http://host/
  z1  : AnsiString; // path
  zz  : AnsiString; // file
  j,p : Integer;
  k,p2: Integer;
  ch  : AnsiChar;
begin
  try
    if AURL='' then
    begin
      Result := ABaseURL;
      Exit;
    end;
    //--------------------------------------
    // проверка протокола
    // если не HTTP - вернуть null 
    k := 0;
    for j:=1 to Length(AURL) do
    begin
      ch := AURL[j];
      if not (ch in ['A'..'Z','a'..'z']) then
      begin
        if ch=':' then
          k := j - 1;
        Break;
      end;
    end;
    if k<>0 then
    begin
      p := 0;
      if G_PosText('HTTPS://', AURL)=1 then
        p := 9;
      if G_PosText('HTTP://', AURL)=1 then
        p := 8;
      if p<>0 then
        if G_PosStr('/', AURL, p)=0 then
          Result := AURL + '/'
        else
          Result := AURL
      else
        Result := '';
      Exit;
    end;
    //--------------------------------------
    // разделить BaseURL на части host path и file
    p := G_PosStr('/', ABaseURL, G_PosStr('://', ABaseURL)+3);
    if p>0 then
    begin
      z0 := Copy(ABaseURL, 1, p-1);
      z1 := Copy(ABaseURL, p, MaxInt);
  
      p  := G_LastCharPos('/', z1);
      p2 := G_CharPos('?', z1);
      if (p2<>0) and (p2<p) then
      begin
        p  := G_LastCharPos('/',z1, p2);
      end;
      zz := Copy(z1, p, MaxInt);
      Delete(z1, p, MaxInt);
    end
      else
    begin
      z0 := ABaseURL;
      z1 := '';
      zz := '/';
    end;

    if AURL[1]='/' then
    begin
      Result := z0 + AURL;
      Exit;
    end;
  
    if Copy(AURL,1,2)='./' then
    begin
      Result := z0 + z1 + Copy(AURL,2,MaxInt);
      Exit;
    end;
    
    if Copy(AURL,1,3)='../' then
    begin
      cv1 := 0;
      cv2 := 0;
      SetLength(sl1, 8);
      SetLength(sl2, 8);
      UrlParsePath(z1, sl1, cv1);
      UrlParsePath(AURL, sl2, cv2);
      k := 1;
      for j:=Low(sl2) to cv2 do
        if (sl2[j]='..') or (sl2[j]='/..') then
          Inc(k);
      Result := z0;
      for j:=Low(sl1) to cv1-k do
        Result := Result + sl1[j];
      for j:=max(k-1,0) to cv2-1 do
        Result := Result + sl2[j];
      Exit;
    end;
  
    Result := z0 + z1 + '/' + AURL

  finally
    for j:=Length(Result) downto 1 do
    begin
      if Result[j] in ['?','&','/'] then
        Break;
      if Result[j]='#' then
      begin
        Delete(Result, j, MaxInt);
        Break;
      end;

    end;

  end;
end;

function GetHtmlBase(const AHtmlText: AnsiString): AnsiString;
var
  p1,p2,n : Integer;
begin
  // <base href="http://stogrup.ru/" />
  p1 := G_PosText('<base ', AHtmlText);
  if p1>0 then
  begin
    p2 := CharsPos(['<','>'], AHtmlText, p1+1);
    n := 1;
    Result := FindNextHref(Copy(AHtmlText,p1,p2-p1+1), n);
  end
    else
  begin
    Result := '';
  end;
end;

procedure FindAllLinks(const AHtmlText: AnsiString; const AOut: TStrings;
  AFilter: TFilterFunc);
var
  s: Integer;
  z: AnsiString;
begin
  s := 1;
  repeat
    z := FindNextHref(AHtmlText, s);
    if (not Assigned(AFilter)) or AFilter(z) then
      AOut.Add(z);
  until s=0;
end;

end.
