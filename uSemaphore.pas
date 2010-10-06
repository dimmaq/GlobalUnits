unit uSemaphore;

interface

uses SysUtils, Classes, SyncObjs, Windows;

type
  ESemaphoreError = class(Exception);

  TSemaphore = class(THandleObject)
  private const
    THREADS_WAIT_TIMEOUT = 99;
  private
    FLimit: Integer;
    FLockInt0: Integer;
    FCounter: Integer;
    procedure SetLimit(const Value: Integer);
    procedure CheckSemaphoreCreate;
  public
    constructor Create(const ALimit: Integer);
    procedure Acquire; override;
    procedure Release; override;
    procedure Enter;
    procedure Leave;
    //---
    property Limit: Integer read FLimit write SetLimit;
    property Counter: Integer read FCounter;
  end;

implementation

{ TSemaphore }

constructor TSemaphore.Create(const ALimit: Integer);
begin
  inherited Create(False);
  FLimit := ALimit;
  FLockInt0 := 0;
  FHandle := INVALID_HANDLE_VALUE;
  FCounter := 0;
// отложеное cоздание семафора
//  FHandle := CreateSemaphore(nil, ALimit, ALimit, nil);
//  if FHandle = 0 then
//    RaiseLastOSError;
end;

procedure TSemaphore.CheckSemaphoreCreate;
var H: THandle;
begin
  if FHandle=INVALID_HANDLE_VALUE then
  begin
    if InterlockedIncrement(FLockInt0)=1 then
    begin
      H := CreateSemaphore(nil, FLimit, FLimit, nil);
      if H = 0 then
        RaiseLastOSError;
      //---
      FHandle := H;
      InterlockedDecrement(FLockInt0);
    end
    else
    begin
      InterlockedDecrement(FLockInt0);
      while FHandle<>INVALID_HANDLE_VALUE do
        Sleep(THREADS_WAIT_TIMEOUT);
    end
  end
end;

procedure TSemaphore.Enter;
begin
  Acquire()
end;

procedure TSemaphore.Leave;
begin
  Release()
end;

procedure TSemaphore.Acquire;
begin
  CheckSemaphoreCreate();
  if WaitFor(INFINITE) = wrError then
    RaiseLastOSError();
  InterlockedIncrement(FCounter)
end;

procedure TSemaphore.Release;
begin
  CheckSemaphoreCreate();
  if not ReleaseSemaphore(FHandle, 1, nil) then
    RaiseLastOSError();
  InterlockedDecrement(FCounter)
end;

procedure TSemaphore.SetLimit(const Value: Integer);
begin
  if FHandle=INVALID_HANDLE_VALUE then
    FLimit := Value
  else
    raise ESemaphoreError.Create('Can''t change Limit value in created semaphore');
end;

end.
