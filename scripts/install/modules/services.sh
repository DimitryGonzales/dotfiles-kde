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

log info "enabling services..."

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

    if "${command[@]}" "--$type" is-enabled "$service" &> /dev/null; then
        log info "$type: $service is already enabled"
        continue
    fi

    if ! "${command[@]}" "--$type" enable "$service" &> /dev/null; then
        log error "$type: failed to enable $service"
        return 1
    fi

    log success "$type: enabled $service"
done

return 0
