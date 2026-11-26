locale_gen_name="locale.gen"
locale_gen_source="$assets_dir/$locale_gen_name"
locale_gen_destination="/etc/$locale_gen_name"

locale_conf_name="locale.conf"
locale_conf_source="$assets_dir/$locale_conf_name"
locale_conf_destination="/etc/$locale_conf_name"

# Check if the locale generation configuration file exists
if [[ ! -f "$locale_gen_source" ]]; then
    log error "the locale generation configuration file is missing: $locale_gen_source"
    return 1
fi

# Apply the locale generation configuration
copy_file "$locale_gen_source" "$locale_gen_destination" || return 1

# Generate the locales
log action "generating the locales"

if ! sudo locale-gen >/dev/null; then
    log error "failed to generate the locales"
    return 1
fi

log success "generated the locales"

# Check if the locale configuration file exists
if [[ ! -f "$locale_conf_source" ]]; then
    log error "the locale configuration file is missing: $locale_conf_source"
    return 1
fi

# Apply the locale configuration
copy_file "$locale_conf_source" "$locale_conf_destination" || return 1

return 0
