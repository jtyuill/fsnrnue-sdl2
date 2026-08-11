#!/usr/bin/env bash
# Install the native macOS runtime beside an existing Fate/stay night Realta Nua
# Ultimate Edition copy. No game data is copied into this repository.
set -euo pipefail

repo_dir=$(cd "$(dirname "$0")" && pwd -P)
port_dir="$repo_dir/Port"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log() { printf '==> %s\n' "$*"; }

[[ $(uname -s) == Darwin ]] || die "this installer requires macOS"
[[ $# -eq 1 ]] || die "usage: $0 /path/to/FSNRNUE114"
[[ -d "$1" ]] || die "game directory does not exist: $1"
game_dir=$(cd "$1" && pwd -P)

for command_name in install sips iconutil; do
    command -v "$command_name" >/dev/null 2>&1 || die "missing required command: $command_name"
done

for required in patch.xp3 data.xp3 etc.xp3 rule.xp3 \
    icon_FATE.ico icon_UBW.ico icon_HF.ico; do
    [[ -f "$game_dir/$required" ]] || die "Ultimate Edition base is missing: $required"
done
if [[ ! -f "$game_dir/Fate.exe" && ! -f "$game_dir/Fate64.exe" ]]; then
    die "Ultimate Edition base is missing Fate.exe/Fate64.exe"
fi

for required in FateMac.sh Port/settings.tjs Port/runtime-macos/krkrsdl2 \
    Port/runtime-macos/plugin/extrans.so Port/runtime-macos/plugin/fstat.so \
    Port/runtime-macos/plugin/krglhwebp.so Port/runtime-macos/plugin/wutcwf.so \
    Port/runtime-macos/plugin/wuvorbis.so; do
    [[ -f "$repo_dir/$required" ]] || die "port checkout is incomplete: $required"
done
[[ -x "$repo_dir/FateMac.sh" ]] || die "port checkout launcher is not executable: FateMac.sh"
[[ -x "$port_dir/runtime-macos/krkrsdl2" ]] || die "port checkout runtime is not executable: Port/runtime-macos/krkrsdl2"
for plugin in extrans fstat krglhwebp wutcwf wuvorbis; do
    [[ -x "$port_dir/runtime-macos/plugin/$plugin.so" ]] \
        || die "port checkout plugin is not executable: Port/runtime-macos/plugin/$plugin.so"
done

icon_properties=$(sips -g pixelWidth -g pixelHeight "$game_dir/icon_FATE.ico" 2>/dev/null) \
    || die "could not inspect icon_FATE.ico"
[[ "$icon_properties" == *$'\n  pixelWidth: 64\n'* \
    && "$icon_properties" == *$'\n  pixelHeight: 64' ]] \
    || die "icon_FATE.ico does not contain the required 64x64 frame"

temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/FateMac-install.XXXXXX") \
    || die "could not create installer temporary directory"
cleanup() {
    rm -rf "$temp_dir"
}
trap cleanup EXIT HUP INT TERM

staged_app="$temp_dir/FateMac.app"
iconset_dir="$temp_dir/FateMac.iconset"
source_icon="$temp_dir/FateMac-64.png"
install -d -m 0755 "$staged_app/Contents/MacOS" "$staged_app/Contents/Resources" "$iconset_dir"

cat >"$staged_app/Contents/MacOS/FateMac" <<'WRAPPER'
#!/bin/sh
set -eu

game_dir=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd -P)
exec "$game_dir/FateMac.sh" "$@"
WRAPPER
chmod 0755 "$staged_app/Contents/MacOS/FateMac"

cat >"$staged_app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>FateMac</string>
    <key>CFBundleIdentifier</key>
    <string>io.github.jtyuill.fsnrnue-sdl2</string>
    <key>CFBundleIconFile</key>
    <string>FateMac</string>
    <key>CFBundleName</key>
    <string>FateMac</string>
    <key>CFBundleDisplayName</key>
    <string>Fate/stay night Réalta Nua</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.14</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST
chmod 0644 "$staged_app/Contents/Info.plist"

log "Deriving the Finder icon from your Ultimate Edition copy"
sips -s format png "$game_dir/icon_FATE.ico" --out "$source_icon" >/dev/null \
    || die "could not convert icon_FATE.ico to PNG"
rgba_properties=$(sips -g samplesPerPixel -g hasAlpha "$source_icon" 2>/dev/null) \
    || die "could not inspect the converted Fate icon"
[[ "$rgba_properties" == *$'\n  samplesPerPixel: 4\n'* \
    && "$rgba_properties" == *$'\n  hasAlpha: yes' ]] \
    || die "converted Fate icon is not RGBA"

render_icon() {
    size=$1
    name=$2
    sips -z "$size" "$size" "$source_icon" --out "$iconset_dir/$name" >/dev/null \
        || die "could not render $name"
}

render_icon 16 icon_16x16.png
render_icon 32 icon_16x16@2x.png
render_icon 32 icon_32x32.png
render_icon 64 icon_32x32@2x.png
render_icon 128 icon_128x128.png
render_icon 256 icon_128x128@2x.png
render_icon 256 icon_256x256.png
render_icon 512 icon_256x256@2x.png
render_icon 512 icon_512x512.png
render_icon 1024 icon_512x512@2x.png
iconutil -c icns "$iconset_dir" -o "$staged_app/Contents/Resources/FateMac.icns" \
    || die "could not assemble FateMac.icns"
chmod 0644 "$staged_app/Contents/Resources/FateMac.icns"

log "Installing native runtime into $game_dir"
install -d -m 0755 "$game_dir/macos/plugin"
install -m 0755 "$repo_dir/FateMac.sh" "$game_dir/FateMac.sh"
install -m 0755 "$port_dir/runtime-macos/krkrsdl2" "$game_dir/macos/krkrsdl2"
install -m 0444 "$port_dir/settings.tjs" "$game_dir/macos/settings.tjs"
for plugin in extrans fstat krglhwebp wutcwf wuvorbis; do
    install -m 0755 "$port_dir/runtime-macos/plugin/$plugin.so" "$game_dir/macos/plugin/$plugin.so"
done

rm -rf "$game_dir/FateMac.app"
mv "$staged_app" "$game_dir/FateMac.app"

cat <<EOF

Native macOS port installed.

  Terminal: $game_dir/FateMac.sh
  Finder:   $game_dir/FateMac.app
  Saves:    $game_dir/faterealtanua_savedata/

The installer did not alter or copy any XP3 archives, Windows executables,
configuration, or save data. Re-run this command after updating the port.
EOF
