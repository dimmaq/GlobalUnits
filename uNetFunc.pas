unit uNetFunc;

interface

uses blcksock, synsock, dnssend, Classes, SysUtils;

function ResolveIPToName(const AIP: u_long): AnsiString; overload;
function ResolveIPToName(const AIP: AnsiString): AnsiString; overload;
function ResolveIPToName(const AIP, ADNS: AnsiString; ATimeout: Integer;
  ARaise: Boolean): AnsiString; overload;
function ResolveNameToIP(const AName: AnsiString): AnsiString; overload;
function ResolveNameToIP(const AName, ADNS: AnsiString; ATimeout: Integer): AnsiString; overload;

implementation

uses
  uAnsiStrings;

function ResolveIPToName(const AIP: u_long): AnsiString;
var lHost: PHostEnt;
begin
  lHost := synsock.GetHostByAddr(@AIP, SizeOf(AIP), AF_INET);
  if lHost <> nil then
    Result := lHost^.h_name
  else
    Result := ''
end;

function ResolveIPToName(const AIP: AnsiString): AnsiString;
begin
  Result := ResolveIPToName(inet_addr(PAnsiChar(AIP)))
end;

function ResolveIPToName(const AIP, ADNS: AnsiString; ATimeout: Integer; ARaise: Boolean): AnsiString;
var
  ldns: TDNSSend;
  sl: TAnsiStringList;
begin
  Result := '';
  sl := TAnsiStringList.Create;
  ldns := TDNSSend.Create;
  try
    ldns.Timeout := ATimeout;
    ldns.TargetHost := ADNS;
    try
      if lDNS.DNSQuery(AIP, QTYPE_PTR, sl) then
        if sl.Count>0 then
          Result := sl[0]
    except
      on E: Exception do
      begin
        if (not (E is ESynapseError)) or ARaise then
          raise;
      end;
    end;
  finally
    sl.Free;
    lDNS.Free;
  end
end;



function ResolveNameToIP(const AName: AnsiString): AnsiString;
var
  HostEnt: PHostEnt;
  InAddr: PInAddr;
begin
  Result := '';
  HostEnt := GetHostByName(PAnsiChar(AName));
  if HostEnt<>nil then
  begin
    InAddr := PInAddr(HostEnt^.h_addr_list^);
    if InAddr<>nil then
      Result := inet_ntoa(InAddr^)
  end
end;

function ResolveNameToIP(const AName, ADNS: AnsiString; ATimeout: Integer): AnsiString;
var
  ldns: TDNSSend;
  sl: TAnsiStringList;
begin
  Result := '';
  sl := TAnsiStringList.Create;
  ldns := TDNSSend.Create;
  try
    ldns.Timeout := ATimeout;
    ldns.TargetHost := ADNS;
    if lDNS.DNSQuery(AName, QTYPE_A, sl) then
    begin
      if sl.Count>0 then
        Result := sl[0]
    end
    else
    begin
      raise ESynapseError.CreateFmt('Unknow error ResolveNameToIP(''%s'',''%s'',%d)', [AName, ADNS, ATimeout]);
    end;
  finally
    sl.Free;
    lDNS.Free;
  end
end;



end.
