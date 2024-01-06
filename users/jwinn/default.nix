{ lib, pkgs, ... }:

{
  users.users.jwinn = {
    uid = 1000;
    description = "Jon Winn";
    isNormalUser = true;
    createHome = true;
    initialPassword = "changeme";
    shell = pkgs.zsh;
    group = "users";
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ];

    packages = with pkgs; [
      jq
      wget
    ];

    openssh.authorizedKeys.keyFiles = [
      ./ssh_ed25519.pub
    ];
  };

  programs = {
    git.enable = true;
    neovim.enable = true;
    # Enable the zsh shell
    zsh.enable = true;
  };
}