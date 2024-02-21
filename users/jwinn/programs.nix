{ config, lib, pkgs, ... }:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  direnv = {
    enable = true;
    nix-direnv.enable = true;

    config.whitelist = {
      exact = [ "$HOME/.envrc" ];
      prefix = [
        "$HOME/nixos-config"
        "$HOME/projects/codeberg.org/jwinn"
        "$HOME/projects/github.com/jwinn"
        "$HOME/projects/gitlab.com/jwinn"
      ];
    };
  };

  git = {
    enable = true;
    userName = "Jon Winn";
    userEmail = "me@jonwinn.com";
    ignores = [ "*.swp" ];
    signing = {
      key = "15ED1D77E7A4EA76";
      signByDefault = true;
    };
    aliases = {
      a = "add";
      ca = "commit -a";
      cam = "commit -am";
      cm = "commit -m";
      cob = "checkout -b";
      co = "checkout";
      fp = "fetch --prune --all";
      l = "log --oneline --decorate --graph";
      lall = "log --oneline --decorate --graph --all";
      ls = "log --oneline --decorate --graph --stat";
      lt = "log --graph --decorate --pretty=format:'%C(yellow)%h%Creset%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset'";
      pog = "push origin gh-pages";
      pom = "push origin master";
      puog = "pull origin gh-pages";
      puom = "pull origin master";
      s = "status";
    };
    extraConfig = {
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      github.user = "jwinn";
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  gpg.enable = true;

  neovim = {
    enable = true;
    #viAlias = true;
    #vimAlias = true;
    #withNodeJs = true;
    #withPython3 = true;
    #withRuby = true;
  };
  tmux = {
    enable = true;
  };

  zsh = {
    enable = true;
  };
}
