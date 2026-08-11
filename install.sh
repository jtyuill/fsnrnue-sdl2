#!/usr/bin/env bash
# Install the native Linux runtime into an existing Fate/stay night Realta Nua
# Ultimate Edition directory. No game data is copied into this repository.
set -euo pipefail

repo_dir=$(cd "$(dirname "$0")" && pwd)
port_dir="$repo_dir/Port"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log() { printf '==> %s\n' "$*"; }

[[ $# -eq 1 ]] || die "usage: $0 /path/to/FSNRNUE"
[[ -d "$1" ]] || die "game directory does not exist: $1"
game_dir=$(cd "$1" && pwd -P)

for command_name in install magick; do
    command -v "$command_name" >/dev/null 2>&1 || die "missing required command: $command_name"
done

for required in patch.xp3 data.xp3 etc.xp3 rule.xp3 \
    icon_FATE.ico icon_UBW.ico icon_HF.ico; do
    [[ -f "$game_dir/$required" ]] || die "Ultimate Edition base is missing: $required"
done
if [[ ! -f "$game_dir/Fate.exe" && ! -f "$game_dir/Fate64.exe" ]]; then
    die "Ultimate Edition base is missing Fate.exe/Fate64.exe"
fi

for required in FateLinux.sh Port/settings.tjs Port/runtime/krkrsdl2 \
    Port/runtime/plugin/extrans.so Port/runtime/plugin/fstat.so \
    Port/runtime/plugin/krglhwebp.so Port/runtime/plugin/wutcwf.so \
    Port/runtime/plugin/wuvorbis.so; do
    [[ -f "$repo_dir/$required" ]] || die "port checkout is incomplete: $required"
done

log "Installing native runtime into $game_dir"
install -d "$game_dir/linux/plugin"
install -m 0755 "$repo_dir/FateLinux.sh" "$game_dir/FateLinux.sh"
install -m 0755 "$port_dir/runtime/krkrsdl2" "$game_dir/linux/krkrsdl2"
install -m 0644 "$port_dir/settings.tjs" "$game_dir/linux/settings.tjs"
for plugin in extrans fstat krglhwebp wutcwf wuvorbis; do
    install -m 0755 "$port_dir/runtime/plugin/$plugin.so" "$game_dir/linux/plugin/$plugin.so"
done

log "Deriving route icons from your Ultimate Edition copy"
for route in FATE UBW HF; do
    magick "$game_dir/icon_${route}.ico[3]" \
        -define bmp:format=bmp4 "$game_dir/linux/icon_${route}.bmp"
done

cat <<EOF

Native Linux port installed.

  Play:  $game_dir/FateLinux.sh
  Saves: $game_dir/faterealtanua_savedata/

The installer did not alter or copy any XP3 archives, Windows executables,
configuration, or save data. Re-run this command after updating the port.
EOF
