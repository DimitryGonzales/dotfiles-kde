resolv_conf_path="/etc/resolv.conf"

mode_path="/run/systemd/resolve/stub-resolv.conf"
mode_name="stub"

resolved_conf_path="/etc/systemd/resolved.conf.d"

fallback_dns_conf_name="fallback_dns.conf"
fallback_dns_conf_source="$assets_dir/$fallback_dns_conf_name"
fallback_dns_conf_destination="$resolved_conf_path/$fallback_dns_conf_name"

# Enable the systemd-resolved mode
if [[ -L "$resolv_conf_path" && "$(readlink -f "$resolv_conf_path")" == "$mode_path" ]]; then
    log info "the systemd-resolved mode is already enabled: $mode_name"
else
    log action "enabling the systemd-resolved mode: $mode_name"

    if ! sudo ln -sf "..$mode_path" "$resolv_conf_path"; then
        log error "failed to enable the systemd-resolved mode"
        return 1
    fi

    log success "enabled the systemd-resolved mode"
fi

# Check if the fallback dns config file exists
if [[ ! -f "$fallback_dns_conf_source" ]]; then
    log error "the fallback dns config file is missing: $fallback_dns_conf_source"
    return 1
fi

# Check if the fallback dns functionality is disabled
if [[ -f "$fallback_dns_conf_destination" ]] && cmp -s "$fallback_dns_conf_source" "$fallback_dns_conf_destination"; then
    log info "the fallback dns functionality is already disabled: $fallback_dns_conf_source = $fallback_dns_conf_destination"
    return 0
fi

# Check if the systemd-resolved config folder exists
if [[ -d "$resolved_conf_path" ]]; then
    log info "the systemd-resolved config folder already exists: $resolved_conf_path"
else
    log action "creating the systemd-resolved config folder: $resolved_conf_path"

    if ! sudo mkdir -p "$resolved_conf_path"; then
        log error "failed to create the systemd-resolved config folder"
        return 1
    fi

    log success "created the systemd-resolved config folder"
fi

# Disable the fallback dns functionality
log action "disabling the fallback dns functionality: $fallback_dns_conf_source -> $fallback_dns_conf_destination"

if ! sudo cp "$fallback_dns_conf_source" "$fallback_dns_conf_destination"; then
    log error "failed to disable the fallback dns functionality"
    return 1
fi

log success "disabled the fallback dns functionality"

return 0
