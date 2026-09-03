#!/usr/bin/env bash

# KFileDialog Settings
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "Places Icons Auto-resize" false
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "Places Icons Static Size" 22

kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "detailViewIconSize" 32
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "iconViewIconSize" 64
kwriteconfig6 --file "$HOME/.config/kdeglobals" --group "KFileDialog Settings" --key "listViewIconSize" 32
