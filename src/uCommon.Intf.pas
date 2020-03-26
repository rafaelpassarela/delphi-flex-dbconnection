unit uCommon.Intf;

interface

uses
  System.Classes, Data.DB, uCommon.DBParams, Datasnap.DBClient,
  uCommon.ConnectionConfig;

type
  TLogType = (
    ltNormal,
    ltSQL,
    ltError,
    ltApiGet,
    ltApiPost);

  ICommonConnection = interface
  ['{91367DC5-876F-4CF6-8D77-D260B8D7495A}']
    function GetServer : string;
    procedure SetServer(const Value : string);
    function GetPort : Integer;
    procedure SetPort(const Value : Integer);
    function GetUserName : string;
    procedure SetUserName(const Value : string);
    function GetPassword : string;
    procedure SetPassword(const Value : string);
    function GetDatabase : string;
    procedure SetDatabase(const Value : string);

    function ExecSelect(const AOwner : TComponent; const AParams : TDBParams) : TDataSet;
    function ExecScript(const AParams : TDBParams) : Boolean;
    function Connected : Boolean;
    function InTransaction : Boolean;
    function StartTransaction : Boolean;
    function Commit(const ARetaining: Boolean) : Boolean;
    function Rollback(const ARetaining : Boolean) : Boolean;
    function GetConnectionObject : TComponent;

    procedure Connect;
    procedure Config(const AConfigObject : TCommonConnectionConfig);
    procedure Disconnect;
    // faz somente um close e open
    procedure ReConnect;

    property Server : string read GetServer write SetServer;
    property Port : Integer read GetPort write SetPort;
    property UserName : string read GetUserName write SetUserName;
    property Password : string read GetPassword write SetPassword;
    property Database : string read GetDatabase write SetDatabase;
  end;

  ICommonDataBase = interface
  ['{7E52D6FB-5374-4F26-9EB4-53173CACDED6}']
    function ExecuteSQL(const AReportParams : TDBParams) : Boolean; overload;
    function ExecuteSQL(const ASQL : string) : Boolean; overload;
    function ExecuteSelect(const AReportParams : TDBParams; out ADataSet : TClientDataSet) : Boolean; overload;
    function ExecuteSelect(const ASQL : string; out ADataSet : TClientDataSet) : Boolean; overload;
  end;

  ICommonLogger = interface
  ['{5DB0C0DC-D32D-4D6C-AC45-D7897F3E2C3A}']
    procedure AddLog(const AMessage : String; const AIncDateTime : Boolean = True;
      const ANewLine : Boolean = True; const ALogType : TLogType = ltNormal);
  end;

implementation

end.
