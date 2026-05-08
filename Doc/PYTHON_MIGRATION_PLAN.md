# MS Teams Exporter: Python Migration Plan

## Cile

- Prepsat export logiku z browser extension do Python projektu, ktery pujde pohodlne pouzivat ve VS Code i pres CLI.
- Zachovat export do JSON jako primarni format pro dalsi zpracovani.
- Mit architekturu pripravenu pro budoucni cross-OS pouziti.
- Odlozit sanitizaci az do posledni faze, ale uz ted s ni pocitat v navrhu.
- Pozdeji pridat prijemny terminalovy viewer pro prohlizeni exportu ve "cyberpunk" stylu.
- Zaroven pripravit lokalni web viewer pro pohodlne hledani, filtrovani a export.

## Zakladni rozhodnuti

- Primarni jazyk: Python.
- Primarni rozhrani: CLI.
- Vyvojove prostredi: VS Code.
- Browser automation vrstva: pravdepodobne Playwright s persistentnim profilem.
- Primarni exportni vystup: JSON.
- Sanitizace: az v posledni fazi.

## Co jsme zjistili z puvodniho projektu

- Export neni zavisly na extension jako takove, ale na pristupu k aktivni Teams web session.
- Nejdulezitejsi cast je:
  - ziskani tokenu/session kontextu
  - zjisteni conversation ID
  - stazeni historie pres Teams API
  - fallback pres DOM scroll, pokud API cesta selze
- Extension resi hlavne UI, storage, download a komunikaci mezi popup/background/content skripty.
- To znamena, ze python prepis je realisticky.

## Navrh fazi

### Faze 0: Priprava projektu

- Zalozit Python projekt se srozumitelnou strukturou.
- Pridat `pyproject.toml`.
- Nastavit lint, format a test runner.
- Pripravit CLI entrypoint.

### Faze 1: Browser/session vrstva

- Otevrit Teams Web pres Playwright.
- Umoznit pouziti persistentniho browser profilu.
- Overit, ze umime pouzit existujici prihlasenou session.
- Pridat diagnosticky prikaz pro kontrolu session a aktivni konverzace.

### Faze 2: API exporter

- Implementovat detekci conversation ID.
- Implementovat Teams auth/service discovery.
- Implementovat strankovane stahovani zprav.
- Implementovat listing vsech discoverable conversations.
- Implementovat export-all do `outdir/index.json` + `outdir/chats/*.json`.
- Prevest zpravy do vlastniho Python modelu.
- Ukladat export do JSON.

### Faze 3: DOM fallback

- Pokud API cesta selze, udelat fallback scraper pres DOM.
- Doscrollovat historii.
- Posbirat zpravy, replies, reactions a metadata v rozumne mire.
- Deduplicit zpravy a sjednotit tvar s API exportem.

### Faze 4: Uzivatelske zpracovani exportu

- Pridat dalsi CLI prikazy pro filtrovanou praci s JSON exporty.
- Pripravit zaklad pro vizualizaci a inspekci dat.
- Navrhnout schema verzovani exportniho formatu.

### Faze 5: Viewer

- Udelat terminalovy viewer pro pohodlne prohlizeni JSON exportu.
- Zaroven pripravit lokalni web viewer jako hlavni UX vrstvu pro Windows a bezne pouziti.
- Nabidnout:
  - seznam konverzaci
  - filtrovani podle autora a datumu
  - detail zpravy
  - hledani v textu
  - zobrazeni reply vazeb, reakci a priloh
  - export vybraneho chatu do `CSV`, `Markdown` a `HTML`

### Faze 6: Sanitizace a tvrdsi hrany

- Doplnit sanitizaci HTML poli a vseho, co by se nekdy renderovalo.
- Projit edge cases.
- Stabilizovat schema.
- Dodelat export/import kompatibilitu pro budoucnost.

## Navrh struktury projektu

```text
MSTeamsExport/
  Doc/
    PYTHON_MIGRATION_PLAN.md
  src/
    msteams_export/
      cli.py
      config.py
      models.py
      browser/
      teams_api/
      dom_fallback/
      export/
      viewer/
      webapp/
  tests/
    unit/
    integration/
    e2e/
    fixtures/
```

## Navrh CLI

Prvni verze by mohla mit prikazy:

- `teams-export session-check`
- `teams-export export chat --output export.json`
- `teams-export export chat --conversation-id <id> --output export.json`
- `teams-export chats list`
- `teams-export export all --outdir ./exports`
- `teams-export export team --output export.json`
- `teams-export inspect export.json`
- `teams-export view export.json`
- `teams-export preview-images export.json`
- `teams-export serve ./exports`

## Viewer idea

Cil neni jen "otevrit JSON", ale udelat citelne prostredi pro analyzu chatu.

Aktualni preferovany smer:

- CLI a exportni engine zustavaji v Pythonu
- terminalovy viewer zustava lehky doplnkovy nastroj
- hlavni UX vrstva bude lokalni web viewer spousteny z CLI

Proc lokalni web viewer:

- funguje prirozeneji na Windows
- umi lepsi hledani, filtry a klikatelne odkazy
- obrazky a bohatsi metadata se v nem delaji snaz nez v cistem terminalu
- pozdeji pujde zabalit i do desktop shellu typu `pywebview`, pokud budeme chtit jedno-okenni appku

## Testovaci strategie

Chceme robustnejsi testy od zacatku, ne az po prvnim prototypu.

### Unit testy

- parsovani timestampu
- konverze API odpovedi do internich modelu
- deduplikace zprav
- parsovani reactions, replies, attachments a mentions
- generovani nazvu souboru a schema exportu

### Fixture-based testy

- uchovavat anonymizovane JSON/HTML fixture vzorky
- testovat male, stredni i velke konverzace
- testovat ruzne druhy obsahu:
  - bezny text
  - reply
  - forwarded zpravy
  - reactions
  - system messages
  - image/file metadata
  - audio/video references

### Integration testy

- browser vrstva + session bootstrap
- API discovery + fetch pipeline
- export do JSON souboru
- fallback rozhodovani mezi API a DOM cestou

### End-to-end testy

- Playwright scenare nad lokalnimi fixture strankami nebo mock Teams surface
- overeni CLI prikazu od vstupu po zapis souboru
- golden-file porovnani vystupniho JSON

### Regression testy

- kazdy bugfix dostane fixture nebo regression test
- drzet sadu realnych anonymizovanych problematickych pripadu

### Ne-funkcni testy

- velke konverzace
- spotreba pameti
- dlouhy scroll fallback
- odolnost na casove limity a chybejici casti DOM

## Prakticke poznamky

- Na zacatek se vyplati postavit API-first variantu.
- DOM fallback bude pomalejsi a krehci, ale je dulezity jako zachrana.
- Viewer nema blokovat prvni pouzitelny export; muze prijit hned po stabilnim JSON pipeline.
- Sanitizaci vedome nechavame na zaver, ale datovy model s ni musi pocitat.

## Nejblizsi dalsi krok

- Zalozit samotny Python projekt, pripravit `pyproject.toml`, CLI kostru a test stack.

## Current Focus

### Viewer search and filtering hardening

- Opravit `Author filter`, ktery se v aktualni web app vrstve nechova spolehlive.
- Pridat checkbox `case sensitive` do sidebar filtru.
- Default pro `case sensitive` nechat vypnuty.
- `case sensitive` aplikovat jednotne na:
  - hledani v seznamu konverzaci
  - hledani uvnitr vybraneho chatu
  - author filter

### Regex support

- Pridat regex podporu do textovych filtru, ale nepromovat ji v hlavnim GUI.
- V GUI ji jen potichu podporovat.
- Zminit ji pouze v `HELP`, aby si ji pokrocili admini nasli sami.
- Pri nevalidnim regexu vratit srozumitelnou chybu nebo fallback, ne rozbit viewer.

### Cross-chat search

- Navrhnout hledani napric vsemi exportovanymi chaty.
- Umoznit hledat text/regex globalne a vratit:
  - seznam odpovidajicich konverzaci
  - pocet matchu
  - rychly jump do konkretniho chatu
- Tohle brat jako samostatny feature krok az po stabilizaci aktualnich filtru.

### Doporuce poradi implementace

1. Opravit `Author filter`.
2. Pridat `case sensitive` toggle a sjednotit matching logiku.
3. Pridat regex support do existujicich textovych filtru.
4. Az potom navrhnout a implementovat cross-chat search.

## Progress log

### 2026-04-08

- Vytvoren prvni Python scaffold v root workspace.
- Pridany `pyproject.toml`, `src/`, `tests/` a VS Code konfigurace.
- Implementovany prvni CLI prikazy `inspect` a `view` pro praci s exportnim JSON.
- `session-check` a `export` jsou pripraveny jako poctive placeholdery pro dalsi fazi.
- Pridany prvni unit testy a fixture export.
- Playwright doplnen do `.venv`.
- `session-check` povysen na realny browser probe s autodetekci systemoveho browseru a persistent profile workflow.
- Pridany `session-open` pro pohodlne bootstrapnuti login session do projektoveho browser profilu.
- Trusted Types v Teams strance blokuji jak `innerHTML`, tak i `DOMParser.parseFromString(...)`, proto byl parsing `contentHtml` presunut z browseru do Pythonu.
- Export aktivniho chatu uz funguje pres Teams web API a Python parser.
- Doplnen conversation discovery pres `/v1/users/ME/conversations` s pagination pres `_metadata.backwardLink`.
- Pridan CLI prikaz `teams-export chats list` pro discovery vsech konverzaci.
- Pridan CLI prikaz `teams-export export all --outdir ...` s vystupem `index.json` + `chats/*.json`.
- Nazvy chat souboru jsou URL-encoded conversation IDs kvuli cross-OS kompatibilite, hlavne pro Windows.
- Realtime smoke test nad prihlasenou session potvrdil:
  - `1242` discoverable conversations
  - `290` meeting chats
  - funkcni export-all smoke run pro `2` chats
- Dodelana sekundarni discovery cesta pro hidden chaty pres lokalni IndexedDB cache `Teams:conversation-manager`.
- Aktualni tenant probe po merge `API + cache` potvrdil:
  - `1244` discoverable conversations
  - `339` hidden chats
  - hidden conversation IDs jdou normalne exportovat pres stejny messages endpoint jako bezne chaty
- Pridan prikaz `teams-export preview-images` pro best-effort nahledy obrazkovych priloh pres existujici Teams session.
- Pridan lokalni web viewer backend a CLI smer `teams-export serve`.
- Viewer smer byl upraven:
  - TUI zustava doplnek
  - lokalni web viewer je preferovana cesta kvuli Windows a portable distribuci
- Rozpracovan portable bundle plan:
  - `.venv` zustava vyvojovy rezim
  - pro sdileni budeme mirit na zkopirovatelny folder s bundled `python.exe`, zdrojaky, launchery a daty
