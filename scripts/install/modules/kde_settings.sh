set_kde_config_key() {
    local file="$1"
    local group="$2"
    local key="$3"
    local value="$4"

    if kwriteconfig6 --file "$file" --group "$group" --key "$key" "$value" > /dev/null; then
        log success "$(basename -- "$file"): set the $group group $key key to $value"
    else
        log error "$(basename -- "$file"): failed to set the $group group $key key to $value"
        exit 1
    fi
}

set_kfiledialog_settings_key() {
    set_kde_config_key "$HOME/.config/kdeglobals" "KFileDialog Settings" "$1" "$2"
}

set_locale_key() {
    set_kde_config_key "$HOME/.config/plasma-localerc" "Formats" "$1" "$2"
}

# Set KFileDialog settings
log info "setting the KFileDialog settings keys..."

set_kfiledialog_settings_key "Places Icons Auto-resize" false
set_kfiledialog_settings_key "Places Icons Static Size" 22

set_kfiledialog_settings_key "detailViewIconSize" 32
set_kfiledialog_settings_key "iconViewIconSize" 64
set_kfiledialog_settings_key "listViewIconSize" 32

# Set locale formats
log info "setting the locale formats keys..."

set_locale_key "LANG" "en_US.UTF-8"
set_locale_key "LC_ADDRESS" "pt_BR.UTF-8"
set_locale_key "LC_MEASUREMENT" "pt_BR.UTF-8"
set_locale_key "LC_MONETARY" "pt_BR.UTF-8"
set_locale_key "LC_NAME" "pt_BR.UTF-8"
set_locale_key "LC_NUMERIC" "pt_BR.UTF-8"
set_locale_key "LC_PAPER" "pt_BR.UTF-8"
set_locale_key "LC_TELEPHONE" "pt_BR.UTF-8"
set_locale_key "LC_TIME" "pt_BR.UTF-8"
