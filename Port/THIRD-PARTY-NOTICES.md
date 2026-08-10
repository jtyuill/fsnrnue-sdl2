# Third-party notices

No Fate/stay night game files are included in this repository. The components
below are native engine/plugin code and are not owned by TYPE-MOON.

## Kirikiri SDL2

- Project: <https://github.com/krkrsdl2/krkrsdl2>
- Pinned source: `3f384a6869f6726929c777bdd0e0c871d5d5383d`
- License: MIT; a copy is in `licenses/krkrsdl2-MIT.txt`
- Local change: `patches/krkrsdl2-window-icon.patch`
- Bundled binary SHA-256:
  `0ef8994391369589487d881e6566ec5df3d3bcafdd0260a6a1ae6fc052c5140b`

Kirikiri SDL2 contains its own third-party submodules. Their notices and source
are available from the pinned upstream tree and are not replaced by this
project's MIT license.

## Native plugins

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

Plugin repositories do not all expose a machine-detected SPDX license. Their
upstream notices and source govern those binaries; this project's `LICENSE`
does not relicense them. Confirm their redistribution terms before making a
binary mirror public.
