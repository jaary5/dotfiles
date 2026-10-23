# Hyprland Theme System --- Documentation

**Repository:** `~/dotfiles`\
**Theme engine:** `~/dotfiles/bin/.local/bin/theme-switch`\
**Runtime state:** `~/.config/theme-switcher/`\
**Configuration manager:** GNU Stow\
**Session:** Arch Linux + Hyprland\

This guide documents the current theme system, its architecture,
responsibilities, known dependencies, operation, troubleshooting, and
the repeatable process for adding themes.

> **Accuracy note:** This document is based on the implementation
> details established during setup. Where behavior depends on the exact
> current contents of a script, it says so explicitly. Before
> refactoring, inspect the script rather than treating a description
> here as a substitute for the source code.

------------------------------------------------------------------------

## 1. Goals and design rules

The system is designed around a few important rules:

1.  `~/dotfiles/themes/` is the **single source of truth** for theme
    assets.
2.  GNU Stow manages configuration files and executable entry points by
    creating symlinks.
3.  `theme-switch` coordinates theme application across desktop
    applications.
4.  Generated active configuration and current selection state live
    outside the Git source tree, under `~/.config/theme-switcher/`.
5.  Application configuration packages should not contain duplicate
    copies of the theme collection.
6.  A theme directory is only useful if the switcher knows how to
    consume its files.

### Source files versus generated files

| Path | Purpose | Ownership |
|---|---|---|
| `~/dotfiles/themes/` | Theme source files and wallpapers | Git |
| `~/dotfiles/bin/.local/bin/` | Theme and wallpaper scripts | Git; deployed with Stow |
| `~/.local/bin/` | Symlinks to scripts | GNU Stow |
| `~/.config/theme-switcher/active/` | Generated active app configuration | `theme-switch` |
| `~/.config/theme-switcher/current-theme` | Selected theme name | `theme-switch` |
| `~/.config/theme-switcher/current-wallpaper` | Last selected wallpaper path | `theme-switch` |
| `~/.config/eza/theme.yml` | Active Eza theme | `theme-switch` |

Do not manually edit generated files in
`~/.config/theme-switcher/active/`. Edit the source in `~/dotfiles/` and
apply the theme again.

------------------------------------------------------------------------

## 2. Repository structure

The relevant layout is:

``` text
~/dotfiles/
├── bin/                              # GNU Stow package
│   ├── .local/
│   │   ├── bin/
│   │   │   ├── theme-switch
│   │   │   ├── theme-menu
│   │   │   └── wallpaper-menu
│   │   └── share/applications/
│   │       └── themes.desktop
│
├── themes/                           # Central theme library; not a Stow package
│   ├── catppuccin-mocha/
│   │   ├── kitty.conf
│   │   ├── waybar.css
│   │   ├── rofi.rasi
│   │   ├── dunst-colors.conf
│   │   ├── starship.toml
│   │   ├── eza-theme.yml             # present where provided
│   │   └── wallpapers/
│   ├── catppuccin-latte/
│   ├── gruvbox/
│   ├── everforest/
│   ├── nord/
│   └── tokyo-night/
│
├── hypr/                             # GNU Stow package
│   └── .config/hypr/
│       ├── hyprland.lua
│       └── hyprpaper.conf
│
├── kitty/
├── rofi/
├── starship/
├── waybar/
└── ...
```

Not every theme necessarily contains every optional asset. Inspect an
existing theme before assuming its exact contents.

### Why `themes/` is separate from Stow packages

The theme folders are data consumed directly by `theme-switch`. They
should not each be Stowed into application config directories. Stowing
multiple theme variants would create competing configurations and
undermine the central selector.

The `hypr/` package deploys Hyprland configuration to `~/.config/hypr/`.
It should not contain a second theme library. An empty duplicate
directory at `hypr/.config/hypr/themes/` was removed; keep wallpapers in
the central `~/dotfiles/themes/<name>/wallpapers/` folders.

------------------------------------------------------------------------

## 3. What the theme system controls

| Component | Theme source | What it controls | Application mechanism |
|---|---|---|---|
| Kitty | `kitty.conf` | Terminal colors | Active config is generated/copied for Kitty |
| Waybar | `waybar.css` | Bar colors and styling | Active stylesheet is updated; Waybar receives a reload signal |
| Rofi | `rofi.rasi` | Launcher/menu appearance | Active Rofi theme is updated and consumed by Rofi |
| Dunst | `dunst-colors.conf` | Notification colors | `theme-apply-dunst` applies colors; Dunst is reloaded |
| Starship | `starship.toml` | Shell prompt colors and style | Active TOML is selected through `STARSHIP_CONFIG` |
| Eza | `eza-theme.yml` | Eza color styling, including owner/group colors | Active theme is installed at `~/.config/eza/theme.yml` |
| Wallpaper | `wallpapers/*` | Desktop background | `hyprctl` sends the selected image to Hyprpaper |

Hyprland window borders, gaps, rounding, blur, shadows, and animations
are **not confirmed as theme-switched** by the current script. They
remain in the regular Hyprland configuration unless explicit application
logic is added later.

Creating a file in a theme folder does not automatically make an
application theme-aware. The switcher must copy, transform, or otherwise
apply that file.

------------------------------------------------------------------------

## 4. How `theme-switch` works

### Main script and installed command

Repository source:

``` text
~/dotfiles/bin/.local/bin/theme-switch
```

Installed command:

``` text
~/.local/bin/theme-switch
```

The installed command should be a Stow-created symlink to the repository
script.

The script is the coordinator. It discovers and validates themes,
prepares active configuration, updates application-specific settings,
selects a wallpaper, applies it, and records the current selection.

### Theme discovery and validation

The theme source directory is the central `~/dotfiles/themes/`
collection. The script checks the selected theme and its supported
wallpaper files. Its exact required-file list and accepted wallpaper
extensions are defined in the script; inspect those rules before adding
new file types or changing the layout.

### Active files

Generated files are kept outside the repository:

``` text
~/.config/theme-switcher/active/
├── kitty.conf
├── waybar.css
├── rofi.rasi
└── starship.toml
```

These are known active files; inspect the directory for the complete
current set. They are runtime output, not Stow sources.

### Starship integration

The Zsh prompt setup uses:

``` zsh
export VIRTUAL_ENV_DISABLE_PROMPT=1
export STARSHIP_CONFIG="$HOME/.config/theme-switcher/active/starship.toml"
eval "$(starship init zsh)"
```

The theme switcher prepares the active Starship config and adjusts its
`palette` value.

Known theme-to-palette mapping:

| Theme | Starship palette |
|---|---|
| `catppuccin-latte` | `catppuccin_latte` |
| `gruvbox` | `gruvbox_dark` |
| Other current themes | `catppuccin_mocha` fallback |

The source Starship configuration is Stow-managed at:

``` text
~/dotfiles/starship/.config/starship.toml
```

The existing prompt references semantic color names such as `green`,
`purple`, `red`, `lavender`, `text`, and `subtext1`. A custom palette
must define the names used by the prompt; otherwise parts of the prompt
may use unexpected fallback colors.

When adding a theme-specific Starship palette:

1.  Add a `[palettes.<palette_name>]` section to the source
    `starship.toml`.
2.  Define all color names used by the prompt.
3.  Add or update the theme-to-palette mapping in `theme-switch`.
4.  Apply the theme and inspect the prompt.

### Eza integration

The active Eza theme is:

``` text
~/.config/eza/theme.yml
```

Theme-specific Eza files are stored in the theme directory where
provided. The current switcher has fallback behavior for themes without
their own Eza theme; inspect that logic before removing or changing the
fallback.

Catppuccin Latte uses darker owner/group foreground colors so those
columns remain readable against a light terminal background. When making
a light theme, check owner and group contrast carefully.

### Dunst integration

The switcher calls the `theme-apply-dunst` helper to apply the selected
Dunst colors, then attempts:

``` bash
dunstctl reload
```

Dunst is the notification daemon in this setup. Do not run SwayNC as a
second notification daemon alongside Dunst unless intentionally
replacing the notification stack and updating the configuration.

### Waybar integration

The current switcher signals Waybar using:

``` bash
pkill -SIGUSR2 waybar
```

Hyprland starts Waybar with the floating configuration:

``` bash
waybar -c ~/.config/waybar/floating/config.jsonc \
       -s ~/.config/waybar/floating/style.css
```

If these paths change, update the startup configuration and the theme
application logic together.

### Wallpaper integration

Each theme stores its wallpapers here:

``` text
~/dotfiles/themes/<theme-name>/wallpapers/
```

The switcher chooses a random supported image and applies it using the
current Hyprpaper IPC command:

``` bash
hyprctl hyprpaper wallpaper ",${image},cover"
```

It records the selected path in:

``` text
~/.config/theme-switcher/current-wallpaper
```

The intended responsibilities are:

-   **Hyprpaper:** wallpaper daemon.
-   **Theme-switcher:** chooses and applies the wallpaper.
-   **Theme directory:** stores source wallpaper images.

Avoid a hardcoded, unrelated wallpaper assignment in `hyprpaper.conf`;
it creates a second wallpaper-selection mechanism. The intended minimal
config is:

``` ini
# Wallpaper selection is managed by the central theme-switcher.
splash = false
```

Hyprpaper must be running before the wallpaper IPC command is sent. A
theme switch after login may work even if login-time theme restoration
is not configured.

------------------------------------------------------------------------

## 5. Menus and user commands

### List and apply themes

``` bash
theme-switch list
theme-switch catppuccin-mocha
theme-switch catppuccin-latte
theme-switch gruvbox
theme-switch nord
theme-switch everforest
theme-switch tokyo-night
```

Use the exact directory name under `~/dotfiles/themes/`.

### Theme menu

Script:

``` text
~/dotfiles/bin/.local/bin/theme-menu
```

It obtains available theme names from `theme-switch list` and presents
them through Rofi. The desktop entry is:

``` text
~/dotfiles/bin/.local/share/applications/themes.desktop
```

### Wallpaper menu

Script:

``` text
~/dotfiles/bin/.local/bin/wallpaper-menu
```

It displays wallpaper thumbnails in a Rofi grid. ImageMagick is used to
generate thumbnails. The Rofi grid theme is:

``` text
~/dotfiles/rofi/.config/rofi/wallpaper-grid.rasi
```

These are separate workflows:

-   `theme-menu` selects a complete theme.
-   `wallpaper-menu` selects a wallpaper.
-   `theme-switch <name>` selects a random wallpaper while applying a
    theme.

Keep all wallpaper images in the central theme folders.

------------------------------------------------------------------------

## 6. Dependencies

The table lists known dependencies based on the components and commands
used. A helper script may introduce additional requirements, so inspect
it before uninstalling packages.

### Core runtime dependencies

| Dependency | Purpose |
|---|---|
| Hyprland and `hyprctl` | Session and IPC; sends wallpaper commands |
| Hyprpaper | Wallpaper daemon |
| Kitty | Terminal and terminal theme |
| Waybar | Status bar and stylesheet |
| Rofi | Theme and wallpaper menus |
| Dunst and `dunstctl` | Notification daemon and reload |
| Starship | Shell prompt |
| Eza | Enhanced directory listing and theme |
| Zsh | Shell initialization for Starship |
| GNU Stow | Deploys configuration and script symlinks |
| Bash | Runs the theme scripts |

### Wallpaper picker dependencies

| Dependency | Purpose |
|---|---|
| ImageMagick | Generates wallpaper thumbnails |
| Rofi | Displays the thumbnail grid |
| Hyprpaper | Displays the chosen wallpaper |
| `find` and standard shell utilities | Discover files and manipulate paths |

The scripts use standard utilities such as `cp`, `mkdir`, `printf`,
`sed`, `find`, `command`, and `pkill`.

Verify the installed commands:

``` bash
for cmd in stow bash hyprctl hyprpaper kitty waybar rofi \
           dunst dunstctl starship eza magick; do
    if command -v "$cmd" >/dev/null 2>&1; then
        printf 'FOUND  %s -> %s\n' "$cmd" "$(command -v "$cmd")"
    else
        printf 'MISSING %s\n' "$cmd"
    fi
done
```

Some ImageMagick installations expose `convert` as well as `magick`. Use
the exact executable referenced in `wallpaper-menu`.

Inspect script dependencies:

``` bash
rg -n 'command -v|hyprctl|hyprpaper|magick|convert|rofi|dunstctl|pkill|sed|cp|find' \
  ~/dotfiles/bin/.local/bin/theme-switch \
  ~/dotfiles/bin/.local/bin/theme-menu \
  ~/dotfiles/bin/.local/bin/wallpaper-menu
```

The current setup is Rofi-based and uses Dunst. Walker and SwayNC are
not required by this design. Do not add `jq` or another dependency
unless the actual scripts need it.

------------------------------------------------------------------------

## 7. Adding a new theme --- complete procedure

This is the normal workflow for adding a theme without changing the
architecture.

### Step 1: Create its directory

Use lowercase names with hyphens:

``` bash
mkdir -p ~/dotfiles/themes/my-new-theme/wallpapers
```

The directory name becomes the argument passed to `theme-switch`.

### Step 2: Create the expected files

A complete theme should look like:

``` text
my-new-theme/
├── kitty.conf
├── waybar.css
├── rofi.rasi
├── dunst-colors.conf
├── starship.toml
├── eza-theme.yml
└── wallpapers/
    ├── wallpaper-01.jpg
    └── wallpaper-02.png
```

The formats are:

-   `kitty.conf`: Kitty configuration syntax.
-   `waybar.css`: GTK CSS used by Waybar.
-   `rofi.rasi`: Rofi theme syntax.
-   `dunst-colors.conf`: Dunst configuration fragment compatible with
    the existing helper/include setup.
-   `starship.toml`: valid TOML Starship configuration.
-   `eza-theme.yml`: valid Eza theme YAML.
-   `wallpapers/`: image files with extensions accepted by the switcher.

The exact required/optional status of files is determined by the
validation logic in `theme-switch`. For a self-contained theme, supply
all of them.

### Step 3: Copy a known-good theme as a template

Do not start with empty configuration files. Copy a working theme and
change its color values while preserving application-specific syntax and
selectors.

``` bash
cp ~/dotfiles/themes/catppuccin-mocha/kitty.conf \
   ~/dotfiles/themes/my-new-theme/

cp ~/dotfiles/themes/catppuccin-mocha/waybar.css \
   ~/dotfiles/themes/my-new-theme/

cp ~/dotfiles/themes/catppuccin-mocha/rofi.rasi \
   ~/dotfiles/themes/my-new-theme/

cp ~/dotfiles/themes/catppuccin-mocha/dunst-colors.conf \
   ~/dotfiles/themes/my-new-theme/

cp ~/dotfiles/themes/catppuccin-mocha/starship.toml \
   ~/dotfiles/themes/my-new-theme/

cp ~/dotfiles/themes/catppuccin-mocha/eza-theme.yml \
   ~/dotfiles/themes/my-new-theme/
```

Then replace the color values with the new palette. Do not blindly
replace every hex value: some files may use colors for different
semantic roles.

### Step 4: Add wallpapers

Place wallpaper images in:

``` text
~/dotfiles/themes/my-new-theme/wallpapers/
```

Check the files:

``` bash
find ~/dotfiles/themes/my-new-theme/wallpapers -maxdepth 1 -type f
```

Check the extension filter in `theme-switch` if an image is not being
discovered.

### Step 5: Add a Starship palette

Edit the Stow-managed source:

``` text
~/dotfiles/starship/.config/starship.toml
```

Add a named palette section, for example:

``` toml
[palettes.my_new_palette]
green = "#..."
purple = "#..."
red = "#..."
lavender = "#..."
text = "#..."
subtext1 = "#..."
```

This is only an illustrative subset. Define every semantic color name
actually referenced by the prompt configuration.

Then update the theme-to-palette mapping in:

``` text
~/dotfiles/bin/.local/bin/theme-switch
```

Map `my-new-theme` to `my_new_palette`. If you do not add a mapping, the
current fallback behavior may select the Mocha palette instead.

### Step 6: Check Eza fallback behavior

If `eza-theme.yml` is included, confirm that the switcher selects it. If
you intentionally rely on the fallback, inspect the fallback colors
against the new terminal background.

For light themes, use sufficiently dark owner/group colors. For dark
themes, make sure those colors remain distinguishable without becoming
excessively bright.

### Step 7: Apply and test

``` bash
theme-switch list
theme-switch my-new-theme
```

Inspect each component:

1.  Kitty: background, foreground, cursor, selection, ANSI colors.
2.  Waybar: text, modules, hover states, borders.
3.  Rofi: prompt, selected row, alternate rows, background.
4.  Dunst: normal and urgency colors.
5.  Starship: prompt segments and symbols in a new shell.
6.  Eza: owner/group columns using `ll`.
7.  Wallpaper: image selected from the new theme's wallpaper folder.

Also test the wallpaper picker:

``` bash
wallpaper-menu
```

### Step 8: Commit source files

``` bash
cd ~/dotfiles
git status --short
git add themes/my-new-theme
git add starship/.config/starship.toml
git add bin/.local/bin/theme-switch
git commit -m "Add my-new-theme desktop theme"
```

Only stage the files actually changed. Do not commit generated files
from `~/.config/theme-switcher/`.

------------------------------------------------------------------------

## 8. Palette design and contrast

Before editing application files, define semantic colors consistently.

| Semantic role | Intended use |
|---|---|
| `base` | Main background |
| `mantle` | Secondary/darker background |
| `crust` | Deepest background |
| `text` | Primary foreground |
| `subtext` | Secondary foreground |
| `surface` | Elevated surface or inactive element |
| `overlay` | Borders, separators, muted controls |
| `blue` | Informational/accent color |
| `green` | Success |
| `yellow` | Warning |
| `red` | Error/destructive state |
| `purple` / `mauve` | Secondary accent |

These are planning names, not a universal syntax accepted by all
applications. Translate the palette into each application's native
configuration format.

Contrast checklist:

-   Light themes need dark text and dark owner/group colors.
-   Dark themes need readable foregrounds and distinguishable muted
    colors.
-   Selected and hovered Rofi/Waybar states should be obvious.
-   Dunst urgency colors should remain distinct.
-   Never use nearly identical foreground and background colors for the
    same UI state.

------------------------------------------------------------------------

## 9. GNU Stow workflow and rules

Stow deploys configuration packages. It does not select themes.

### Deploy scripts and desktop entry

``` bash
cd ~/dotfiles
stow --restow bin
```

### Deploy Hyprland configuration

``` bash
cd ~/dotfiles
stow --restow hypr
```

### Inspect symlinks

``` bash
ls -l ~/.local/bin/theme-switch
ls -l ~/.local/bin/theme-menu
ls -l ~/.local/bin/wallpaper-menu
ls -l ~/.config/hypr
```

Rules:

-   Put a file in a Stow package only when it should be symlinked into
    the home directory.
-   Keep theme source assets under `~/dotfiles/themes/`.
-   Keep generated active configuration under
    `~/.config/theme-switcher/`.
-   Do not Stow runtime state.
-   Do not create another wallpaper collection under
    `hypr/.config/hypr/`.
-   Before restowing after moving files, inspect conflicts and existing
    symlinks.
-   Keep scripts executable in the repository:

``` bash
chmod +x ~/dotfiles/bin/.local/bin/theme-switch
chmod +x ~/dotfiles/bin/.local/bin/theme-menu
chmod +x ~/dotfiles/bin/.local/bin/wallpaper-menu
```

------------------------------------------------------------------------

## 10. Startup and wallpaper lifecycle

The Hyprland Lua configuration starts these processes from its
`hyprland.start` hook:

-   Dunst
-   Waybar, using the floating configuration and stylesheet
-   Hyprpolkitagent
-   Hyprpaper

The wallpaper lifecycle should be:

1.  Hyprland session starts.
2.  Hyprpaper starts.
3.  Theme initialization runs after Hyprpaper is ready.
4.  The switcher applies the selected theme and wallpaper.

Starting Hyprpaper alone does not necessarily restore the last selected
theme. The switcher records the selected theme in `current-theme`; a
startup command can use that state to restore it. If login-time
restoration is desired, ensure the switcher runs after Hyprpaper is
ready. Do not rely on an arbitrary delay without checking the daemon
readiness/IPC behavior.

The intended `hyprpaper.conf` is minimal:

``` ini
# Wallpaper selection is managed by the central theme-switcher.
splash = false
```

This avoids a fixed wallpaper path competing with the central selector.

------------------------------------------------------------------------

## 11. Troubleshooting

### `theme-switch: command not found`

``` bash
ls -l ~/.local/bin/theme-switch
printf '%s\n' "$PATH"
```

If the symlink is missing:

``` bash
cd ~/dotfiles
stow --restow bin
```

### Theme is missing from the list

``` bash
find ~/dotfiles/themes -mindepth 1 -maxdepth 1 -type d
```

Check that the theme is a direct child of `themes/` and satisfies the
script's validation rules.

### An application does not change

1.  Confirm the source file exists and is non-empty.
2.  Confirm the switcher copied/generated the active file.
3.  Confirm the application config imports or points to the active file.
4.  Confirm the app is running and the reload command succeeded.
5.  Launch the app from a terminal to inspect errors.

``` bash
find ~/.config/theme-switcher/active -maxdepth 1 -type f -printf '%f\n'
cat ~/.config/theme-switcher/current-theme
```

### Waybar does not reload

``` bash
pgrep -a waybar
```

The switcher currently sends `SIGUSR2`. Confirm Waybar is running and
the stylesheet path used by Waybar references the intended active CSS.

### Dunst colors do not change

``` bash
command -v theme-apply-dunst
pgrep -a dunst
dunstctl reload
```

If the helper is missing, find the Stow package that provides it and
deploy that package.

### Wallpaper does not change

``` bash
pgrep -a hyprpaper
cat ~/.config/theme-switcher/current-wallpaper
```

Check that the recorded file exists:

``` bash
test -f "$(cat ~/.config/theme-switcher/current-wallpaper)" \
  && echo "Wallpaper exists" \
  || echo "Wallpaper path is invalid"
```

Inspect Hyprpaper IPC:

``` bash
hyprctl hyprpaper
```

If Hyprpaper is not running, start it and retry. If it is running but
the wallpaper command fails, check the installed Hyprpaper version and
its supported IPC syntax.

### Starship does not change

``` bash
printf '%s\n' "$STARSHIP_CONFIG"
rg -n '^[[:space:]]*palette[[:space:]]*=' \
  ~/.config/theme-switcher/active/starship.toml
rg -n 'STARSHIP_CONFIG|starship init|VIRTUAL_ENV_DISABLE_PROMPT' \
  ~/.config/zsh
```

`STARSHIP_CONFIG` should point to
`~/.config/theme-switcher/active/starship.toml`. Open a new shell if
necessary.

### Eza colors are unreadable

``` bash
cat ~/.config/eza/theme.yml
```

Adjust the source theme's Eza colors and reapply the theme. Check
contrast against the terminal background.

### Rofi wallpaper grid is broken

Check:

``` text
~/dotfiles/rofi/.config/rofi/wallpaper-grid.rasi
```

Confirm ImageMagick is installed and the exact command used by
`wallpaper-menu` exists. Check the thumbnail cache/output paths
referenced by that script.

------------------------------------------------------------------------

## 12. Useful inspection commands

``` bash
# List theme directory names
find ~/dotfiles/themes -mindepth 1 -maxdepth 1 -type d -printf '%f\n'

# List files in a theme
find ~/dotfiles/themes/catppuccin-mocha -maxdepth 2 -type f

# Read the main switcher
less ~/dotfiles/bin/.local/bin/theme-switch

# Find theme paths and app integration points
rg -n 'THEME_DIR|CONFIG_DIR|ACTIVE|wallpaper|starship|eza|dunst|waybar|rofi|kitty' \
  ~/dotfiles/bin/.local/bin/theme-switch

# Inspect runtime state
cat ~/.config/theme-switcher/current-theme
cat ~/.config/theme-switcher/current-wallpaper

# Inspect generated active files
find ~/.config/theme-switcher -maxdepth 2 -type f -printf '%p\n'

# Check Stow symlinks
ls -l ~/.local/bin/theme-switch ~/.local/bin/theme-menu \
      ~/.local/bin/wallpaper-menu

# Check repository changes
cd ~/dotfiles && git status --short
```

------------------------------------------------------------------------

## 13. Maintenance checklist

Before making changes:

-   [ ] Determine whether the file is a Stow source, theme source, or
    generated runtime file.
-   [ ] Inspect the current script before assuming its validation rules
    or dependencies.
-   [ ] Back up working scripts/configs before structural edits.
-   [ ] Keep one central theme collection.
-   [ ] Preserve filenames and formats expected by the switcher.
-   [ ] Update Starship palette mapping for a custom palette.
-   [ ] Check Eza contrast on both light and dark backgrounds.
-   [ ] Confirm wallpaper extensions are accepted.
-   [ ] Test every application after applying the theme.
-   [ ] Review `git status` and commit source files only.
-   [ ] Never commit generated runtime state from
    `~/.config/theme-switcher/`.

------------------------------------------------------------------------

## 14. Implementation details to verify when refactoring

These points depend on the current contents of the scripts and should be
checked before changing the implementation:

-   Exact wallpaper extensions accepted by `theme-switch`.
-   Exact required-file validation rules.
-   Eza fallback selection behavior.
-   Dunst include/import mechanism inside `theme-apply-dunst`.
-   ImageMagick command and thumbnail cache path inside
    `wallpaper-menu`.
-   Whether login-time restoration of the previous theme is wired into
    startup.
-   Hyprpaper IPC syntax supported by the installed version.

The scripts are the final authority. Update this document whenever those
behaviors change.

------------------------------------------------------------------------

## 15. Mental model

``` text
                  ~/dotfiles/themes/
                  (source theme assets)
                          |
                          v
               ~/.local/bin/theme-switch
                   (theme coordinator)
                          |
             +------------+-------------+
             |            |             |
             v            v             v
        Active app    Runtime state   Wallpaper
         configs      current-theme   via hyprctl
             |        current-wallpaper    |
             v                            v
      Kitty / Waybar /                  Hyprpaper
      Rofi / Dunst /
      Starship / Eza
```

-   **Git** versions the source.
-   **Stow** deploys configuration and scripts.
-   **The theme-switcher** applies a theme.
-   **Applications** render active configuration.
-   **Runtime state** records what is selected.

Following this model means adding a theme should mostly involve creating
a new directory under `~/dotfiles/themes/`, supplying its application
files and wallpapers, adding a Starship palette mapping, and testing the
result. It should not require restructuring the Stow packages for every
new color scheme.
