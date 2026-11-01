# Variables
software_path="$HOME/software"

directories=(
    # Software
    "$software_path"
    "$software_path/apps"
    "$software_path/games"
    "$software_path/prefixes"
)

# Check if the directories list is empty
if [[ "${#directories[@]}" -eq 0 ]]; then
    log info "the directories list is empty"
    return 0
fi

# Create directories
for directory in "${directories[@]}"; do
    log action "creating directory: $directory"

    if [[ -d "$directory" ]]; then
        log cancel "directory already exists"
        continue
    fi

    if ! mkdir -p "$directory"; then
        log error "failed to create directory"
        return 1
    fi

    log success "created directory"
done

return 0
