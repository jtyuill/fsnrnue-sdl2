#!/bin/sh
set -eu

case $0 in
    /*) launcher=$0 ;;
    *) launcher=$PWD/$0 ;;
esac
game_dir=$(CDPATH= cd -- "$(dirname -- "$launcher")" && pwd -P)
runtime_dir=$game_dir/linux
engine=$runtime_dir/krkrsdl2

if [ ! -r "$game_dir/patch.xp3" ]; then
    printf '%s\n' "FateLinux.sh must stay beside patch.xp3." >&2
    exit 1
fi
if [ ! -x "$engine" ]; then
    printf '%s\n' "Native runtime is missing or not executable: $engine" >&2
    exit 1
fi

export KRKRSDL2_PATH="$runtime_dir:$runtime_dir/plugin${KRKRSDL2_PATH:+:$KRKRSDL2_PATH}"

nix_ld_dir=/run/current-system/sw/share/nix-ld/lib
if [ -x "$nix_ld_dir/ld.so" ]; then
    if ! command -v nix >/dev/null 2>&1; then
        printf '%s\n' "NixOS detected, but 'nix' is unavailable on PATH." >&2
        exit 1
    fi

    if ! nix_libraries=$(nix eval --raw --impure --expr '
        with import <nixpkgs> {};
        lib.makeLibraryPath [
          stdenv.cc.cc.lib
          libx11 libxext libxrandr libxcursor libxi libxfixes libxrender
          wayland libxkbcommon libdecor mesa libglvnd libdrm
          libpulseaudio alsa-lib pipewire libjack2
          fontconfig freetype
        ]
    '); then
        printf '%s\n' "Unable to resolve the native runtime libraries from <nixpkgs>." >&2
        exit 1
    fi

    export NIX_LD="$nix_ld_dir/ld.so"
    export NIX_LD_LIBRARY_PATH="$nix_libraries:$nix_ld_dir${NIX_LD_LIBRARY_PATH:+:$NIX_LD_LIBRARY_PATH}"
    export LD_LIBRARY_PATH="$runtime_dir/plugin:$nix_libraries:$nix_ld_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
else
    export LD_LIBRARY_PATH="$runtime_dir/plugin${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

exec "$engine" -nosel "-basepath=$game_dir/" "$game_dir/patch.xp3" "$@"
