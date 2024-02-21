{ config, lib, pkgs, ... }:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  # provide ZRAM as swap
  zramSwap = lib.mkIf isLinux {
    enable = lib.mkDefault true;
  };
}
