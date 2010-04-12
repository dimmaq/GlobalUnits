unit uRELog;

interface

uses Windows, Messages, SysUtils, RichEdit, Graphics, ComCtrls;

type
  TRELog = class(TObject)
  private
    FRichEdit : TRichEdit;
    FShowDate : Boolean;
    FShowTime : Boolean;
    FShowMs : Boolean;
    FSaveFile : Boolean;
    FFileName : AnsiString;
    FReplaceCRLF : Boolean;
    FMaxLine : Integer;
    //---
    procedure WriteRE(const aText:AnsiString;aColor:TColor);
    procedure WriteLnRE(const aText:AnsiString;aColor:TColor);
  public
    constructor Create(RichEdit:TRichEdit); // override;
    //----------------
    procedure WriteLog(const aText:AnsiString; AColor:TColor=clBlack);
    procedure WriteError(const aText:AnsiString; AColor:TColor=clRed);
    property RichEdit: TRichEdit read FRichEdit write FRichEdit;
    property ShowDate: Boolean read FShowDate write FShowDate default False;
    property ShowTime: Boolean read FShowTime write FShowTime default False;
    property ShowMs: Boolean read FShowMs write FShowMs default False;
    property SaveFile: Boolean read FSaveFile write FSaveFile default False;
    property FileName: AnsiString read FFileName write FFileName;
    property ReplaceCRLF: Boolean read FReplaceCRLF write FReplaceCRLF default False;
    property MaxLine: Integer read FMaxLine write FMaxLine;
  end;

implementation

{ TRELog }

procedure AppendStrToFile(const AFileName,ABuffer:AnsiString);
var hf: THandle;
begin
  hf := INVALID_HANDLE_VALUE;
  try
    hf := CreateFile(PAnsiChar(AFileName),
                    GENERIC_WRITE,
                    FILE_SHARE_READ,
                    nil,
                    OPEN_ALWAYS,
                    FILE_ATTRIBUTE_ARCHIVE,
                    0);
// Result := (h<>INVALID_HANDLE_VALUE) and (FileWrite(h, Pointer(ABuffer)^, Length(ABuffer))<>-1);
    if hf<>INVALID_HANDLE_VALUE then
    begin
      SetFilePointer(hf, 0, nil, FILE_END);
      FileWrite(hf, Pointer(ABuffer)^, Length(ABuffer));

    end;
  finally
    CloseHandle(hf);
  end;
end;

constructor TRELog.Create(RichEdit: TRichEdit);
begin
  FRichEdit := RichEdit;
  FMaxLine := MAXWORD;
end;

procedure TRELog.WriteLnRE(const aText: AnsiString; aColor: TColor);
var str:AnsiString;
begin
  if FShowDate or FShowTime then
  begin
    str := '[ ';
    if FShowDate then
      str := str + FormatDateTime('dd.mm.yyyy', Date);
    if FShowDate and FShowTime then
      str := str + ' - ';
    if FShowTime then
      if FShowMs then
        str := str + FormatDateTime('hh:nn:ss:zzz', Time)
      else
        str := str + FormatDateTime('hh:nn:ss', Time);
    str := str + ' ]   ';
  end;
  str := str + aText;
  if ReplaceCRLF then
  begin
    str := StringReplace(str, #10#13, #13, [rfReplaceAll]);
    str := StringReplace(str, #13#10, #13, [rfReplaceAll]);
    str := StringReplace(str, #13#13, #13, [rfReplaceAll]);
    str := StringReplace(str, #13   , ' ', [rfReplaceAll]);
  end;
  WriteRE(str+#13#10, aColor);
  //-------------------------------------------------------
  if SaveFile then
    AppendStrToFile(FileName, str+#13#10);
end;

procedure TRELog.WriteLog(const aText: AnsiString; AColor:TColor);
begin
  WriteLnRE(aText, AColor)
end;

procedure TRELog.WriteError(const aText: AnsiString; AColor:TColor);
begin
  WriteLnRE(aText, AColor)
end;

procedure TRELog.WriteRE(const aText: AnsiString; aColor: TColor);
var FLastChar : TCharRange;
begin
  FRichEdit.Lines.BeginUpdate;
  if FRichEdit.Lines.Count>FMaxLine then
    FRichEdit.Lines.Clear;
  FLastChar.cpMin := FRichEdit.GetTextLen;
  FLastChar.cpMax := FLastChar.cpMin;
  FRichEdit.Perform(EM_EXSETSEL, 0, Longint(@FLastChar));
  FRichEdit.SelAttributes.Color := aColor;
  FRichEdit.Perform(EM_REPLACESEL, 0, Longint(PChar(aText)));
  FRichEdit.Perform(EM_EXGETSEL, 0, Longint(@FLastChar));
  FRichEdit.Lines.EndUpdate;
  FRichEdit.Perform(EM_SCROLl, SB_PAGEDOWN	, 0);
end;

end.
