{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isWSL = pkgs.stdenv.hostPlatform.isWindows;

  user = "jwinn";
  userHome = "/home/${user}";
in
{
  home = {
    homeDirectory = userHome;
    file = import ./files.nix { inherit user userHome; };
    packages = pkgs.callPackage ./packages.nix {};
    sessionPath = [ "${userHome}/.local/bin" ];
    # The state version is required and should stay at the version you
    # originally installed.
    stateVersion = "23.11";
    username = user;

    # generic HiDPI cursor(s)
    pointerCursor = lib.mkIf (isLinux && !isWSL) {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 64;
      x11.enable = true;
    };
  };

  programs = import ./programs.nix { inherit config lib pkgs; };

  xdg.enable = true;

  xresources.extraConfig = builtins.readFile ./Xresources;
}
