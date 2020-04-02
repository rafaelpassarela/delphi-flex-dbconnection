unit uConnection.FireDAC.Base;

interface

uses
  uConnection.Base, uCommon.ConnectionConfig, uCommon.DBParams, Data.DB,
  System.Classes, System.SysUtils, Vcl.Forms, FireDAC.Comp.Client,
  FireDAC.Stan.Option,
//FMX: FireDAC.FMXUI.Wait
  {$IFDEF CONSOLE}
  FireDAC.ConsoleUI.Wait,
  {$ELSE}
  FireDAC.VCLUI.Wait,
  {$ENDIF}
  FireDAC.Phys;

type
  TConnectionFireDACBase = class(TConnectionBase)
  private
    FContainer : TForm;
  protected
    procedure InitConnection(out AConnectionObject : TObject); override;
    function GetDriverName : string; virtual; abstract;
    function GetConnectionObjectAsFireDAC : TFDConnection;
    function GetContainer : TForm;

    function ExecSelect(const AOwner : TComponent; const AParams : TDBParams) : TDataSet; override;
    function ExecScript(const AParams : TDBParams) : Boolean; override;
    procedure Initialize; override;
    procedure Finalize; override;
    procedure FreeContainers; override;
  public
    function Connected: Boolean; override;
    function InTransaction: Boolean; override;
    function StartTransaction : Boolean; override;
    function Commit(const ARetaining: Boolean) : Boolean; override;
    function Rollback(const ARetaining : Boolean) : Boolean; override;
    function GetConnectionObject : TComponent; override;

    procedure Connect; override;
    procedure Config(const AConfigObject : TCommonConnectionConfig); override;
    procedure Disconnect; override;
    procedure ReConnect; override;
  end;

implementation

{ TECommerceConnectionFireDAC }

function TConnectionFireDACBase.Commit(const ARetaining: Boolean): Boolean;
begin
  try
    if InTransaction then
    begin
      if ARetaining then
        GetConnectionObjectAsFireDAC.CommitRetaining
      else
        GetConnectionObjectAsFireDAC.Commit;
    end;
    Result := True;
  except
    on E:Exception do
      raise Exception.Create('Erro ao realizar commit dos dados. ' + E.Message);
  end;
end;

procedure TConnectionFireDACBase.Connect;
begin
  inherited;
  GetConnectionObjectAsFireDAC.Connected := True;
end;

procedure TConnectionFireDACBase.Config(const AConfigObject : TCommonConnectionConfig);
var
  lDir : string;
begin
  inherited;

  GetConnectionObjectAsFireDAC.DriverName := GetDriverName;

  lDir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

  UserName := AConfigObject.UserName;
  Database := StringReplace(AConfigObject.DataBaseName, '.\', lDir, []);
  Password := AConfigObject.Password;
  Server := AConfigObject.ServerName;
  Port := AConfigObject.Port;
end;

function TConnectionFireDACBase.Connected: Boolean;
begin
  Result := GetConnectionObjectAsFireDAC.Connected;
end;

procedure TConnectionFireDACBase.Disconnect;
begin
  inherited;
  GetConnectionObjectAsFireDAC.Connected := False;
end;

function TConnectionFireDACBase.ExecScript(const AParams : TDBParams): Boolean;
var
  lQry : TFDQuery;
begin
  lQry := TFDQuery.Create(FContainer);
  try
    lQry.FetchOptions.Items := [fiBlobs, fiDetails];
    lQry.SQL.Assign(AParams.SQL);
    lQry.Params.Assign(AParams);
    lQry.Connection := GetConnectionObjectAsFireDAC;
    lQry.ExecSQL;

    Result := True;
  finally
    FreeAndNil(lQry);
  end;
end;

function TConnectionFireDACBase.GetConnectionObject: TComponent;
begin
  Result := GetConnectionObjectAsFireDAC;
end;

function TConnectionFireDACBase.GetConnectionObjectAsFireDAC: TFDConnection;
begin
  Result := TFDConnection(FConnectionObject);
end;

function TConnectionFireDACBase.GetContainer: TForm;
begin
  Result := FContainer;
end;

function TConnectionFireDACBase.ExecSelect(const AOwner : TComponent;
  const AParams : TDBParams): TDataSet;
begin
  Result := TFDQuery.Create(AOwner);
  TFDQuery(Result).FetchOptions.Items := [fiBlobs, fiDetails];
  TFDQuery(Result).SQL.Assign( AParams.SQL );
  TFDQuery(Result).Params.Assign( AParams );
  TFDQuery(Result).Connection := GetConnectionObjectAsFireDAC;
end;

procedure TConnectionFireDACBase.Finalize;
begin
  inherited;
end;

procedure TConnectionFireDACBase.FreeContainers;
begin
  inherited;

  if Assigned(FContainer) then
    FreeAndNil(FContainer);
end;

procedure TConnectionFireDACBase.InitConnection(out AConnectionObject : TObject);
begin
  inherited;
  AConnectionObject := TFDConnection.Create(FContainer);
end;

procedure TConnectionFireDACBase.Initialize;
begin
  FContainer := TForm.Create(nil);

  inherited;
end;

function TConnectionFireDACBase.InTransaction: Boolean;
begin
  Result := GetConnectionObjectAsFireDAC.InTransaction;
end;

procedure TConnectionFireDACBase.ReConnect;
var
  lConnection : TFDConnection;
begin
  inherited;
  lConnection := GetConnectionObjectAsFireDAC;
  if lConnection.Connected then
    lConnection.Connected := False;
  lConnection.Connected := True;
end;

function TConnectionFireDACBase.Rollback(const ARetaining: Boolean): Boolean;
begin
  try
    if InTransaction then
    begin
      if ARetaining then
        GetConnectionObjectAsFireDAC.RollbackRetaining
      else
        GetConnectionObjectAsFireDAC.Rollback;
    end;
    Result := True;
  except
    on E:Exception do
      raise Exception.Create('Erro ao realizar rollback dos dados. ' + E.Message);
  end;
end;

function TConnectionFireDACBase.StartTransaction: Boolean;
begin
  if not InTransaction then
    GetConnectionObjectAsFireDAC.StartTransaction;
  Result := True;
end;

end.
