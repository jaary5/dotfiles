# Sound Debug

## Hardware

- **Motherboard:** MSI B450-A PRO MAX II
- **Audio Codec:** Realtek ALC897

## Problem

On a fresh Linux installation:

- Rear Line Out does not work correctly.
- Front headphone jack does not work correctly.

This issue persists across all Linux distributions.


## Solution

### 1. Install HDA Jack Retask

```bash
sudo pacman -S alsa-tools
```

### 2. Launch HDA Jack Retask

```bash
sudo hdajackretask      # Dont use sudo on hyprland
```

### 3. Select the codec

```
Realtek ALC897
```

### 4. Enable these options

- ☑ Set model = auto
- ☑ Advanced override

### 5. Configure the following pin overrides

#### Pink Mic, Front side (Pin ID: 0x19)

- ☑ Override
- Jack Detection: Not present
- Leave rest of the settings whatever it offers

#### Green Headphone, Front side (Pin ID: 0x1b)

- ☑ Override
- Jack Detection: Not present
- Leave rest of the settings whatever it offers

### 6. Verify against the screenshot

![HDA Jack Retask](hda-jack-retask.png)

### 7. Apply the changes

Click:

- **Apply now**
- **Install boot override**

### 8. Reboot

Restart the computer for the changes to take effect.