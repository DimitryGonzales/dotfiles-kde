resolv_conf_path="/etc/resolv.conf"

mode_path="/run/systemd/resolve/stub-resolv.conf"
mode_name="stub"

fallback_dns_conf_name="fallback_dns.conf"
fallback_dns_conf_source="$assets_dir/$fallback_dns_conf_name"
fallback_dns_conf_destination="/etc/systemd/resolved.conf.d/$fallback_dns_conf_name"

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

copy_file "$fallback_dns_conf_source" "$fallback_dns_conf_destination" || return 1

return 0
