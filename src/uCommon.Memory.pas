unit uCommon.Memory;

interface

type
  TCommomMemory = class
  private
    class function InterlockedAdd(var Addend: Integer; Increment: Integer): Integer;
  public
    class function InterlockedIncrement(var Addend: Integer): Integer;
    class function InterlockedDecrement(var Addend: Integer): Integer;
  end;

implementation

{ TCommomMemory }

class function TCommomMemory.InterlockedAdd(var Addend: Integer; Increment: Integer): Integer;
asm
      MOV   ECX,EAX
      MOV   EAX,EDX
 LOCK XADD  [ECX],EAX
      ADD   EAX,EDX
end;

class function TCommomMemory.InterlockedDecrement(var Addend: Integer): Integer;
asm
      MOV   EDX,-1
      JMP   InterlockedAdd
end;

class function TCommomMemory.InterlockedIncrement(var Addend: Integer): Integer;
asm
      MOV   EDX,1
      JMP   InterlockedAdd
end;

end.
