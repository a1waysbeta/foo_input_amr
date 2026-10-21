# foo_input_amr

Adaptive Multirate (AMR-NB) input decoder for foobar2000, upgraded to build against
the **foobar2000 SDK 2026-10-01** (foobar2000 v2.x), for both **x86 (32-bit)** and
**x64 (64-bit)**.

Based on the last public source drop (v1.1.3, 2018) by Andrzej Lichnerowicz /
Quang Nguyen, which no longer compiled against modern SDKs.

## What changed in 1.2.0

- Builds against foobar2000 SDK 2026-10-01; project migrated from `v141_xp` to the
  `v143` toolset with C++20, and from Win32-only to **Win32 + x64**.
- `input_info_reader::get_file_stats()` (removed in modern SDKs) replaced by
  `get_stats2()`.
- Rejecting tag writes now throws `exception_tagging_unsupported` (current SDK
  convention) instead of `exception_io_unsupported_format`.
- The `vendor/spdlog` git submodule (never initialized in the public source drop)
  was dropped in favour of a small self-contained debug logger (`foo_amr/amr_log.h`).
  Release builds contain no logging code; `_DEBUG` builds log to
  `%TEMP%\foo_input_amr.txt` and to the debugger.
- Component version bumped to 1.2.0.

Decoder core (`3gpp/`, the 3GPP AMR-NB reference decoder) is unchanged.

## Building

### Online (GitHub Actions)

Push to `main` (or trigger the workflow manually / push a `v*` tag) — the workflow
downloads the official SDK archive, builds both architectures and uploads:

- `foo_input_amr_x86` / `foo_input_amr_x64` — the raw DLLs
- `foo_input_amr_component` — a ready-to-install `foo_input_amr.fb2k-component`
  (32-bit DLL at the root, 64-bit DLL under `x64\`)

### Locally (Visual Studio 2022)

1. Run `setup-sdk.ps1` (downloads the official SDK 2026-10-01 into `sdk/`), or
   extract <https://www.foobar2000.org/downloads/SDK-2026-10-01.7z> into `sdk/`
   yourself.
2. Open `foo_amr.sln` and build `Release` (or `Debug`) for `Win32` / `x64`.

The solution references the SDK projects under `sdk/`; nothing else is required.

## Installation

Drop `foo_input_amr.dll` (32-bit) into the `components` folder of a 32-bit
foobar2000 v2.x install, or use the packaged `foo_input_amr.fb2k-component`
(double-click / drag onto foobar2000) which handles both architectures.

## License

The AMR-NB decoder core (`3gpp/`) is 3GPP reference code (c) 2001 3GPP.
See `LICENSE` for the plugin license.
