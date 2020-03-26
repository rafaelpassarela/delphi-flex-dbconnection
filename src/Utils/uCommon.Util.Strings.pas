unit uCommon.Util.Strings;

interface

type
  TCommonUtilStrings = class
  public
    class function UTF8ToIso8859(const AUTFString : string) : string;
  end;

implementation

{ TCommonUtilStrings }

class function TCommonUtilStrings.UTF8ToIso8859(const AUTFString: string): string;
begin
  Result := UTF8ToString(AnsiString(AUTFString));
end;

end.
