yadm_repository_url="https://github.com/DimitryGonzales/dotfiles-kde.git"

if yadm status &> /dev/null; then
    log info "a yadm repository already exists"
else
    log info "cloning yadm repository...: $yadm_repository_url"

    if yadm clone "$yadm_repository_url" > /dev/null; then
        log success "cloned yadm repository"

        log info "checking out yadm repository..."

        if yadm checkout --force > /dev/null; then
            log success "checked out yadm repository"
        else
            log error "failed to check out yadm repository"
            exit 1
        fi
    else
        log error "failed to clone yadm repository"
        exit 1
    fi
fi
