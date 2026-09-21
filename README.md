ElegooSlicer Linux Installer

Unofficial installer, launcher, and automatic update checker for ElegooSlicer on Linux.

This project provides a simple way to install and keep ElegooSlicer updated on Linux using the official AppImage published by ELEGOO.

The installer automatically detects the Linux distribution, downloads the latest official ElegooSlicer AppImage directly from ELEGOO's GitHub releases, installs it for the current user, configures desktop integration, and provides automatic update checking and uninstall functionality.

After installation, ElegooSlicer can be launched normally from the Linux application menu.

Before starting the application, the launcher performs a quick version check:

If the installed version is already the latest version, ElegooSlicer opens normally without displaying any dialog.

If a newer version is available, the launcher shows the installed and available versions and asks whether you want to update.

If you choose not to update, the currently installed version opens normally.

If the internet connection is unavailable or GitHub cannot be reached, the installed ElegooSlicer opens normally.

[!IMPORTANT]
This is an unofficial community project.

This project is not affiliated with, maintained by, sponsored by, or endorsed by ELEGOO.

ElegooSlicer, ELEGOO, their logos, and related trademarks belong to their respective owners.

The installer does not redistribute ElegooSlicer. The application is downloaded directly from the official ELEGOO GitHub repository during installation.

Features

The installer automatically:

Detects the Linux distribution and package manager

Checks the official ELEGOO GitHub repository for the latest ElegooSlicer release

Downloads the official Linux AppImage directly from ELEGOO

Installs ElegooSlicer in the current user's home directory

Records the installed ElegooSlicer version

Checks for new ElegooSlicer releases when the application is launched

Opens ElegooSlicer silently when no update is available

Offers an update when a newer release is detected

Allows the currently installed version to be opened without updating

Continues opening ElegooSlicer normally if the update check fails

Provides a separate launcher for manual updates and reinstallation

Allows the currently installed version to be reinstalled

Preserves the previous AppImage while an update is being performed

Extracts the correct application icon from the official AppImage

Converts the bundled resources/images/ElegooSlicer.ico to a Linux-compatible PNG

Installs the icon into the user's local icon theme

Creates an ElegooSlicer application launcher

Creates an ElegooSlicer update launcher

Creates an ElegooSlicer uninstaller launcher

Updates the desktop application and icon caches

Preserves user profiles and personal ElegooSlicer configuration when uninstalling

No system-wide ElegooSlicer installation is required.

Distribution Compatibility

The installer contains support for several Linux distributions and package managers.

However, implemented support does not mean that the distribution has been tested yet.

Distribution

Package Manager

Status

CachyOS

pacman

✅ Tested

Arch Linux

pacman

⬜ Not tested

Manjaro

pacman

⬜ Not tested

Debian

apt

⬜ Not tested

Ubuntu

apt

⬜ Not tested

Fedora

dnf

⬜ Not tested

openSUSE

zypper

⬜ Not tested

Currently tested

CachyOS is currently the only distribution on which the installer has been tested.

Testing and feedback from users of other distributions are welcome.

If you successfully test the installer on another supported distribution, please open an issue or pull request with the distribution name, version, desktop environment, and any relevant observations.

Installation

Quick installation

Install ElegooSlicer with a single command:

rm -rf ~/.cache/elegoo-slicer-installer && curl -fsSL https://raw.githubusercontent.com/eltonnikecasa/ElegooSlicer-Linux-Installer/main/instalar-elegoo-slicer.sh -o /tmp/instalar-elegoo-slicer.sh && chmod +x /tmp/instalar-elegoo-slicer.sh && /tmp/instalar-elegoo-slicer.sh

This clears the installer's local cache, downloads the latest installer directly from this repository, makes it executable, and starts the installation.

Step-by-step installation

If you prefer to download and run the installer manually:

Clone this repository:

git clone https://github.com/eltonnikecasa/ElegooSlicer-Linux-Installer.git
cd ElegooSlicer-Linux-Installer

Make the installer executable:

chmod +x instalar-elegoo-slicer.sh

Run it:

./instalar-elegoo-slicer.sh

The installer checks the official ELEGOO GitHub releases and determines the latest available ElegooSlicer version.

If ElegooSlicer is not currently installed, the installer displays the version that will be installed and asks for confirmation.

The installer provides a graphical interface using Zenity or KDialog, depending on what is available on the system.

Required dependencies can be installed automatically using the detected package manager.

Automatic Update Check

After installation, the normal ElegooSlicer application launcher performs a lightweight update check before starting ElegooSlicer.

Internally, the launcher uses:

elegoo-slicer --launch

The launcher checks the latest release published in the official ELEGOO GitHub repository.

Already up to date

If the installed version matches the latest available version, no update dialog is displayed.

ElegooSlicer simply opens normally.

This means the automatic version check does not add unnecessary confirmation dialogs during normal use.

New version available

If a newer ElegooSlicer release is detected, a dialog displays:

Installed version

Latest available version

The user can choose:

Update — starts the update process and installs the latest official AppImage.

Not now — skips the update and opens the currently installed version.

Updating is never mandatory.

Offline or GitHub unavailable

The automatic version check is designed not to prevent ElegooSlicer from being used.

If:

The computer is offline

GitHub cannot be reached

The GitHub API does not respond

The version check times out

Another network-related error occurs

the update check is silently skipped and the currently installed ElegooSlicer version opens normally.

An internet connection is therefore not required to launch an already installed ElegooSlicer.

Manual Updates

The installer creates a separate application launcher called:

Update ElegooSlicer

This launcher can be opened directly from the Linux application menu.

It can also be started from the terminal:

elegoo-slicer --update

The update interface checks both:

The currently installed version

The latest version available from ELEGOO

Newer version available

If a newer version exists, the installer displays both versions and asks whether ElegooSlicer should be updated.

For example:

Installed version: 2.x.x
Available version: 2.y.y

Do you want to update ElegooSlicer?

Already running the latest version

If the installed version and latest available version are identical, the installer reports that the latest version is already installed and offers to reinstall it.

For example:

Installed version: 2.x.x
Available version: 2.x.x

You already have the latest version.

Do you want to reinstall this version?

This can be useful if the AppImage or desktop integration needs to be repaired.

Updating Using the Repository Script

The original repository script can also be run again manually:

cd ElegooSlicer-Linux-Installer
./instalar-elegoo-slicer.sh

The script queries the official ELEGOO GitHub releases API and determines the latest available ElegooSlicer version.

Depending on the current installation state, it will offer to:

Install ElegooSlicer

Update ElegooSlicer

Reinstall the current ElegooSlicer version

The existing AppImage is temporarily preserved while the new version is installed.

Official ElegooSlicer Downloads

ElegooSlicer itself is not hosted or distributed by this repository.

The installer retrieves releases directly from the official ELEGOO repository:

https://github.com/elegooofficial/ElegooSlicer

This keeps the installer separate from the ElegooSlicer software distribution and ensures that the downloaded AppImage originates from ELEGOO's official GitHub releases.

Application Icon

One of the purposes of this installer is to provide proper desktop integration on Linux.

The official AppImage contains the application icon at:

resources/images/ElegooSlicer.ico

During every installation, update, or reinstallation, the installer:

Temporarily extracts the downloaded AppImage.

Locates resources/images/ElegooSlicer.ico.

Extracts the available icon representations.

Selects the highest-resolution valid image.

Converts and normalizes it to a transparent 256×256 PNG.

Installs it into the user's local Linux icon theme.

Updates the desktop launchers and icon cache.

The installed icon uses a stable name:

elegooslicerico.png

This means the desktop launcher does not depend on the filename of a particular ElegooSlicer release.

Installation Locations

ElegooSlicer and the installer components are installed only for the current user.

AppImage

~/.local/opt/elegoo-slicer/ElegooSlicer.AppImage

Installed version record

~/.local/opt/elegoo-slicer/VERSION

This file records the installed ElegooSlicer version.

It allows the launcher to compare the installed version with the latest release available from ELEGOO.

ElegooSlicer launcher script

~/.local/bin/elegoo-slicer

The installed launcher is responsible for:

Starting ElegooSlicer

Checking for updates

Starting the update/reinstallation workflow

Starting the uninstaller

Application launcher

~/.local/share/applications/elegoo-slicer.desktop

Update launcher

~/.local/share/applications/atualizar-elegoo-slicer.desktop

Uninstaller launcher

~/.local/share/applications/desinstalar-elegoo-slicer.desktop

Application icon

~/.local/share/icons/hicolor/256x256/apps/elegooslicerico.png

Temporary files

Temporary installation files are stored under:

${XDG_CACHE_HOME:-~/.cache}/elegoo-slicer-installer

Temporary extraction and download files are removed after a successful installation.

Command-Line Modes

The installed launcher supports several operating modes.

Launch ElegooSlicer

elegoo-slicer --launch

Performs a lightweight update check and then starts ElegooSlicer.

If no update is available, no dialog is shown.

Update or reinstall

elegoo-slicer --update

Checks the installed and available versions.

If a newer version exists, an update is offered.

If both versions are identical, reinstallation is offered.

Uninstall

elegoo-slicer --uninstall

Starts the ElegooSlicer uninstall process.

Opening 3D Model Files

The ElegooSlicer desktop launcher registers supported model file types.

These include formats such as:

STL

3MF

OBJ

AMF

When a supported model file is opened with ElegooSlicer, the launcher performs the normal update check and then passes the selected file to the ElegooSlicer AppImage.

If no update is available, this happens transparently.

Uninstalling

The installer creates an application called:

Uninstall ElegooSlicer

It can be launched directly from the Linux application menu.

The same process can be started from the terminal:

elegoo-slicer --uninstall

Before removing ElegooSlicer, the user is asked for confirmation.

The uninstaller removes:

ElegooSlicer AppImage

Installed version record

ElegooSlicer desktop launcher

Update launcher

Uninstaller launcher

Installed application icon

Installed ElegooSlicer launcher script

Personal ElegooSlicer profiles and configuration are intentionally preserved.

This makes it possible to reinstall ElegooSlicer later without intentionally deleting the user's existing slicer profiles.

Supported Package Managers

The installer currently recognizes:

pacman
apt
dnf
zypper

These provide intended support for distributions including:

CachyOS

Arch Linux

Manjaro

Debian

Ubuntu

Fedora

openSUSE

Note: Only CachyOS has currently been tested.

Graphical Interface

The installer uses one of the following graphical dialog systems:

Zenity

KDialog

If neither is available during installation or maintenance, the installer attempts to install Zenity using the detected package manager.

A command-line fallback is also available when a graphical dialog system cannot be used.

The normal ElegooSlicer launcher does not attempt to install graphical dependencies every time the slicer is opened.

The installer also refreshes the appropriate desktop application databases and KDE application caches when the relevant tools are available.

Required and Optional Dependencies

Depending on the Linux distribution and existing system configuration, the installer may use:

curl

ImageMagick

Zenity

KDialog

FUSE compatibility libraries

curl is used to query GitHub and download the official AppImage.

ImageMagick is used to extract and convert the icon bundled with ElegooSlicer.

Zenity or KDialog provides the graphical dialogs.

FUSE compatibility libraries may be installed when required for AppImage support.

Safety and Updates

The installer is designed to minimize changes to the operating system.

ElegooSlicer itself is installed entirely inside the current user's home directory.

Before replacing an existing ElegooSlicer AppImage during an update or reinstallation, the current AppImage is temporarily backed up.

If installation fails during the replacement process, the installer attempts to restore the previous AppImage.

The automatic update check does not automatically install a new version.

A new ElegooSlicer release is installed only after user confirmation.

If the automatic version check cannot reach GitHub, the installed application remains usable.

The installer may request sudo access only when a required system dependency needs to be installed through the Linux distribution's package manager.

Privacy and Network Access

The launcher contacts GitHub to check whether a newer ElegooSlicer release is available.

The request is made to the official GitHub releases API for the ELEGOO ElegooSlicer repository.

No personal ElegooSlicer profiles, models, projects, printer settings, or other user files are uploaded by this installer.

The installer downloads the ElegooSlicer AppImage only after an installation, update, or reinstallation has been confirmed.

Reporting Problems

If you encounter a problem with the installer, please open an issue in this repository:

https://github.com/eltonnikecasa/ElegooSlicer-Linux-Installer/issues

When reporting an installation problem, please include:

Linux distribution

Distribution version

Desktop environment

Package manager

ElegooSlicer version

Installer version or commit

Whether the problem occurred during installation, launch, update, reinstallation, or uninstall

Installer output or error message

Please do not report problems caused by this installer to ELEGOO.

Issues related specifically to the official ElegooSlicer application should be reported through the appropriate official ELEGOO channels.

Testing Other Distributions

Help testing other Linux distributions is welcome.

If you successfully install or update ElegooSlicer using this installer on a distribution currently marked as Not tested, please open an issue or pull request.

Please include:

Distribution

Distribution version

Desktop environment

Installer version/commit

ElegooSlicer version installed

Whether the initial installation succeeded

Whether automatic update checking worked

Whether manual updating worked

Whether the application launcher and icon worked correctly

Whether opening STL/3MF files worked correctly

Whether uninstalling worked correctly

Any dependencies or additional steps required

Once a distribution has been successfully verified, its status can be updated in the compatibility table.

Contributions

Contributions are welcome.

Useful contributions include:

Testing additional Linux distributions

Testing different desktop environments

Improving distribution detection

Improving desktop integration

Improving automatic update checking

Fixing installation or update problems

Testing AppImage compatibility

Improving documentation

Pull requests should clearly describe what was changed and which Linux distribution(s) were used for testing.

License

The ElegooSlicer Linux Installer scripts and documentation in this repository are released under the MIT License.

This license applies only to the code and documentation created for this installer.

It does not apply to ElegooSlicer, ELEGOO trademarks, logos, application assets, or other software and intellectual property owned by ELEGOO or other parties.

Disclaimer

This software is provided without warranty.

Use it at your own risk.

This project is an independent community utility intended to simplify the installation, updating, and desktop integration of the official ElegooSlicer AppImage on Linux.

ELEGOO is not responsible for this installer or for issues caused by its use.
