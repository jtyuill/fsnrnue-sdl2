# Fate/stay night Realta Nua Ultimate Edition — native Linux and macOS

Run **Fate/stay night Realta Nua Ultimate Edition** with a native
[Kirikiri SDL2](https://github.com/krkrsdl2/krkrsdl2) runtime on Linux or
macOS. No Wine and no proprietary game data in this repository.

You must provide your own legally obtained Ultimate Edition installation. The
platform installer adds a native runtime beside the existing Windows runtime;
it does not copy, modify, or delete the game's XP3 archives, executables,
configuration, or save data.

## Status

The Linux port is tested with Ultimate Edition 1.1.4 on x86-64 Linux. Its
exercised paths include:

- title, configuration, route, patch, and nested menus
- Fate/UBW/HF route-specific window icons
- story rendering, mouse input, TCWF voice decoding, Ogg audio, and WebP images
- portable saves and save thumbnails across a clean relaunch
- optional patch archive selection and high-resolution menu scaling

The macOS port is tested with Ultimate Edition 1.1.4 on Apple Silicon macOS.
Both the terminal launcher and Finder application reach the game flow, accept
input, load all five required native plugins, and use the existing portable
save directory. The macOS engine and plugins contain both `arm64` and
`x86_64` slices; Intel is verified in the artifacts but has not been exercised
on Intel hardware. macOS uses a static Finder/Dock icon derived during
installation instead of Linux's dynamic route-specific window icons.

Kirikiri SDL2 does not implement Kirikiri's Windows `VideoOverlay` backend.
Movie playback is therefore skipped; story, voice, music, images, menus, and
saves continue to work.

## Requirements

Both ports require an existing Ultimate Edition directory containing at least
`patch.xp3`, `data.xp3`, `etc.xp3`, `rule.xp3`, `config.ksc`, `Fate.exe` or
`Fate64.exe`, and the three `icon_*.ico` files.

### Linux

- x86-64 Linux
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

## Runtime provenance and refresh

### Rebuild the Linux engine

A prebuilt x86-64 Linux runtime is checked in for direct installation. To
rebuild it from source instead:

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

### Refresh the macOS runtime

The engine and four plugins are official universal release artifacts.
`wutcwf.so` is a universal rebuild from its exact release source ref with the
local import-stub fix recorded in `Port/THIRD-PARTY-NOTICES.md`. Fetch and
verify the pinned archives with:

```sh
./Port/fetch-runtime-macos.sh
./install-mac.sh "$HOME/FSNRNUE114"
```

The fetcher downloads into `.build/macos-runtime-downloads`, verifies every
official archive and extracted binary by SHA-256, preserves only the
hash-verified `wutcwf.so` rebuild, requires both `x86_64` and `arm64` slices,
and only then replaces `Port/runtime-macos/`. A changed upstream `latest`
artifact is rejected instead of being accepted as an implicit update.

Build output, downloaded archives, and cloned sources stay under `.build/`,
which is gitignored.

## Repository layout

```text
FateLinux.sh                       relocatable Linux game launcher
FateMac.sh                         relocatable macOS game launcher
install.sh                         in-place Linux installer
install-mac.sh                     in-place macOS and Finder-app installer
Port/settings.tjs                  shared Linux/macOS compatibility overlay
Port/runtime/krkrsdl2              native x86-64 Linux engine
Port/runtime/plugin/*.so           required Linux Kirikiri plugins
Port/runtime-macos/krkrsdl2        official universal macOS engine
Port/runtime-macos/plugin/*.so     four official plugins plus rebuilt TCWF
Port/build-engine.sh               reproducible Linux engine build
Port/fetch-runtime-macos.sh        verified official macOS artifact fetcher
Port/patches/                       local native engine/plugin changes
Port/THIRD-PARTY-NOTICES.md        upstream provenance
```

Generated `linux/icon_*.bmp` and
`FateMac.app/Contents/Resources/FateMac.icns` files remain only in your game
directory because they are derived from proprietary Ultimate Edition assets.

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
