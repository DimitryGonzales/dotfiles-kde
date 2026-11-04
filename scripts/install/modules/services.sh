services=(
    user:opentabletdriver.service

    system:docker.socket
    system:paccache.timer
    system:plasmalogin.service
    system:systemd-oomd.service
    system:tor.service
    system:ufw.service
)

# Check if the service list is empty
if [[ "${#services[@]}" -eq 0 ]]; then
    log info "the list of services is empty"
    return 0
fi

# Enable the services
for entry in "${services[@]}"; do
    type="${entry%%:*}"
    service="${entry#*:}"

    case "$type" in
    "system")
        command=(sudo systemctl)
        ;;
    "user")
        command=(systemctl)
        ;;
    *)
        log error "unknown service type: $type"
        return 1
        ;;
    esac

    # Check if the service is already enabled
    if "${command[@]}" "--$type" is-enabled --quiet "$service"; then
        log info "the service is already enabled: $service ($type)"
        continue
    fi

    log action "enabling the service: $service ($type)"

    if ! "${command[@]}" "--$type" enable --quiet "$service"; then
        log error "failed to enable the service"
        return 1
    fi

    log success "enabled the service"
done

return 0
