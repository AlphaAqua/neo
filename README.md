# neo

![neo is AWESOME](assets/neo_is_awesome.gif)

**WARNING: neo may cause discomfort and seizures in people with photosensitive epilepsy. User discretion is advised.**

**neo** recreates the digital rain effect from "The Matrix". Streams of random
characters will endlessly scroll down your terminal screen.

Cool features:

- Simulates the effect convincingly:
  - Similar color palatte and uneven colors
  - Glitchy characters
  - Half-width katakana characters
- Can display a message similar to the title crawl in the movies
- Unicode support
- Supports 16/256 colors and 32-bit color
- Automatic detection of terminal color and Unicode support
- Handles terminal resizing
- Fully customizable colors and characters
- Many key controls and command-line options for customization

**neo** is best enjoyed with some good Scotch while listening to Aphex Twin and working on tech.

## Prerequisites/Dependencies

**neo** works with Linux and other UNIX-like operating systems such as macOS and FreeBSD. Native Windows is not supported, but it is possible to run **neo** using WSL.

The following packages are required to build and run **neo**:

- *build-essential*: make and g++ are used to build **neo**
- *libncurses-dev*: **neo** uses the ncursesw library to control the terminal
- *autoconf*: **neo** is built using autotools (NOT NEEDED if using an official release tarball)

Ensure that your C++ compiler supports C++11 and that your autoconf version is at least 2.61. g++ and clang++ both work for compilation.

If you want to see Unicode characters, you must use a font that supports the characters you are trying to display. Your OS must have the font, and your terminal must use it. Your locale should have Unicode support (usually UTF-8). Check your $LANG environment variable.

A fast terminal emulator such as Alacritty is highly recommended. **neo** can be a bit of a CPU hog, especially on large screens with slow terminal emulators.

## Automated Builds

Pre-built `.deb` packages are available for Debian/Ubuntu systems in multiple architectures:
- **amd64** - 64-bit x86 systems (standard PCs, servers)
- **armhf** - 32-bit ARM systems (Raspberry Pi, embedded devices)

The `.deb` package includes:
- The neo binary installed to `/usr/bin/neo`
- Man page accessible via `man neo`
- Systemd service that can be enabled to start at boot

### Download from GitHub Releases (Recommended)

Download the latest stable release for your architecture:

```Shell
# For amd64 (64-bit x86 - standard PCs)
wget https://github.com/AlphaAqua/neo/releases/latest/download/neo_<VERSION>_amd64.deb

# For armhf (32-bit ARM - Raspberry Pi, etc.)
wget https://github.com/AlphaAqua/neo/releases/latest/download/neo_<VERSION>_armhf.deb

# Or download a specific version (e.g., 1.0.0)
wget https://github.com/AlphaAqua/neo/releases/download/v1.0.0/neo_1.0.0_amd64.deb
wget https://github.com/AlphaAqua/neo/releases/download/v1.0.0/neo_1.0.0_armhf.deb
```

You can also browse all releases at: https://github.com/AlphaAqua/neo/releases

### Download from GitHub Actions Artifacts

**Note:** Artifacts require GitHub authentication and cannot be downloaded with `curl`/`wget`.

To download the latest build artifact from any branch:

**Option 1: Via GitHub Web UI**
1. Go to the [Actions](https://github.com/AlphaAqua/neo/actions) tab
2. Click on the latest successful workflow run
3. Scroll down to the "Artifacts" section
4. Download the artifact for your architecture:
   - `neo-deb-package-amd64` for 64-bit x86 systems
   - `neo-deb-package-armhf` for 32-bit ARM systems

**Option 2: Using GitHub CLI (requires authentication)**
```Shell
# Install GitHub CLI if not already installed: https://cli.github.com/
sudo apt install gh
gh auth login

# List recent workflow runs to get the run ID
gh run list --repo AlphaAqua/neo --limit 5

# Download artifact by run ID (replace RUN_ID with actual ID from list above)
# For amd64:
gh run download RUN_ID --repo AlphaAqua/neo --name neo-deb-package-amd64
# For armhf:
gh run download RUN_ID --repo AlphaAqua/neo --name neo-deb-package-armhf

# Or download from the latest successful run (amd64):
gh run download --repo AlphaAqua/neo $(gh run list --repo AlphaAqua/neo --workflow "Build and Package" --status success --limit 1 --json databaseId --jq '.[0].databaseId') --name neo-deb-package-amd64
```

### Installation

Once downloaded, install the package for your architecture:
```Shell
# For amd64:
sudo dpkg -i neo_<VERSION>_amd64.deb

# For armhf:
sudo dpkg -i neo_<VERSION>_armhf.deb
```

### Uninstallation

```Shell
sudo apt remove neo
```

## Building and Installing

**Make sure you have read the Prerequisites section and satisified all the requirements.** See [doc/INSTALL](doc/INSTALL) for more details.

### Option 1: Using an official release tarball

Click on the latest release on this GitHub page. Under the Assets pane, click on neo-\<VERSION>.tar.gz and save it somewhere. Ignore the other "Source code" files.

Open a terminal and navigate to wherever you saved the tarball. Run the following commands:

```Shell
# Only for macOS with Homebrew
export LDFLAGS="-L/opt/homebrew/opt/ncurses/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ncurses/include"
# End of macOS Homebrew commands

tar xzf neo-<VERSION>.tar.gz
cd neo-<VERSION>
./configure
make
sudo make install
```

### Option 2: Building from this repo

Clone this repository, open a terminal, and navigate to the repo directory.

Run the following commands:

```Shell
./autogen.sh
./configure
make -j3
sudo make install
```

## Uninstalling

To uninstall **neo**, run the following command from the directory where you built **neo**:

```Shell
sudo make uninstall
```

**neo** can also be manually uninstalled by simply deleting the installed *neo* executable and *neo.6* man page.

## Running

Once **neo** is installed, simply run:

```Shell
neo
```

**neo** has many options and key controls, arguably *too* many, and definitely too many to list here. Check the help message and manual for more info:

```Shell
neo -h
man neo
```

## Screenshots

![In Soviet Russia](assets/in_soviet_russia.png)

![Green Hexadecimal](assets/green_hex.png)

![Golden Greek](assets/golden_greek.png)

## FAQ/Troubleshooting

###
**Q:** **neo** displays garbage characters on the screen. How can this be fixed?

**A:** **neo** will attempt to use half-width katakana characters by default. You may not have a font installed that can display them correctly, or your terminal might not support Unicode well. Try "--charset=ascii" or changing your font. You may also need to use the "--colormode=0" option to disable color.

###
**Q:** Colors aren't working. How can this be fixed?

**A:** Make sure your terminal supports colors. Double check if you need to set the TERM environment variable to enable colors. You may want to try the "--colormode" option.

###
**Q:** How do I disable the blinking characters?

**A:** Use the --noglitch option.

###
**Q:** Can I make the text scroll faster or slower?

**A:** Yes, use the -S/--speed option. Also, the UP and DOWN keys change the speed. The --async option may be fun to try.

###
**Q:** How do I change the colors?

**A:** Use the -c/--color option (e.g. "-c red"). The number keys also change the color while running. Check out the "COLOR FILE" section in the manual if you want to customize **neo** with your own colors.

###
**Q:** How do I change the characters displayed?

**A:** Use the --charset and/or --chars option. You may also need to use the -F/--fullwidth option depending on the characters you selected.

###
**Q:** How do I display a message in the center of the screen?

**A:** Use the -m/--message option. Don't forget to use double quotes!

###
**Q:** **neo** just shows simple ASCII characters. How can I make it show Unicode characters?

**A:** **neo** detects if your locale supports Unicode. Typically, your $LANG environment variable should have "UTF" somewhere if it does (e.g. "en_US.UTF-8"). You can use commands such as localectl to change these settings. You can force **neo** to attempt to use Unicode by setting a custom charset (e.g. --charset=extended), but this still may not work due to other OS and terminal settings.

## Testing

**neo** includes automated system tests that verify the digital rain effect renders correctly to the terminal. Tests run automatically in CI/CD on every push.

To run tests locally:
```Shell
./tests/system_test.sh
```

Requirements: tmux must be installed for system tests.

## Creating a Release

To create a new release with pre-built packages:

1. **Ensure your changes are merged to the main branch**
   ```Shell
   git checkout main
   git pull
   ```

2. **Create and push a version tag** (e.g., v1.0.0)
   ```Shell
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **GitHub Actions will automatically:**
   - Build packages for both amd64 and armhf architectures
   - Run all system tests
   - Create a GitHub Release
   - Upload both .deb packages to the release

The release will be available at: https://github.com/AlphaAqua/neo/releases

## Bugs

File a GitHub issue. Crashes and build failures will be prioritized. Minor bugs, documentation errors, etc should hopefully get triaged and fixed... eventually.

## Contributing

See [doc/HACKING](doc/HACKING) for more implementation details and a list of things that could be improved.

Requests for enhancement (RFEs) are not likely to be considered or implemented unless they are:

- Within the scope of the original application
- Simple
- Likely to be used by more than one person

The original author deliberately avoided some features present in similar projects (e.g. custom fonts and Windows support) for simplicity.

Pull requests will be handled in a similar manner. Pull requests for bug fixes are more likely to be accepted than new features.

## Acknowledgments

- Chris Allegretta, the original author of CMatrix, and Abishek V Ashok, its current maintainer. CMatrix was a source of inspiration for **neo**.
- Thomas E. Dickey, because **neo** would have been a PITA to write without ncursesw
- Everyone involved in the production of "The Matrix" and the rest of the franchise

## License

**neo** is provided under the GNU GPL v3. See [doc/COPYING](doc/COPYING) for more details.

## Disclaimer

This project is not affiliated with "The Matrix", Warner Bros. Entertainment Inc., Village Roadshow Pictures, Silver Pictures, nor any of their parent companies, subsidiaries, partners, or affiliates.
