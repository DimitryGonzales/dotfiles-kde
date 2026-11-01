# Variables
services=(
    user:opentabletdriver.service

    system:docker.socket
    system:paccache.timer
    system:plasmalogin.service
    system:systemd-oomd.service
    system:tor.service
    system:ufw.service
)

# Check if the list of services is empty
if [[ "${#services[@]}" -eq 0 ]]; then
    log info "the list of services is empty"
    return 0
fi

# Enable services
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

    log action "enabling service: $service ($type)"

    if "${command[@]}" "--$type" is-enabled --quiet "$service"; then
        log cancel "service already enabled"
        continue
    fi

    if ! "${command[@]}" "--$type" enable --quiet "$service"; then
        log error "failed to enable service"
        return 1
    fi

    log success "enabled service"
done

return 0
