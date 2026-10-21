#!/usr/bin/env bash

# Check if the multilib repository is enabled
if grep -Fxq "#[multilib]" /etc/pacman.conf; then
    printf "error: enable the multilib repository before executing the script\n" >&2
    exit 1
fi

# Elevate privileges
sudo -v

# Script directory
script_dir="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

# Update the system
printf "updating the system...\n"

if sudo pacman -Syu; then
    printf "updated the system\n"
else
    printf "error: failed to update the system\n" >&2
    exit 1
fi

# Install paru
if ! command -v paru &> /dev/null; then
    printf "installing paru...\n"

    if (
        sudo pacman -S --needed base-devel git &&
        cd /tmp &&
        git clone https://aur.archlinux.org/paru.git &&
        cd paru &&
        makepkg -si &&
        cd "$script_dir"
    ); then
        printf "installed paru\n"
    else
        printf "error: failed to install paru\n" >&2
        exit 1
    fi
fi

# Install packages
packages_list_path="$script_dir/packages_list.sh"

if [[ -f "$packages_list_path" ]]; then
    source "$packages_list_path"

    printf "installing packages...\n"

    if paru -S --needed "${packages_list[@]}"; then
        printf "installed packages\n"
    else
        printf "error: failed to install packages\n" >&2
        exit 1
    fi
else
    printf "error: missing packages list(%s)" "$packages_list_path" >&2
    exit 1
fi

# KFileDialog Settings
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "Places Icons Auto-resize" false
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "Places Icons Static Size" 22

kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "detailViewIconSize" 32
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "iconViewIconSize" 64
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "listViewIconSize" 32
