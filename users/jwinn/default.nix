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
      mosh
    ];

    openssh.authorizedKeys.keyFiles = [
      ./ssh_ed25519.pub
    ];
  };

  programs = {
    direnv.enable = true;
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

  services.xserver = {
    autorun = false;
    enable = true;
    desktopManager = {
      xterm.enable = false;
    };
    displayManager = {
      defaultSession = "none+i3";
      lightdm.enable = true;
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu # application launcher most people use
        i3status # gives you the default i3 status bar
        #i3lock # default i3 screen locker
        #i3blocks # if you are planning on using i3blocks over i3status
      ];
    };
  };
}
