#!/usr/bin/env bash

# Shell options
shopt -s dotglob nullglob

# Variables
script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
script_name="$(basename "${BASH_SOURCE[0]}")"

assets_dir="$script_dir/assets"
modules_dir="$script_dir/modules"

packages_path="$script_dir/packages.sh"
groups_path="$script_dir/groups.sh"
services_path="$script_dir/services.sh"

shell="zsh"

# Functions
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
sudo -v || exit 1

# Update the system
log info "updating the system..."

if sudo pacman -Syu; then
    log success "updated the system"
else
    log error "failed to update the system"
    exit 1
fi

# Install paru
if command -v paru &> /dev/null; then
    log info "paru is already installed"
else
    log info "installing paru..."

    if (
        sudo pacman -S --needed base-devel git &&
        cd /tmp &&
        git clone https://aur.archlinux.org/paru.git &&
        cd paru &&
        makepkg -si
    ); then
        log success "installed paru"
    else
        log error "failed to install paru"
        exit 1
    fi
fi

# Install packages
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
    log error "missing packages file: $packages_path"
    exit 1
fi

# Add user to groups
if [[ -f "$groups_path" ]]; then
    source "$groups_path"

    log info "adding $USER to groups..."

    for group in "${groups[@]}"; do
        if groups "$USER" | grep -Fwq "$group"; then
            log info "$USER is already in the $group group"
        else
            log info "adding $USER to the $group group..."

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

            if sudo gpasswd -a "$USER" "$group" > /dev/null; then
                log success "added $USER to the $group group"
            else
                log error "failed to add $USER to the $group group"
                exit 1
            fi
        fi
    done
else
    log error "missing groups file: $groups_path"
    exit 1
fi

# Enable services
if [[ -f "$services_path" ]]; then
    source "$services_path"

    log info "enabling services..."

    for service in "${services[@]}"; do
        if systemctl is-enabled "$service" &> /dev/null; then
            log info "the $service service is already enabled"
        else
            log info "enabling the $service service..."

            if sudo systemctl enable "$service" > /dev/null; then
                log success "enabled the $service service"
            else
                log error "failed to enable the $service service"
                exit 1
            fi
        fi
    done
else
    log error "missing services file: $services_path"
    exit 1
fi

# Set default shell
shell_path="$(command -v "$shell")"

if [[ "$SHELL" == "$shell_path" ]]; then
    log info "$shell is already the default shell"
else
    log info "setting $shell as the default shell..."

    if chsh -s "$shell_path" > /dev/null; then
        log success "set $shell as the default shell"
    else
        log error "failed to set $shell as the default shell"
        exit 1
    fi
fi

# Execute modules
if [[ -d "$modules_dir" ]]; then
    modules=("$modules_dir"/*.sh)

    if [[ "${#modules[@]}" -eq 0 ]]; then
        log info "no modules to execute"
    else
        log info "executing modules..."

        for module in "${modules[@]}"; do
            log info "executing module...: $module"

            source "$module" &&
            log success "module executed: $module"
        done
    fi
else
    log info "the modules directory doesn't exist: $modules_dir"
fi

# Reboot
log success "script execution fisished"

read -rp "Reboot? [Y/n] " reboot

if [[ "${reboot,,}" == "y" || -z "$reboot" ]]; then
    printf "Reboot in "

    for i in $(seq 10 -1 1); do
        printf "%d..." "$i"
        sleep 1
    done

    reboot
fi
