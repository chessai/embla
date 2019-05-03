{ pkgs }:

self: super:

with { inherit (pkgs.stdenv) lib; };

with pkgs.haskell.lib;

{
  embla = (
    with rec {
      emblaSource = pkgs.lib.cleanSource ../.;
      emblaBasic  = self.callCabal2nix "embla" emblaSource { };
    };
    overrideCabal emblaBasic (old: {
    })
  );
}
