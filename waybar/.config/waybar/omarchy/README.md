# Omarchy Waybar Profile

This profile replicates the looks, typography, and functionality of DHH's **Omarchy** status bar using pure Waybar (no Quickshell required).

---

## Module Functionality Breakdown

### 1. Left Modules (`modules-left`)

| Module | Description | Format / Visual | Interactions & Actions |
| :--- | :--- | :--- | :--- |
| **`custom/omarchy`** | Omarchy application launcher logo | `<span font='omarchy'>\ue900</span>` (custom Omarchy logo glyph) | • **Left-Click**: Launches `walker`<br>• **Right-Click**: Launches `kitty`<br>• **Tooltip**: Shows keybinds & shortcuts |
| **`hyprland/workspaces`** | Minimal workspace switcher | • Persistent workspaces: `1` to `5`<br>• Active workspace: `󱓻` (solid pill)<br>• Empty workspaces: Muted opacity (50%) | • **Click**: Switches / activates selected workspace |

---

### 2. Center / Mid Modules (`modules-center`)

| Module | Description | Format / Visual | Interactions & Actions |
| :--- | :--- | :--- | :--- |
| **`clock`** | Day and 24-hour time clock | `{:L%A %H:%M}` (e.g., `Tuesday 16:45`) | • **Right-Click**: Toggles calendar view<br>• **Scroll Up / Down**: Shifts calendar months<br>• **Alt-Format**: `{:L%d %B W%V %Y}` |
| **`custom/weather`** | Live condition-based weather | Weather Nerd Font glyph adjusted for live local sunrise/sunset (e.g. ``, ``, ``, ``, ``) | • **Interval**: 300s (cached for 10 min to avoid rate-limiting)<br>• **Left-Click**: Sends desktop notification with location, condition, temperature, and wind speed<br>• **Tooltip**: Condition, temperature, and wind summary |
| **`custom/update`** | Package update indicator | `` (Only displayed when package updates are available) | • **Interval**: 3600s (checks `pacman` / `yay`)<br>• **Left-Click**: Launches terminal upgrade (`kitty -e yay -Syu`)<br>• **Tooltip**: Number of pending package updates |
| **`custom/voxtype`** | Voice dictation indicator | • Idle: Hidden<br>• Recording: `󰍬`<br>• Transcribing: `󰔟` | • Detects active `voxtype` / dictation processes |
| **`custom/screenrecording-indicator`** | Screen recording status | `󰻂` in red `#a55555` (Only visible during active recording) | • **Interval**: 2s polling & signal `RTMIN+8`<br>• **Left-Click**: Gracefully stops recording (`gpu-screen-recorder` / `wf-recorder` / `wl-screenrec`), saves video, and notifies |
| **`idle_inhibitor`** | Sleep / idle lock inhibition | • Active: `󱫖` in red `#a55555`<br>• Inactive: Hidden (0px width) | • **Left-Click**: Toggles Wayland idle inhibitor to prevent system sleep/locking |
| **`custom/notification-silencing-indicator`** | Do Not Disturb (DND) status | `󰂛` in red `#a55555` (Only visible when notifications are silenced) | • **Interval**: 3s polling & signal `RTMIN+10`<br>• **Left-Click**: Toggles DND on/off via `swaync` / `mako` and notifies |

---

### 3. Right Modules (`modules-right`)

| Module | Description | Format / Visual | Interactions & Actions |
| :--- | :--- | :--- | :--- |
| **`group/tray-expander`** | Collapsible system tray drawer | Collapsed chevron `` (`custom/expand-icon`) that slides open into active tray icons | • **Hover / Click**: Smooth 600ms animated drawer transition reveals the system tray icons (`tray`) |
| **`hyprland/language`** | Active keyboard layout | `󰌌 {short}` (e.g., `󰌌 EN`) | • **Left-Click**: Cycles next keyboard layout (`hyprctl switchxkblayout current next`)<br>• **Tooltip**: Full layout name |
| **`bluetooth`** | Bluetooth manager status | • Connected: `󰂱`<br>• On / Idle: ``<br>• Off / Disabled: `󰂲`<br>• No controller: Hidden | • **Left-Click**: Opens `blueman-manager`<br>• **Right-Click**: Toggles Bluetooth power off<br>• **Tooltip**: Connected devices list & count |
| **`network`** | Network & WiFi indicator | • WiFi: Dynamic signal bars (`󰤯` to `󰤨`)<br>• Ethernet: `󰀂`<br>• Disconnected: `󰤮` | • **Left-Click**: Opens terminal network manager (`kitty -e nmtui`)<br>• **Tooltip**: SSID, frequency, IP address, download (`⇣`) & upload (`⇡`) transfer speeds |
| **`pulseaudio`** | Audio volume & mute indicator | • Default speaker: ``, ``, ``<br>• Headphones: ``<br>• Muted: `` | • **Left-Click**: Opens `pavucontrol`<br>• **Right-Click**: Toggles mute (`wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle`)<br>• **Scroll Up / Down**: Adjusts volume in 5% steps |
| **`backlight`** | Screen brightness indicator | Brightness glyph (`󰃞`, `󰃟`, `󰃠`) | • **Scroll Up / Down**: Adjusts brightness by ±5% via `brightnessctl`<br>• **Tooltip**: Exact brightness percentage |
| **`cpu`** | CPU activity monitor | Chip glyph `󰍛` | • **Interval**: 5s<br>• **Left-Click**: Opens system monitor `btop` in `kitty`<br>• **Tooltip**: Current CPU usage percentage |
| **`battery`** | Battery level & power rate | • Discharging: `{icon}` (`󰁺`–`󰁹`)<br>• Charging: `{icon}` (`󰢜`–`󰂅`)<br>• Plugged: ``<br>• Warning: 20% (yellow), Critical: 10% (red) | • **Left-Click**: Opens session/power menu (`wlogout`)<br>• **Right-Click**: Sends Omarchy battery notification showing percentage, charge/discharge wattage, capacity in Wh, and time remaining<br>• **Tooltip**: Real-time wattage (`W↓`/`W↑`) and remaining time |

---

## Directory Structure

```text
omarchy/
├── colors.css                      # Omarchy theme color variables
├── config.jsonc                    # Pure Waybar configuration
├── style.css                       # Omarchy minimalist stylesheet
├── README.md                       # This functionality reference
├── fonts/
│   └── omarchy.ttf                 # Authentic Omarchy logo font glyph
└── scripts/
    ├── battery-status.sh           # Formats & sends detailed battery notification
    ├── check-updates.sh            # Lightweight package update checker
    ├── notification-silencing.sh   # SwayNC DND detector & toggle
    ├── screen-recording.sh         # Screen recorder detector & toggle
    ├── voxtype.sh                  # Dictation status monitor
    └── weather.py                  # Sunrise/sunset-aware wttr.in weather fetcher
```

---

## Quick Launch & Autostart

### Manual Run:
```bash
waybar -c ~/.config/waybar/omarchy/config.jsonc -s ~/.config/waybar/omarchy/style.css
```

### Autostart in Hyprland (`hyprland.lua`):
```lua
hl.exec_cmd("waybar -c ~/.config/waybar/omarchy/config.jsonc -s ~/.config/waybar/omarchy/style.css")
```
