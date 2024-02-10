{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isWSL = pkgs.stdenv.hostPlatform.isWindows;
in
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

    # generally specific packages, should be in a project's folder,
    # using direnv and shell.nix to configure
    packages = with pkgs; [
      bat
      fzf
      gcc # used by treesitter
      htop
      jq
      kitty
      mosh
      nodejs # used by copilot.vim
      ripgrep
    ] ++ lib.optionals (isDarwin) [
      # is setup on linux through systemPackages, but not nixos-darwin
      cachix
    ] ++ lib.optionals (isLinux && !isWSL) [
      chromium
      firefox
      rofi
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

  time.timeZone = "America/Los_Angeles";
}
