# Central Theme Management

A practical guide to the theme-switcher setup in this dotfiles repository.

## 1. What it is

The theme manager keeps the visual appearance of the desktop in one place. Instead of separately changing Kitty, Waybar, Rofi, Dunst and the wallpaper, you choose one theme and the `theme-switch` script updates the applications connected to it.

The design has three parts:

1. **Dotfiles** — application configuration and scripts, managed with GNU Stow.
2. **Theme library** — the colors, application theme files and wallpapers for each theme.
3. **Runtime state** — generated files in your home directory that record the active theme and wallpaper.

The theme library is the source of truth. Runtime files are generated from it; they are not the place to make permanent theme edits.

## 2. How the pieces fit together

```text
~/dotfiles/
├── bin/                         # theme-switch, wallpaper-menu, helpers
├── dunst/                       # Dunst configuration
├── hypr/                        # Hyprland and Hyprpaper configuration
├── kitty/                       # Kitty configuration
├── rofi/                        # Rofi configuration and wallpaper grid
├── waybar/                      # floating Waybar configuration
└── themes/                      # central theme library (not a Stow package)
    ├── catppuccin-mocha/
    ├── catppuccin-latte/
    ├── everforest/
    ├── gruvbox/
    ├── nord/
    └── tokyo-night/
```

Each theme directory contains the assets used by the manager:

| Asset | Used by |
|---|---|
| `kitty.conf` | Kitty colors |
| `waybar.css` | Waybar colors |
| `rofi.rasi` | Rofi theme colors |
| `dunst-colors.conf` | Dunst colors |
| `wallpapers/` | Wallpapers available for that theme |
| Eza theme file, when present | Eza directory colors |

Not every theme has to contain every optional asset. Keep the filenames and formats consistent with the existing themes.

### Runtime files (not Stow-managed)

The manager writes generated state under:

```text
~/.config/theme-switcher/
├── active/
│   └── kitty.conf
├── current-theme
└── current-wallpaper
```

- `active/` contains generated application configuration copied from the selected theme.
- `current-theme` stores the selected theme name.
- `current-wallpaper` stores the full path of the selected wallpaper.

The wallpaper picker also keeps generated thumbnails in:

```text
~/.cache/wallpaper-menu/<theme>/
```

These are disposable cache files, not source assets. The picker creates its per-theme cache as needed.

GTK configuration lives outside the Stow packages too:

```text
~/.config/gtk-3.0/
~/.config/gtk-4.0/
```

The theme manager changes GTK preferences through desktop settings tools. These directories may not exist on a fresh installation until GTK settings are first written.

**Important:** GNU Stow creates symlinks for the packages you stow. It does not automatically create or populate every generated runtime directory listed above.

## 3. Software connected to the theme manager

| Software | What changes with the theme |
|---|---|
| Kitty | Terminal colors |
| Waybar (floating config only) | Bar colors |
| Rofi | Launcher and menu colors |
| Dunst | Notification colors |
| Hyprpaper | Wallpaper selection and persistence |
| GTK / Nautilus | Dark or light GTK preference |
| Starship | Prompt palette |
| Eza | Directory colors, when a theme palette is available |

The manager only controls applications and settings wired into its scripts.

The current setup uses **Rofi**, not Walker, and **Dunst**, not SwayNC. Waybar uses `~/.config/waybar/floating/`; the docked/Omarchy configuration is not part of this setup.

## 4. What happens when you switch themes

The normal flow is:

1. You run `theme-switch <theme-name>`.
2. The script reads the requested theme's assets from `~/dotfiles/themes/`.
3. It updates generated active configuration and records the selected theme.
4. It updates connected application colors and reloads relevant components.
5. It selects a wallpaper from that theme's `wallpapers/` directory and applies it.
6. It saves wallpaper state so the selection can be restored later.
7. It updates the prompt palette and other supported integrations.

The exact commands are implemented in `bin/.local/bin/`. Treat those scripts as authoritative if this guide and the code ever disagree.

### Useful commands

```bash
# List available themes
theme-switch list

# Show the currently selected theme
theme-switch current

# Apply a theme
theme-switch nord

# Open the wallpaper picker for the current theme
wallpaper-menu
```

`theme-switch current` only reports the saved theme. It does **not** reapply it.

The wallpaper picker uses Rofi and generated thumbnails. The first opening after adding wallpapers may take longer; later openings reuse the cache.

## 5. Creating a new theme

The easiest and safest method is to copy an existing theme directory and edit the copy. This preserves the filenames and formats expected by the current scripts.

For example, start a theme named `my-theme`:

```bash
cd ~/dotfiles/themes
cp -r nord my-theme
```

Edit the copied files:

1. **`kitty.conf`** — terminal background, foreground, cursor and ANSI colors.
2. **`waybar.css`** — color variables used by the floating Waybar stylesheet.
3. **`rofi.rasi`** — Rofi background, foreground, selected and border colors.
4. **`dunst-colors.conf`** — notification colors.
5. **`wallpapers/`** — replace or add wallpapers for this theme.
6. **Eza palette** — update it if the copied theme has one and you want Eza colors to match.

Keep existing filenames and formatting. Do not rename assets unless you also update every script that refers to them.

### Add wallpapers

Put image files directly inside the new theme's `wallpapers/` directory. The current picker supports PNG, JPG/JPEG, WebP and BMP.

The picker generates thumbnails automatically. Its cache key uses the image filename, timestamp and size, so changed images get a new thumbnail.

### Test the new theme

```bash
theme-switch list
theme-switch my-theme
theme-switch current
```

Check Kitty, Waybar, Rofi, Dunst, GTK/Nautilus, the prompt and wallpaper. If the theme does not appear in the list, inspect the theme discovery logic in `theme-switch`.

When it works, commit the new theme directory to Git along with any intentional script changes.

## 6. Fresh Arch Linux installation workflow

A fresh installation needs more than Stow. Stow links files already in the repository; it does not install packages, create all runtime state, or generate every cache.

### Step 1 — Install the required software

Install the applications used by the dotfiles and theme scripts. The core set includes:

- GNU Stow
- Kitty
- Waybar
- Rofi
- Dunst
- Hyprpaper
- Hyprland
- Starship
- Eza
- ImageMagick (`magick`, used for wallpaper thumbnails)
- GTK settings tools (`gsettings` / `gsettings-desktop-schemas`)

Also install dependencies referenced by scripts, such as `notify-send` and `hyprctl`. Package names can vary; check a command with `command -v` if a script reports a missing dependency.

### Step 2 — Get the dotfiles

```bash
git clone https://github.com/jaary5/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Step 3 — Stow the configuration packages

The active Stow packages for this setup are:

```bash
stow bin dunst hypr kitty rofi waybar
```

Do not stow `themes/`. It is a central source directory read by the scripts, not a Stow package.

If Stow reports a conflict, inspect the existing target before deleting or replacing anything. Do not blindly use `--adopt`.

### Step 4 — Create runtime directories

Runtime state is outside the repository and should not be committed to Git:

```bash
mkdir -p ~/.config/theme-switcher/active
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0
```

The wallpaper thumbnail cache is created by `wallpaper-menu` when it runs:

```text
~/.cache/wallpaper-menu/
```

You normally do not need to create it manually.

### Step 5 — Initialize the theme state

Choose a theme that exists under `~/dotfiles/themes/` and apply it:

```bash
theme-switch catppuccin-mocha
```

This should create or update the current-theme state, generated active files and wallpaper state through the normal switcher workflow.

If the switcher expects `current-theme` or `current-wallpaper` to exist before the first run, inspect its initialization logic and create only the missing state in the format it expects. Do not guess a wallpaper path.

### Step 6 — Check wallpaper startup configuration

Hyprpaper uses:

```text
~/.config/hypr/hyprpaper.conf
```

The saved wallpaper and this configuration must agree so Hyprpaper can load the last selected wallpaper at login without a delayed theme-switch command. Confirm that the file points to a real image in the selected theme's wallpaper directory.

### Step 7 — Start the desktop and verify

After logging into Hyprland, check:

- Kitty opens with the selected theme.
- Floating Waybar uses the selected colors.
- Rofi and Dunst use the selected colors.
- Hyprpaper restores the saved wallpaper.
- GTK applications such as Nautilus follow the selected dark/light preference.
- Starship and Eza use their available theme palettes.
- `wallpaper-menu` opens and can change the wallpaper.

If one application is wrong, troubleshoot that integration rather than rebuilding the entire theme manager.

## 7. What belongs in Git and what does not

| Keep in `~/dotfiles` and commit | Keep in the home directory as generated state |
|---|---|
| Theme asset directories | `~/.config/theme-switcher/active/` |
| `theme-switch` and `wallpaper-menu` scripts | `current-theme` |
| Kitty, Waybar, Rofi and Dunst source configs | `current-wallpaper` |
| Hyprland / Hyprpaper source configuration | Wallpaper thumbnail cache |
| Rofi wallpaper-grid theme | Generated GTK settings, unless deliberately versioned |

A useful rule:

> **If you designed or edited it, it probably belongs in the dotfiles repository. If a script generated it while applying a theme, it probably belongs in runtime state.**

## 8. Troubleshooting checklist

- **A theme is missing:** check its directory name and the theme discovery logic in `theme-switch`.
- **An application did not change:** check that its asset exists and that the script reloads that application.
- **Wallpaper picker is slow the first time:** thumbnail generation is expected; later launches should use the cache.
- **Wallpaper does not survive reboot:** check `current-wallpaper` and `~/.config/hypr/hyprpaper.conf`.
- **A fresh install has missing paths:** Stow does not create generated runtime state; create the directories in Step 4 and run the theme switcher once.
- **A command is missing:** check it with `command -v <command>` and install the package that provides it.

---

*This guide describes the current Arch Linux + Hyprland setup. The scripts in `~/dotfiles/bin/.local/bin/` remain the source of truth for implementation details.*
