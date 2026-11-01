# Variables
locale_gen_name="locale.gen"
locale_conf_name="locale.conf"

locale_gen_source="$assets_dir/$locale_gen_name"
locale_gen_destination="/etc/$locale_gen_name"

locale_conf_source="$assets_dir/$locale_conf_name"
locale_conf_destination="/etc/$locale_conf_name"

# Functions
check_file() {
    local file="$1"

    # Check if the file exists
    if [[ ! -f "$file" ]]; then
        log error "locale file is missing: $file"
        return 1
    fi

    return 0
}

copy() {
    local source="$1"
    local destination="$2"

    # Compare with the destination file
    if [[ -f "$destination" ]] && cmp -s "$source" "$destination"; then
        log info "file already exists with identical content: $source = $destination"
        return 0
    fi

    log action "copying file: $source -> $destination"

    if ! sudo cp "$source" "$destination"; then
        log error "failed to copy file"
        return 1
    fi

    log success "copied file"

    return 0
}

# Check if the necessary locale files exist
check_file "$locale_gen_source" || return 1
check_file "$locale_conf_source" || return 1

# Apply the locale generation configuration
copy "$locale_gen_source" "$locale_gen_destination" || return 1

# Generate locales
log action "generating locales"

if ! sudo locale-gen >/dev/null; then
    log error "failed to generate locales"
    return 1
fi

log success "generated locales"

# Apply the locale configuration
copy "$locale_conf_source" "$locale_conf_destination" || return 1

return 0
