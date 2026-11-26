#!/usr/bin/env bash

# Shell options
shopt -s dotglob nullglob

# Variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
assets_dir="$script_dir/assets"

paru_package="paru-bin"

packages_path="$script_dir/packages.sh"

modules_dir="$script_dir/modules"
modules=("$modules_dir"/*.sh)

# Functions
section() {
    local message="$1"

    # Print a line break if it is not the first section
    if [[ -v _first_section_printed ]]; then
        printf "\n"
    else
        _first_section_printed=true
    fi

    # Print the message
    printf "%b[%s]%b\n" "$YELLOW" "$message" "$RESET"
}

log() {
    local type="${1^^}"
    local message="$2"

    # Determine the calling file
    local file="${BASH_SOURCE[0]}"
    local source_file

    for source_file in "${BASH_SOURCE[@]}"; do
        if [[ "$source_file" != "$file" ]]; then
            file="$source_file"
            break
        fi
    done

    file="$(basename "$file")"

    # Determine the type color
    local type_color

    case "$type" in
    "INFO") type_color="$BLUE" ;;
    "ACTION") type_color="$CYAN" ;;
    "SUCCESS") type_color="$GREEN" ;;
    "ERROR") type_color="$RED" ;;
    *)
        log error "invalid log type: $type"
        exit 1
        ;;
    esac

    # Print the log
    local command=(
        printf "%b[%s]%b %b[%s]%b %s\n"
        "$MAGENTA" "$file" "$RESET"
        "$type_color" "$type" "$RESET"
        "$message"
    )

    if [[ "$type" == "ERROR" ]]; then
        "${command[@]}" >&2
    else
        "${command[@]}"
    fi
}

copy_file() {
    local source="$1"
    local destination="$2"

    local destination_directory
    destination_directory="$(dirname "$destination")"

    # Check if the source file exists
    if [[ ! -f "$source" ]]; then
        log error "the source file is missing: $source"
        return 1
    fi

    # Use elevated privileges for destinations outside the home directory
    local prefix=()

    [[ "$destination" != "$HOME/"* ]] && prefix=(sudo)

    # Check whether the destination already exists and if is identical to the source
    if [[ -f "$destination" ]] && cmp -s "$source" "$destination"; then
        log info "the destination already exists and is identical to the source: $source = $destination"
        return 0
    fi

    # Create the destination directory if it does not exist
    if [[ ! -d "$destination_directory" ]]; then
        log action "creating the destination directory: $destination_directory"

        if ! "${prefix[@]}" mkdir -p "$destination_directory"; then
            log error "failed to create the destination directory"
            return 1
        fi

        log success "created the destination directory"
    fi

    # Copy the source to the destination
    log action "copying the source to the destination: $source -> $destination"

    if ! "${prefix[@]}" cp -T "$source" "$destination"; then
        log error "failed to copy the source to the destination"
        return 1
    fi

    log success "copied the source to the destination"

    return 0
}

# Check if the multilib repository is enabled
if grep -Fxq "#[multilib]" /etc/pacman.conf; then
    log error "enable the multilib repository before executing the script"
    exit 1
fi

# Elevate privileges
sudo -v || exit 1

# Update the system
section "update"

log action "updating the system"

if ! sudo pacman -Syu; then
    log error "failed to update the system"
    exit 1
fi

log success "updated the system"

# Install paru
section "paru"

if command -v paru &>/dev/null; then
    log info "paru is already installed"
else
    log action "installing paru"

    if ! (
        sudo pacman -S --needed base-devel git &&
            cd /tmp &&
            git clone "https://aur.archlinux.org/$paru_package.git" &&
            cd "$paru_package" &&
            makepkg -si
    ); then
        log error "failed to install paru"
        exit 1
    fi

    log success "installed paru"
fi

# Install the packages
section "packages"

if [[ ! -f "$packages_path" ]]; then
    log error "the package list file is missing: $packages_path"
    exit 1
fi

log action "sourcing the package list: $packages_path"

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
section "modules"

if [[ ! -d "$modules_dir" ]]; then
    log error "the modules directory doesn't exist: $modules_dir"
    exit 1
fi

if [[ "${#modules[@]}" -eq 0 ]]; then
    log info "no modules to execute"
else
    for module in "${modules[@]}"; do
        module_file="$(basename "$module")"
        module_name="${module_file%.sh}"

        section "modules > $module_name"

        log action "executing the module: $module_file"

        if ! source "$module"; then
            log error "failed to execute the module"
            exit 1
        fi

        log success "executed the module"
    done
fi

# Finish/Reboot
section "finish/reboot"

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
