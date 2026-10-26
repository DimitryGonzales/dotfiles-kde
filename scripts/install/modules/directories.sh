software_path="$HOME/software"

make_directory() {
    if [[ -d "$1" ]]; then
        log info "directory already exists: $1"
    else
        if mkdir -p "$1" > /dev/null; then
            log success "created directory: $1"
        else
            log error "failed to create directory: $1"
            exit 1
        fi
    fi
}

log info "creating directories..."

# Create software folder
make_directory "$software_path"
make_directory "$software_path/apps"
make_directory "$software_path/games"
make_directory "$software_path/prefixes"
