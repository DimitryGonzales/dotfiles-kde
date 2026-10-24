mount_options_name="mount_options.conf"
mount_options_path="$assets_dir/$mount_options_name"
mount_options_destination="/etc/udisks2/$mount_options_name"

if [[ -f "$mount_options_path" ]]; then
    if [[ -f "$mount_options_destination" ]] && cmp -s "$mount_options_path" "$mount_options_destination"; then
        log info "the mount options are already applied"
    else
        log info "applying the mount options..."

        if sudo cp "$mount_options_path" "$mount_options_destination" > /dev/null; then
            log success "applied the mount options"
        else
            log error "failed to apply the mount options"
            exit 1
        fi
    fi
else
    log error "the mount options file is missing: $mount_options_path"
    exit 1
fi
