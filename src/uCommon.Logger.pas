unit uCommon.Logger;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  System.SysUtils, Vcl.Forms, Winapi.Windows, System.Math, System.Classes,
  Vcl.Graphics, Vcl.ExtCtrls, System.TypInfo, System.DateUtils, uCommon.Intf;

type
  TCommonLogger = class(TInterfacedPersistent, ICommonLogger)
  private
    FLogDir : String;
    FMaxLogSize : Word;
    FActive: Boolean;
    FFilePrefix: String;
    FLastOldCheck : TDateTime;
    function GetLogFileName : String;
    function GetLogFullPath : String;
    function FileSize(const AFileName : String) : Int64;
    function GetNextBackupName(const ACurrentFileName : String) : String;
    procedure SetMaxLogSize(const Value: Word);
    procedure ClearOldFiles;
  protected
    // Logs\       -> <exe bin>\Logs\
    function GetBackupPathSulfix : string; virtual;

    // ECommerce_  -> Logs\ECommerce_20191101
    function GetLogFileNamePrefix : string; virtual; abstract;

    // .log
    function GetLogFileExtension : string; virtual; abstract;

    // .bkp
    function GetBackupFileExtension : string; virtual; abstract;

    // 7
    function GetLogLifeTime : Word; virtual;

    procedure OnInitialize; virtual;
    procedure OnFinalize; virtual;
  public
    constructor Create(const AFilePrefix : String = ''); reintroduce;
    destructor Destroy; override;

    procedure AddLog(const AMessage : String; const AIncDateTime : Boolean = True;
      const ANewLine : Boolean = True; const ALogType : TLogType = ltNormal);

    property FilePrefix : String read FFilePrefix;
    property MaxLogSize : Word read FMaxLogSize write SetMaxLogSize;
    property Active : Boolean read FActive write FActive;
    property FileName : String read GetLogFullPath;
  end;

implementation

{ TECommerceLogger }

procedure TCommonLogger.AddLog(const AMessage: String;
  const AIncDateTime, ANewLine : Boolean; const ALogType : TLogType);
var
  LogFile: Text;
  lMens : string;
  lFileName: String;
begin
  if not FActive then
    Exit;

  // verifica para apagar automaticamente 1x por hora
  if IncHour(FLastOldCheck, 1) < Now  then
    ClearOldFiles;

  lFileName := FLogDir + GetLogFileName;

  if FileExists(lFileName) then
  begin
    AssignFile(LogFile, lFileName);
    if FileSize(lFileName) > (1024 * MaxLogSize) then
    begin
      CopyFile(PChar(lFileName), PChar(GetNextBackupName(lFileName)), False );
      DeleteFile(PChar(lFileName));
      ReWrite(LogFile);
    end
    else
      Append(LogFile);
  end
  else
  begin
    AssignFile(LogFile, lFileName);
    ReWrite(LogFile);
  end;

  // data e hora
  if AIncDateTime then
  begin
    lMens := FormatDateTime('hh:nn:ss:zzz - ', Time);
    // tipo
    lMens := lMens + GetEnumName(TypeInfo(TLogType), Ord(ALogType)) + ' - ';
  end
  else
    lMens := EmptyStr;

  // mens
  lMens := lMens + StringReplace(AMessage, #10, ' ', [rfReplaceAll, rfIgnoreCase]);
  lMens := StringReplace(lMens, #13, ' ', [rfReplaceAll, rfIgnoreCase]);

  if ANewLine then
    WriteLn(LogFile, lMens)
  else
    Write(LogFile, lMens);
  CloseFile(LogFile);
end;

procedure TCommonLogger.ClearOldFiles;
var
  lList: TStringList;
  lFileDate : TDateTime;
  lFileAtr: TWin32FileAttributeData;
  lSystemTime, lLocalTime: TSystemTime;
  i : Integer;

  procedure PopulateFileList;
  var
    lRec: TSearchRec;
  begin
    try
      if FindFirst(FLogDir + FFilePrefix + '*.*', faAnyFile, lRec) = 0 then
      begin
        repeat
          if FileExists(FLogDir + lRec.Name) then
            lList.Add(FLogDir + lRec.Name);
        until FindNext(lRec) <> 0;
      end;
    finally
      System.SysUtils.FindClose(lRec);
    end;
  end;

begin
  lList := TStringList.Create;
  try
    PopulateFileList;
    for i := 0 to lList.Count - 1 do
    begin
      if GetFileAttributesEx(PChar(lList.Strings[i]), GetFileExInfoStandard, @lFileAtr) then
      begin
        if FileTimeToSystemTime(lFileAtr.ftCreationTime, lSystemTime)
        and SystemTimeToTzSpecificLocalTime(nil, lSystemTime, lLocalTime) then
        begin
          lFileDate := SystemTimeToDateTime(lLocalTime);
          if lFileDate < (Now - GetLogLifeTime) then
            DeleteFile(PChar(lList.Strings[i]));
        end
        else
          DeleteFile( PChar(lList.Strings[i]) )
      end
      else
        DeleteFile( PChar(lList.Strings[i]) );
    end;
  finally
    if Assigned(lList) then
      FreeAndNil(lList);

    FLastOldCheck := Now;
  end;
end;

constructor TCommonLogger.Create(const AFilePrefix : String);
begin
  FLogDir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))
           + GetBackupPathSulfix;
  if not DirectoryExists(FLogDir) then
    CreateDir(FLogDir);

  FMaxLogSize := 2048; // 2 Mb
  FActive := True;
  if AFilePrefix = EmptyStr then
    FFilePrefix := GetLogFileNamePrefix
  else
    FFilePrefix := AFilePrefix;

  FLastOldCheck := Date;

  OnInitialize;
end;

destructor TCommonLogger.Destroy;
begin
  OnFinalize;
  inherited;
end;

function TCommonLogger.FileSize(const AFileName : String): Int64;
var
  lInfo: TWin32FileAttributeData;
begin
  Result := -1;

  if not GetFileAttributesEx(PWideChar(AFileName), GetFileExInfoStandard, @lInfo) then
    Exit;

  Result := lInfo.nFileSizeLow or (lInfo.nFileSizeHigh shl 32);
end;

function TCommonLogger.GetBackupPathSulfix: string;
begin
  Result := 'Logs\';
end;

function TCommonLogger.GetLogFileName: String;
begin
  Result := FFilePrefix + FormatDateTime('yyyy-mm-dd', Date) + GetLogFileExtension;
end;

function TCommonLogger.GetLogFullPath: String;
begin
  Result := FLogDir + GetLogFileName;
end;

function TCommonLogger.GetLogLifeTime: Word;
begin
  Result := 7;
end;

function TCommonLogger.GetNextBackupName(const ACurrentFileName : String): String;
var
  lBaseName: string;
  lCount: Integer;
  lRec: TSearchRec;
begin
  lBaseName := StringReplace(ACurrentFileName, GetLogFileExtension, '', [rfIgnoreCase]);
  lCount := 0;

  if FindFirst(lBaseName + GetBackupFileExtension + '*', faAnyFile, lRec) = 0 then
  begin
    repeat
      Inc(lCount);
    until FindNext(lRec) <> 0;
  end;
  System.SysUtils.FindClose(lRec);
  Inc(lCount);

  Result := lBaseName + GetBackupFileExtension + IntToStr(lCount);
end;

procedure TCommonLogger.OnFinalize;
begin
//
end;

procedure TCommonLogger.OnInitialize;
begin
//
end;

procedure TCommonLogger.SetMaxLogSize(const Value: Word);
begin
  if Value <> FMaxLogSize then
    FMaxLogSize := Max(1024, Value);
end;

end.



