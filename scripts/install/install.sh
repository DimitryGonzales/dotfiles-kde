#!/usr/bin/env bash

script_dir="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"
script_name="$(basename -- "${BASH_SOURCE[0]}")"

log() {
    local tag
    if [[ -v script_name ]]; then
        tag="$script_name"
    else
        tag="SCRIPT"
    fi

    local level="${1^^}"

    if [[ "$level" == "WARNING" || "$level" == "ERROR" ]]; then
        printf "[%s] [%s] %s\n" "$tag" "$level" "$2" >&2
    else
        printf "[%s] [%s] %s\n" "$tag" "$level" "$2"
    fi
}

# Check if the multilib repository is enabled
if grep -Fxq "#[multilib]" /etc/pacman.conf; then
    log error "enable the multilib repository before executing the script"
    exit 1
fi

# Elevate privileges
sudo -v

# Update the system
log info "updating the system..."

if sudo pacman -Syu; then
    log success "updated the system"
else
    log error "failed to update the system"
    exit 1
fi

# Install paru
if ! command -v paru &> /dev/null; then
    log warning "paru is not installed"
    log info "installing paru..."

    if (
        sudo pacman -S --needed base-devel git &&
        cd /tmp &&
        git clone https://aur.archlinux.org/paru.git &&
        cd paru &&
        makepkg -si &&
        cd "$script_dir"
    ); then
        log success "installed paru"
    else
        log error "failed to install paru"
        exit 1
    fi
fi

# Install packages
packages_path="$script_dir/packages.sh"

if [[ -f "$packages_path" ]]; then
    source "$packages_path"

    log info "installing packages..."

    if paru -S --needed "${packages[@]}"; then
        log success "installed packages"
    else
        log error "failed to install packages"
        exit 1
    fi
else
    log error "missing package list: $packages_path"
    exit 1
fi

# Add user to groups
groups_path="$script_dir/groups.sh"

if [[ -f "$groups_path" ]]; then
    source "$groups_path"

    for group in "${groups[@]}"; do
        if groups "$USER" | grep -Fwq "$group"; then
            log info "$USER is already in the $group group"
        else
            if ! getent group "$group" &> /dev/null; then
                log warning "the $group group doesn't exist"
                log info "creating the $group group..."

                if sudo groupadd "$group" > /dev/null; then
                    log success "created the $group group"
                else
                    log error "failed to create the $group group"
                    exit 1
                fi
            fi

            log info "adding $USER to the $group group..."

            if sudo gpasswd -a "$USER" "$group" > /dev/null; then
                log success "added $USER to the $group group"
            else
                log error "failed to add $USER to the $group group"
                exit 1
            fi
        fi
    done
else
    log error "missing group list: $groups_path"
    exit 1
fi

# Enable services
services_path="$script_dir/services.sh"

if [[ -f "$services_path" ]]; then
    source "$services_path"

    for service in "${services[@]}"; do
        if systemctl is-enabled "$service" &> /dev/null; then
            log info "$service is already enabled"
        else
            if sudo systemctl enable "$service" > /dev/null; then
                log success "enabled $service"
            else
                log error "failed to enable $service"
                exit 1
            fi
        fi
    done
else
    log error "missing service list: $services_path"
    exit 1
fi

exit 0

# KFileDialog Settings
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "Places Icons Auto-resize" false
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "Places Icons Static Size" 22

kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "detailViewIconSize" 32
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "iconViewIconSize" 64
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "listViewIconSize" 32
