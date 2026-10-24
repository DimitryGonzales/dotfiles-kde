locale_gen_name="locale.gen"
locale_gen_path="$assets_dir/$locale_gen_name"
locale_gen_destination="/etc/$locale_gen_name"

locale_conf_name="locale.conf"
locale_conf_path="$assets_dir/$locale_conf_name"
locale_conf_destination="/etc/$locale_conf_name"

if [[ -f "$locale_gen_path" ]]; then
    if [[ -f "$locale_gen_destination" ]] && cmp -s "$locale_gen_path" "$locale_gen_destination"; then
        log info "the locale generation configuration is already applied"
    else
        log info "applying the locale generation configuration..."

        if sudo cp "$locale_gen_path" "$locale_gen_destination" > /dev/null; then
            log success "applied the locale generation configuration"
        else
            log error "failed to apply the locale generation configuration"
            exit 1
        fi

        log info "generating locales..."

        if sudo locale-gen > /dev/null; then
            log success "generated locales"
        else
            log error "failed to generate locales"
            exit 1
        fi
    fi
else
    log error "the locale generation file is missing: $locale_gen_path"
    exit 1
fi

if [[ -f "$locale_conf_path" ]]; then
    if [[ -f "$locale_conf_destination" ]] && cmp -s "$locale_conf_path" "$locale_conf_destination"; then
        log info "the locale configuration is already applied"
    else
        log info "applying the locale configuration..."

        if sudo cp "$locale_conf_path" "$locale_conf_destination" > /dev/null; then
            log success "applied the locale configuration"
        else
            log error "failed to apply the locale configuration"
            exit 1
        fi
    fi
else
    log error "the locale configuration file is missing: $locale_conf_path"
    exit 1
fi
