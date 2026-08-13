# =========================================================
# Keybindings
# =========================================================

# Cursor shape per vi mode
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

# Disable command mode line highlight
ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# zsh-vi-mode resets bindings during initialization,
# so custom bindings must be registered through this hook.
zvm_after_init() {

    # Ctrl+Right → move forward one word
    bindkey '^[[1;5C' forward-word

    # Ctrl+Left → move backward one word
    bindkey '^[[1;5D' backward-word

    # Ctrl+F → fzf file picker
    bindkey '^F' _fzf_file_no_hidden

    # Up/Down → history substring search
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
}
