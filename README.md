# ElegooSlicer Linux Installer

Unofficial installer and updater for **ElegooSlicer on Linux**.

This project provides a simple installation script that automatically detects the Linux distribution, downloads the latest official ElegooSlicer AppImage directly from ELEGOO's GitHub releases, installs it for the current user, configures the application icon and launcher, and provides an uninstaller.

> [!IMPORTANT]
> **This is an unofficial community project.**
>
> This project is **not affiliated with, maintained by, sponsored by, or endorsed by ELEGOO**.
>
> ElegooSlicer, ELEGOO, their logos, and related trademarks belong to their respective owners.
>
> The installer does **not redistribute ElegooSlicer**. The application is downloaded directly from the official ELEGOO GitHub repository during installation.

## Features

The installer automatically:

* Detects the Linux distribution and package manager
* Checks the official ELEGOO GitHub repository for the latest ElegooSlicer release
* Downloads the official Linux AppImage directly from ELEGOO
* Installs ElegooSlicer in the current user's home directory
* Preserves the previous installation while an update is being performed
* Extracts the correct application icon from the official AppImage
* Converts the bundled `resources/images/ElegooSlicer.ico` to a Linux-compatible PNG
* Installs the icon into the user's local icon theme
* Creates an ElegooSlicer application launcher
* Creates an ElegooSlicer uninstaller launcher
* Updates the desktop application and icon caches
* Preserves user profiles and personal ElegooSlicer configuration when uninstalling

No system-wide ElegooSlicer installation is required.

## Distribution Compatibility

The installer contains support for several Linux distributions and package managers.

However, **implemented support does not mean that the distribution has been tested yet**.

| Distribution | Package Manager | Status       |
| ------------ | --------------- | ------------ |
| CachyOS      | pacman          | ✅ Tested     |
| Arch Linux   | pacman          | ⬜ Not tested |
| Manjaro      | pacman          | ⬜ Not tested |
| Debian       | apt             | ⬜ Not tested |
| Ubuntu       | apt             | ⬜ Not tested |
| Fedora       | dnf             | ⬜ Not tested |
| openSUSE     | zypper          | ⬜ Not tested |

### Currently tested

**CachyOS** is currently the only distribution on which the installer has been tested.

Testing and feedback from users of other distributions are welcome.

If you successfully test the installer on another supported distribution, please open an issue or pull request with the distribution name, version, desktop environment, and any relevant observations.

## Installation

Download the installer:

```bash
git clone https://github.com/YOUR-USERNAME/ElegooSlicer-Linux-Installer.git
cd ElegooSlicer-Linux-Installer
```

Make the installer executable:

```bash
chmod +x instalar-elegoo-slicer.sh
```

Run it:

```bash
./instalar-elegoo-slicer.sh
```

The installer provides a graphical interface using **Zenity** or **KDialog**, depending on what is available on the system.

Required dependencies can be installed automatically using the detected package manager.

## Updating ElegooSlicer

Run the installer again:

```bash
./instalar-elegoo-slicer.sh
```

The installer queries the official ELEGOO GitHub releases API and determines the latest available ElegooSlicer version.

If ElegooSlicer is already installed, the script treats the operation as an update.

The existing AppImage is temporarily preserved while the new version is installed.

## Official Downloads

ElegooSlicer itself is **not hosted or distributed by this repository**.

The installer retrieves releases directly from:

`elegooofficial/ElegooSlicer`

on GitHub.

This keeps the installer separate from the ElegooSlicer software distribution and ensures that the downloaded AppImage originates from ELEGOO's official release repository.

## Application Icon

One of the purposes of this installer is to provide proper desktop integration on Linux.

The official AppImage contains the application icon at:

```text
resources/images/ElegooSlicer.ico
```

During every installation or update, the installer:

1. Temporarily extracts the downloaded AppImage.
2. Locates `resources/images/ElegooSlicer.ico`.
3. Extracts the available icon representations.
4. Selects the highest-resolution valid image.
5. Converts and normalizes it to a transparent 256×256 PNG.
6. Installs it into the user's local Linux icon theme.
7. Updates the desktop launcher and icon cache.

The installed icon uses a stable name:

```text
elegooslicerico.png
```

This means the desktop launcher does not depend on the filename of a particular ElegooSlicer release.

## Installation Locations

ElegooSlicer is installed only for the current user.

### AppImage

```text
~/.local/opt/elegoo-slicer/ElegooSlicer.AppImage
```

### Application launcher

```text
~/.local/share/applications/elegoo-slicer.desktop
```

### Application icon

```text
~/.local/share/icons/hicolor/256x256/apps/elegooslicerico.png
```

### Uninstaller

```text
~/.local/bin/desinstalar-elegoo-slicer
```

### Uninstaller launcher

```text
~/.local/share/applications/desinstalar-elegoo-slicer.desktop
```

Temporary installation files are stored in the user's cache directory and removed after installation.

## Uninstalling

The installer creates an application called:

**Desinstalar ElegooSlicer**

It can be launched directly from the Linux application menu.

The uninstaller removes:

* ElegooSlicer AppImage
* ElegooSlicer desktop launcher
* Uninstaller launcher
* Installed application icon
* Uninstaller script

Personal ElegooSlicer profiles and configuration are intentionally preserved.

## Supported Package Managers

The installer currently recognizes:

```text
pacman
apt
dnf
zypper
```

These provide intended support for distributions including:

* CachyOS
* Arch Linux
* Manjaro
* Debian
* Ubuntu
* Fedora
* openSUSE

Again, only **CachyOS has currently been tested**.

## Desktop Environments

The installer supports graphical dialogs through:

* Zenity
* KDialog

It also refreshes the appropriate desktop databases and attempts to refresh KDE application caches when KDE tools are available.

The first tested environment is CachyOS.

Additional desktop environment testing is welcome.

## Safety

The installer is designed to minimize changes to the system.

ElegooSlicer itself is installed inside the user's home directory.

Before replacing an existing ElegooSlicer AppImage during an update, the current AppImage is temporarily backed up.

If installation fails during the replacement process, the installer attempts to restore the previous AppImage.

The installer may request `sudo` access only when a required system package needs to be installed through the distribution's package manager.

## Reporting Problems

When reporting an installation problem, please include:

* Linux distribution
* Distribution version
* Desktop environment
* Package manager
* ElegooSlicer version
* Installer output or error message

Please do not report issues with this installer to ELEGOO unless the issue is specifically related to ElegooSlicer itself.

Problems caused by this installation script should be reported to this repository.

## Contributions

Contributions are welcome.

Useful contributions include:

* Testing additional Linux distributions
* Testing different desktop environments
* Improving distribution detection
* Improving desktop integration
* Fixing installation or update problems
* Improving documentation

If you test an currently untested distribution successfully, please open an issue or pull request so its status can be updated in the compatibility table.

## License

The **ElegooSlicer Linux Installer** scripts and documentation in this repository are released under the **MIT License**.

This license applies only to the code and documentation created for this installer.

It does **not** apply to ElegooSlicer, ELEGOO trademarks, logos, application assets, or other software and intellectual property owned by ELEGOO or other parties.

## Disclaimer

This software is provided without warranty.

Use it at your own risk.

This project is an independent community utility intended to simplify the installation and desktop integration of the official ElegooSlicer AppImage on Linux.

**ELEGOO is not responsible for this installer or for issues caused by its use.**
