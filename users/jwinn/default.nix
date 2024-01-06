{ lib, pkgs, ... }:

{
  users.users.jwinn = {
    isNormalUser = true;
    initialPassword = "changeme";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "audio"
      "docker"
      "networkmanager"
      "video"
    ];
    packages = with pkgs; [
      jq
      wget
    ]

    openssh.authorizedKeys.keys = [
      (lib.strings.fileContents ./ssh_ed25519.pub)
    ];
  };

  programs = {
    git.enable = true;
    neovim.enable = true;
    # Enable the zsh shell
    zsh.enable = true;
  };
}
