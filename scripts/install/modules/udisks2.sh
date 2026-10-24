mount_options_path="$assets_dir/mount_options.conf"

if [[ -f "$mount_options_path" ]]; then
    log info "applying mount options..."

    if sudo cp "$mount_options_path" /etc/udisks2/ > /dev/null; then
        log success "applied mount options"
    else
        log error "failed to apply mount options"
        exit 1
    fi
else
    log error "missing mount options file: $mount_options_path"
    exit 1
fi
