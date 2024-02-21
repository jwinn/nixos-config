{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isWSL = pkgs.stdenv.hostPlatform.isWindows;

  shell = "zsh";
  user = "jwinn";
  userHome = "/home/${user}";
in
{
  imports = [
    ../../modules/home-manager.nix
  ];

  users.users.${user} = {
    description = "Jon Winn";
    hashedPassword = "$y$j9T$O5nP5uCELjF73NNTNB5np.$FIJD/7aAawqdmUGojQvKVkf4R5IjaYFuuO4P1J2rqS0";
    isNormalUser = true;
    group = "users";
    shell = pkgs.zsh;
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];

    openssh.authorizedKeys.keyFiles = [
      ./ssh_ed25519.pub
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = import ./home.nix;
  };

  programs.zsh.enable = true;

  time.timeZone = "America/Los_Angeles";
}
