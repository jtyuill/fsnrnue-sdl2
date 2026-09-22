#!/usr/bin/env bash
# Rebuild the bundled Kirikiri SDL2 runtime from the pinned upstream revision.
set -euo pipefail

repo_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)
port_dir="$repo_dir/Port"
work_dir="${BUILD_DIR:-$repo_dir/.build}"
source_dir="$work_dir/krkrsdl2"
build_dir="$work_dir/krkrsdl2-build"
upstream="${KRKRSDL2_REPO_URL:-https://github.com/krkrsdl2/krkrsdl2.git}"
commit="3f384a6869f6726929c777bdd0e0c871d5d5383d"
patch_file="$port_dir/patches/krkrsdl2-window-icon.patch"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log() { printf '==> %s\n' "$*"; }

[[ $(uname -s) == Linux && $(uname -m) == x86_64 ]] \
    || die "this build requires x86-64 Linux"

for command_name in git cmake ninja pkg-config nasm cc c++ install patchelf; do
    command -v "$command_name" >/dev/null 2>&1 || die "missing build command: $command_name"
done

mkdir -p "$work_dir"
if [[ ! -d "$source_dir/.git" ]]; then
    log "Cloning Kirikiri SDL2"
    git clone --no-checkout "$upstream" "$source_dir"
fi

log "Checking out Kirikiri SDL2 $commit"
git -C "$source_dir" fetch origin "$commit"
git -C "$source_dir" checkout --detach "$commit"
git -C "$source_dir" submodule update --init --recursive

if git -C "$source_dir" apply --check "$patch_file"; then
    git -C "$source_dir" apply "$patch_file"
elif ! git -C "$source_dir" apply --reverse --check "$patch_file"; then
    die "window-icon patch does not apply cleanly; use a clean BUILD_DIR"
fi

log "Configuring native runtime"
cmake -S "$source_dir" -B "$build_dir" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DSDL_PIPEWIRE=OFF \
    -DSDL_KMSDRM=OFF

log "Building native runtime"
cmake --build "$build_dir" --parallel
# Do not ship the build host's loader or library search paths (notably Nix).
portable_engine="$build_dir/krkrsdl2-portable"
install -m 0755 "$build_dir/krkrsdl2" "$portable_engine"
patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 --remove-rpath "$portable_engine"
install -m 0755 "$portable_engine" "$port_dir/runtime/krkrsdl2"
printf 'Installed rebuilt runtime: %s\n' "$port_dir/runtime/krkrsdl2"
