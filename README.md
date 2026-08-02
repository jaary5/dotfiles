# dotfiles

Arch config managed with **GNU Stow**

## Structure

```
dotfiles/
├── bash/          # Bash configuration
├── kitty/         # Kitty terminal
├── local-bin/     # Personal scripts
├── mpv/           # MPV configuration
└── README.md
```

Each directory is a **Stow package** that mirrors home directory

Example:

```
kitty/
└── .config/
    └── kitty/
        └── kitty.conf
```

becomes

```
~/.config/kitty
```

after running Stow.

<br><br>

# Initial setup

Install required packages:

```bash
sudo pacman -S git stow
```

Clone the repository:

```bash
git clone <SSH> 
cd ~/dotfiles
```

Create all symlinks:

```bash
stow */
```

<br><br>

# Adding a new configuration

Suppose I want to manage:

```
~/.config/btop
```

Create the package inside ~/dotfiles:

```bash
mkdir -p btop/.config
```

Move the configuration:

```bash
mv ~/.config/btop ~/dotfiles/btop/.config/
```

Create the symlink:

```bash
stow btop
```

Verify the symlink:

```bash
ls -l ~/.config | grep btop
```

Expected output:

```text
btop -> /home/<username>/dotfiles/btop/.config/btop
```

Commit:

```bash
git add .
git commit -m "Add btop configuration"
git push
```

<br><br>

# Adding a home directory file

Example:

```
~/.bashrc
```

Navigate to dotfiles:

```bash
cd ~/dotfiles
```

Create package:

```bash
mkdir bash
mv ~/.bashrc ~/dotfiles/bash/.bashrc
stow bash
```

<br><br>

# Adding scripts

Personal scripts belong in:

```
local-bin/
└── .local/
    └── bin/
```

Example:

```
~/.local/bin/toggle-audio
```

becomes

```
local-bin/.local/bin/toggle-audio
```

Then:

```bash
stow local-bin
```

<br><br>

# Updating configuration

Edit normally:

```bash
nvim ~/.config/kitty/kitty.conf
```

or

```bash
nvim ~/.bashrc
```

Since these are symlinks, changes are automatically made inside this repository.

Commit when finished:

```bash
git add .
git commit -m "Describe changes"
git push
```

<br><br>

# Useful commands

Create symlinks:

```bash
stow <package>
```

Create every symlink:

```bash
stow */
```

Remove a package:

```bash
stow -D <package>
```

Restow after moving files:

```bash
stow -R <package>
```

See symlinks:

```bash
ls -l ~/.config
```

Check where a symlink points:

```bash
readlink ~/.config/kitty
```