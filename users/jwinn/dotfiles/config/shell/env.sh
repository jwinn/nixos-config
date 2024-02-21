# shellcheck shell=sh
# Largely based on: https://heptapod.host/flowblok/dotfiles

# https://www.freedesktop.org XDG ENV variable declarations
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# Note: macOS suggested locations differ from below, but go for consistency
export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-"/etc/xdg:/home/jwinn/.nix-profile/etc/xdg:/nix/profile/etc/xdg:/home/jwinn/.local/state/nix/profile/etc/xdg:/etc/profiles/per-user/jwinn/etc/xdg:/nix/var/nix/profiles/default/etc/xdg:/run/current-system/sw/etc/xdg"}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"/home/jwinn/.config"}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-"/nix/store/gmjng1jngvn6dvkxcdvhjjavjazvlp3w-desktops/share:/home/jwinn/.nix-profile/share:/nix/profile/share:/home/jwinn/.local/state/nix/profile/share:/etc/profiles/per-user/jwinn/share:/nix/var/nix/profiles/default/share:/run/current-system/sw/share"}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-"/home/jwinn/.local/share"}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-"/home/jwinn/.cache"}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-"/run/user/1000"}"

# "normalize" for sehll env expectations for the given system
export HOSTNAME="${HOSTNAME:-"vmware-aarch64"}"
export USER="${USER:-"jwinn"}"
export NAME="${NAME:-"Jon Winn"}"
export SHELL_NAME="${SHELL_NAME:-"${SHELL##*/}"}"
export OSTYPE="${OSTYPE:-"nixos-tapir"}"
export OS_ARCH="${OS_ARCH:-"arm64"}"
export OS_NAME="${OS_NAME:-"nixos"}"
export OS_PRODUCT_NAME="${OS_PRODUCT_NAME:-"nixos-tapir"}"
export OS_VERSION="${OS_VERSION:-"23.11"}"

export OS_IS_LINUX=1

# TBD: https://github.com/asdf-vm/asdf/issues/687
# set asdf config and tool version files path
export ASDF_CONFIG_FILE="${ASDF_CONFIG_FILE:-"${XDG_CONFIG_HOME}/asdf/asdfrc"}"
export ASDF_DATA_DIR="${XDG_DATA_HOME:-"${XDG_DATA_HOME}/asdf"}"

# We need to set $ENV so that if you use shell X as your login shell,
# and then start "sh" as a non-login interactive shell the startup scripts
# will correctly run.
export ENV="/home/jwinn/.config/sh/interactive.sh"

# We also need to set BASH_ENV, which is run for *non-interactive* shells.
# (unlike $ENV, which is for interactive shells)
export BASH_ENV="/home/jwinn/.config/bash/env.bash"

# shellcheck source-path=SCRIPTDIR
. "${XDG_CONFIG_HOME}/shell/functions.sh"

# set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/bin" ] ; then
  path_prepend "${HOME}/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/.local/bin" ] ; then
  path_prepend "${HOME}/.local/bin:${PATH}"
fi

umask 0022

safe_source "${XDG_CONFIG_HOME}/shell/env.local"
