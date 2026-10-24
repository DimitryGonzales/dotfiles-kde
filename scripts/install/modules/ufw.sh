if sudo ufw status | grep -Fxq "Status: active"; then
    log info "ufw is already enabled"
else
    log info "enabling ufw..."

    if sudo ufw enable > /dev/null; then
        log success "enabled ufw"
    else
        log error "failed to enable ufw"
        exit 1
    fi
fi
