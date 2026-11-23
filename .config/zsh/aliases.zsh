# Files
alias cat="bat"

alias cp="cp -v"
alias mkdir="mkdir -pv"
alias mv="mv -v"
alias rm="rm -v"

alias ls="eza -lgh --icons --hyperlink --group-directories-first"
alias lsa="eza -lagh --icons --hyperlink --group-directories-first"

# Packages
alias clean="sudo rm -r /var/cache/pacman/pkg/download-*; yes | paru -Sccd"
alias p="paru"
