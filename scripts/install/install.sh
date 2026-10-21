#!/usr/bin/env bash

# Check if the multilib repository is enabled
if grep -Fxq "#[multilib]" /etc/pacman.conf; then
    printf "Enable the multilib repository before executing the script!\n" >&2
    exit 1
fi

# Elevate privileges
sudo -v

# Script directory
SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"

# Check if the necessary packages are installed
# necessary_packages_file="$HOME/scripts/install/necessary_packages.txt"
# if ! [[ -f "$necessary_packages_file" ]]; then
#     printf "Missing necessary packages file: %s\n" "$necessary_packages_file" >&2
#     exit 1
# fi
#
# if ! pacman -Q "$(cat $necessary_packages_file)" &> /dev/null; then
#     printf "Missing necessary packages!\n"
#
#     read -rp "Install missing packages? [Y/n] " install_missing_packages
#     if [[ "${install_missing_packages,,}" == "y" || -z "$install_missing_packages" ]]; then
#         sudo pacman -S --needed "$(cat $necessary_packages_file)" || exit 1
#     else
#         exit 0
#     fi
# fi

# Update the system
printf "Updating the system...\n"

if ! sudo pacman -Syu; then
    printf "Failed to update the system!\n" >&2
    exit 1
fi

# Install paru
if ! command -v paru; then
    printf "Installing paru...\n"

    if ! (
        sudo pacman -S --needed base-devel git &&
        cd /tmp &&
        git clone https://aur.archlinux.org/paru.git &&
        cd paru &&
        makepkg -si &&
        cd "$SCRIPT_DIR"
    ); then
        printf "Failed to install paru!\n" >&2
        exit 1
    fi
fi

# Install packages
PACKAGES_PATH="$SCRIPT_DIR/packages.txt"

if [[ -f "$PACKAGES_PATH" ]]; then
    if ! paru -S "$(cat "$PACKAGES_PATH")"; then
        printf "Failed to install packages!\n" >&2
        exit 1
    fi
else
    printf "Missing packages list: %s" "$PACKAGES_PATH" >&2
    exit 1
fi

# KFileDialog Settings
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "Places Icons Auto-resize" false
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "Places Icons Static Size" 22

kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "detailViewIconSize" 32
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "iconViewIconSize" 64
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "listViewIconSize" 32
