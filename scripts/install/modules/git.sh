git_options=(
    credential.helper:store
)

for entry in "${git_options[@]}"; do
    option="${entry%%:*}"
    value="${entry#*:}"

    # Check if the option is already set to the new value
    if [[ "$(git config --global --get "$option")" == "$value" ]]; then
        log info "the git option is already set to $value: $option"
        continue
    fi

    # Set the git option
    log action "setting the git option to $value: $option"

    if ! git config --global "$option" "$value"; then
        log error "failed to set the git option"
        return 1
    fi

    log success "set the git option"
done

return 0
