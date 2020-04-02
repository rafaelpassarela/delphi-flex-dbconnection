unit uCommon.ConnectionConfig;

interface

uses
  uRpSerialization, System.SysUtils, Vcl.Forms;

type
  TConnectionEngines = (
    ceNone,
    ceMySQL,
    ceFireBird,
    ceFireBirdEmbedded
  );

  TConnectionEnginesHelper = record helper for TConnectionEngines
    function AsInteger: Cardinal; overload;
    function AsString: string;
    procedure AsInteger(const Value: Cardinal); overload;
  end;

  TCommonConnectionConfig = class(TBaseSerializableObject)
  private
    FUserName: string;
    FPassword: string;
    FDataBaseName: string;
    FServerName: string;
    FPort: Integer;
    FConnectionEngine: TConnectionEngines;
  protected
    function GetConfigName : string; virtual;
    function GetConfigDir : string; virtual;
    procedure Initialize; override;
    procedure DoLoadFromNode(const ANode: IXMLNode); override;
    procedure DoSaveToNode; override;
  public
    constructor Create(const AAutoLoad : Boolean = True); reintroduce;
    procedure Reset; override;
    procedure LoadConfig;
    procedure SaveConfig;

    property ConnectionEngine : TConnectionEngines read FConnectionEngine write FConnectionEngine;
    property UserName : string read FUserName write FUserName;
    property Password : string read FPassword write FPassword;
    property DataBaseName : string read FDataBaseName write FDataBaseName;
    property ServerName : string read FServerName write FServerName;
    property Port : Integer read FPort write FPort;
  end;

implementation

{ TCommonConnectionConfig }

constructor TCommonConnectionConfig.Create(const AAutoLoad : Boolean);
begin
  inherited Create(nil);
  if AAutoLoad then
    LoadConfig;
end;

procedure TCommonConnectionConfig.DoLoadFromNode(const ANode: IXMLNode);
var
  lAux : Cardinal;
begin
  inherited;
  FromNode('engine', lAux, TypeInfo(TConnectionEngines));
  FConnectionEngine := TConnectionEngines(lAux);

  FromNode('database', FDataBaseName, True);
  FromNode('server', FServerName, True);
  FromNode('port', FPort);
  FromNode('user.name', FUserName, True);
  FromNode('user.pwd', FPassword, True);
end;

procedure TCommonConnectionConfig.DoSaveToNode;
begin
  inherited;
  ToNode('engine', Ord(FConnectionEngine), TypeInfo(TConnectionEngines));
  ToNode('database', FDataBaseName, True);
  ToNode('server', FServerName, True);
  ToNode('port', FPort);
  ToNode('user.name', FUserName, True);
  ToNode('user.pwd', FPassword, True);
end;

function TCommonConnectionConfig.GetConfigDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
end;

function TCommonConnectionConfig.GetConfigName: string;
begin
  Result := StringReplace(ExtractFileName(Application.ExeName), '.exe', 'DbConfig.json', [rfIgnoreCase]);
end;

procedure TCommonConnectionConfig.Initialize;
begin
  inherited;
  FormatType := sfJSON;
  IncludeClassName := False;
  IncludeEmptyFields := True;
end;

procedure TCommonConnectionConfig.LoadConfig;
var
  lFileName : string;
begin
  lFileName := GetConfigDir + GetConfigName;
  if FileExists(lFileName) then
    LoadFromFile(lFileName, sfJSON)
  else begin
    Reset;
    SaveToFile(lFileName, sfJSON);
  end;
end;

procedure TCommonConnectionConfig.Reset;
begin
  inherited;
  FConnectionEngine := ceNone;
  FUserName := EmptyStr;
  FPassword := EmptyStr;
  FDataBaseName := EmptyStr;
  FServerName := EmptyStr;
  FPort := 0;
end;

procedure TCommonConnectionConfig.SaveConfig;
var
  lFileName : string;
begin
  lFileName := GetConfigDir + GetConfigName;
  Self.SaveToFile(lFileName, sfJSON);
end;

{ TConnectionEnginesHelper }

procedure TConnectionEnginesHelper.AsInteger(const Value: Cardinal);
begin
  Self := TConnectionEngines(Value);
end;

function TConnectionEnginesHelper.AsString: string;
begin
  case Self of
    ceNone: Result := '';
    ceMySQL: Result := 'MySQL';
    ceFireBird: Result := 'FB';
    ceFireBirdEmbedded: Result := 'FB'
  else
    raise Exception.Create('Egine de conexão desconhecida.');
  end;
end;

function TConnectionEnginesHelper.AsInteger: Cardinal;
begin
  Result := Ord(Self);
end;

end.
