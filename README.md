# Fate/stay night Realta Nua Ultimate Edition — native Linux

Run **Fate/stay night Realta Nua Ultimate Edition** with a native Linux
[Kirikiri SDL2](https://github.com/krkrsdl2/krkrsdl2) runtime. No Wine and no
proprietary game data in this repository.

You must provide your own legally obtained Ultimate Edition installation. The
installer adds a Linux runtime beside the existing Windows runtime; it does not
copy, modify, or delete the game's XP3 archives, executables, configuration, or
save data.

## Status

Tested with Ultimate Edition 1.1.4 on x86-64 Linux. The exercised paths include:

- title, configuration, route, patch, and nested menus
- Fate/UBW/HF route-specific window icons
- story rendering, mouse input, TCWF voice decoding, Ogg audio, and WebP images
- portable saves and save thumbnails across a clean relaunch
- optional patch archive selection and high-resolution menu scaling

Kirikiri SDL2 does not implement Kirikiri's Windows `VideoOverlay` backend.
Movie playback is therefore skipped; story, voice, music, images, menus, and
saves continue to work.

## Requirements

- An existing Ultimate Edition directory containing at least:
  `patch.xp3`, `data.xp3`, `etc.xp3`, `rule.xp3`, `config.ksc`,
  `Fate.exe` or `Fate64.exe`, and the three `icon_*.ico` files
- x86-64 Linux
- Bash, coreutils, and ImageMagick (`magick`)
- A normal C++ runtime and desktop graphics/audio libraries

Runtime packages:

### Arch Linux

```sh
sudo pacman -S --needed imagemagick gcc-libs libx11 libxext libxrandr \
  libxcursor libxi libxfixes libxrender wayland libxkbcommon libdecor \
  mesa libpulse alsa-lib libjack2 fontconfig freetype2
```

### Debian / Ubuntu

```sh
sudo apt install imagemagick libstdc++6 libx11-6 libxext6 libxrandr2 \
  libxcursor1 libxi6 libxfixes3 libxrender1 libwayland-client0 \
  libxkbcommon0 libdecor-0-0 libgl1 libpulse0 libasound2 \
  libjack-jackd2-0 libfontconfig1 libfreetype6
```

On NixOS, `FateLinux.sh` detects `nix-ld` and constructs the required runtime
library path from `<nixpkgs>`. ImageMagick is still needed while installing.

## Install using Ultimate Edition as the base

```sh
git clone https://github.com/jtyuill/fsnrue-sdl2.git
cd fsnrue-sdl2

./install.sh "/path/to/Fate stay night Realta Nua Ultimate Edition"
```

The installer:

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

Saves remain in `faterealtanua_savedata/` beside the game archives, matching the
Ultimate Edition `config.ksc` setting.

Re-run `install.sh` after pulling a newer version of this repository. Keep a
backup of your game directory as normal, although the installer only overwrites
its own `FateLinux.sh` and `linux/` runtime files.

## Rebuild the native engine

A prebuilt x86-64 runtime is checked in for direct installation. To rebuild it
from source instead:

```sh
./Port/build-engine.sh
./install.sh "/path/to/Ultimate Edition"
```

`build-engine.sh` clones Kirikiri SDL2 at pinned commit
`3f384a6869f6726929c777bdd0e0c871d5d5383d`, initializes its submodules,
applies `Port/patches/krkrsdl2-window-icon.patch`, builds with CMake/Ninja, and
replaces `Port/runtime/krkrsdl2`.

Build dependencies include Git, CMake, Ninja, pkg-config, NASM, GCC/Clang, X11,
XCB, Wayland protocols, libffi, libxkbcommon, libdecor, Mesa/OpenGL, PulseAudio,
ALSA, JACK, Fontconfig, and FreeType development headers. On NixOS, the exact
build environment used for the checked-in binary can be entered with:

```sh
nix-shell -p cmake ninja pkg-config nasm gcc libxcb libx11 libxext \
  libxrandr libxcursor libxi libxfixes libxrender libxscrnsaver \
  libxinerama libxxf86vm wayland wayland-scanner wayland-protocols \
  libffi libxkbcommon libdecor mesa libglvnd pulseaudio alsa-lib \
  libjack2 fontconfig freetype --run './Port/build-engine.sh'
```

Build output and cloned sources stay under `.build/`, which is gitignored.

## Repository layout

```text
FateLinux.sh                       relocatable game launcher
install.sh                         in-place Ultimate Edition installer
Port/settings.tjs                  Linux compatibility and UI overlay
Port/runtime/krkrsdl2              native x86-64 engine
Port/runtime/plugin/*.so           required native Kirikiri plugins
Port/build-engine.sh               reproducible engine build
Port/patches/                       local engine changes
Port/THIRD-PARTY-NOTICES.md        upstream provenance
```

Generated `linux/icon_*.bmp` files remain only in your game directory because
they are derived from proprietary Ultimate Edition assets.

## Legal

- Ultimate Edition, its patches, translations, images, icons, audio, video,
  scripts, and XP3 archives are not included. Supply a copy you are entitled to
  use.
- Scripts, documentation, and the compatibility overlay authored for this
  repository are MIT-licensed; see `LICENSE`.
- The native runtime and plugins are third-party components with their own
  terms and provenance; see `Port/THIRD-PARTY-NOTICES.md`.

This is an unofficial compatibility project and is not affiliated with
TYPE-MOON, Notes, Aniplex, or the Ultimate Edition patch authors.
