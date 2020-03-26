unit uConnection.FireDAC.MySQL;

interface

uses
  uConnection.Base, uConnection.FireDAC.Base, Data.DB, System.Classes,
  System.SysUtils, Vcl.Forms, FireDAC.Comp.Client, FireDAC.Phys.MySQLDef,
  FireDAC.Phys, FireDAC.Stan.Def, FireDAC.Phys.MySQL, FireDAC.DApt,
  FireDAC.Stan.Async;

type
  TConnectionFireDACMySQL = class(TConnectionFireDACBase)
  protected
    function GetDriverName : string; override;

    function GetServer : string; override;
    procedure SetServer(const Value : string); override;
    function GetPort : Integer; override;
    procedure SetPort(const Value : Integer); override;
    function GetUserName : string; override;
    procedure SetUserName(const Value : string); override;
    function GetPassword : string; override;
    procedure SetPassword(const Value : string); override;
    function GetDatabase : string; override;
    procedure SetDatabase(const Value : string); override;
  end;

implementation

{ TECommerceConnectionFireDAC }

function TConnectionFireDACMySQL.GetDatabase: string;
begin
  Result := GetConnectionObjectAsFireDAC.Params.Database;
end;

function TConnectionFireDACMySQL.GetDriverName: string;
begin
  Result := 'MySQL';
end;

function TConnectionFireDACMySQL.GetPassword: string;
begin
  Result := GetConnectionObjectAsFireDAC.Params.Password;
end;

function TConnectionFireDACMySQL.GetPort: Integer;
begin
  Result := TFDPhysMySQLConnectionDefParams(GetConnectionObjectAsFireDAC.Params).Port;
end;

function TConnectionFireDACMySQL.GetServer: string;
begin
  Result := TFDPhysMySQLConnectionDefParams(GetConnectionObjectAsFireDAC.Params).Server;
end;

function TConnectionFireDACMySQL.GetUserName: string;
begin
  Result := GetConnectionObjectAsFireDAC.Params.UserName;
end;

procedure TConnectionFireDACMySQL.SetDatabase(const Value: string);
begin
  inherited;
  GetConnectionObjectAsFireDAC.Params.Database := Value;
end;

procedure TConnectionFireDACMySQL.SetPassword(const Value: string);
begin
  inherited;
  GetConnectionObjectAsFireDAC.Params.Password := Value;
end;

procedure TConnectionFireDACMySQL.SetPort(const Value: Integer);
begin
  inherited;
  TFDPhysMySQLConnectionDefParams(GetConnectionObjectAsFireDAC.Params).Port := Value;
end;

procedure TConnectionFireDACMySQL.SetServer(const Value: string);
begin
  inherited;
  TFDPhysMySQLConnectionDefParams(GetConnectionObjectAsFireDAC.Params).Server := Value;
end;

procedure TConnectionFireDACMySQL.SetUserName(const Value: string);
begin
  inherited;
  GetConnectionObjectAsFireDAC.Params.UserName := Value;
end;

end.
