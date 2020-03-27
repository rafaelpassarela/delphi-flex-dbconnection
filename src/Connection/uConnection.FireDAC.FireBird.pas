unit uConnection.FireDAC.FireBird;

interface

uses
  uConnection.Base, uConnection.FireDAC.Base, Data.DB, System.Classes,
  System.SysUtils, Vcl.Forms, FireDAC.Comp.Client, FireDAC.Phys.FBDef,
  FireDAC.Phys, FireDAC.Stan.Def, FireDAC.Phys.IBBase, FireDAC.DApt,
  FireDAC.Phys.FB, FireDAC.Stan.Async, uCommon.ConnectionConfig,
  FireDAC.Phys.IBWrapper;

type
  TConnectionFireDACFireBird = class(TConnectionFireDACBase)
  protected
    function GetProtocol : TIBProtocol; virtual;
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
  public
    procedure Config(const AConfigObject: TCommonConnectionConfig); override;
  end;

implementation

{ TECommerceConnectionFireDAC }

procedure TConnectionFireDACFireBird.Config(
  const AConfigObject: TCommonConnectionConfig);
begin
  inherited;

  TFDPhysFBConnectionDefParams(GetConnectionObjectAsFireDAC.Params).CharacterSet := csWIN1252;
  TFDPhysFBConnectionDefParams(GetConnectionObjectAsFireDAC.Params).PageSize := ps8192;
  TFDPhysFBConnectionDefParams(GetConnectionObjectAsFireDAC.Params).Protocol := GetProtocol;
end;

function TConnectionFireDACFireBird.GetDatabase: string;
begin
  Result := GetConnectionObjectAsFireDAC.Params.Database;
end;

function TConnectionFireDACFireBird.GetDriverName: string;
begin
  Result := 'FB';
end;

function TConnectionFireDACFireBird.GetPassword: string;
begin
  Result := GetConnectionObjectAsFireDAC.Params.Password;
end;

function TConnectionFireDACFireBird.GetPort: Integer;
begin
  Result := TFDPhysFBConnectionDefParams(GetConnectionObjectAsFireDAC.Params).Port;
end;

function TConnectionFireDACFireBird.GetProtocol: TIBProtocol;
begin
  Result := ipTCPIP;
end;

function TConnectionFireDACFireBird.GetServer: string;
begin
  Result := TFDPhysFBConnectionDefParams(GetConnectionObjectAsFireDAC.Params).Server;
end;

function TConnectionFireDACFireBird.GetUserName: string;
begin
  Result := GetConnectionObjectAsFireDAC.Params.UserName;
end;

procedure TConnectionFireDACFireBird.SetDatabase(const Value: string);
begin
  inherited;
  GetConnectionObjectAsFireDAC.Params.Database := Value;
end;

procedure TConnectionFireDACFireBird.SetPassword(const Value: string);
begin
  inherited;
  GetConnectionObjectAsFireDAC.Params.Password := Value;
end;

procedure TConnectionFireDACFireBird.SetPort(const Value: Integer);
begin
  inherited;
  TFDPhysFBConnectionDefParams(GetConnectionObjectAsFireDAC.Params).Port := Value;
end;

procedure TConnectionFireDACFireBird.SetServer(const Value: string);
begin
  inherited;
  TFDPhysFBConnectionDefParams(GetConnectionObjectAsFireDAC.Params).Server := Value;
end;

procedure TConnectionFireDACFireBird.SetUserName(const Value: string);
begin
  inherited;
  GetConnectionObjectAsFireDAC.Params.UserName := Value;
end;

end.
