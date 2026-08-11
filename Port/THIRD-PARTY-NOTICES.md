# Third-party notices

No Fate/stay night game files are included in this repository. The components
below are native engine/plugin code and are not owned by TYPE-MOON.

## Kirikiri SDL2

- Project: <https://github.com/krkrsdl2/krkrsdl2>
- Pinned source: `3f384a6869f6726929c777bdd0e0c871d5d5383d`
- License: MIT; a copy is in `licenses/krkrsdl2-MIT.txt`

### Linux bundled build

- Local change: `patches/krkrsdl2-window-icon.patch`
- Bundled `runtime/krkrsdl2` SHA-256:
  `0ef8994391369589487d881e6566ec5df3d3bcafdd0260a6a1ae6fc052c5140b`

### macOS official artifact

- Release archive:
  <https://github.com/krkrsdl2/krkrsdl2/releases/download/latest/krkrsdl2-macos.zip>
- Archive SHA-256:
  `608dce209d43f3310b0d13be49258db3bb20e0638f3738eb291cb77687342ef5`
- Source ref: `3f384a6869f6726929c777bdd0e0c871d5d5383d`
- Bundled `runtime-macos/krkrsdl2` SHA-256:
  `5a2b572e07b2080fdd0ccc0c5cd175f91e3e227faa7d7cdd6721136b599a22e4`

Kirikiri SDL2 contains its own third-party submodules. Their notices and source
are available from the pinned upstream tree and are not replaced by this
project's MIT license.

## Native plugins

### Linux artifacts

| Binary | Upstream | SHA-256 |
|---|---|---|
| `extrans.so` | <https://github.com/krkrsdl2/SamplePlugin> | `86f0e690227cba14da7220becb5e6dcb55b64ec5ff7d7a764a19bdde7b2e257d` |
| `wutcwf.so` | <https://github.com/krkrsdl2/SamplePlugin> | `9fe3db394f0ccb84bfdc39c25ee39ce83859b210725e1341af89d4ef9649a9b0` |
| `fstat.so` | <https://github.com/krkrsdl2/fstat> | `99642eb60a44f31438bdfa24938efb0cf0fe0b8ffb0da734989401eb5e58f5e0` |
| `krglhwebp.so` | <https://github.com/krkrsdl2/krglhwebp> | `40da17442b26ef47f38ebae2e167222f0daae0f50310427349ed965b79d026bc` |
| `wuvorbis.so` | <https://github.com/krkrsdl2/wuvorbis> | `413506f3f2560f2c4fdecfff024b68cbade12ecffdaeba8194f75969e47db566` |

`extrans.so`, `fstat.so`, `krglhwebp.so`, and `wuvorbis.so` came from the
upstream Ubuntu release artifacts. `wutcwf.so` was rebuilt from SamplePlugin
commit `d8c49d30815fbc45c8a2ded3d055ff7b7c659106` against the upstream
`tp_stubz` and `tvpsnd` interfaces.

### macOS official artifacts

The universal macOS plugins come from these release archives. Although the
upstream release paths contain `latest_krkrsdl2`, the fetcher pins their
contents by SHA-256 and rejects any changed artifact.

| Archive | Source ref | Archive SHA-256 |
|---|---|---|
| [`SamplePlugin-macos.zip`](https://github.com/krkrsdl2/SamplePlugin/releases/download/latest_krkrsdl2/SamplePlugin-macos.zip) | `b088f2ccc76b49c76f7069f85982904438a7d95f` | `35be2125bb6dd388bee79d40345d11ce10117dc548c91f32732150f464265855` |
| [`fstat-macos.zip`](https://github.com/krkrsdl2/fstat/releases/download/latest_krkrsdl2/fstat-macos.zip) | `f761803424368aaac1674563f6a63544a8014806` | `ff0fc9509f854db52205c20bd5c328d296ddb72eb6200b891881453f86f6892a` |
| [`krglhwebp-macos.zip`](https://github.com/krkrsdl2/krglhwebp/releases/download/latest_krkrsdl2/krglhwebp-macos.zip) | `20916089b16d40f5a9ad3f8e51042947ef4aa013` | `52f861fc35870051994e6115add53798fdbbbf38ef0b82fa04f95d4215d4036f` |
| [`wuvorbis-macos.zip`](https://github.com/krkrsdl2/wuvorbis/releases/download/latest_krkrsdl2/wuvorbis-macos.zip) | `e02d600e6f7c2826097b8c4cf60902a746a98fd0` | `6d9eecd01693a3eeb733d0c4ed68ad7b23d6f48791bdab5421126b5feb704395` |

| Binary | SHA-256 |
|---|---|
| `runtime-macos/plugin/extrans.so` | `9d539882affcbc2b7e9b3517ccb1c9cbf43580d09c4facbab0cfba2a5c2aab45` |
| `runtime-macos/plugin/wutcwf.so` | `68ba4556177e4bcb86ec9113dfed81de89de0f91133233895d5300aca01d0e62` |
| `runtime-macos/plugin/fstat.so` | `aa192e0468dd067b0a4ab43d2213c0b3554963faa785d76cae6eb0bf51675776` |
| `runtime-macos/plugin/krglhwebp.so` | `100bc9a08e7820ba79e61eafa15b260e0b21d2a4750f7f1db3a0af26dc7dc1fb` |
| `runtime-macos/plugin/wuvorbis.so` | `ac01e2dbf1252abdfb24886a3653e2ee79db477f412250b87d6e61e3741329d3` |

The official SamplePlugin archive contains `wutcwf.so` with SHA-256
`e6cfc13230144d3df7712a667b3b9b3e5bb0e1012998e96c43cc2be0762cc6d5`,
but its `arm64` slice crashes in `TVPGetImportFuncPtr` while loading against
the pinned engine on the exercised Apple Silicon system. The bundled
`wutcwf.so` was rebuilt from exact SamplePlugin ref
`b088f2ccc76b49c76f7069f85982904438a7d95f`, after applying
`patches/wutcwf-macos-local-string-copy.patch`, with its existing CMake target
and `-DCMAKE_OSX_ARCHITECTURES='arm64;x86_64'`. The patch keeps the TSS module's
metadata string copies local; that entry point runs outside `V2Link`, so the
upstream `TJS_str*` import stubs have no initialized function exporter. The
fetcher verifies the official archive member and preserves only this
hash-verified rebuild.

Plugin repositories do not all expose a machine-detected SPDX license. Their
upstream notices and source govern those binaries; this project's `LICENSE`
does not relicense them. Confirm their redistribution terms before making a
binary mirror public.
