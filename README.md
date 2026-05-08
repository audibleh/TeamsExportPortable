# MS Teams Export CLI

Python-first rewrite workspace for exporting and inspecting Microsoft Teams web chat data.

## Current status

- Python project scaffold is ready.
- CLI entrypoint is available.
- JSON inspection and terminal viewing are implemented.
- Local web viewer with search, filters and practical export formats is available.
- Local web viewer now also acts as a local control panel for `export all` and `attachments mirror`, with browser-side progress bars and stop/resume controls.
- Browser session-check via Playwright is available.
- Real Teams web API export is working for:
  - active chat export
  - conversation discovery
  - export-all into `outdir/index.json` + `outdir/chats/*.json`
- `teams-export export all` now shows live CLI progress for total conversations, hidden chats, meeting chats and cumulative exported messages.
- Chat filenames are URL-encoded conversation IDs so they stay cross-platform safe, including Windows.
- Mirrored attachment paths are stored as bundle-relative paths, so copied export folders stay portable across macOS, Linux and Windows.

## Quick start

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -e . --no-build-isolation
teams-export inspect tests/fixtures/sample_export.json
teams-export view tests/fixtures/sample_export.json --limit 3
teams-export session-open --browser auto
teams-export session-check --browser auto --headless
teams-export serve ./exports --open-browser
python -m unittest discover -s tests/unit -p 'test_*.py'
```

## CLI commands

- `teams-export session-check`
- `teams-export session-open`
- `teams-export export chat`
- `teams-export export chat --conversation-id <id>`
- `teams-export chats list`
- `teams-export export all --outdir ./exports`
- `teams-export export team`
- `teams-export inspect`
- `teams-export view`
- `teams-export preview-images`
- `teams-export attachments mirror`
- `teams-export serve ./exports --open-browser`

## Suggested flow

```bash
source .venv/bin/activate
teams-export session-check --browser auto --headless
teams-export chats list --output ./exports/conversations.json
teams-export export all --outdir ./exports --skip-existing
teams-export attachments mirror ./exports --browser auto --min-free-gb 30
teams-export serve ./exports --open-browser
teams-export inspect ./exports/chats/19%3Aexample%40thread.v2.json
teams-export view ./exports/chats/19%3Aexample%40thread.v2.json --limit 20
```

## Notes

- `teams-export export all` can take a long time on large histories. Use `--max-chats` for smoke tests and `--skip-existing` for resumable runs.
- Teams discovery currently gives us reliable totals for conversations, hidden chats and meeting chats, but not a trustworthy total message count before export starts. The CLI therefore shows a running `msgs:` counter instead of a fake total-message progress bar.
- `Ctrl+C` during `teams-export export all` is now two-stage:
  first press finishes the current chat and writes a partial `index.json`;
  second press stops after the current Teams API page and still tries to write a partial index safely.
- Meeting chats are already present in the main conversations feed and export correctly in current smoke tests.
- Hidden chats are now discovered by merging the primary conversations API feed with the local `Teams:conversation-manager` IndexedDB cache. In the current tenant probe this surfaced `339` hidden chats that were not exposed by the primary feed alone.
- The new local web viewer is the recommended UX direction for Windows and cross-platform use. It already supports conversation search/filtering, failed/partial/metadata-only diagnostics and single-chat export to `CSV`, `Markdown` and `HTML`.
- The local viewer is no longer just a passive browser. It now includes a control panel for starting/stopping `export all` and `attachments mirror` jobs over localhost, with local-only POST controls protected by a per-session token.
- Animated GIF attachments and video attachments are now filtered out in the parser and viewer so the archive stays focused on more useful files.
- `teams-export attachments mirror` is resumable. Already mirrored assets are reused on the next run, and the progress line now shows mirrored data volume, free disk space and a best-effort ETA.
- `teams-export attachments mirror` now protects free disk space with `--min-free-gb` and stops safely if the bundle disk drops below the configured threshold. The default is `30 GB`.
- `Ctrl+C` during `teams-export attachments mirror` is now two-stage:
  first press finishes the current chat's attachments and writes resumable partial metadata;
  second press stops after the current attachment and still writes the partial mirror state.
- Current tenant probing suggests classic chats, hidden chats and meeting chats export well, but `TeamsStandardChannel`, `TeamsTeam` and `EngageCommunity` still need special handling. The current fallback behavior is:
  `TeamsStandardChannel` => partial channel export with warning and last known message when live history is blocked;
  `TeamsTeam` / `EngageCommunity` => metadata-only export with warning.
- Viewer attachment links now go through a local authenticated proxy instead of opening raw Teams/SharePoint URLs directly. This avoids downloading garbage header-only pseudo-files, but it cannot resurrect links whose backing SharePoint files are already gone after a tenant rename or cleanup.
- When an attachment has been mirrored into `exports/assets/`, the viewer now serves the local file first. That makes those files available offline even after the old tenant or SharePoint path disappears.
- Do not treat `.venv` as the final portable distribution format. For a copyable bundle, prefer a dedicated `runtime/python/` directory with a bundled interpreter and launchers such as [run-viewer.cmd](/Users/martin.rysavy/MSTeamsExport/run-viewer.cmd) and [run-export.cmd](/Users/martin.rysavy/MSTeamsExport/run-export.cmd).

See [PYTHON_MIGRATION_PLAN.md](/Users/martin.rysavy/MSTeamsExport/Doc/PYTHON_MIGRATION_PLAN.md) for the phased plan and [PORTABLE_BUNDLE_PLAN.md](/Users/martin.rysavy/MSTeamsExport/Doc/PORTABLE_BUNDLE_PLAN.md) for the distribution layout.
