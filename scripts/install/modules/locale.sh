locale_gen_path="$assets_dir/locale.gen"
locale_conf_path="$assets_dir/locale.conf"

if [[ -f "$locale_gen_path" ]]; then
    log info "applying the locale generation configuration..."

    if sudo cp "$locale_gen_path" "/etc/" > /dev/null; then
        log success "applied the locale generation configuration"
    else
        log error "failed to apply the locale generation configuration"
        exit 1
    fi

    log info "generating the locales..."

    if sudo locale-gen > /dev/null; then
        log success "generated the locales"

        if [[ -f "$locale_conf_path" ]]; then
            log info "applying the locale configuration..."

            if sudo cp "$locale_conf_path" "/etc/" > /dev/null; then
                log success "applied the locale configuration"
            else
                log error "failed to apply the locale configuration"
                exit 1
            fi
        else
            log error "missing locale configuration file: $locale_conf_path"
            exit 1
        fi
    else
        log error "failed to generate the locales"
        exit 1
    fi
else
    log error "missing locale generation file: $locale_gen_path"
    exit 1
fi
