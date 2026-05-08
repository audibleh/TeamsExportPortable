# Portable Bundle Plan

## Cil

Mit distribuovatelny folder, ktery pujde zkopirovat na jiny stroj a spustit bez lokalni instalace projektu do systemoveho Pythonu.

Pro Windows je cilovy UX:

- uzivatel rozbali nebo zkopiruje jeden adresar
- v nem bude bundled `python.exe`
- spusti [run-viewer.cmd](/Users/martin.rysavy/MSTeamsExport/run-viewer.cmd) nebo [run-export.cmd](/Users/martin.rysavy/MSTeamsExport/run-export.cmd)
- data, exporty i browser profile zustanou uvnitr jednoho prenositelneho stromu

## Proc ne `.venv`

`.venv` je skvela pro vyvoj, ale neni idealni jako finalni portable format:

- casto obsahuje absolutni cesty
- je vazana na konkretni OS a build Pythonu
- prekopirovani mezi stroji nebo mezi verzemi Pythonu byva krehke
- na Windows a macOS/Linux nejsou binarni zalezitosti zamenitelne

Proto:

- `.venv` zustava dev rezim
- portable bundle bude mit vlastni runtime v `runtime/python/`

## Doporuceny layout

```text
TeamsExportPortable/
  run-viewer.cmd
  run-viewer.ps1
  run-export.cmd
  run-export.ps1
  runtime/
    python/
      python.exe
      Lib/
      DLLs/
      Scripts/
  src/
    msteams_export/
      ...
  exports/
    index.json
    chats/
  .state/
    profiles/
    previews/
  Doc/
```

Poznamka:

- `src/` muze byt pozdeji nahrazeno zabalenym wheel/site-packages layoutem, ale na prvni iteraci je jednodussi a citelnejsi nechat zdrojaky otevrene.

## Jak to ma fungovat

### Viewer

- launcher nastavi `PYTHONPATH=src`
- pouzije `runtime/python/python.exe`
- spusti `python -m msteams_export serve ./exports --open-browser`

To je dulezite proto, ze lokalni web viewer je nyni hlavni UX vrstva pro:

- hledani
- filtrovani
- klikatelne odkazy a prilohy
- export do `CSV`, `Markdown` a `HTML`

### Export

- launcher pouzije stejny bundled interpreter
- defaultne muze spustit `export all --outdir ./exports --skip-existing`
- pokrocilejsi pouziti pujde pres parametry CLI

## Data a stav

- `exports/` bude drzet vystupy `index.json + chats/*.json`
- `.state/profiles/` bude drzet persistentni browser profile
- `.state/previews/` bude drzet generovane nahledy obrazku

To znamena, ze pri kopirovani folderu se prenese:

- aplikace
- runtime
- exportovana data
- lokalni session/browser stav, pokud to budeme chtit zachovat

Poznamka k archivnim datum:

- mirrored attachmenty se ukladaji jako relativni cesty uvnitr bundle, typicky `assets/...`
- tyto cesty jsou zamerne normalizovane tak, aby fungovaly i po presunu mezi macOS a Windows
- viewer ma preferovat lokalni asset pred puvodnim SharePoint linkem, takze offline archiv neni zavisly na stare organizaci
- GIF a video prilohy chceme dale ignorovat, aby bundle nerostl kvuli memum a malo uzitecnemu obsahu

## Disk a navazani

Attachment mirror musi byt navrzen jako dlouhy, prerusitelny job:

- mirror beh je resumable, takze dalsi spusteni znovu pouzije jiz stazene assety
- pri preruseni ma zustat bundle citelny a konzistentni
- cilove chovani je drzet minimalne `30 GB` volneho mista na disku, pokud uzivatel nezvoli jinak
- progress ma zobrazovat nejen pocet assetu, ale i odhad ETA a aktualni volne misto

## Cross-OS smer

Architektura jadra uz je Python-first a prenositelna.

Rozdil mezi platformami bude hlavne v:

- launcherech
- bundled runtime
- browser detection a profile cestach

Aktualne pripravujeme hlavne Windows-friendly cestu, protoze:

- user-friendly viewer v browseru funguje prirozene
- `python.exe + .cmd/.ps1` je jednoducha distribuce
- pozdeji pujde pridat obdobne `.sh` launchery pro macOS/Linux

## Co nedelat jako prvni krok

- nespolihat na kopirovani `.venv` jako finalni distribuci
- neblokovat se hned na `PyInstaller`
- nevest viewer pres `ipywidgets`

Proc:

- `PyInstaller` muze prijit pozdeji, ale ted chceme mit citelny, testovatelny Python runtime
- `ipywidgets` je moc svazane s notebook/Jupyter prostredim
- lokalni web viewer je pro bezne uzivatele i Windows praktictejsi

## Dalsi konkretni krok

Az budeme chtit prvni skutecny portable bundle build:

1. Pripravit `dist/portable/`
2. Vlozit do nej bundled Windows Python runtime
3. Nainstalovat zavislosti primo do bundled runtime
4. Zkopirovat `src/`, `Doc/`, launchery a pripadne prazdne `exports/` a `.state/`
5. Otestovat viewer a export na cistem Windows stroji bez lokalniho setupu projektu
