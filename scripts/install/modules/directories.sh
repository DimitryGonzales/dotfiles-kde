# Variables
software_path="$HOME/software"

directories=(
    # Software
    "$software_path"
    "$software_path/apps"
    "$software_path/games"
    "$software_path/prefixes"
)

# Check if the directory list is empty
if [[ "${#directories[@]}" -eq 0 ]]; then
    log info "the list of directories is empty"
    return 0
fi

# Create the directories
for directory in "${directories[@]}"; do
    # Check if the directory already exists
    if [[ -d "$directory" ]]; then
        log info "the directory already exists: $directory"
        continue
    fi

    log action "creating the directory: $directory"

    if ! mkdir -p "$directory"; then
        log error "failed to create the directory"
        return 1
    fi

    log success "created the directory"
done

return 0
