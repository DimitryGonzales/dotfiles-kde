software_path="$HOME/software"

make_directory() {
    if [[ -d "$1" ]]; then
        log info "folder already exists: $1"
    else
        if mkdir -p "$1" > /dev/null; then
            log success "created folder: $1"
        else
            log error "failed to create folder: $1"
            exit 1
        fi
    fi
}

log info "creating folders..."

# Create software folder
make_directory "$software_path"
make_directory "$software_path/apps"
make_directory "$software_path/games"
make_directory "$software_path/prefixes"
