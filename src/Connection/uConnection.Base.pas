unit uConnection.Base;

interface

uses
  System.Classes, System.SysUtils, Data.DB, uCommon.Intf, uCommon.DBParams,
  uCommon.ConnectionConfig;

type
  TConnectionBaseClass = class of TConnectionBase;

  TConnectionBase = class(TInterfacedPersistent, ICommonConnection)
  protected
    FConnectionObject : TObject;
    FSharedConnection : Boolean; // quando o objeto de conexão é externo
    procedure InitConnection(out AConnectionObject : TObject); virtual;
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    procedure FreeContainers; virtual;

    // ICommonConnection
    function GetServer : string; virtual; abstract;
    procedure SetServer(const Value : string); virtual; abstract;
    function GetPort : Integer; virtual; abstract;
    procedure SetPort(const Value : Integer); virtual; abstract;
    function GetUserName : string; virtual; abstract;
    procedure SetUserName(const Value : string); virtual; abstract;
    function GetPassword : string; virtual; abstract;
    procedure SetPassword(const Value : string); virtual; abstract;
    function GetDatabase : string; virtual; abstract;
    procedure SetDatabase(const Value : string); virtual; abstract;

    function ExecSelect(const AOwner : TComponent; const AParams : TDBParams) : TDataSet; virtual; abstract;
    function ExecScript(const AParams : TDBParams) : Boolean; virtual; abstract;
  public
    constructor Create; overload;
    constructor Create(const AConnection : TObject); overload;
    destructor Destroy; override;

    procedure SetConnectionObject(const AConnection : TObject);
    procedure Connect; virtual; abstract;
    procedure Config(const AConfigObject : TCommonConnectionConfig); virtual; abstract;
    procedure Disconnect; virtual; abstract;
    procedure ReConnect; virtual; abstract;
    function Connected : Boolean; virtual; abstract;
    function InTransaction : Boolean; virtual; abstract;
    function StartTransaction : Boolean; virtual; abstract;
    function Commit(const ARetaining: Boolean) : Boolean; virtual; abstract;
    function Rollback(const ARetaining : Boolean) : Boolean; virtual; abstract;
    function GetConnectionObject : TComponent; virtual; abstract;

    property Server : string read GetServer write SetServer;
    property Port : Integer read GetPort write SetPort;
    property UserName : string read GetUserName write SetUserName;
    property Password : string read GetPassword write SetPassword;
    property Database : string read GetDatabase write SetDatabase;
  end;

implementation

{ TECommerceConnectionBase }

constructor TConnectionBase.Create(const AConnection: TObject);
begin
  Initialize;
  SetConnectionObject(AConnection);
end;

constructor TConnectionBase.Create;
begin
  Initialize;
  SetConnectionObject(nil);
end;

destructor TConnectionBase.Destroy;
begin
  Finalize;

  if (not FSharedConnection) and Assigned(FConnectionObject) then
  begin
    Self.Disconnect;
    FreeAndNil(FConnectionObject);
  end;

  FreeContainers;

  inherited;
end;

procedure TConnectionBase.Finalize;
begin
//
end;

procedure TConnectionBase.FreeContainers;
begin
//
end;

procedure TConnectionBase.InitConnection(out AConnectionObject : TObject);
begin
//
end;

procedure TConnectionBase.Initialize;
begin
//
end;

procedure TConnectionBase.SetConnectionObject(const AConnection: TObject);
begin
  FConnectionObject := AConnection;
  FSharedConnection := Assigned(FConnectionObject);
  // se nao tem conexão, cria uma nova
  if not FSharedConnection then
    InitConnection(FConnectionObject);
end;

end.
