#!/bin/sh
set -eu

case $0 in
    /*) launcher=$0 ;;
    *) launcher=$PWD/$0 ;;
esac
game_dir=$(CDPATH= cd -- "$(dirname -- "$launcher")" && pwd -P)
runtime_dir="$game_dir/macos"
engine="$runtime_dir/krkrsdl2"

if [ ! -r "$game_dir/patch.xp3" ]; then
    printf '%s\n' "FateMac.sh must stay beside patch.xp3." >&2
    exit 1
fi
if [ ! -x "$engine" ]; then
    printf '%s\n' "Native runtime is missing or not executable: $engine" >&2
    exit 1
fi

export KRKRSDL2_PATH="$runtime_dir:$runtime_dir/plugin${KRKRSDL2_PATH:+:$KRKRSDL2_PATH}"

exec "$engine" -nosel "-basepath=$game_dir/" "$game_dir/patch.xp3" "$@"
