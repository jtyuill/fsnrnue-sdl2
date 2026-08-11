# Runtime maintenance

The files under `Port/runtime/` and `Port/runtime-macos/` are third-party
runtime artifacts. They contain no Ultimate Edition game data. Keep their
source revisions, local patches, licenses, and hashes synchronized with
[`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md).

Both maintenance scripts resolve paths relative to their own location, so they
may be invoked from any working directory. Their downloads, source checkouts,
and build products default to the ignored repository-level `.build/`
directory.

## Rebuild the Linux engine

`build-engine.sh` rebuilds only the Linux Kirikiri SDL2 engine. It does not
rebuild or replace the native plugins under `runtime/plugin/`.

Run it on an x86-64 Linux system with these commands available:

- Git, including submodule support
- CMake and Ninja
- `pkg-config` and NASM
- C and C++ compilers exposed as `cc` and `c++`
- POSIX `install`
- the development libraries required by the pinned Kirikiri SDL2 source and
  its submodules

From the repository root:

```sh
./Port/build-engine.sh
```

The script:

1. clones Kirikiri SDL2 and its submodules into `.build/krkrsdl2/` when no
   checkout exists;
2. fetches and checks out the exact commit recorded in the script;
3. updates all pinned submodules;
4. applies `patches/krkrsdl2-window-icon.patch` if it is not already applied;
5. configures a Release build in `.build/krkrsdl2-build/` with Ninja; and
6. installs the resulting executable as `runtime/krkrsdl2`.

Use a different ignored work directory without changing the script:

```sh
BUILD_DIR="$PWD/.build/linux-clean" ./Port/build-engine.sh
```

For testing a fork or local mirror, `KRKRSDL2_REPO_URL` may override the clone
URL. The selected repository must contain the exact pinned commit:

```sh
KRKRSDL2_REPO_URL=https://example.invalid/krkrsdl2.git \
  ./Port/build-engine.sh
```

The source revision is pinned, but the compiler and system libraries are not.
Before committing a rebuilt executable:

- inspect its architecture, dynamic dependencies, required symbol versions,
  and runtime search paths;
- exercise the Linux launcher with an existing Ultimate Edition installation;
- confirm no game archives, configuration, or save data changed; and
- update the Linux engine hash and any changed build provenance in
  `THIRD-PARTY-NOTICES.md`.

Useful inspection commands include:

```sh
sha256sum Port/runtime/krkrsdl2
readelf -h Port/runtime/krkrsdl2
readelf -d Port/runtime/krkrsdl2
readelf --version-info Port/runtime/krkrsdl2
```

## Refresh the macOS runtime

`fetch-runtime-macos.sh` refreshes the universal macOS engine and plugins from
hash-pinned upstream release archives. It must run on macOS because it uses
Apple's archive and Mach-O tools.

Required commands:

- `curl`
- `ditto`
- `install`
- `shasum`
- `lipo`

From the repository root:

```sh
./Port/fetch-runtime-macos.sh
```

The script:

1. downloads the engine and plugin archives into
   `.build/macos-runtime-downloads/`;
2. rejects every archive whose SHA-256 does not match the value embedded in
   the script;
3. stages the selected engine and plugin files;
4. verifies the SHA-256 of every staged runtime artifact;
5. requires both `arm64` and `x86_64` slices in every artifact; and
6. installs the verified files under `runtime-macos/`.

Use another ignored download and staging directory with `BUILD_DIR`:

```sh
BUILD_DIR="$PWD/.build/macos-clean" ./Port/fetch-runtime-macos.sh
```

The bundled macOS `wutcwf.so` is intentionally not replaced by the copy in the
official SamplePlugin archive. The script verifies that official archive
member, then verifies and preserves the checked-in universal rebuild. Its exact
source revision, patch, rationale, and expected hash are documented in
`THIRD-PARTY-NOTICES.md`. Changing that rebuild requires updating the embedded
hash in the fetcher and the corresponding provenance notice together.

A successful refresh proves the configured archive and artifact hashes and the
two required Mach-O architectures. Before committing refreshed artifacts:

- exercise both `FateMac.sh` and `FateMac.app` with an existing Ultimate
  Edition installation on macOS;
- confirm no game archives, configuration, or save data changed;
- compare all resulting hashes with `THIRD-PARTY-NOTICES.md`; and
- update source references, archive URLs, hashes, patches, and license notices
  whenever the pinned inputs change.

Do not commit downloaded archives, cloned source trees, build output, game
files, generated icons, logs, or save data. Keep those files under `.build/` or
outside the repository.
