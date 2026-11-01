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
groups_path="$script_dir/groups.sh"

shell="zsh"

# Functions
log() {
    local tag
    tag="$(basename "${BASH_SOURCE[1]}")"

    local type="${1^^}"
    local color

    case "$type" in
    "INFO") color="$BLUE" ;;
    "ACTION") color="$CYAN" ;;
    "CANCEL") color="$YELLOW" ;;
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
log action "installing paru"

if command -v paru &>/dev/null; then
    log cancel "paru is already installed"
else
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

# Install packages
if [[ ! -f "$packages_path" ]]; then
    log error "the packages list file is missing: $packages_path"
    exit 1
fi

log action "sourcing packages list"

if ! source "$packages_path"; then
    log error "failed to source packages list"
    exit 1
fi

log success "sourced packages list"

if [[ "${#packages[@]}" -eq 0 ]]; then
    log info "the packages list is empty"
else
    log action "installing packages"

    if ! paru -S --needed "${packages[@]}"; then
        log error "failed to install packages"
        exit 1
    fi

    log success "installed packages"
fi

# Add user to groups
if [[ ! -f "$groups_path" ]]; then
    log error "the groups file is missing: $groups_path"
    exit 1
fi

log action "sourcing groups list"

if ! source "$groups_path"; then
    log error "failed to source groups list"
    exit 1
fi

log success "sourced groups list"

if [[ "${#groups[@]}" -eq 0 ]]; then
    log info "the groups list is empty"
else
    for group in "${groups[@]}"; do
        log action "adding user to group: $group"

        if groups "$USER" | grep -Fwq "$group"; then
            log cancel "user is already in group"
            continue
        fi

        if ! getent group "$group" &>/dev/null; then
            log info "group doesn't exist"

            log action "creating group"

            if ! sudo groupadd "$group"; then
                log error "failed to create group"
                exit 1
            fi

            log success "created group"
        fi

        if ! sudo gpasswd -a "$USER" "$group" >/dev/null; then
            log error "failed to add user to group"
            exit 1
        fi

        log success "added user to group"
    done
fi

# Set default shell
if ! shell_path="$(command -v "$shell")"; then
    log error "failed to define shell path"
    exit 1
fi

log action "setting shell as the default: $shell"

if [[ "$SHELL" == "$shell_path" ]]; then
    log cancel "shell is already the default"
else
    if ! chsh -s "$shell_path" >/dev/null; then
        log error "failed to set shell as the default"
        exit 1
    fi

    log success "set shell as the default"
fi

# Execute modules
if [[ ! -d "$modules_dir" ]]; then
    log info "the modules directory doesn't exist: $modules_dir"
    exit 1
fi

modules=("$modules_dir"/*.sh)

if [[ "${#modules[@]}" -eq 0 ]]; then
    log info "no modules to execute"
else
    for module in "${modules[@]}"; do
        module_name="$(basename "$module")"

        log action "executing module: $module_name"

        if ! source "$module"; then
            log error "failed to execute module"
            exit 1
        fi

        log success "executed module"
    done
fi

# Reboot
log success "script execution finished"

read -rp "A reboot is necessary to apply all changes. Reboot now? [Y/n] " reboot

if [[ "${reboot,,}" == "y" || -z "$reboot" ]]; then
    printf "Reboot in "

    for i in $(seq 10 -1 1); do
        printf "%d..." "$i"
        sleep 1
    done

    reboot
fi
