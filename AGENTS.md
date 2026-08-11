# AGENTS.md

## Project

This repository provides native Linux and macOS launchers and runtime files for **Fate/stay night Realta Nua Ultimate Edition**. No Ultimate Edition game files are redistributed by this repository; proprietary game archives, executables, assets, and save data remain outside it.

The checked-in runtime and plugins are third-party components. Preserve the provenance and licensing information in `Port/THIRD-PARTY-NOTICES.md` when changing or refreshing them.

## Repository layout

- `install.sh` — installs the Linux runtime into an existing Ultimate Edition directory.
- `install-mac.sh` — installs the macOS runtime and Finder app wrapper.
- `FateLinux.sh` and `FateMac.sh` — relocatable launchers installed beside the game.
- `Port/settings.tjs` — shared compatibility overlay.
- `Port/runtime/` — checked-in x86-64 Linux engine and plugins.
- `Port/runtime-macos/` — checked-in universal macOS engine and plugins.
- `Port/build-engine.sh` — reproducible Linux engine build.
- `Port/fetch-runtime-macos.sh` — hash-verified macOS runtime refresh.
- `Port/patches/` — local changes applied to the upstream engine.

## Working rules

- Keep the Linux and macOS installers idempotent, relocatable, and limited to files owned by this project. Do not copy, modify, or delete game archives, Windows executables, configuration, or save data.
- Use Bash with `set -euo pipefail`, quote paths, and preserve the existing `die`, `log`, and validation patterns in shell scripts.
- Do not commit proprietary Ultimate Edition data or game-derived/generated media. Build output, downloaded archives, and cloned sources belong under the ignored `.build/` directory.
- When changing runtime binaries or plugins, use the documented rebuild/fetch scripts and update provenance or checksums as required. Do not replace pinned artifacts with an unverified `latest` download.
- Keep platform-specific behavior in the appropriate launcher or installer. Shared compatibility behavior belongs in `Port/settings.tjs`.
- Avoid unrelated formatting or dependency changes. Update `README.md` when user-facing commands, requirements, supported platforms, or repository layout change.

## Validation

There is no checked-in automated test suite. At minimum, run shell syntax checks for every modified shell script:

```sh
bash -n install.sh install-mac.sh FateLinux.sh FateMac.sh \
  Port/build-engine.sh Port/fetch-runtime-macos.sh
```

For installer or launcher changes, exercise the affected path with an existing Ultimate Edition directory when available. Confirm that only project-owned files are created or replaced and that existing game data and saves remain untouched. For runtime changes, follow the rebuild or fetch instructions in `README.md` and verify the relevant Linux or macOS launch flow.

Do not attach proprietary game files, archives, screenshots, or save data to issues or pull requests. Redact local paths and other personal information from logs before sharing them.
