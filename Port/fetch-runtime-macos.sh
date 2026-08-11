#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
build_dir=${BUILD_DIR:-"$repo_dir/.build"}
download_dir="$build_dir/macos-runtime-downloads"
runtime_dir="$repo_dir/Port/runtime-macos"
staging_dir="$download_dir/staging.$$"

fail() {
    printf 'fetch-runtime-macos: %s\n' "$*" >&2
    exit 1
}

log() {
    printf 'fetch-runtime-macos: %s\n' "$*"
}

[ "$(uname -s)" = Darwin ] || fail "this script requires macOS"

for command_name in curl ditto install shasum lipo; do
    command -v "$command_name" >/dev/null 2>&1 || fail "required command not found: $command_name"
done

cleanup() {
    rm -rf "$staging_dir"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$download_dir" "$staging_dir/archives" "$staging_dir/extracted" "$staging_dir/runtime-macos/plugin"

verify_sha256() {
    expected=$1
    path=$2
    output=$(shasum -a 256 "$path") || fail "could not hash $path"
    actual=${output%% *}
    [ "$actual" = "$expected" ] || fail "checksum mismatch for $(basename -- "$path"): expected $expected, got $actual"
}

download_archive() {
    name=$1
    url=$2
    expected=$3
    destination="$download_dir/$name"
    temporary="$staging_dir/archives/$name"

    log "downloading $name"
    curl -fL --retry 3 --output "$temporary" "$url" || fail "download failed for $url"
    verify_sha256 "$expected" "$temporary"
    install -m 0644 "$temporary" "$destination" || fail "could not cache $name"
}

extract_archive() {
    name=$1
    destination="$staging_dir/extracted/$name"
    mkdir -p "$destination"
    ditto -x -k "$download_dir/$name" "$destination" || fail "could not extract $name"
}

verify_universal() {
    path=$1
    archs=$(lipo -archs "$path") || fail "could not inspect architectures for $path"
    case " $archs " in
        *" x86_64 "*) ;;
        *) fail "$(basename -- "$path") is missing x86_64 architecture (found: $archs)" ;;
    esac
    case " $archs " in
        *" arm64 "*) ;;
        *) fail "$(basename -- "$path") is missing arm64 architecture (found: $archs)" ;;
    esac
}

download_archive \
    krkrsdl2-macos.zip \
    https://github.com/krkrsdl2/krkrsdl2/releases/download/latest/krkrsdl2-macos.zip \
    608dce209d43f3310b0d13be49258db3bb20e0638f3738eb291cb77687342ef5
download_archive \
    SamplePlugin-macos.zip \
    https://github.com/krkrsdl2/SamplePlugin/releases/download/latest_krkrsdl2/SamplePlugin-macos.zip \
    35be2125bb6dd388bee79d40345d11ce10117dc548c91f32732150f464265855
download_archive \
    fstat-macos.zip \
    https://github.com/krkrsdl2/fstat/releases/download/latest_krkrsdl2/fstat-macos.zip \
    ff0fc9509f854db52205c20bd5c328d296ddb72eb6200b891881453f86f6892a
download_archive \
    krglhwebp-macos.zip \
    https://github.com/krkrsdl2/krglhwebp/releases/download/latest_krkrsdl2/krglhwebp-macos.zip \
    52f861fc35870051994e6115add53798fdbbbf38ef0b82fa04f95d4215d4036f
download_archive \
    wuvorbis-macos.zip \
    https://github.com/krkrsdl2/wuvorbis/releases/download/latest_krkrsdl2/wuvorbis-macos.zip \
    6d9eecd01693a3eeb733d0c4ed68ad7b23d6f48791bdab5421126b5feb704395

for archive_name in \
    krkrsdl2-macos.zip \
    SamplePlugin-macos.zip \
    fstat-macos.zip \
    krglhwebp-macos.zip \
    wuvorbis-macos.zip
do
    extract_archive "$archive_name"
done

install -m 0755 "$staging_dir/extracted/krkrsdl2-macos.zip/krkrsdl2" "$staging_dir/runtime-macos/krkrsdl2"
install -m 0755 "$staging_dir/extracted/SamplePlugin-macos.zip/extrans.so" "$staging_dir/runtime-macos/plugin/extrans.so"
# The official wutcwf arm64 slice crashes in TVPGetImportFuncPtr. Preserve the
# verified universal rebuild from SamplePlugin b088f2ccc76b49c76f7069f85982904438a7d95f with Port/patches/wutcwf-macos-local-string-copy.patch.
verify_sha256 e6cfc13230144d3df7712a667b3b9b3e5bb0e1012998e96c43cc2be0762cc6d5 "$staging_dir/extracted/SamplePlugin-macos.zip/wutcwf.so"
[ -f "$runtime_dir/plugin/wutcwf.so" ] || fail "rebuilt wutcwf.so is missing from $runtime_dir/plugin"
verify_sha256 68ba4556177e4bcb86ec9113dfed81de89de0f91133233895d5300aca01d0e62 "$runtime_dir/plugin/wutcwf.so"
install -m 0755 "$runtime_dir/plugin/wutcwf.so" "$staging_dir/runtime-macos/plugin/wutcwf.so"
install -m 0755 "$staging_dir/extracted/fstat-macos.zip/fstat.so" "$staging_dir/runtime-macos/plugin/fstat.so"
install -m 0755 "$staging_dir/extracted/krglhwebp-macos.zip/krglhwebp.so" "$staging_dir/runtime-macos/plugin/krglhwebp.so"
install -m 0755 "$staging_dir/extracted/wuvorbis-macos.zip/wuvorbis.so" "$staging_dir/runtime-macos/plugin/wuvorbis.so"

verify_sha256 5a2b572e07b2080fdd0ccc0c5cd175f91e3e227faa7d7cdd6721136b599a22e4 "$staging_dir/runtime-macos/krkrsdl2"
verify_sha256 9d539882affcbc2b7e9b3517ccb1c9cbf43580d09c4facbab0cfba2a5c2aab45 "$staging_dir/runtime-macos/plugin/extrans.so"
verify_sha256 68ba4556177e4bcb86ec9113dfed81de89de0f91133233895d5300aca01d0e62 "$staging_dir/runtime-macos/plugin/wutcwf.so"
verify_sha256 aa192e0468dd067b0a4ab43d2213c0b3554963faa785d76cae6eb0bf51675776 "$staging_dir/runtime-macos/plugin/fstat.so"
verify_sha256 100bc9a08e7820ba79e61eafa15b260e0b21d2a4750f7f1db3a0af26dc7dc1fb "$staging_dir/runtime-macos/plugin/krglhwebp.so"
verify_sha256 ac01e2dbf1252abdfb24886a3653e2ee79db477f412250b87d6e61e3741329d3 "$staging_dir/runtime-macos/plugin/wuvorbis.so"

verify_universal "$staging_dir/runtime-macos/krkrsdl2"
for plugin_path in "$staging_dir"/runtime-macos/plugin/*.so; do
    verify_universal "$plugin_path"
done

install -d -m 0755 "$runtime_dir" "$runtime_dir/plugin"
install -m 0755 "$staging_dir/runtime-macos/krkrsdl2" "$runtime_dir/krkrsdl2"
for plugin_path in "$staging_dir"/runtime-macos/plugin/*.so; do
    install -m 0755 "$plugin_path" "$runtime_dir/plugin/$(basename -- "$plugin_path")"
done

log "installed verified universal runtime in $runtime_dir"
