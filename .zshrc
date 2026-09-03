# Enable completion
autoload -Uz compinit
compinit

# Enable history
HISTORY_SIZE=1000

HISTFILE=~/.histfile
HISTSIZE="$HISTORY_SIZE"
SAVEHIST="$HISTORY_SIZE"

# Set keymap (emacs)
bindkey -e

# Sources
source ~/.config/zsh/aliases.zsh # Aliases

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh # Autosuggestions

source ~/.config/zsh/prompt.zsh # Prompt

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # Syntax highlighting (must be sourced at the end)
