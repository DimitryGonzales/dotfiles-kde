reflector_conf_name="reflector.conf"
reflector_conf_source="$assets_dir/$reflector_conf_name"
reflector_conf_destination="/etc/xdg/reflector/$reflector_conf_name"

# Check if the reflector configuration file exists
if [[ ! -f "$reflector_conf_source" ]]; then
    log error "the reflector configuration file is missing: $reflector_conf_source"
    return 1
fi

copy_file "$reflector_conf_source" "$reflector_conf_destination" || return 1

return 0
