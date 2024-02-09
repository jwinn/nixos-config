{ config, ... }:

{
  nixpkgs.overlays = import ../lib/overlays.nix;
}
