{ lib, pkgs, ... }:

{
  users.users.jwinn = {
    createHome = true;
    description = "Jon Winn";
    initialPassword = "changeme";
    isNormalUser = true;
    shell = pkgs.zsh;
    group = "users";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];

    packages = with pkgs; [
      jq
      kitty
      mosh
      rofi
      wezterm
    ];

    openssh.authorizedKeys.keyFiles = [
      ./ssh_ed25519.pub
    ];
  };

  programs = {
    direnv.enable = true;
    firefox.enable = true;
    git.enable = true;
    neovim = {
      enable = true;
      #viAlias = true;
      #vimAlias = true;
      #withNodeJs = true;
      #withPython3 = true;
      #withRuby = true;
    };
    tmux.enable = true;
    # Enable the zsh shell
    zsh.enable = true;
  };

  time.timeZone = "America/Los_Angeles";
}
