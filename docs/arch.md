# Management with `yay`

` ` = worth remembering for routine use.

##  Option Flags

- `S` = [synchronize]  repository package operations, such as installing or upgrading.
- `s` = [search] modifier, as in `-Ss` for searching repositories.
- `i` = [information], as in `-Qi` for detailed information about an installed package.
- `Q` = [query] the local installed-package database.
- `l` = [list], as in `-Sl` for listing packages in enabled official repositories.

**Important:** Uppercase and lowercase letters matter. `-S` and `-s` do different jobs.


##  Search and install

| Command | What it does |
|---|---|
| `yay package` | Search for matching packages interactively; choose a result to install if prompted. |
| `yay -Ss package` | Search official repositories and the AUR for matching packages. |
| `yay -G package` | Download an AUR package's build files without installing it. Use this to inspect its `PKGBUILD`. |

**Note:** `yay package` is an interactive search-and-install workflow. Check the package name and repository prefix (`extra/`, `core/`, `multilib/`, or `aur/`) before choosing.

##  Check installed packages

| Command | What it does |
|---|---|
| `yay -Q package` | Check if a package is installed with version. |
| `yay -Qs package` | Check if a package is installed with version + One line info |
| `yay -Qi package` | Show detailed information about an installed package, including version, dependencies, install date, and install reason. |


##  Upgrade the system

| Command | What it does |
|---|---|
| `yay -Syu` | Refresh repository databases as needed and perform a full system upgrade, including applicable AUR package updates. |

Use `yay -Syu` for routine full system upgrades.

Arch Linux does not support partial upgrades, so avoid using `yay -Sy package` to install a package without upgrading the rest of the system.

##  Remove packages

| Command | What it does |
|---|---|
| `yay -R package` | Remove the package, leaving dependencies behind. |
| `yay -Rs package` | Remove the package and dependencies that are no longer required. |
| `yay -Rns package` | Remove the package, unneeded dependencies, and package-managed backup configuration files where applicable. |

For ordinary removal, `-Rns` is often a convenient choice. Read the proposed removal list before confirming.

**Note:** This does not delete every user configuration file in your home directory.




##  For unfamiliar AUR packages:

```bash
yay -G package
cd package
less PKGBUILD
```

Review the build instructions before building. AUR build files are community-maintained scripts, so only build them when you understand and trust what they do.
