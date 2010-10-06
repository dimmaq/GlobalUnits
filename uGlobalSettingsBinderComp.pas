unit uGlobalSettingsBinderComp;

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

type
  TGlobalSettingsBinderComp = class(TComponent)
  private
    FSettings: TGlobalSettingsBase;
    FCompById: TIntegerAssociationList;
    FIdByComp: TIntegerAssociationList;
    FWinHandle: HWND;
    FOnGlobSettingsChange: TGlobSettingsChangeEvent;
    FOnCompSettingsChange: TNotifyEvent;
    FLocked: Boolean;
    //---
    procedure SetGlobalSettings(ASettings: TGlobalSettingsBase);
    procedure CompSettingsChanged(ASender: TObject);
    procedure WndProc(var AMsg: TMessage);
    procedure UpdateSettingsA(ID: Integer);
    procedure UpdateSettingsB(AItem: TSettingsBaseItem);
    procedure UpdateSettingsC(AItem: TSettingsBaseItem; AId: Integer);
    procedure UpdateSettingsD(A: TSettingsBaseItem; B: TComponent; AId: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //---
    procedure Add(const AComp: TComponent; const AId: Integer); overload;
    procedure Add(const AComp: TComponent;
      const AItem: TSettingsBaseItem); overload;
    //---
    property GlobalSettings: TGlobalSettingsBase read FSettings write SetGlobalSettings;
  published
    property OnGlobSettingsChange: TGlobSettingsChangeEvent
      read FOnGlobSettingsChange write FOnGlobSettingsChange;
    property OnCompSettingsChange: TNotifyEvent
      read FOnCompSettingsChange write FOnCompSettingsChange;
    property Locked: Boolean read FLocked write FLocked;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TGlobalSettingsBinderComp]);
end;

{ TGlobalSettingsBinder }

constructor TGlobalSettingsBinderComp.Create(AOwner: TComponent);
begin
  inherited;
  FSettings  := nil;
  FCompById  := TIntegerAssociationList.Create;
  FIdByComp  := TIntegerAssociationList.Create;
  FWinHandle := Classes.AllocateHWnd(WndProc);
  //---
  FOnGlobSettingsChange := nil;
  FOnCompSettingsChange := nil;
  //---
  FLocked := True;
end;

destructor TGlobalSettingsBinderComp.Destroy;
begin
  Classes.DeallocateHWnd(FWinHandle);
  FreeAndNil(FCompById);
  FreeAndNil(FIdByComp);
  inherited;
end;

procedure TGlobalSettingsBinderComp.SetGlobalSettings(
  ASettings: TGlobalSettingsBase);
begin
  if Assigned(FSettings) then
  begin
    FSettings.NotifyHandle := 0;
    FSettings := nil;
  end;
  FSettings := ASettings;
  FSettings.NotifyHandle := FWinHandle;
end;

procedure TGlobalSettingsBinderComp.UpdateSettingsA(ID: Integer);
begin
  UpdateSettingsC(FSettings.Search(ID), ID)
end;

procedure TGlobalSettingsBinderComp.UpdateSettingsB(AItem: TSettingsBaseItem);
begin
  UpdateSettingsC(AItem, AItem.ID)
end;

procedure TGlobalSettingsBinderComp.UpdateSettingsC(AItem: TSettingsBaseItem;
  AId: Integer);
begin
  UpdateSettingsD(AItem, TComponent(FCompById.Items[AID]), AID)
end;

procedure TGlobalSettingsBinderComp.UpdateSettingsD(A: TSettingsBaseItem;
  B: TComponent; AId: Integer);
begin
  if FLocked then
    Exit;
  //---
  FLocked := True;
  FSettings.DontNotify := True;
  try
    if (A<>nil) and (B<>nil) then
    begin
      if (B is TCustomEdit) and (A is TSettingsAStrItem) then
        TCustomEdit(B).Text := TSettingsAStrItem(A).Value
      else
      if (B is TCheckBox) and (A is TSettingsBoolItem) then
        TCheckBox(B).Checked := TSettingsBoolItem(A).Value
      else
      if (B is TComboBox) and (A is TSettingsIntItem) then
        TComboBox(B).ItemIndex := TSettingsIntItem(A).Value
      else
      if (B is TSpinEdit) and (A is TSettingsIntItem) then
        TSpinEdit(B).Value := TSettingsIntItem(A).Value
    end;
    //---
    if Assigned(FOnGlobSettingsChange) then
      FOnGlobSettingsChange(FSettings, A, B, AId);
    //---
  finally
    FLocked := False;
    FSettings.DontNotify := False;
  end;
end;

procedure TGlobalSettingsBinderComp.WndProc(var AMsg: TMessage);
var
  Handled: Boolean;
begin
  Handled := True;
  if (AMsg.Msg=WM_USER) and not FLocked then
  begin
    if AMsg.WParam=WM_UPDATE_SETTINGS then
      UpdateSettingsA(AMsg.LParam)
    else if AMsg.WParam=WM_UPDATE_SETTINGSA then
      UpdateSettingsB(TSettingsBaseItem(AMsg.LParam));
    Handled := False;
  end;
  //---
  if Handled then
    AMsg.Result := 0
  else
    AMsg.Result := DefWindowProc(FWinHandle, AMsg.Msg, AMsg.WParam, AMsg.LParam);
end;

procedure TGlobalSettingsBinderComp.Add(const AComp: TComponent;
  const AId: Integer);
begin
  if AComp is TEdit then
    TEdit(AComp).OnChange := CompSettingsChanged
  else if AComp is TLabeledEdit then
    TLabeledEdit(AComp).OnChange := CompSettingsChanged
  else if AComp is TCheckBox then
    TCheckBox(AComp).OnClick := CompSettingsChanged
  else if AComp is TComboBox then
    TComboBox(AComp).OnChange := CompSettingsChanged
  else if AComp is TSpinEdit then
    TSpinEdit(AComp).OnChange := CompSettingsChanged

  ;
  if AId>0 then
  begin
    FCompById.Add(AID, AComp);
    FIdByComp.Add(Integer(AComp), Pointer(AID));
  end;
end;

procedure TGlobalSettingsBinderComp.Add(const AComp: TComponent;
  const AItem: TSettingsBaseItem);
begin
  Add(AComp, AItem.ID)
end;

procedure TGlobalSettingsBinderComp.CompSettingsChanged(ASender: TObject);
var A: TSettingsBaseItem;
begin
  if FLocked then
    Exit;
  //---
  FLocked := True;
  FSettings.DontNotify := True;
  try
    A := FSettings.Search(Integer(FIdByComp.Items[Integer(ASender)]));
    if A<>nil then
    begin
      if (ASender is TCustomEdit) and (A is TSettingsAStrItem) then
        TSettingsAStrItem(A).Value := TCustomEdit(ASender).Text
      else
      if (ASender is TCheckBox) and (A is TSettingsBoolItem) then
        TSettingsBoolItem(A).Value := TCheckBox(ASender).Checked
      else
      if (ASender is TComboBox) and (A is TSettingsIntItem) then
        TSettingsIntItem(A).Value := TComboBox(ASender).ItemIndex
      else
      if (ASender is TSpinEdit) and (A is TSettingsIntItem) then
        TSettingsIntItem(A).Value := TSpinEdit(ASender).Value

    end;
    //---
    if Assigned(FOnCompSettingsChange) then
      FOnCompSettingsChange(ASender);
    //---
  finally
    FLocked := False;
    FSettings.DontNotify := False;
  end
end;


end.

