# Fate/stay night Realta Nua Ultimate Edition SDL2 for Linux and macOS

This project runs Fate/stay night **Realta Nua Ultimate Edition** (NOT the Steam Remaster) with the
[Kirikiri SDL2](https://github.com/krkrsdl2/krkrsdl2) runtime on Linux or macOS.

You must provide an existing Ultimate Edition installation. No Ultimate Edition game files are redistributed by this repository.
The platform installer adds a native runtime beside the existing Windows runtime;
it does not copy, modify, or delete the game's XP3 archives, executables,
configuration, or save data.

The game should work identical to the Windows binary, however videos are currently broken on both Linux and macOS.

The installers leave existing game data and saves untouched. Running the game updates its configuration and saves normally, so keep backups.

**This project is in its infancy**, and there will be some issues. Please contribute by opening an issue or PR!

**This project was built with Ultimate Edition `v1.1.4`. It seems `v1.1.5` is the latest version, but is harder to find on the internet.**

## Native window and menu

The game runs in a native resizable window with the
platform title bar and window controls. Because Kirikiri SDL2 does not provide
the Windows system-menu API used by Ultimate Edition, the compatibility overlay
enables the game's in-window menu instead. The **System**, **Display**,
**Language**, **Patch**, and **Help** menus remain available at the top of the
game window, with sizing adjusted for the current window scale.

![Fate/stay night Realta Nua Ultimate Edition running in a native window with the in-game menu bar](titlebar.png)

## Requirements

- An existing Ultimate Edition installation containing `patch.xp3`, `data.xp3`, `etc.xp3`, `rule.xp3`, `Fate.exe` or `Fate64.exe`, and the three `icon_*.ico` files.
- **Linux:** x86-64, glibc 2.38 or newer, and a `libstdc++.so.6` providing `GLIBCXX_3.4.32` (for example, Ubuntu 24.04 or Debian 13). A graphical desktop and system fonts are required.
- **Linux installation:** ImageMagick 7's `magick` command.
- **macOS:** macOS 26 or newer on Apple Silicon or Intel. The bundled `wutcwf.so` determines this minimum; the engine alone supports older versions.
- **Note: Intel Mac is currently untested but should work. Please open an issue if you are experiencing problems.**

## Install using Ultimate Edition as the base

```sh
git clone https://github.com/jtyuill/fsnrnue-sdl2.git
cd fsnrnue-sdl2
```

### Linux

```sh
./install-linux.sh "/path/to/Fate stay night Realta Nua Ultimate Edition"
```

The Linux installer:

1. validates that the target looks like an Ultimate Edition installation;
2. installs the native runtime, plugins, compatibility overlay, and generated
   route icons under `linux/`, with `FateLinux.sh` beside the game archives;
3. leaves every game archive and the existing save directory untouched.

All route icons are converted before replacing installed runtime files. Both
installers reject symlinked runtime destinations and directory/file collisions
rather than risk writing through them into game data.

Play from any working directory:

```sh
"/path/to/Fate stay night Realta Nua Ultimate Edition/FateLinux.sh"
```

Extra Kirikiri arguments are forwarded, for example:

```sh
./FateLinux.sh -forcelog
./FateLinux.sh -window
```

Re-run `install-linux.sh` after pulling a newer version of this repository. Keep a
backup of your game directory as normal, although the installer only overwrites
its own `FateLinux.sh` and `linux/` runtime files.

### macOS

Install into the standard Ultimate Edition location:

```sh
./install-mac.sh "$HOME/FSNRNUE114"
```

The macOS installer validates the same Ultimate Edition files, installs the
universal runtime under `macos/`, and creates two launch paths:

```sh
"$HOME/FSNRNUE114/FateMac.sh"
open "$HOME/FSNRNUE114/FateMac.app"
```

`FateMac.app` can also be opened directly in Finder. It is a small wrapper
around `FateMac.sh`; it contains no second runtime and no game data. Its
`FateMac.icns` is generated only from your 64×64 `icon_FATE.ico` frame during
installation. Extra Kirikiri arguments are forwarded by both launch formats:

```sh
"$HOME/FSNRNUE114/FateMac.sh" -forcelog -window
open "$HOME/FSNRNUE114/FateMac.app" --args -forcelog -window
```

Re-run `install-mac.sh` after updating the checkout. It idempotently replaces
only its own launcher, `macos/` runtime files, and generated files inside
`FateMac.app`; unrelated bundle contents are preserved.

On first launch, Ultimate Edition prompts for the save location. Canceling that
prompt keeps `faterealtanua_savedata/` beside the game archives. The resulting
per-install `config.ksc` is not part of a fresh Ultimate Edition installation
and is not required by either platform installer.


## Maintenance and checks

See [`Port/README.md`](Port/README.md) for rebuilding the Linux engine and
refreshing pinned macOS artifacts. Normal installation uses the checked-in
runtime and does not require a build or download.

Run the regression tests on a supported native platform with Python 3 and that
platform's installer prerequisites:

```sh
python3 -m unittest discover -s tests -v
bash -n install-linux.sh install-mac.sh FateLinux.sh FateMac.sh \
  Port/build-engine.sh Port/fetch-runtime-macos.sh
```

The tests generate their own installer fixtures and exercise the bundled TJS
engine without proprietary game data. They cover data preservation, repeated
installation, unsafe destinations, failed icon conversion, caption formatting,
and missing native plugins. They do not replace a graphical game smoke test.

## Legal

- No game files of any kind are distributed by this repository.
- This is an unofficial project not endorsed by TYPE-MOON or Beast's Lair. 
- Scripts, documentation, and the compatibility overlay authored for this
  repository are MIT-licensed; see `LICENSE`.
- The native runtime and plugins are third-party components with their own
  terms and provenance; see `Port/THIRD-PARTY-NOTICES.md`.

