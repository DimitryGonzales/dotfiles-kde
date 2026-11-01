#!/usr/bin/env bash

# Shell options
shopt -s dotglob nullglob

# Variables
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RESET='\033[0m'

script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
assets_dir="$script_dir/assets"
modules_dir="$script_dir/modules"

packages_path="$script_dir/packages.sh"

# Functions
log() {
    local tag
    tag="$(basename "${BASH_SOURCE[1]}")"

    local type="${1^^}"

    local color

    case "$type" in
    "INFO") color="$BLUE" ;;
    "ACTION") color="$CYAN" ;;
    "SUCCESS") color="$GREEN" ;;
    "ERROR") color="$RED" ;;
    *)
        log error "invalid log type: $type"
        exit 1
        ;;
    esac

    local command=(printf "%b %b %s\n" "${MAGENTA}[$tag]${RESET}" "${color}[$type]${RESET}" "$2")

    if [[ "$type" == "ERROR" ]]; then
        "${command[@]}" >&2
    else
        "${command[@]}"
    fi
}

# Check if the multilib repository is enabled
if grep -Fxq "#[multilib]" /etc/pacman.conf; then
    log error "enable the multilib repository before executing the script"
    exit 1
fi

# Elevate privileges
sudo -v || exit 1

# Update the system
log action "updating the system"

if ! sudo pacman -Syu; then
    log error "failed to update the system"
    exit 1
fi

log success "updated the system"

# Install paru
if command -v paru &>/dev/null; then
    log info "paru is already installed"
else
    log action "installing paru"

    if ! (
        sudo pacman -S --needed base-devel git &&
            cd /tmp &&
            git clone https://aur.archlinux.org/paru.git &&
            cd paru &&
            makepkg -si
    ); then
        log error "failed to install paru"
        exit 1
    fi

    log success "installed paru"
fi

# Install the packages
if [[ ! -f "$packages_path" ]]; then
    log error "the package list file is missing: $packages_path"
    exit 1
fi

log action "sourcing the package list"

if ! source "$packages_path"; then
    log error "failed to source the package list"
    exit 1
fi

log success "sourced the package list"

if [[ "${#packages[@]}" -eq 0 ]]; then
    log info "the package list is empty"
else
    log action "installing the packages"

    if ! paru -S --needed "${packages[@]}"; then
        log error "failed to install the packages"
        exit 1
    fi

    log success "installed the packages"
fi

# Execute the modules
if [[ ! -d "$modules_dir" ]]; then
    log error "the modules directory doesn't exist: $modules_dir"
    exit 1
fi

modules=("$modules_dir"/*.sh)

if [[ "${#modules[@]}" -eq 0 ]]; then
    log info "no modules to execute"
else
    for module in "${modules[@]}"; do
        module_name="$(basename "$module")"

        log action "executing the module: $module_name"

        if ! source "$module"; then
            log error "failed to execute the module"
            exit 1
        fi

        log success "executed the module"
    done
fi

# Reboot
log success "the script has finished executing"

read -rp "A reboot is necessary to apply all changes. Reboot now? [Y/n] " reboot

if [[ "${reboot,,}" == "y" || -z "$reboot" ]]; then
    printf "Rebooting in "

    for i in $(seq 10 -1 1); do
        printf "%d..." "$i"
        sleep 1
    done

    reboot
fi
