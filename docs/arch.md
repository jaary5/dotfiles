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

<table>
<thead><tr><th style="white-space: nowrap">Command</th><th>What it does</th></tr></thead>
<tbody>
<tr><td style="white-space: nowrap"><code>yay package</code></td><td>Search for matching packages interactively; choose a result to install if prompted.</td></tr>
<tr><td style="white-space: nowrap"><code>yay -Ss package</code></td><td>Search official repositories and the AUR for matching packages.</td></tr>
<tr><td style="white-space: nowrap"><code>yay -G package</code></td><td>Download an AUR package's build files without installing it. Use this to inspect its <code>PKGBUILD</code>.</td></tr>
</tbody>
</table>

**Note:** `yay package` is an interactive search-and-install workflow. Check the package name and repository prefix (`extra/`, `core/`, `multilib/`, or `aur/`) before choosing.

##  Check installed packages

<table>
<thead><tr><th style="white-space: nowrap">Command</th><th>What it does</th></tr></thead>
<tbody>
<tr><td style="white-space: nowrap"><code>yay -Q package</code></td><td>Check if a package is installed with version.</td></tr>
<tr><td style="white-space: nowrap"><code>yay -Qs package</code></td><td>Check if a package is installed with version + One line info.</td></tr>
<tr><td style="white-space: nowrap"><code>yay -Qi package</code></td><td>Show detailed information about an installed package, including version, dependencies, install date, and install reason.</td></tr>
</tbody>
</table>


##  Upgrade the system

<table>
<thead><tr><th style="white-space: nowrap">Command</th><th>What it does</th></tr></thead>
<tbody>
<tr><td style="white-space: nowrap"><code>yay -Syu</code></td><td>Refresh repository databases as needed and perform a full system upgrade, including applicable AUR package updates.</td></tr>
</tbody>
</table>

Use `yay -Syu` for routine full system upgrades.

Arch Linux does not support partial upgrades, so avoid using `yay -Sy package` to install a package without upgrading the rest of the system.

##  Remove packages

<table>
<thead><tr><th style="white-space: nowrap">Command</th><th>What it does</th></tr></thead>
<tbody>
<tr><td style="white-space: nowrap"><code>yay -R package</code></td><td>Remove the package, leaving dependencies behind.</td></tr>
<tr><td style="white-space: nowrap"><code>yay -Rs package</code></td><td>Remove the package and dependencies that are no longer required.</td></tr>
<tr><td style="white-space: nowrap"><code>yay -Rns package</code></td><td>Remove the package, unneeded dependencies, and package-managed backup configuration files where applicable.</td></tr>
</tbody>
</table>

For ordinary removal, `-Rns` is often a convenient choice. Read the proposed removal list before confirming.

**Note:** This does not delete every user configuration file in your home directory.




##  For unfamiliar AUR packages:

```bash
yay -G package
cd package
less PKGBUILD
```

Review the build instructions before building. AUR build files are community-maintained scripts, so only build them when you understand and trust what they do.
