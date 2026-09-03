# Files
alias cat="bat"

alias cp="cp -v"
alias mkdir="mkdir -pv"
alias mv="mv -v"
alias rm="rm -v"

alias ls="eza -lgh --icons --hyperlink --group-directories-first"
alias lsa="eza -lagh --icons --hyperlink --group-directories-first"

# Git
alias git="$HOME/Documents/scripts/git-switch.sh && git"
alias yadm="$HOME/Documents/scripts/git-switch.sh && yadm"

# Packages
alias clean="sudo rm -r /var/cache/pacman/pkg/download-*; yes | paru -Sccd"
alias p="paru"
alias update="sudo reflector --verbose --country Brazil --sort age --save /etc/pacman.d/mirrorlist && paru"

# yt-dlp
alias x="yt-dlp --cookies $HOME/Documents/cookies/x.com_cookies.txt"
