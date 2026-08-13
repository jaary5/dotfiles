# =========================================================
# Aliases
# =========================================================

# Better ls
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias tree='eza --tree --icons'

# Reuse ls completions for eza
compdef eza=ls

# Better cat
alias cat='bat'

# Core utilities
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# Navigation
alias -- -='cd -'

# Editor
#alias vim='nvim'

# Git
alias glog='PAGER="less -F -X" git log'
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'


# Custom commands
alias ta="toggle-audio"
alias cbl="codeblocks-light"
alias kh="kitty-hotkeys"
alias po="poweroff"
