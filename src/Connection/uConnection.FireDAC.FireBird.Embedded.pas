unit uConnection.FireDAC.FireBird.Embedded;

interface

uses
  uConnection.FireDAC.FireBird, FireDAC.Phys.IBWrapper;

type
  TConnectionFireDACFireBirdEmbedded = class(TConnectionFireDACFireBird)
  protected
    function GetProtocol: TIBProtocol; override;
  end;

implementation

{ TConnectionFireDACFireBirdEmbedded }

function TConnectionFireDACFireBirdEmbedded.GetProtocol: TIBProtocol;
begin
  Result := ipLocal;
end;

end.
