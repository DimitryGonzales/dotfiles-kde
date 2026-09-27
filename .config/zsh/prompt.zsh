# Init prompt (pure)
autoload -U promptinit; promptinit
prompt pure

# Remove newline at the start
print() {
    [[ $# -eq 0 && ${funcstack[-1]} = prompt_pure_precmd ]] || builtin print "$@"
}

prompt_needs_newline=false

precmd() {
    if [[ "$prompt_needs_newline" == true ]]; then
        echo
    fi
    prompt_needs_newline=true
}

clear() {
    prompt_needs_newline=false
    command clear
}
