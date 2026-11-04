shell="zsh"

# Determine the shell path
if ! shell_path="$(command -v "$shell")"; then
    log error "failed to determine the shell path: $shell"
    return 1
fi

# Set the default shell
if [[ "$SHELL" == "$shell_path" ]]; then
    log info "the shell is already the default: $shell"
    return 0
fi

log action "setting the shell as the default: $shell"

if ! chsh -s "$shell_path" >/dev/null; then
    log error "failed to set the shell as the default"
    return 1
fi

log success "set the shell as the default"

return 0
