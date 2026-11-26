mount_options_name="mount_options.conf"
mount_options_source="$assets_dir/$mount_options_name"
mount_options_destination="/etc/udisks2/$mount_options_name"

# Check if the mount options file exists
if [[ ! -f "$mount_options_source" ]]; then
    log error "the mount options file is missing: $mount_options_source"
    return 1
fi

# Apply the mount options
copy_file "$mount_options_source" "$mount_options_destination" || return 1

return 0
