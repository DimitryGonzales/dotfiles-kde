# Variables
yadm_repository_url="https://github.com/DimitryGonzales/dotfiles-kde.git"

# Check if a yadm repository already exists
if yadm status &>/dev/null; then
    log info "a yadm repository already exists"
    return 0
fi

# Clone the yadm repository
log action "cloning yadm repository: $yadm_repository_url"

if ! yadm clone --quiet "$yadm_repository_url"; then
    log error "failed to clone yadm repository"
    return 1
fi

log success "cloned yadm repository"

# Check out the yadm repository
log action "checking out yadm repository"

if ! yadm checkout --force --quiet; then
    log error "failed to check out yadm repository"
    return 1
fi

log success "checked out yadm repository"

return 0
