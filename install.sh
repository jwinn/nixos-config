#!/bin/sh

set -eu

# POSIX way to get script's dir:
#   https://stackoverflow.com/a/29834779/12156188
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
SCRIPT_NAME="$(basename -- "${0}")"

######################################################################
# Colors
######################################################################

NO_COLOR="$(tput sgr0 2>/dev/null || printf '\033[m')"
BOLD="$(tput bold 2>/dev/null || printf '\033[1m')"

RED="$(tput setaf 1 2>/dev/null || printf '\033[38;5;1m')"
GREEN="$(tput setaf 2 2>/dev/null || printf '\033[38;5;2m')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '\033[38;5;3m')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '\033[38;5;5m')"
CYAN="$(tput setaf 6 2>/dev/null || printf '\033[38;5;6m')"

######################################################################
# Print
######################################################################

# Usage: print_info <message>
# Description: outputs a colorized, where applicable, info message
print_info() {
  printf "%s\n" "${CYAN}[*]${NO_COLOR} $*"
}

# Usage: print_warn <message>
# Description: outputs a colorized, where applicable, warning message
print_warn() {
  printf "%s\n" "${YELLOW}[!] $*${NO_COLOR}"
}

# Usage: print_error <message>
# Description: outputs a colorized, where applicable, error message
print_error() {
  printf "%s\n" "${RED}[x] $*${NO_COLOR}" >&2
}

# Usage: print_critical
# Description: outputs a colorized, where applicable, pre-defined critical message
print_critical() {
  print_error "Something unexpected has happened, please contact the maintainer"
}

# Usage: print_success <message>
# Description: outputs a colorized, where applicable, success message
print_success() {
  printf "%s\n" "${GREEN}[✓]${NO_COLOR} $*"
}

# Usage: print_prompt <question> [<default choice>]
# Description: prompts for input to y or n, defaults to n, unless passed
# Return: 0 if y or 1 if n
# Note: use of `local` is not, technically, POSIX compliant
print_prompt() {
  if [ ${FORCE:-0} -eq 1 ]; then
    return 0
  fi

  local _msg="${1}"
  local _default=${2-}
  local _yes="y"
  local _no="N"
  local _rc=0
  local _answer=

  if [ "${_default}" != "${_default#[Yy]}" ]; then
    _yes="Y"
    _no="n"
  fi

  printf "%s %s? [%s/%s] " \
    "${MAGENTA}[?]${NO_COLOR}" \
    "${_msg}" \
    "${BOLD}${_yes}${NO_COLOR}" \
    "${BOLD}${_no}${NO_COLOR}"

  read -r _answer </dev/tty
  _rc=$?

  if [ $_rc -ne 0 ]; then
    print_error "Unable to read from prompt"
    return 1
  fi

  if [ -z "${_answer-}" ] \
    && [ "${_yes}" = "Y" ] \
    || [ "${_answer}" != "${_answer#[Yy]}" ]; then

    return 0
  else
    return 1
  fi
}

######################################################################
# Utility
######################################################################

# Usage: has_command <command>
# Description: checks if the command is in the current PATH
# Return: 0, if command found in PATH
#         1, if not found in PATH
has_command() {
  command -v "${1}" 1>/dev/null 2>&1
}

# Usage: scmd <command>
# Description: uses `sudo` to run cmd with elevated privileges
# TODO: very rudimentary/naive, needs improvement
scmd() {
  if [ ${EUID:-$(id -u)} -eq 0 ]; then
    ${@}
  fi

  if ! has_command sudo; then
    print_error "Non-root user and sudo not found in: ${PATH}"
    return 1
  fi

  if sudo ${@}; then
    return 0
  else
    return $?
  fi
}

# Usage: str_contains <haystack> <needle>
# Description: determins if the needle is in the haystack string
str_contains() {
  if [ "${1#*$2}" != "${1}" ]; then
    return 0
  else
    return 1
  fi
}

# Usage: str_lcase <string>
# Description: lower cases the string
str_lcase() {
  echo "${1}" | tr '[:upper:]' '[:lower:]'
}

######################################################################
# Environment
######################################################################

# Usage: get_disk
# Description: tries to determine the block device disk to use
# Outputs: the lcase disk
get_disk() {
  if ! has_command lsblk; then
    print_error "<lsblk> not found in: ${PATH}"
    return 1
  fi

  # TODO: prompt if more than 1?
  disks=$(lsblk --json | jq -r '[.blockdevices[] | select(.type | ascii_downcase == \"disk\").name] | unique | join(\" \")')

  # Ask for disk as input from choices
  # Set disk to first in list, if any
  disk=${disks}
  # Allow user to choose, if more than one
  if [ "${disk}" != "${disks}" ]; then
    printf "%s\n\n" "Please choose from the avilable disks:"
    printf "\t%s\n" ${disks}

    dsk=
    while true; do
      printf "\ndisk [%s]: " "${disk}" >&2
      read -r dsk

      # Use default, if nothing entered
      if [ -z "${dsk}" ]; then
        dsk="${disk}"
      fi

      if [ -b /dev/${dsk} ]; then
        break
      fi

      print_error "/dev/${dsk} is not a block device, try again..."
    done

    disk="${dsk}"

    unset -v dsk
  fi

  DISK="$(str_lcase "${disk}")"

  unset -v disks
  unset -v disk
  return 0
}

# Usage: get_os_arch
# Description: gets and lcase the os architecture; normalizes
# Outputs: the lcase os architecture
get_os_arch() {
  _arch="$(str_lcase "${ARCH:-"$(uname -m)"}")"

  case "${_arch}" in
    amd64*) _arch="x86_64" ;;
    armv*) _arch="arm" ;;
    arm64*) _arch="aarch64" ;;
  esac

  # `uname` may misreport 32-bit as 64-bit OS
  if [ "${_arch}" = "x86_64" ] && [ $(getconf LONG_BIT) -eq 32 ]; then
    _arch="i686"
  elif [ "${_arch}" = "aarch64" ] && [ $(getconf LONG_BIT) -eq 32 ]; then
    _arch="arm"
  fi

  printf "%s" "${_arch}"

  unset -v _arch
}

# Usage: get_os_name
# Description: gets and lcase the os name; normalizes cygwin, msys, mingw
# Outputs: the lcase os name
get_os_name() {
  _os_name="$(str_lcase "$(uname -s)")"

  case "${_os_name}" in
    msys_nt*) _os_name="windows" ;;
    cygwin_nt*) _os_name="windows" ;;
    mingw*) _os_name="windows" ;;
  esac

  printf "%s" "${_os_name}"

  unset -v _os_name
}

# Usage: get_machine
# Description: tries to determine the machine
# Outputs: the lcase machine
get_machine() {
  os_name="$(get_os_name)"
  machine=""
  case "${os_name}" in
    darwin*) machine="darwin" ;;
    linux*)
      model=
      search="firmware/devicetree/base/model"
      search="${search} devices/virtual/dmi/id/board_name"
      search="${search} devices/virtual/dmi/id/sys_vendor"
      search="${search} devices/virtual/dmi/id/product_name"

      for f in ${search}; do
        if [ -f "/sys/${f}" ]; then
          model="$(tr -d '\0' < /sys/${f})"

          case "${model}" in
            Microsoft*) machine="hyperv" ;;
            Parallels*) machine="parallels" ;;
            QEMU*) machine="qemu" ;;
            Raspberry*) machine="raspberrypi" ;;
            VMware*) machine="vmware" ;;
            *) continue ;;
          esac

          if [ -n "${machine}" ]; then
            break
          fi
        fi
      done

      unset -v model
      unset -v search
      ;;
    *) ;;
  esac

  printf "%s" "${machine}"

  unset -v machine
  unset -v os_name

  return 0
}

#
# Options
#
DISK=""
GIT_REPO="${GIT_REPO:-"https://github.com/jwinn/nixos-config.git"}"
NAME="${NAME:-"$(get_machine)-$(get_os_arch)"}"

# Usage: usage
# Description: prints this porgam's usage and options
usage() {
  cat << EOF
Usage: bootstrap [options] <command=[install]>

Manages initial NixOS basic operations

Options:

  -d, --disk     Override the disk to partition and format [${DISK}]
  -h, --help     Display this help message
  -n, --name     Host name to configure/install for/to [${NAME}]
  -r, --repo     Git repo to pull configuration file(s) from [${GIT_REPO}]

EOF
}

# Usage: verify
# Description: checks if requisite commands exist on the machine
# Return: 0, if all requisite commands exist
#         1, if a required command does not exist
verify() {
  if [ "$(id -u)" -ne 0 ] && ! has_command sudo; then
    print_error "Non-root user and <sudo> not found in: ${PATH}"
    return 1
  fi

  if ! has_command nix; then
    print_critical "<nix> not found in: ${PATH}"
    return 1
  fi

  if ! has_command nix-env; then
    print_critical "<nix> not found in: ${PATH}"
    return 1
  fi

  return 0
}

# Usage: verify_disk <disk>
# Description: checks if the specified disk exists
# Return: 0, if the disk exists
#         1, if the disk does not exist
verify_disk() {
  if [ ! -b "/dev/${1}" ]; then
    print_error "Cannot find the disk: ${1}"
    return 1
  fi

  return 0
}

# Usage: ensure_pkgs
# Description: uses `nix-env` to install required packages
ensure_pkgs() {
  pkgs="git jq"
  for pkg in ${pkgs}; do
    if ! has_command ${pkg}; then
      print_info "${pkg} not found, installing..."
      scmd nix-env --install --prebuilt-only --attr nixos.${pkg} || return $?
    fi
  done

  unset -v pkg
  unset -v pkgs

  return 0
}

# Usage: partition_and_mount <disk>
# TODO: change naive error checking
partition_and_mount() {
  disk="${1}"

  print_info "If mounted, unmounting: ${disk}"
  if scmd umount -R /mnt/boot 2>/dev/null || true \
    && scmd umount -R /mnt 2>/dev/null || true \
    && scmd umount /dev/${disk}* 2>/dev/null || true \
  ; then
    print_success "Successfully unmounted disk: ${disk}"
  else
    return $?
  fi

  sleep 1

  print_info "Partitioning disk: ${disk}"
  if scmd parted /dev/${disk} -- mklabel gpt \
    && scmd parted /dev/${disk} -- mkpart primary btrfs 512MB \
    && scmd parted /dev/${disk} -- mkpart ESP fat32 1MB 512MB \
    && scmd parted /dev/${disk} -- set 3 esp on \
  ; then
    print_success "Successfully partitioned disk: ${disk}"
  else
    return $?
  fi

  sleep 1

  print_info "Formatting partitions for: ${disk}"
  disk_json=$(lsblk -o +partlabel,parttypename --json | jq -c --arg disk "${disk}" '.blockdevices[] | select(.name | ascii_downcase == $disk)')
  nixos=$(echo "${disk_json}" | jq -r '.children[] | select(.parttypename == "Linux filesystem") | .name')
  boot=$(echo "${disk_json}" | jq -r '.children[] | select(.partlabel == "ESP") | .name')

  unset -v disk_json

  if scmd mkfs.btrfs -f -L nixos /dev/${nixos} \
    && scmd mkfs.fat -F 32 -n boot /dev/${boot} \
  ; then

    print_success "Successfully formatted disk: ${disk}"
  else
    return $?
  fi

  unset -v nixos
  unset -v swap
  unset -v boot

  sleep 1

  print_info "Mounting disks for: ${disk}"
  if scmd mount /dev/disk/by-label/nixos /mnt \
    && scmd mkdir -p /mnt/boot \
    && scmd mount /dev/disk/by-label/boot /mnt/boot \
  ; then

    print_success "Successfully mounted disk: ${disk}"
  else
    return $?
  fi

  print_info "${disk} mounted to: '/mnt' and '/mnt/boot'"

  unset -v disk

  return 0
}

install() {
  name="${1:?}"
  disk="${2}"

  # Only run if on NixOS
  if ! has_command nixos-install; then
    print_error "Cannot install on non-NixOS"
    return 1
  fi

  # TODO: naive approach to grepping config for installer import
  # may be different on NixOS VirtualBox, EC2, etc
  # TBD: should the bootstrap just allow install, regardless of NixOS state?
  if [ -z "cat /etc/nixos/configuration.nix | grep 'installer/cd-dvd'" ]; then
    print_error "Should only be run on a live ISO of NixOS"
    return 1
  fi

  if [ -z "${disk}" ]; then
    if get_disk; then
      disk="${DISK}"
    else
      return $?
    fi
  fi

  verify_disk "${disk}" || return $?

  # TODO: determine if already partitioned, instead of prompting
  if print_prompt "Parition and mount the disk \"${disk}\"" "y" \
    && ! partition_and_mount "${disk}";
  then
    print_error "Unable to partition and mount the disk"
    return 1
  fi

  unset -v disk

  # Change the default configuration file location
  NIXOS_CONFIG_DIR="/mnt/etc/nixos/config"

  if print_prompt "Use custom configuration: ${NIXOS_CONFIG_DIR}" "y"; then
    if [ -d "${NIXOS_CONFIG_DIR}" ] \
      && print_prompt "Update from ${GIT_REPO}" "n";
    then
      print_info "Updating repo for: ${NIXOS_CONFIG_DIR}"
      cd ${NIXOS_CONFIG_DIR} && scmd git pull && cd -
    else
      print_info "Cloning ${GIT_REPO} into: ${NIXOS_CONFIG_DIR}"
      scmd git clone ${GIT_REPO} ${NIXOS_CONFIG_DIR}
    fi
  fi

  # Note: if a new hardware type (not in the git project),
  # then add the hardware.nix file as a new machine type
  if [ ! -f "/mnt/etc/nixos/configuration.nix" ]; then
    print_info "Generating basic configuration in '/mnt/etc/nixos'"
    scmd nixos-generate-config --root /mnt
  fi

  export NIXOS_CONFIG="${NIXOS_CONFIG_DIR}/hosts/${name}/default.nix"

  if [ ! -f "${NIXOS_CONFIG}" ]; then
    print_error "Unable to find config file: ${NIXOS_CONFIG}"
    return 1
  fi

  if print_prompt "Would you like to install \"${name}\"" "y"; then
    print_info "Installing NixOS using the host name: ${name}"
    if scmd nixos-install --no-root-passwd -I "nixos-config=${NIXOS_CONFIG}"; then
      print_success "Successfully installed NixOS using: ${NIXOS_CONFIG}"
    else
      return $?
    fi
  fi

  # If the passwd file for the installed system exists
  pwd_file="/mnt/etc/passwd"

  if [ -r "${pwd_file}" ]; then
    # Get a list of login users, excluding root
    users="$(grep -v '^.*nologin$' ${pwd_file} | cut -d ':' -f 1 | grep -v root)"

    # Set the users to the current args, i.e. a quasi-array
    set -- ${users}

    user_name=
    user_id=
    user_gid=

    print_info "Choose from the following users to own ${NIXOS_CONFIG_DIR}"

    while true; do
      printf "%s\n" ${users}
      read -r -p "Choice (${1}): " user_name
      # Trim one space, if any, from beginning and end
      user_name="${user_name## }"
      user_name="${user_name%% }"

      # Use the first one, if not found
      if [ -z "${user_name}" ]; then
        print_warn "Using default ${1}"
        user_name="${1}"
      fi

      user_id=$(awk -F':' -v u="${user_name}" '$1 ~ u { print $3 }' ${pwd_file})
      user_gid=$(awk -F':' -v u="${user_name}" '$1 ~ u { print $4 }' ${pwd_file})

      if [ -n "${user_id}" ] && [ -n "${user_gid}" ]; then
        break
      fi

      print_warn "User name ${user_name} not found in ${pwd_file}"
    done

    if [ "${user_id}" -gt 0 ]; then
      print_info "Changing ownership for \"${NIXOS_CONFIG_DIR}\" to ${user_id}:${user_gid}"
      scmd chown -R ${user_id}:${user_gid} "${NIXOS_CONFIG_DIR}"
    fi

    unset -v user_id
    unset -v user_gid

    if [ -n "${users}" ] \
      && print_prompt "Do you want to retrieve chezmoi dotfiles for users" "y";
    then
      user=

      for user in ${users}; do
        # TODO: should be more efficient to parse the user with awk once
        #       and set as positional args, i.e. `set -- $user`
        user_id=$(awk -F':' -v u="${user}" '$1 ~ u { print $3 }' ${pwd_file})
        user_home=$(awk -F':' -v u="${user}" '$1 ~ u { print $6 }' ${pwd_file})
        user_gid=$(awk -F':' -v u="${user}" '$1 ~ u { print $4 }' ${pwd_file})

        # Will retrieve, from GitHub, the user's chezmoi managed dotfiles
        if [ "${user_id}" -gt 0 ] \
          && print_prompt "Retrieve chezmoi managed dotfiles for the user: ${user}" "y";
        then
          user_df_dir="${user_home}/dotfiles"
          user_init_file="${user_home}/init-chezmoi.sh"
          login_files="bash_login login profile zprofile"

          print_info "Retrieving dotfiles for ${user} to: ${user_df_dir}"
          scmd git clone https://github.com/${user}/dotfiles.git \
            "/mnt${user_df_dir}" || return $?
  
          if print_prompt "Run dotfiles/install.sh at first login" "y"; then
            f=

            print_info "Updating login scripts..."
            for f in ${login_files}; do
              scmd tee -a "/mnt${user_home}/.${f}" > /dev/null <<EOF
sh "${user_init_file}" && exec ${SHELL}
EOF
            done

        	  unset -v f

            print_info "Writing init file: ${user_init_file}"
            scmd tee "/mnt${user_init_file}" >/dev/null <<EOF
#!/bin/sh

# Remove reference from login files:
for f in ${login_files}; do
  if [ -w "\${HOME}/.\${f}" ]; then
    awk '!/\$0/' "\${HOME}/.\${f}" > "/tmp/\${f}"
    mv "/tmp/\${f}" "\${HOME}/.\${f}"
    [ -s "\${HOME}/.\${f}" ] && rm -f "\${HOME}/.\${f}"
  fi
done

# Run the chezmoi install file
if [ -f "${user_df_dir}/install.sh" ]; then
  cd "${user_df_dir}" > /dev/null && sh install.sh && cd - > /dev/null
fi

# Remove this script
rm -f \$0
EOF
          else
            print_info "Remember to run <install.sh> in \${HOME}/dotfiles"
          fi

          # Update user home dir ownership
          print_info "Changing ${user_home} ownership to ${user_id}:${user_gid}"
          scmd chown -R ${user_id}:${user_gid} "/mnt${user_home}"
    
          unset -v user_home
          unset -v user_id
          unset -v user_gid
          unset -v user_df_dir
          unset -v user_init_file
          unset -v login_files
        fi
      done

      unset -v user
    fi

    unset -v user
    unset -v users
    unset -v user_name
  fi

  unset -v pwd_file

  #scmd umount -R /mnt || true

  if print_prompt "Do you want to reboot" "y"; then
    scmd reboot
  else
    print_info "Feel free to make any changes in '/mnt' before <reboot>"
  fi

  unset -v source

  return $?
}

main() {
  verify || exit $?
  ensure_pkgs || exit $?

  install "${NAME}" "${DISK}" || exit $?
}

# Parse argv
while [ $# -gt 0 ]; do
  case "${1}" in
    -d | --disk)
      DISK="${2}"
      shift 2
      ;;
    -d=* | --disk=*)
      DISK="${1#*=}"
      shift 1
      ;;

    -n | --name)
      NAME="${2}"
      shift 2
      ;;
    -n=* | --name=*)
      NAME="${1#*=}"
      shift 1
      ;;

    -r | --repo)
      GIT_REPO="${2}"
      shift 2
      ;;
    -r=* | --repo=*)
      GIT_REPO="${1#*=}"
      shift 1
      ;;

    -h | --help)
      usage
      exit
      ;;

    --)
      break
      ;;

    *)
      print_error "Unknown option provided: ${1}" ""
      usage
      exit 1
      ;;
  esac
done

# Call main
main
