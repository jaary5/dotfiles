# Global Super+C / Super+V Copy & Paste


| Key       | Action |
| --------- | ------ |
| `Super+C`   | Copy   |
| `Super+V`   | Paste  |

The remapping is handled by **keyd**, which operates at the keyboard/input level. This makes the Super key combinations available across applications and display-server boundaries. keyd's configuration is stored under `/etc/keyd/`.

The setup currently uses an intermediate set of keys rather than directly mapping Super+C to Ctrl+C.


## How Super+C works

```text
Super+C
   │
   ▼
keyd
   │
   ▼
Ctrl+Insert
   │
   ▼
Kitty
   │
   ▼
copy_to_clipboard
   │
   ▼
Wayland system clipboard
```

The keyd configuration contains:

```ini
[meta]
c = C-insert
```

This means:

```text
Super+C → Ctrl+Insert
```

Kitty then interprets `Ctrl+Insert` as its copy command through:

```conf
map ctrl+insert copy_to_clipboard
```


## How Super+V works

```text
Super+V
   │
   ▼
keyd
   │
   ▼
Shift+Insert
   │
   ▼
Terminal/application paste
```

The keyd configuration contains:

```ini
[meta]
v = S-insert
```

Therefore:

```text
Super+V → Shift+Insert
```

---

## Configuration locations

### keyd

The configuration is stored in the dotfiles repository at:

```text
keyd/etc/keyd/default.conf
```

Stow creates the system-level link:

```text
/etc/keyd/default.conf
```

The actual keyd configuration is therefore version-controlled by the dotfiles repository while remaining at the location expected by keyd.

### Kitty

Kitty's configuration is:

```text
~/.config/kitty/kitty.conf
```

The following mapping is required:

```conf
map ctrl+insert copy_to_clipboard
```

---

## Installation / Restoration

Install keyd:

```bash
sudo pacman -S keyd
```

Enable it:

```bash
sudo systemctl enable --now keyd
```

Clone the dotfiles repository and enter it:

```bash
cd ~/dotfiles
```

Stow the keyd configuration:

```bash
sudo stow -t / keyd
```

Then verify the configuration:

```bash
sudo keyd check
```

Reload keyd if necessary:

```bash
sudo keyd reload
```

---

## Current key bindings

| Physical shortcut | keyd output    | Application behavior |
| ----------------- | -------------- | -------------------- |
| `Super+C`           | `Ctrl+Insert`    | Copy                 |
| `Super+V`           | `Shift+Insert`   | Paste                |

### Important

`Super+C` is **not** mapped directly to `Ctrl+C`.

This is intentional because `Ctrl+C` has a special meaning in terminals: it normally interrupts a running process.

Using:

```text
Super+C → Ctrl+Insert
```

avoids changing the normal terminal `Ctrl+C` behavior.

---

## Neovim

Neovim has not been specially configured for these shortcuts yet.

The normal Neovim clipboard behavior is therefore unchanged.

Current Neovim workflow:

```text
y → yank
p → paste
```

If Super+C / Super+V are later configured specifically for Neovim, documentation of  those mappings will be updated here.

---

## Troubleshooting

Check the keyd configuration:

```bash
sudo keyd check
```

Reload it:

```bash
sudo keyd reload
```

Check the service:

```bash
systemctl status keyd
```

View keyd logs:

```bash
sudo journalctl -u keyd
```

Check whether the Stow link exists:

```bash
ls -l /etc/keyd/default.conf
```

The file should point into the dotfiles repository.

---

## Files managed by this setup

```text
dotfiles/
├── keyd/
│   ├── keyd.md
│   └── etc/
│       └── keyd/
│           └── default.conf
│
└── kitty/
    └── .config/
        └── kitty/
            └── kitty.conf
```

The two pieces work together:

```text
keyd
 ↓
Super+C → Ctrl+Insert
Super+V → Shift+Insert

Kitty
 ↓
Ctrl+Insert  → copy_to_clipboard
Shift+Insert → paste
```

<br>

<table>
<tr>
<td valign="top">

**Super+C — Copy**

```text
┌──────────┐       ┌──────────┐       ┌──────────────┐
│  Super+C │ ────► │   keyd   │ ────► │ Ctrl+Insert  │
└──────────┘       └──────────┘       └──────┬───────┘
                                             │
                                             ▼
                                    Kitty copy command
```

</td>
<td valign="top">

**Super+V — Paste**

```text
┌──────────┐       ┌──────────┐       ┌──────────────┐
│  Super+V │ ────► │   keyd   │ ────► │ Shift+Insert │
└──────────┘       └──────────┘       └──────┬───────┘
                                             │
                                             ▼
                                         Kitty paste
```

</td>
</tr>
</table>

