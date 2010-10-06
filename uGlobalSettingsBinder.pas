unit uGlobalSettingsBinder;

interface

uses
  SysUtils, Classes, Windows, Messages, StdCtrls, ExtCtrls, Spin,
  AcedContainers,
  uGlobalVars,
  uGlobalSettings,
  uSettingsBaseItem,
  uSettingsAStringsList,
  uSettingsUStringsList,
  uSettingsAStrList,
  uSettingsUStrList,
  uSettingsBoolList,
  uSettingsIntList;

type
  TGlobSettingsChangeEvent = procedure(ASender: TObject;
    AItem: TSettingsBaseItem; AComp: TComponent; AId: Integer) of object;
  TCompSettingsChangeEvent = procedure(AComp: TObject;
    AItem: TSettingsBaseItem) of object;

  TGlobalSettingsBinder = class
  private
    FSettings: TGlobalSettingsBase;
    //---
    // массивы для быстрого поиска связи
    FCompById: TIntegerAssociationList;
    FIdByComp: TIntegerAssociationList;
    FCompByItem: TIntegerAssociationList;  
    FItemByComp: TIntegerAssociationList;
    FCompChangeEvent: TIntegerAssociationList; 
    //---
    FWinHandle: HWND;
    FOnGlobSettingsChange: TGlobSettingsChangeEvent;
    FOnCompSettingsChange: TCompSettingsChangeEvent;
    FLocked: Boolean; 
    //---
    procedure CallOnChangeOldEvent(AComp: TObject);
    function ReplaceOnChangeEvent(AComp: TObject;
      AEvent: TNotifyEvent): TNotifyEvent;
    procedure CompSettingsChanged(ASender: TObject);
    procedure WndProc(var AMsg: TMessage);
    procedure UpdateSettingsById(const AID: Integer);
    procedure UpdateSettingsByItem(const AItem: TSettingsBaseItem);
    procedure UpdateSettingsByListId(const AListId: TIntegerList);
    procedure UpdateSettingsByListItem(const AListItem: TSettingsSimpleList);
    //---
    procedure _UpdateSettings(const A: TSettingsBaseItem; const B: TComponent;
      const AId: Integer);
    procedure _AddItem(const AComp: TComponent; const AItem: TSettingsBaseItem;
      const AId: Integer);
  public
    constructor Create(ASettings: TGlobalSettingsBase);
    destructor Destroy; override;
    //---
    procedure Add(const AComp: TComponent; const AId: Integer); overload;
    procedure Add(const AComp: TComponent; const AName: AnsiString); overload;
    procedure Add(const AComp: TComponent;
      const AItem: TSettingsBaseItem); overload;
    //---
    property OnGlobSettingsChange: TGlobSettingsChangeEvent
      read FOnGlobSettingsChange write FOnGlobSettingsChange;
    property OnCompSettingsChange: TCompSettingsChangeEvent
      read FOnCompSettingsChange write FOnCompSettingsChange;
    property Locked: Boolean read FLocked write FLocked;
  end;

implementation

type
  TEventObject = class
  private
    FEvent: TNotifyEvent;
  public
    property Event: TNotifyEvent read FEvent write FEvent;
  end;


{ TGlobalSettingsBinder }

constructor TGlobalSettingsBinder.Create(ASettings: TGlobalSettingsBase);
begin
  FSettings   := ASettings;
  FCompById   := TIntegerAssociationList.Create;
  FIdByComp   := TIntegerAssociationList.Create;
  FCompByItem := TIntegerAssociationList.Create;
  FItemByComp := TIntegerAssociationList.Create;
  FCompChangeEvent := TIntegerAssociationList.Create;
  FCompChangeEvent.OwnValues := True;

  FWinHandle := Classes.AllocateHWnd(WndProc);
  //---
  FOnGlobSettingsChange := nil;
  FOnCompSettingsChange := nil;
  //---
  FSettings.NotifyHandle := FWinHandle;
  FLocked := True;
end;

destructor TGlobalSettingsBinder.Destroy;
begin
  Classes.DeallocateHWnd(FWinHandle);
  FreeAndNil(FCompChangeEvent);
  FreeAndNil(FCompById);
  FreeAndNil(FIdByComp);
  FreeAndNil(FCompByItem);
  FreeAndNil(FItemByComp);
  inherited;
end;



procedure TGlobalSettingsBinder._AddItem(const AComp: TComponent;
  const AItem: TSettingsBaseItem; const AId: Integer);
begin
  if AComp is TEdit then
    with TEdit(AComp) do
      OnChange := ReplaceOnChangeEvent(AComp, OnChange)
  else if AComp is TLabeledEdit then
    with TLabeledEdit(AComp) do
      OnChange := ReplaceOnChangeEvent(AComp, OnChange)
  else if AComp is TCheckBox then
    with TCheckBox(AComp) do
      OnClick := ReplaceOnChangeEvent(AComp, OnClick)
  else if AComp is TComboBox then
    with TComboBox(AComp) do
      OnChange := ReplaceOnChangeEvent(AComp, OnChange)
  else if AComp is TSpinEdit then
    with TSpinEdit(AComp) do 
      OnChange := ReplaceOnChangeEvent(AComp, OnChange)
  else if AComp is TMemo then
    with TMemo(AComp) do
      OnChange := ReplaceOnChangeEvent(AComp, OnChange)
  else if AComp is TRadioGroup then
    with TRadioGroup(AComp) do
      OnClick := ReplaceOnChangeEvent(AComp, OnClick)
  ;
  if AId>0 then
  begin
    FCompById.Add(AID, AComp);
    FIdByComp.Add(Integer(AComp), Pointer(AID));
  end;
  if Assigned(AItem) then
  begin
    FCompByItem.Add(Integer(AItem), AComp);
    FItemByComp.Add(Integer(AComp), AItem);
  end;        
end;

procedure TGlobalSettingsBinder.Add(const AComp: TComponent;
  const AId: Integer);
begin
  _AddItem(AComp, FSettings.Search(AId), Aid);
end;

procedure TGlobalSettingsBinder.Add(const AComp: TComponent;
  const AName: AnsiString);
begin
  Add(AComp, FSettings.Search(AName));
end;

procedure TGlobalSettingsBinder.Add(const AComp: TComponent;
  const AItem: TSettingsBaseItem);
begin
  if Assigned(AItem) then
    _AddItem(AComp, AItem, AItem.ID)
end;



function TGlobalSettingsBinder.ReplaceOnChangeEvent(AComp: TObject;
  AEvent: TNotifyEvent): TNotifyEvent;
var lEvent: TEventObject;
begin
  if Assigned(AEvent) then
  begin
    lEvent := TEventObject.Create;
    lEvent.Event := AEvent;
    FCompChangeEvent.Add(Integer(AComp), Pointer(lEvent));
  end;
  Result := CompSettingsChanged;
end;

procedure TGlobalSettingsBinder._UpdateSettings(const A: TSettingsBaseItem;
  const B: TComponent; const AId: Integer);
begin
  if FLocked then
    Exit;
  //---
  FLocked := True;
  FSettings.DontNotify := True;
  try
    if (A<>nil) and (B<>nil) then
    begin
      if B is TCustomEdit then TCustomEdit(B).Text      := A.AsText  else
      if B is TCheckBox   then TCheckBox(B).Checked     := A.AsBool  else
      if B is TComboBox   then TComboBox(B).ItemIndex   := A.AsInt   else
      if B is TSpinEdit   then TSpinEdit(B).Value       := A.AsInt   else
      if B is TRadioGroup then TRadioGroup(B).ItemIndex := A.AsInt
    end;
  finally
    FLocked := False;
    FSettings.DontNotify := False;
  end;
  //---
  if Assigned(FOnGlobSettingsChange) then
    FOnGlobSettingsChange(FSettings, A, B, AId);
end;

procedure TGlobalSettingsBinder.UpdateSettingsById(const AID: Integer);
begin
  _UpdateSettings(FSettings.Search(AID), TComponent(FCompById.Items[AID]), AID)
end;

procedure TGlobalSettingsBinder.UpdateSettingsByItem(
  const AItem: TSettingsBaseItem);
begin
  _UpdateSettings(AItem, TComponent(FCompByItem[Integer(AItem)]), AItem.ID)
end;

procedure TGlobalSettingsBinder.UpdateSettingsByListId(
  const AListId: TIntegerList);
var
  j: Integer;
  A: TSettingsBaseItem;
  B: TComponent;
  I: Integer;
begin
  if FLocked or (AListId.Count<=0) then Exit;
  //---
  try
    for j:=0 to AListId.Count-1 do
    begin
      I := AListId[j];
      A := FSettings.Search(I);
      B := FCompById[I];
      //---
      _UpdateSettings(A, B, I);
    end;
  finally
    AListId.Free;
  end;
end;

procedure TGlobalSettingsBinder.UpdateSettingsByListItem(
  const AListItem: TSettingsSimpleList);
var
  j: Integer;
  A: TSettingsBaseItem;
  B: TComponent;
begin
  if FLocked or (AListItem.Count<=0) then Exit;
  //---
  try
    for j:=0 to AListItem.Count-1 do
    begin
      A := AListItem[j];
      B := FCompByItem[Integer(A)];
      //---
      _UpdateSettings(A, B, A.ID);
    end;
  finally
    AListItem.Free;
  end;
end;

procedure TGlobalSettingsBinder.WndProc(var AMsg: TMessage);
var
  Handled: Boolean;
begin
  Handled := True;
  if (AMsg.Msg=WM_USER) and not FLocked then
  begin
    if AMsg.WParam=WM_UPDATE_SETTINGS then
      UpdateSettingsById(AMsg.LParam)
    else if AMsg.WParam=WM_UPDATE_SETTINGSA then
      UpdateSettingsByItem(TSettingsBaseItem(AMsg.LParam))
    else if AMsg.WParam=WM_UPDATE_FEWSETTINGS then
      UpdateSettingsByListId(TIntegerList(AMsg.LParam))
    else if AMsg.WParam=WM_UPDATE_FEWSETTINGSA then
      UpdateSettingsByListItem(TSettingsSimpleList(AMsg.LParam));
    //---
    Handled := False;
  end;
  //---
  if Handled then
    AMsg.Result := 0
  else
    AMsg.Result := DefWindowProc(FWinHandle, AMsg.Msg, AMsg.WParam, AMsg.LParam);
end;



procedure TGlobalSettingsBinder.CallOnChangeOldEvent(AComp: TObject);
var lEvent: TEventObject;
begin
  lEvent := FCompChangeEvent.Items[Integer(AComp)];
  if Assigned(lEvent) then
    lEvent.Event(AComp);  
end;

procedure TGlobalSettingsBinder.CompSettingsChanged(ASender: TObject);
var A: TSettingsBaseItem;
begin
  if FLocked then
    Exit;
  //---
  FLocked := True;
  FSettings.DontNotify := True;
  try
    A := FItemByComp[Integer(ASender)];
    try
      if A<>nil then
      begin
        if ASender is TCustomEdit then
          A.AsText := TCustomEdit(ASender).Text
        else
        if ASender is TCheckBox then
          A.AsBool := TCheckBox(ASender).Checked
        else
        if ASender is TComboBox then
          A.AsInt := TComboBox(ASender).ItemIndex
        else
        if ASender is TSpinEdit then
          A.AsInt := TSpinEdit(ASender).Value
        else
        if ASender is TRadioGroup then
          A.AsInt := TRadioGroup(ASender).ItemIndex
      end;
      FLocked := False;
      FSettings.DontNotify := False;
      //---
      if Assigned(FOnCompSettingsChange) then
        FOnCompSettingsChange(ASender, A);
      //---
      CallOnChangeOldEvent(ASender);
    except
      on E: Exception do
        if not (E is EConvertError) then
          raise;
    end;
  finally
    FLocked := False;
    FSettings.DontNotify := False;
  end
end;


end.
