services=(
    user:opentabletdriver.service

    system:docker.socket
    system:paccache.timer
    system:plasmalogin.service
    system:systemd-oomd.service
    system:tor.service
    system:ufw.service
)

if [[ "${#services[@]}" -eq 0 ]]; then
    log info "the services list is empty"
    return 0
fi

log action "enabling services..."

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

    if "${command[@]}" "--$type" is-enabled --quiet "$service"; then
        log info "service already enabled: $service ($type)"
        continue
    fi

    if ! "${command[@]}" "--$type" enable --quiet "$service"; then
        log error "failed to enable service: $service ($type)"
        return 1
    fi

    log success "enabled service: $service ($type)"
done

return 0
