{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  nixpkgs.overlays = import ../lib/overlays.nix;

  # Global system packages
  environment.systemPackages = with pkgs; [
    cachix
    killall
    niv
    vim
    wget
  ] ++ lib.optionals (isLinux) [
    lynx
    xclip
  ] ++ lib.optionals (isDarwin) [
  ];

  programs = {
    git.enable = true;
    mtr.enable = true;
    tmux.enable = true;
    vim.defaultEditor = lib.mkDefault true;
  };
}
