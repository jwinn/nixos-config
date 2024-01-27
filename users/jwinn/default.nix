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
      firefox
      jq
      kitty
      mosh
      wezterm
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

  services.xserver.autorun = true;
  #services.xserver.desktopManager.xfce = {
  #  enable = true;
  #  enableXfwm = false;
  #  noDesktop = true;
  #};
  #services.xserver.displayManager = {
  #  defaultSession = "xfce+i3";
  #};
}
