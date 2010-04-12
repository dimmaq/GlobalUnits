unit uRELog2;

interface

uses Windows, Messages, SysUtils, RichEdit, Graphics, ComCtrls;

type
  TRELog2 = class(TObject)
    FRichEdit : TRichEdit;
    FShowDate : Boolean;
    FShowTime : Boolean;
    FShowMs : Boolean;
    FSaveFile : Boolean;
    FFileName : AnsiString;
    FReplaceCRLF : Boolean;
    FMaxLine : Integer;
  private
    procedure WriteRE(const aText:AnsiString;aColor:TColor);
    procedure WriteLnRE(const aText:AnsiString;aColor:TColor);
  public
    constructor Create(RichEdit:TRichEdit); // override;
    //----------------
    procedure WriteLog(const aText:AnsiString);
    procedure WriteError(const aText:AnsiString);
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

procedure AppendStrToFile(const aFileName,AStr:AnsiString);
var f : TextFile;
begin
  AssignFile(f, aFileName);
  If FileExists(aFileName) then Append(f)
                           else Rewrite(f);
  Writeln(f, aStr);
  CloseFile(f)
end;

constructor TRELog2.Create(RichEdit: TRichEdit);
begin
  FRichEdit := RichEdit;
  FMaxLine := MAXWORD;
end;

procedure TRELog2.WriteLnRE(const aText: AnsiString; aColor: TColor);
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
    AppendStrToFile(FileName, str);
end;

procedure TRELog2.WriteLog(const aText: AnsiString);
begin
  WriteLnRE(aText, clBlack)
end;

procedure TRELog2.WriteError(const aText: AnsiString);
begin
  WriteLnRE(aText, clRed)
end;

procedure TRELog2.WriteRE(const aText: AnsiString; aColor: TColor);
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

