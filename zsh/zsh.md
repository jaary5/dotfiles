# Zsh Configuration Guide

A minimal, modular Zsh setup for Arch Linux, managed with GNU Stow inspired from https://github.com/radleylewis/zsh

## Quick Install

### Step 1: Install packages (Arch Linux)

```bash
sudo pacman -S zsh git stow eza bat fd fzf zoxide starship ripgrep neovim
```

### Step 2: Clone and stow dotfiles

```bash
git clone <dotfiles-repository> ~/dotfiles
cd ~/dotfiles
stow zsh
```

### Step 3: Test it

```bash
zsh               # tests without changing your login shell
```

```bash
echo "$ZDOTDIR"   # should show: /home/USERNAME/.config/zsh
echo "$EDITOR"    # should show: nvim
```

Check:

``` bash
zsh --version
zoxide --version
fzf --version
starship --version
```

Check current bindings:

| Key | Action |
|---|---|
| `Tab` | Completion |
| `Ctrl+T` | FZF file picker |
| `Ctrl+F` | Custom picker (ignores hidden files) |
| `Ctrl+Right` | Move forward one word |
| `Ctrl+Left` | Move backward one word |
| `Ctrl+\` | Toggle autosuggestions |
| `Up` / `Down` | History substring search |


### Step 4: Make it default

```bash
chsh -s /usr/bin/zsh
```


## Features & Plugins


| Program | Feature / Role | What It Does |
|---|---|---|
| `zsh` | Shell | Interactive shell used to run commands and manage the terminal |
| `stow` | Dotfile management | Creates symlinks from `~/dotfiles` to the correct locations |
| `eza` | Better `ls` | Modern directory listing with icons, Git information and tree view |
| `bat` | Better `cat` | Displays files with syntax highlighting and provides FZF previews |
| `fd` | File finder | Fast, simple alternative to `find`; used by FZF |
| `fzf` | Fuzzy finder | Interactive file/history search; `Ctrl+T` and `Ctrl+F` |
| `zoxide` | Smart navigation | Smarter `cd` that remembers frequently used directories (`z project`) |
| `starship` | Shell prompt | Modern, customizable prompt showing useful information |
| `zsh-autosuggestions` | Autosuggestions | Suggests commands based on shell history as you type |
| `zsh-vi-mode` | Vi mode | Provides Vim-style editing modes in the shell |
| `fast-syntax-highlighting` | Syntax highlighting | Highlights commands and syntax while typing |
| `zsh-history-substring-search` | History search | Searches command history using the text currently typed |
| `ripgrep` (`rg`) | Better `grep` | Fast text search; used as the `grep` replacement |
| `neovim` (`nvim`) | Default editor | Terminal editor used by Zsh and other programs |
| Custom aliases | Shortcuts | Provides shortcuts such as `ll`, `la`, `cat`, `vim`, `po` and `dotfiles` |
| XDG directories | Configuration organization | Keeps Zsh configuration under `~/.config/zsh` and state/cache files under XDG directories |

<br>

The Zsh plugins are **not installed with pacman**. The configuration
automatically clones them from GitHub into:

``` text
~/.local/share/zsh/plugins/
```

Required plugins:

-   `zsh-autosuggestions`
-   `zsh-history-substring-search`
-   `zsh-vi-mode`
-   `fast-syntax-highlighting`



## File Structure

``` text
~/dotfiles/zsh/
├── .zshenv                         (sets environment variables)
└── .config/
    └── zsh/
        ├── .zshrc                  (loads all modules below)
        ├── aliases.zsh             (ls→eza, cat→bat, grep→rg, etc.)
        ├── plugins.zsh             (autosuggestions, vi-mode, syntax highlight)
        ├── bindings.zsh            (custom keybindings)
        ├── fzf.zsh                 (fuzzy finder setup)
        └── prompt.zsh              (starship init)

~/.local/share/zsh/plugins/         (third-party plugins installed here)
```

GNU Stow maps the package structure onto home directory.

``` text
~/dotfiles/zsh/.zshenv
        ↓
~/.zshenv
```

```text
~/dotfiles/zsh/.config/zsh/
        ↓
~/.config/zsh/
```


## Why This Structure?

- **`.zshenv` in `~`**: Zsh reads this before knowing about `ZDOTDIR`, so it sets `ZDOTDIR="$HOME/.config/zsh"` to redirect everything else there
- **Modular `.zsh` files**: Easier to maintain and modify individual features
- **Plugins separate**: Third-party repos stay in `~/.local/share`, not in dotfiles
- **GNU Stow**: Keeps actual files in git repo, symlinks point to real locations


## Startup Files

Zsh reads these in order for login shells:

| File | Purpose |
|------|---------|
| `.zshenv` | Environment variables (read by every shell) |
| `.zprofile` | Login-shell setup (optional, not used here) |
| `.zshrc` | Interactive shell (commands, plugins, aliases) |
| `.zlogin` | Login commands after `.zshrc` (optional) |
| `.zlogout` | Cleanup on logout (optional) |

This setup only needs two config files. `.zshenv` and `.zshrc`.


### 1 `.zshenv` - Environment Variables 

```bash
export XDG_CONFIG_HOME="$HOME/.config"      # Main location for user configuration (XDG directories)
export XDG_CACHE_HOME="$HOME/.cache"        # Location for temporary/cache files (XDG directories)
export XDG_DATA_HOME="$HOME/.local/share"   # Location for application data (XDG directories)
export XDG_STATE_HOME="$HOME/.local/state"  # Location for application state/history (XDG directories)

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"       # Tells Zsh to look for the rest of its
                                            # configuration inside ~/.config/zsh

export EDITOR="nvim"                        # Default editor for terminal programs

export PATH="$HOME/.local/bin:$PATH"        # Add personal scripts/programs to PATH
```

### 2 `.zshrc` - main configuration file for interactive Zsh sessions

It acts as the **controller** and loads the configuration modules

```bash
source "$ZDOTDIR/aliases.zsh"    # Aliases and custom commands
source "$ZDOTDIR/plugins.zsh"    # Zsh plugins
source "$ZDOTDIR/bindings.zsh"   # Keyboard shortcuts
source "$ZDOTDIR/prompt.zsh"     # Starship prompt
```


```bash
.zshrc                   # this structure makes individual features easier to modify
  ├── aliases.zsh
  ├── plugins.zsh
  ├── bindings.zsh
  └── prompt.zsh
```
---

### History

- Stored in: `~/.local/state/zsh/history`
- Size: 100,000 entries
- Deduplicates and ignores duplicates

### Completion

- Tab completion with menu select
- Case-insensitive matching
- Completion cache: `~/.cache/zsh/zcompdump`

### Shell Behavior

- `AUTOCD`: Type directory name instead of `cd dirname`
- `NOBEEP`: Disable terminal beep
- `NUMERIC_GLOB_SORT`: Sort numbers naturally (file1, file2, file10)


## Key Tools Explained

### Zoxide
Replaces `cd` with directory history:
```bash
z project      # jump to ~/path/to/project (learned from history)
zoxide query   # list all learned directories
```

### FZF + fd + bat
- `Ctrl+T`: Open file picker (searches all files)
- `Ctrl+F`: Custom picker (ignores hidden files)
- Previews files with `bat` syntax highlighting

### Plugins (auto-installed)

- **zsh-autosuggestions**: Command suggestions from history
- **zsh-vi-mode**: Vim keybindings (INSERT, NORMAL, VISUAL modes)
- **zsh-history-substring-search**: Search history by prefix
- **fast-syntax-highlighting**: Real-time syntax coloring

### Aliases

```bash
ls  → eza --icons
ll  → eza -lh
la  → eza -lha
tree  → eza --tree
cat → bat
grep → rg
```


## Maintenance

#### Reload configuration
```bash
exec zsh
```

#### Update plugins
```bash
zplugin-update
```

#### Commit changes to dotfiles
```bash
cd ~/dotfiles
git add .
git commit -m "Update zsh configuration"
git push
```


## Troubleshooting

**Zsh not loading `.zshrc`?**
```bash
echo "$ZDOTDIR"           # should be ~/.config/zsh
ls -la ~/.config/zsh/.zshrc
```

**Syntax errors?**
```bash
zsh -n ~/.config/zsh/.zshrc  # no output = no errors
```

**FZF keybindings not working?**
```bash
ls /usr/share/fzf/key-bindings.zsh
```

**Plugins not loading?**
```bash
ls ~/.local/share/zsh/plugins/  # should see plugin folders
```


## One-Liner 

**`.zshenv` sets environment paths, `.zshrc` loads modular features (aliases, plugins, keybindings, prompt), plugins live in `~/.local/share/zsh`, and GNU Stow symlinks everything from `~/dotfiles` to your home.**