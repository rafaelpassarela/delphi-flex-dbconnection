unit uCommon.Util.Windows;

interface

uses
  System.Win.Registry, System.SysUtils, Winapi.Windows, System.Classes,
  IdGlobal, IdStack;

type
  TCommonUtilWindows = class
  public
    class procedure StartWithWindows(const AExePath : string; const ATitle : string;
      const ARegister : Boolean);
    class function LocalComputerName : string;
    class function IpList : TStringList;
    class function GetExeVer(const APath : string) : string;
  end;

implementation

{ TCommonUtilWindows }

class function TCommonUtilWindows.GetExeVer(const APath: string): string;
var
  lVerInfoSize: Cardinal;
  lVerValueSize: Cardinal;
  lDummy: Cardinal;
  lPVerInfo: Pointer;
  lPVerValue: PVSFixedFileInfo;
begin
  Result := '';
  lVerInfoSize := GetFileVersionInfoSize(PChar(APath), lDummy);
  GetMem(lPVerInfo, lVerInfoSize);
  try
    if GetFileVersionInfo(PChar(APath), 0, lVerInfoSize, lPVerInfo) then
    begin
      if VerQueryValue(lPVerInfo, '\', Pointer(lPVerValue), lVerValueSize) then
      begin
        with lPVerValue^ do
          Result := Format('v%d.%d.%d.%d', [
            HiWord(dwFileVersionMS), //Major
            LoWord(dwFileVersionMS), //Minor
            HiWord(dwFileVersionLS), //Release
            LoWord(dwFileVersionLS)]); //Build
      end;
    end;
  finally
    FreeMem(lPVerInfo, lVerInfoSize);
  end;
end;

class function TCommonUtilWindows.IpList: TStringList;
var
  lIdList: TIdStackLocalAddressList;
  lIP: TIdStackLocalAddress;
  i: Integer;
begin
  Result := TStringList.Create;

  TIdStack.IncUsage;
  lIdList := TIdStackLocalAddressList.Create;
  try
    GStack.GetLocalAddressList(lIdList);
    for i := 0 to lIdList.Count - 1 do
    begin
      lIP := lIdList[i];
      if lIP.IPVersion = Id_IPv4 then
        Result.Add(lIP.IPAddress);
    end;
  finally
    TIdStack.DecUsage;
    if Assigned(lIdList) then
      FreeAndNil(lIdList);
  end;
end;

class function TCommonUtilWindows.LocalComputerName: string;
var
  lComputerName: Array [0 .. 256] of char;
  lSize: DWORD;
begin
  lSize := 256;
  Winapi.Windows.GetComputerName(lComputerName, lSize);
  Result := lComputerName;
end;

class procedure TCommonUtilWindows.StartWithWindows(const AExePath,
  ATitle: string; const ARegister: Boolean);
const
  C_CONST_REG_KEY = '\Software\Microsoft\Windows\CurrentVersion\Run';
  // or: RegKey = '\Software\Microsoft\Windows\CurrentVersion\RunOnce';
var
  lRegistry: TRegistry;
  lExe : string;
begin
  lRegistry := TRegistry.Create;
  try
    lRegistry.RootKey := HKEY_LOCAL_MACHINE;
    if lRegistry.OpenKey(C_CONST_REG_KEY, False) then
    begin
      if ARegister then
      begin
        lExe := Trim(AExePath);
        if lExe <> EmptyStr then
        begin
          if not lExe.StartsWith('"') then
            lExe := '"' + lExe;
          if not lExe.EndsWith('"') then
            lExe := lExe + '"';

          lRegistry.WriteString(ATitle, AExePath)
        end;
      end else
        lRegistry.DeleteValue(ATitle);
    end;
  finally
    if Assigned(lRegistry) then
      FreeAndNil(lRegistry);
  end;
end;

end.
