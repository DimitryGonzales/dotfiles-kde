# Variables
config_dir="$HOME/.config"

kfiledialog_keys=(
    # Places icons
    "Places Icons Auto-resize:false"
    "Places Icons Static Size:22"

    # View icon sizes
    "detailViewIconSize:32"
    "iconViewIconSize:64"
    "listViewIconSize:32"
)

locale_keys=(
    "LANG:en_US.UTF-8"
    "LC_ADDRESS:pt_BR.UTF-8"
    "LC_MEASUREMENT:pt_BR.UTF-8"
    "LC_MONETARY:pt_BR.UTF-8"
    "LC_NAME:pt_BR.UTF-8"
    "LC_NUMERIC:pt_BR.UTF-8"
    "LC_PAPER:pt_BR.UTF-8"
    "LC_TELEPHONE:pt_BR.UTF-8"
    "LC_TIME:pt_BR.UTF-8"
)

# Functions
set_keys() {
    local file="$1"
    local group="$2"
    shift 2

    local file_name entry key value current_value

    file_name="$(basename "$file")"

    # Check if the key list is empty
    if [[ "${#@}" -eq 0 ]]; then
        log info "the key list is empty"
        return 0
    fi

    # Set keys
    for entry in "$@"; do
        key="${entry%%:*}"
        value="${entry#*:}"

        # Read the current value
        if ! current_value="$(kreadconfig6 --file "$file" --group "$group" --key "$key")"; then
            log error "failed to read key"
            return 1
        fi

        # Compare with the current value
        if [[ "$current_value" == "$value" ]]; then
            log info "key is already set to $value: $key ($group ($file_name))"
            continue
        fi

        log action "setting key to $value: $key ($group ($file_name))"

        if ! kwriteconfig6 --file "$file" --group "$group" --key "$key" "$value"; then
            log error "failed to set key"
            return 1
        fi

        log success "set key"
    done

    return 0
}

# Set KFileDialog keys
set_keys "$config_dir/kdeglobals" "KFileDialog Settings" "${kfiledialog_keys[@]}" || return 1

# Set the locale keys
set_keys "$config_dir/plasma-localerc" "Formats" "${locale_keys[@]}" || return 1

return 0
