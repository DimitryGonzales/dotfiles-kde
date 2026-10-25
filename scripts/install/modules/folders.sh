software_path="$HOME/software"

create_folder() {
    if mkdir -p "$1" > /dev/null; then
        log success "created folder: $1"
    else
        log error "failed to create folder: $1"
        exit 1
    fi
}

log info "creating folders..."

# Create software folder
create_folder "$software_path"
create_folder "$software_path/apps"
create_folder "$software_path/games"
create_folder "$software_path/prefixes"
