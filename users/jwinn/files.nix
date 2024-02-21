{ user, userHome, ... }:

{
  ".bash_logout".source = ./dotfiles/config/bash/logout.bash;
  ".bash_profile".source = ./dotfiles/bash_profile;
  ".bashrc".source = ./dotfiles/bashrc;
  ".editorconfig".source = ./dotfiles/editorconfig;
  ".profile".source = ./dotfiles/profile;
  ".shellcheckrc".source = ./dotfiles/shellcheckrc;

  ".config" = {
    source = ./dotfiles/config;
    recursive = true;
  };

  ".Xresources.d" = {
    source = ./dotfiles/Xresources.d;
    recursive = true;
  };

  ".xinitrc".source = ./dotfiles/xinitrc;

  ".zlogout".source = ./dotfiles/config/zsh/logout.zsh;
  ".zprofile".source = ./dotfiles/config/zsh/login.zsh;
  ".zshenv".source = ./dotfiles/config/zsh/env.zsh;
  ".zshrc".source = ./dotfiles/config/zsh/interactive.zsh;
}
