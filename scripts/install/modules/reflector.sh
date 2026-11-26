reflector_conf_name="reflector.conf"
reflector_conf_source="$assets_dir/$reflector_conf_name"
reflector_conf_destination="/etc/xdg/reflector/$reflector_conf_name"

# Check if the reflector configuration file exists
if [[ ! -f "$reflector_conf_source" ]]; then
    log error "the reflector configuration file is missing: $reflector_conf_source"
    return 1
fi

# Check if the reflector configuration is already applied
if [[ -f "$reflector_conf_destination" ]] && cmp -s "$reflector_conf_source" "$reflector_conf_destination"; then
    log info "the reflector configuration is already applied: $reflector_conf_source = $reflector_conf_destination"
else
    # Apply the reflector configuration
    log action "applying the reflector configuration: $reflector_conf_source -> $reflector_conf_destination"

    if ! sudo cp "$reflector_conf_source" "$reflector_conf_destination"; then
        log error "failed to apply the reflector configuration"
        return 1
    fi

    log success "applied the reflector configuration"
fi
