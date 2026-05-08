# macOS Portable Track

Tento adresar je vyhrazeny pro macOS-specific portable kroky.

Plan:

- bundled `python3` runtime
- `.command` a `.sh` launchery
- viewer a export spustitelne bez vyvojove `.venv`
- releasovy zip a smoke-test nad archivem
- cisty root bundle s minimalnim poctem user-facing spoustecu

Aktualni stav:

- prvni funkcni runtime prototyp uz jde seednout z lokalniho Homebrew Python frameworku
- po seed kroku je potreba macOS-specific patch + ad-hoc re-sign, to uz dela `Portable/scripts/seed_runtime.py`
- Homebrew dylib zavislosti jdou stahnout dovnitr bundle pres `Portable/scripts/vendor_macos_dylibs.py`

Overene lokalne:

- bundled `python3 -V`
- `python3 -m msteams_export inspect tests/fixtures/sample_export.json`
- `ssl`, `sqlite3`, `lzma`, `decimal`, `hashlib`, `_zstd` import po dylib vendor kroku
- `playwright`, `playwright.sync_api`, `greenlet`, `pyee`, `typing_extensions` import po `seed_site_packages.py`
- `./run-viewer.command --help`
- `./run-session-open.command --help`
- `./Tools/Advanced/run-session-check.sh --help`
- headless `session-check` probe z portable runtime uz umi spustit system Edge; v cistem portable profilu byl probe neautentizovany, coz je ocekavane, dokud se do toho profilu neprovede login

Prakticky local workflow:

```bash
./.venv/bin/python Portable/scripts/build_macos_portable_from_local.py --output-root Portable/staging
./.venv/bin/python Portable/scripts/package_portable_release.py --stage-root Portable/staging/macos/TeamsExportPortable
./.venv/bin/python Portable/scripts/smoke_test_macos_bundle.py \
  --archive Portable/dist/macos/TeamsExportPortable-macos-v0.1.7.zip \
  --sample-export tests/fixtures/sample_export.json
```

Poznamky:

- v bundle rootu zustavaji zamerne jen `run-session-open.command` a `run-viewer.command`
- `run-session-open.command` je klikaci launcher pro vytvoreni a prihlaseni Teams session uvnitr portable `.state`
- pokrocile launchery jsou v `Tools/Advanced/`
- `Tools/Advanced/run-session-check.command` je rychly probe, jestli portable bundle vidi pouzitelny browser a Teams session
- `Portable/scripts/package_portable_release.py` vytvari zip s preserved symlinky a executable bity
- `Portable/scripts/smoke_test_macos_bundle.py` umi testovat jak staging bundle, tak hotovy zip po rozbaleni do docasneho prostoru

Budouci obsah:

- launch permission a executable-bit poznamky
- Gatekeeper/quarantine poznamky
- smoke-test notes pro cisty macOS stroj
