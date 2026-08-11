# Fate/stay night Realta Nua Ultimate Edition SDL2 for Linux and macOS

This project runs Fate/stay night **Realta Nua Ultimate Edition** (NOT the Steam Remaster) with the
[Kirikiri SDL2](https://github.com/krkrsdl2/krkrsdl2) runtime on Linux or macOS.

You must provide an existing Ultimate Edition installation. No Ultimate Edition game files are redistributed by this repository.
The platform installer adds a native runtime beside the existing Windows runtime;
it does not copy, modify, or delete the game's XP3 archives, executables,
configuration, or save data.

## Status

The game should work identical to the Windows binary, however videos are currently broken on both Linux and macOS.

This project is in its infancy. Please contribute by opening an issue or PR!

## Requirements

Both ports require an existing Ultimate Edition directory containing at least
`patch.xp3`, `data.xp3`, `etc.xp3`, `rule.xp3`, `config.ksc`, `Fate.exe` or
`Fate64.exe`, and the three `icon_*.ico` files.

### Linux

- x64 Linux
- Bash, coreutils, and ImageMagick (`magick`)
- A normal C++ runtime and desktop graphics/audio libraries

Runtime packages:

#### Arch Linux

```sh
sudo pacman -S --needed imagemagick gcc-libs libx11 libxext libxrandr \
  libxcursor libxi libxfixes libxrender wayland libxkbcommon libdecor \
  mesa libpulse alsa-lib libjack2 fontconfig freetype2
```

#### Debian / Ubuntu

```sh
sudo apt install imagemagick libstdc++6 libx11-6 libxext6 libxrandr2 \
  libxcursor1 libxi6 libxfixes3 libxrender1 libwayland-client0 \
  libxkbcommon0 libdecor-0-0 libgl1 libpulse0 libasound2 \
  libjack-jackd2-0 libfontconfig1 libfreetype6
```

On NixOS, `FateLinux.sh` detects `nix-ld` and constructs the required runtime
library path from `<nixpkgs>`. ImageMagick is still needed while installing.

### macOS

- macOS 10.14 or newer
- Intel or Apple Silicon
- The macOS built-in Bash, `install`, `sips`, and `iconutil`

The checked-in macOS runtime is universal and uses only macOS system libraries
and frameworks. No Homebrew packages or dynamic-library path overrides are
required.

## Install using Ultimate Edition as the base

```sh
git clone https://github.com/jtyuill/fsnrnue-sdl2.git
cd fsnrnue-sdl2
```

### Linux

```sh
./install.sh "/path/to/Fate stay night Realta Nua Ultimate Edition"
```

The Linux installer:

1. validates that the target looks like an Ultimate Edition installation;
2. copies only this repository's native runtime, plugins, launcher, and
   compatibility overlay into `linux/` under the game directory;
3. derives BMP window icons locally from **your** `icon_FATE.ico`,
   `icon_UBW.ico`, and `icon_HF.ico`; and
4. leaves every game archive and the existing save directory untouched.

Play from any working directory:

```sh
"/path/to/Fate stay night Realta Nua Ultimate Edition/FateLinux.sh"
```

Extra Kirikiri arguments are forwarded, for example:

```sh
./FateLinux.sh -forcelog
./FateLinux.sh -window
```

Re-run `install.sh` after pulling a newer version of this repository. Keep a
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
only its own launcher, `macos/` runtime files, and `FateMac.app`.

On both platforms, saves remain in `faterealtanua_savedata/` beside the game
archives, matching the Ultimate Edition `config.ksc` setting.


## Legal

- No game files of any kind are distributed by this repository.
- This is an unofficial project not endorsed by TYPE-MOON or Beast's Lair. 
- Scripts, documentation, and the compatibility overlay authored for this
  repository are MIT-licensed; see `LICENSE`.
- The native runtime and plugins are third-party components with their own
  terms and provenance; see `Port/THIRD-PARTY-NOTICES.md`.

