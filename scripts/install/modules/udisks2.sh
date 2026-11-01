# Variables
mount_options_name="mount_options.conf"
mount_options_source="$assets_dir/$mount_options_name"
mount_options_destination="/etc/udisks2/$mount_options_name"

# Check if mount options file exist
if [[ ! -f "$mount_options_source" ]]; then
    log error "the mount options file is missing: $mount_options_source"
    return 1
fi

# Apply mount options
log action "applying the mount options: $mount_options_source -> $mount_options_destination"

if [[ -f "$mount_options_destination" ]] && cmp -s "$mount_options_source" "$mount_options_destination"; then
    log cancel "the mount options are already applied"
    return 0
fi

if ! sudo cp "$mount_options_source" "$mount_options_destination"; then
    log error "failed to apply the mount options"
    return 1
fi

log success "applied the mount options"

return 0
