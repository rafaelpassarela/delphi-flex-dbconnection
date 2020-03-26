unit uCommon.DataBase;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient, Datasnap.Provider,
  Vcl.ExtCtrls, uCommon.Logger, uCommon.Intf, uCommon.DBParams;

type
  EDataBaseSQLError = class(Exception)
  private
    FSQL : String;
  public
    constructor Create(const AMessage : String; const pSQL : String);

    property SQL : String read FSQL;
  end;

  TCommonDataBase = class(TInterfacedPersistent, ICommonDataBase)
  protected
    FConnection: ICommonConnection;
    FLogger : ICommonLogger;
    procedure OnCreate; virtual;
    procedure OnDestroy; virtual;
    procedure LogSQLCommand(const ASQL : string; const AParamValues : string);
    function DoReconnect : Boolean;
    function TryToReconnect(const AMessage : string) : Boolean;
    function CanLog : Boolean;
  public
    constructor Create(const AConnection : ICommonConnection; const ALogger : ICommonLogger);
    destructor Destroy; override;
    // IECommerceDB
    function ExecuteSQL(const AReportParams : TDBParams) : Boolean; overload;
    function ExecuteSQL(const ASQL : string) : Boolean; overload;

    function ExecuteSelect(const AReportParams : TDBParams; out ADataSet : TClientDataSet) : Boolean; overload;
    function ExecuteSelect(const ASQL : string; out ADataSet : TClientDataSet) : Boolean; overload;

    property Connection : ICommonConnection read FConnection;
  end;

implementation

{ TECommerceDataBase }

function TCommonDataBase.CanLog: Boolean;
begin
  Result := Assigned(FLogger);
end;

constructor TCommonDataBase.Create(const AConnection : ICommonConnection;
  const ALogger : ICommonLogger);
begin
  inherited Create;

  FConnection := AConnection;
  FLogger := ALogger;

  OnCreate;
end;

destructor TCommonDataBase.Destroy;
begin
  OnDestroy;
  inherited;
end;

function TCommonDataBase.DoReconnect: Boolean;
begin
  Result := False;
  try
    FConnection.ReConnect;
    Result := True;
  except
    on E:Exception do
    begin
      if CanLog then
      begin
        FLogger.AddLog('[' + E.ClassName + '] ' + E.Message, True, True, ltError);
        if (Pos('Connection must be active', E.Message) > 0)
        or (Pos('connect to MySQL server', E.Message) > 0) then
        begin
          Sleep(5000);
          Result := DoReconnect;
        end;
      end;
    end;
  end;
end;

function TCommonDataBase.ExecuteSQL(const ASQL: string): Boolean;
var
  lParams : TDBParams;
begin
  lParams := TDBParams.Create(ASQL);
  try
    Result := ExecuteSQL(lParams)
  finally
    FreeAndNil(lParams);
  end;
end;

procedure TCommonDataBase.LogSQLCommand(const ASQL: string; const AParamValues : string);
var
  lSQL : string;
begin
  lSQL := Trim(ASQL);
  if CanLog and (not lSQL.Equals(EmptyStr)) then
  begin
    if lSQL[Length(lSQL)] <> ';' then
      lSQL := lSQL + ';';

    FLogger.AddLog(lSQL + '  ' + AParamValues, True, False, ltSQL );
  end;
end;

function TCommonDataBase.ExecuteSelect(const AReportParams: TDBParams;
  out ADataSet: TClientDataSet): Boolean;
var
  lContainer: TPanel;
  lQry : TDataSet;
  lProvider : TDataSetProvider;
  lCdsConsulta : TClientDataSet;
  lStartTime : TTime;
begin
  ADataSet := nil;

  lContainer := TPanel.Create(nil);
  lQry := FConnection.ExecSelect(lContainer, AReportParams);
  lProvider := TDataSetProvider.Create(lContainer);
  lCdsConsulta := TClientDataSet.Create(lContainer);
  try
    lProvider.Name := 'dspEcomm' + FormatDateTime('hhmmsszzz', Now);
    lProvider.DataSet := lQry;

    lCdsConsulta.ProviderName := lProvider.Name;
    try
      // adiciona o log do comando
      LogSQLCommand(AReportParams.SQL.Text, AReportParams.GetParamValues);

      lStartTime := Now;
      lCdsConsulta.Open;
      // depois de abrir, loga novamente com o tempo
      if CanLog then
        FLogger.AddLog(' /* ' + FormatDateTime('hh:nn:ss:zzz', Now - lStartTime) + ' */', False, True);

      ADataSet := TClientDataSet.Create(nil);
      ADataSet.XMLData := lCdsConsulta.XMLData;

      Result := True;
    except
      on E:Exception do
      begin
        if CanLog then
          FLogger.AddLog('[' + E.ClassName + '] ' + E.Message, True, True, ltError);

        if TryToReconnect(E.Message) then
          Result := ExecuteSelect(AReportParams, ADataSet)
        else
          raise EDataBaseSQLError.Create(E.Message, AReportParams.SQL.Text);
      end;
    end;
  finally
    FreeAndNil(lCdsConsulta);
    FreeAndNil(lProvider);
    FreeAndNil(lQry);

    FreeAndNil(lContainer);
  end;
end;

function TCommonDataBase.ExecuteSelect(const ASQL: string; out ADataSet: TClientDataSet): Boolean;
var
  lParam : TDBParams;
begin
  lParam := TDBParams.Create(ASQL);
  try
    Result := ExecuteSelect(lParam, ADataSet);
  finally
    FreeAndNil(lParam);
  end;
end;

function TCommonDataBase.ExecuteSQL(const AReportParams: TDBParams): Boolean;
var
  lStartTime : TTime;
begin
  if AReportParams.SQL.Text <> EmptyStr then
  begin
    try
      LogSQLCommand(AReportParams.SQL.Text, AReportParams.GetParamValues);

      lStartTime := Now;
      Result := FConnection.ExecScript(AReportParams);

      if CanLog then
        FLogger.AddLog(' /* ' + FormatDateTime('hh:nn:ss:zzz', Now - lStartTime) + ' */', False, True);
    except
      on E:Exception do
      begin
        if CanLog then
          FLogger.AddLog('[' + E.ClassName + '] ' + E.Message, True, True, ltError);

        if TryToReconnect(E.Message) then
          Result := ExecuteSQL(AReportParams)
        else
          raise EDataBaseSQLError.Create(E.Message, AReportParams.SQL.Text);
      end;
    end;
  end else
    Result := False;
end;

procedure TCommonDataBase.OnCreate;
begin
//
end;

procedure TCommonDataBase.OnDestroy;
begin
//
end;

function TCommonDataBase.TryToReconnect(const AMessage: string): Boolean;
begin
  if (Pos('MySQL server has gone away', AMessage) > 0)
  or (Pos('Lost connection to MySQL', AMessage) > 0) then
    Result := DoReconnect
  else
    Result := False;
end;

{ EDataBaseSQLError }

constructor EDataBaseSQLError.Create(const AMessage, pSQL: String);
begin
  FSQL := pSQL;
  inherited Create(AMessage);
end;

end.
