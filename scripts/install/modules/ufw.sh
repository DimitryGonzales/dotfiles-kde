# Enable ufw
log action "enabling ufw"

if sudo ufw status | grep -Fxq "Status: active"; then
    log cancel "ufw is already enabled"
    return 0
fi

if ! sudo ufw enable >/dev/null; then
    log error "failed to enable ufw"
    return 1
fi

log success "enabled ufw"

return 0
