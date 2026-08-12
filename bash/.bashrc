#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# path for ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# Default text editor for terminal programs (Yazi, Git, crontab)
# environment variables to decide which editor to launch
export EDITOR="nvim"
export VISUAL="nvim"

# starship
eval "$(starship init bash)"

# Custom commands
alias ta="toggle-audio"
alias cbl="codeblocks-light"
alias kh="kitty-hotkeys"
alias cat='bat'
alias po='poweroff'

# avro keyboard
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
