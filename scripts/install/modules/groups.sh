# Variables
groups=(
    docker
    gamemode
    openrazer
    plugdev
)

# Check if the group list is empty
if [[ "${#groups[@]}" -eq 0 ]]; then
    log info "the group list is empty"
    return 0
fi

# Add the user to the groups
for group in "${groups[@]}"; do
    # Check if the user is already in the group
    if groups "$USER" | grep -Fwq "$group"; then
        log info "the user is already in the group: $group"
        continue
    fi

    log action "adding the user to the group: $group"

    # Check if the group exists
    if ! getent group "$group" &>/dev/null; then
        log info "the group doesn't exist"

        log action "creating the group"

        if ! sudo groupadd "$group"; then
            log error "failed to create the group"
            return 1
        fi

        log success "created the group"
    fi

    if ! sudo gpasswd -a "$USER" "$group" >/dev/null; then
        log error "failed to add the user to the group"
        return 1
    fi

    log success "added the user to the group"
done

return 0
