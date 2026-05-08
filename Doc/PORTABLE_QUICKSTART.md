# Portable Quickstart

Platform: macos
Expected bundled runtime executable: `runtime/python/bin/python3`

## What this staging build already contains

- application source code in `src/`
- launchers in the bundle root
- `exports/` and `.state/` folder layout
- portable metadata and quick-start docs

## What is still expected before final distribution

- add a platform-specific bundled Python runtime into `runtime/python/`
- install runtime dependencies into that bundled runtime
- run a smoke test on a clean target machine

## Data policy for this build

- current exports copied in: no
- current .state copied in: no

## Typical entrypoints

- main viewer launcher: run `run-viewer.command` from the bundle root
- first sign-in launcher: run `run-session-open.command` from the bundle root
- advanced diagnostic and CLI launchers live under `Tools/Advanced/`
- there you can find `run-export` and `run-session-check`
