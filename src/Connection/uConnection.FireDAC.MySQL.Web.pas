unit uConnection.FireDAC.MySQL.Web;

interface

uses
  uConnection.FireDAC.MySQL, uCommon.ConnectionConfig, System.SysUtils, Vcl.Forms,
  FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, FireDAC.VCLUI.Wait, Data.DB;

type
  TConnectionFireDACMySQLWeb = class(TConnectionFireDACMySQL)
  protected
    function GetDriverName: string; override;
  public
    procedure Config(const AConfigObject : TCommonConnectionConfig); override;
  end;

implementation

{ TConnectionFireDACMySQLWeb }

procedure TConnectionFireDACMySQLWeb.Config(const AConfigObject: TCommonConnectionConfig);
var
  lConfig : TCommonConnectionConfig;
begin
  if Assigned(AConfigObject) then
    inherited
  else begin
    lConfig := TCommonConnectionConfig.Create(False);
    try
      GetConnectionObjectAsFireDAC.Params.Clear;
      GetConnectionObjectAsFireDAC.DriverName := GetDriverName;

      lConfig.UserName := 'online_username';
      lConfig.DataBaseName := 'dbname';
      lConfig.Password := 'passwd';
      lConfig.ServerName := 'server_url';
      lConfig.Port := 3307;

      UserName := lConfig.UserName;
      Database := lConfig.DataBaseName;
      Password := lConfig.Password;
      Server := lConfig.ServerName;
      Port := lConfig.Port;
    finally
      if Assigned(lConfig) then
        FreeAndNil(lConfig);
    end;
  end;
end;

function TConnectionFireDACMySQLWeb.GetDriverName: string;
begin
  // Driver configurado no FDDrivers para conectar no MySQL velho
  Result := 'MySQL_RetroConfig';
end;

end.
