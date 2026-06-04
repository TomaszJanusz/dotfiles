# dotfiles CLI — życiowy podręcznik

Praktyczne scenariusze: co robić gdy X. Zorganizowane od najczęstszych do edge case'ów. Code blocks po angielsku (terminal nie zna polskiego), opisy po polsku.

---

## TL;DR — top 10 komend

```bash
dotfiles update          # pull z GitHub + apply (auto brew bundle gdy Brewfile się zmienił)
dotfiles apply           # apply bez pulla
dotfiles diff            # co zmieni apply
dotfiles save            # lokalne zmiany configów → repo (BEZ commita)
dotfiles commit "msg"    # re-add + commit (BEZ pusha)
dotfiles push            # git push
dotfiles sync            # update + save + status
dotfiles flag KEY VAL    # zmień jedną wartość w chezmoi.toml [data]
dotfiles migrate         # zaciągnij nowe promptBoolOnce z templateu bez gum re-run
dotfiles help            # pełna lista
```

Dla nawigacji w shellu:
```bash
dfcd                     # cd do source dir (chezmoi source-path)
```

---

## Mental model

Repo ma dwa **niezależne źródła stanu**:

```
   GitHub (origin)
       ↕  git pull / git push
   Source dir (~/.local/share/chezmoi/)
       ↕  chezmoi apply / chezmoi re-add
   $HOME (real configi)
```

`dotfiles` CLI to wrapper który łączy oba kierunki w spójne workflow:

- **REPO → DOM:** `update` (pull + apply), `apply` (tylko apply)
- **DOM → REPO:** `save` (re-add), `commit`, `push`
- **Inspekcja:** `diff`, `status`, `log`, `path`

---

## dotfiles vs chezmoi — kto co robi

**Reguła:** zawsze najpierw szukaj `dotfiles X`. Jeśli nie ma — fallback do `chezmoi Y`.

| Co chcesz | Komenda |
|---|---|
| pull + apply | `dotfiles update` |
| apply z auto-brew-bundle | `dotfiles apply` |
| diff | `dotfiles diff` |
| status | `dotfiles status` |
| commit + push helpers | `dotfiles save/commit/push/sync` |
| edycja pliku w repo | `dotfiles edit <path>` |
| force re-run scriptów | `dotfiles reset-once` |
| nowa promptBoolOnce flaga | `dotfiles migrate` |
| zmiana wartości flagi | `dotfiles flag KEY VAL` |
| **edycja chezmoi.toml ręczna** | `chezmoi edit-config` |
| **lista trackowanych plików** | `chezmoi managed` |
| **dump state bucket** | `chezmoi state dump` |
| **path do source dir (programatic)** | `chezmoi source-path` |
| **render pojedynczego pliku do stdout** | `chezmoi cat ~/.zprofile` |
| **dry-run apply** | `chezmoi apply -n -v` |
| **execute pojedynczy template** | `chezmoi execute-template < file` |
| **archive snapshot** | `chezmoi archive --output=snapshot.tar` |
| **re-pick gum selekcji** | `dotfiles reinit` (wrapper) lub `chezmoi init` |

---

## Spis treści

1. [Setup i utrzymanie](#1-setup-i-utrzymanie)
2. [Pakiety: dodawanie, usuwanie, modyfikacja](#2-pakiety-dodawanie-usuwanie-modyfikacja)
3. [Configi i dotfiles](#3-configi-i-dotfiles)
4. [Flagi i template inputs](#4-flagi-i-template-inputs)
5. [Synchronizacja DOM ↔ REPO](#5-synchronizacja-dom--repo)
6. [Migracja między maszynami](#6-migracja-między-maszynami)
7. [Troubleshooting](#7-troubleshooting)
8. [Architektura — referencyjna ściągawka](#8-architektura--referencyjna-ściągawka)

---

## 1. Setup i utrzymanie

### 1.1 Świeża maszoba — pierwsza godzina

**Problem:** dostałeś nowego Maca, chcesz mieć cały setup za jednym ruchem.

**Rozwiązanie:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/TomaszJanusz/dotfiles/master/bootstrap.sh)"
```

Skrypt: instaluje Xcode CLT (czeka aktywnie aż się skończy), Homebrew, gum, chezmoi, potem `chezmoi init --apply` (gum prompts → Brewfile → wszystkie skrypty `run_*`).

**Dlaczego nie `curl ... | bash`:** bash przy pipe czyta script body ze stdina, więc `exec </dev/tty` zniszczyłoby skrypt. `bash -c "$(...)"` ładuje całość jako argument, stdin zostaje na TTY → sudo i gum działają.

**Pułapka:** po pierwszym `chezmoi apply` SHELL=zsh aż do **logout/login**. `chsh -s` zmienia default ale aktywna sesja go nie podchwyci. Otwórz nowe okno terminala albo wyloguj się.

**Powiązane:** 6.6, 7.5

---

### 1.2 Codzienne odświeżenie z remote

**Problem:** ktoś (ty sam z drugiej maszyny) wpushował commit, chcesz go zaaplikować.

**Rozwiązanie:**
```bash
dotfiles update
```

Robi: `git pull` w source + `chezmoi apply`. Jeśli rendered `~/.Brewfile` się zmienił (sprawdzane przez shasum przed/po) → auto `brew bundle install`.

**Dlaczego:** `chezmoi update` natywnie = pull + apply. Wrapper dodaje belt-and-suspenders dla bundle install (na wypadek gdyby `run_onchange_after_02` nie wyłapał zmiany).

**Pułapka:** jeśli masz lokalne zmiany w trackowanych plikach (np. ręcznie edytowałeś `~/.config/fish/config.fish`), chezmoi zapyta "X has changed since last write" → patrz 5.5.

**Powiązane:** 5.5, 7.2

---

### 1.3 Apply po lokalnej edycji szablonu w repo

**Problem:** edytowałeś plik w source dir (`dfcd` + edycja + zapis), chcesz zobaczyć efekt w $HOME.

**Rozwiązanie:**
```bash
dotfiles diff           # pokaż co się stanie
dotfiles apply          # zaaplikuj
```

**Dlaczego:** apply nie pulla, więc jeśli zmieniłeś tylko lokalnie i nie chcesz commita teraz, to twoja opcja. Push robisz dopiero gdy gotowy: `dotfiles commit "..." && dotfiles push`.

**Powiązane:** 5.1, 5.2

---

### 1.4 Reinstalacja po wywaleniu czegoś z brew

**Problem:** zrobiłeś `brew uninstall pkg` tymczasowo, ale chcesz go z powrotem (pkg jest w Brewfile).

**Rozwiązanie:**
```bash
brew bundle install --file=~/.Brewfile
```

Idempotentne — instaluje tylko brakujące. Jeśli chcesz wymuszony full reinstall:
```bash
dotfiles reset-once     # czyści state run_once / run_onchange
dotfiles apply          # _02-install-packages odpali się od nowa
```

**Powiązane:** 2.4, 7.3

---

### 1.5 Restart fish/zsh sessionu z fresh env

**Problem:** po zmianach w `~/.zprofile` lub `~/.config/fish/config.fish` bieżąca sesja ich nie widzi.

**Rozwiązanie:**
```bash
exec zsh -l    # zsh login shell (czyta .zprofile)
# lub
exec fish      # fish (czyta config.fish)
```

Bez `exec` powstanie zagnieżdżony shell. Z `exec` zastępuje bieżący proces.

**Pułapka:** Mac apps (Claude Code, Terminal, iTerm) dziedziczą env z `launchd`, nie z twojego shella. Restart aplikacji potrzebny jeśli ma czytać nowe PATH / SHELL.

---

## 2. Pakiety: dodawanie, usuwanie, modyfikacja

### 2.1 Nowy pakiet do gum-selektora (template change)

**Problem:** chcesz dorzucić nową opcję do menu wyboru pakietów (np. `cask "neovim"` w dev-tools).

**Rozwiązanie:**

W repo, edytuj `.chezmoi.toml.tmpl` (sekcja `$devPkgs`) — dodaj `"neovim"` do listy gum choose. Potem `dot_Brewfile.tmpl`:

```
{{ if has "neovim" (splitList "\n" .packages) -}}
cask "neovim"
{{ end -}}
```

Commit + push. Na docelowej maszynie:
```bash
dotfiles update          # ciągnie commit, ale gum NIE odpala
dotfiles reinit          # pull + chezmoi init — przelatuj defaulty, Space na neovim
dotfiles apply           # auto brew bundle zauważy nowy wpis
```

**Dlaczego:** persisted `[data].packages` w `chezmoi.toml` zapamiętuje twoje gum wybory. Nowa opcja w template'cie nie pojawi się magicznie w persisted answers — gum musi się odpalić ponownie.

**Pułapka:** `chezmoi init` wymaże twoje **odznaczone** rzeczy też. Jeśli wcześniej odznaczyłeś `tunnelbear`, w reinit musisz go znowu odznaczyć.

**Powiązane:** 2.2, 4.3

---

### 2.2 Pakiet TYLKO na tej maszynie (poza repo)

**Problem:** chcesz zainstalować coś jednorazowo, nie zapisując do `~/.Brewfile`.

**Rozwiązanie:**
```bash
brew install pkg-name
# lub
brew install --cask app-name
```

Skoro Brewfile jest source of truth, ten pakiet **NIE wróci** sam na inne maszyny. Pearcleaner też go nie pokaże jako "managed". Jeśli kiedyś chcesz dodać do repo: edytuj template, commit, push (patrz 2.1).

**Pułapka:** `brew bundle cleanup --force --file=~/.Brewfile` usunie te pakiety jeśli kiedyś odpalisz. Twoje ad-hoc instalacje są "ekstra".

---

### 2.3 Usunięcie pakietu na zawsze (z repo)

**Problem:** już nie chcesz `cyberduck` nigdzie.

**Rozwiązanie:**
```bash
# 1. W chezmoi.toml usuń z packages
dotfiles edit ~/.config/chezmoi/chezmoi.toml
# (usuń linię z "cyberduck" w stringu packages)

# 2. Apply — Brewfile się odbuduje bez tej linii
dotfiles apply

# 3. Odinstaluj z systemu
brew uninstall --cask cyberduck
```

Dla **wszystkich maszyn** dodatkowo: edytuj `.chezmoi.toml.tmpl` (usuń "cyberduck" z gum choose `--selected` defaults), commit, push.

**Powiązane:** 2.5

---

### 2.4 Tymczasowe wyłączenie pakietu (brew uninstall, nie ruszamy repo)

**Problem:** chcesz na chwilę pozbyć się czegoś (np. Karabiner-Elements szaleje), nie zmieniając konfigu.

**Rozwiązanie:**
```bash
brew uninstall --cask karabiner-elements
```

Pakiet znika z systemu. Brewfile go dalej deklaruje, więc:
- `brew bundle install` ZAINSTALUJE GO Z POWROTEM
- `dotfiles apply` to samo

Aby się NIE wrócił po następnym apply — patrz 2.3 (usuń z repo). Lub dorzuć do `.chezmoiignore` jeśli to bardziej tymczasowe.

---

### 2.5 Cleanup śmieci po cask uninstall

**Problem:** odinstalowałeś app ale w `~/Library/Preferences/`, `~/Library/Application Support/` zostały megabajty configów.

**Rozwiązanie:**
```bash
# Nuklearna: brew zap (usuwa wg deklaracji cask'a)
brew uninstall --zap --cask app-name

# Lub graficzna inspekcja:
open -a Pearcleaner
```

Pearcleaner mamy w utils opt-in. Pokazuje "orphan files" po uninstall, pozwala selektywnie wyciąć.

**Pułapka:** `--zap` nie ma undo. Pearcleaner jest bezpieczniejszy bo widzisz przed kliknięciem.

---

### 2.6 Lista zainstalowanych vs Brewfile drift

**Problem:** chcesz zobaczyć co jest zainstalowane ad-hoc (poza Brewfile).

**Rozwiązanie:**
```bash
brew bundle check --file=~/.Brewfile --verbose
# pokaże missing/extra

# Lub porównanie pełne:
brew bundle dump --file=/tmp/current.Brewfile --force
diff -u ~/.Brewfile /tmp/current.Brewfile
```

`+` (po prawej) = masz zainstalowane ale nie w repo (ad-hoc). `-` = w repo ale nie zainstalowane.

---

## 3. Configi i dotfiles

### 3.1 Nowy plik konfiguracyjny do trackingu

**Problem:** zainstalowałeś `httpie` i masz `~/.config/httpie/config.json` z customizacjami. Chcesz to mieć na innych maszynach.

**Rozwiązanie:**
```bash
chezmoi add ~/.config/httpie/config.json
```

Plik trafi do `~/.local/share/chezmoi/private_dot_config/httpie/config.json` (zgodnie z naming convention: `~/.config/` → `private_dot_config/`). Potem:
```bash
dotfiles commit "track httpie config"
dotfiles push
```

**Pułapka:** jeśli plik zawiera **sekrety** (tokeny API itp.) — patrz 3.5.

---

### 3.2 Edycja istniejącego trackowanego pliku

**Problem:** chcesz zmienić swój `~/.gitconfig` (który jest w repo jako `dot_gitconfig.tmpl`).

**Rozwiązanie:**
```bash
dotfiles edit ~/.gitconfig
```

To otworzy plik w source dir (NIE w `$HOME`). Po zapisaniu chezmoi sam zaaplikuje. Pod spodem to `chezmoi edit ~/.gitconfig`.

**Alternatywa:** edytuj plik w $HOME, potem `dotfiles save` wciągnie zmianę z powrotem do repo.

---

### 3.3 Per-machine variants (template conditionals)

**Problem:** maszyna A ma być w trybie X, maszyna B w Y. Jeden config plik.

**Rozwiązanie:**

W repo, plik jako `.tmpl`:
```
private_dot_config/somelapp/config.tmpl
```

Treść:
```
{{ if eq .chezmoi.hostname "MBP-TJ" -}}
mode = "personal"
{{ else -}}
mode = "work"
{{ end -}}
```

Inne zmienne dostępne: `.chezmoi.os`, `.chezmoi.arch`, `.chezmoi.username`, plus twoje flagi z `chezmoi.toml [data]`.

**Powiązane:** 4.1

---

### 3.4 Plik który app modyfikuje runtime (use create_ prefix)

**Problem:** trackujesz `~/.config/omf/bundle` ale OMF go modyfikuje (zmienia mode, dodaje komentarze) → chezmoi pyta "has changed since last write?" przy każdym apply.

**Rozwiązanie:**

W source dir, dopisz prefix `create_`:
```
private_dot_config/omf/create_bundle
```

Po tym chezmoi pisze plik **tylko gdy nie istnieje** (na fresh maszynie). Potem nie ingeruje, OMF może modyfikować.

**Trade-off:** edycja `create_bundle` w repo **nie zsyncuje się** do maszyn które już mają ten plik. Pojawia się tylko przy fresh installu.

**Powiązane:** 5.5, 7.8

---

### 3.5 Sensytywne configi (sekrety, tokeny) — strategia

**Problem:** twój `~/.config/gh/hosts.yml` ma token GitHub. Nie chcesz w plain text w gicie.

**Rozwiązania (kolejność od najprostszego):**

**A) Nie trackuj go w ogóle.** Manual import via 1Password Secure Note przy fresh install.

**B) Trackuj jako template z `op://` referencjami** (jeśli używasz 1Password CLI):
```
github_token = {{ onepasswordRead "op://Personal/GitHub Token/credential" }}
```
Wymaga `op` zainstalowanego i sesji `eval $(op signin)` przed apply.

**C) `encrypted_` prefix z age.** Setup `age-keygen`, klucz prywatny w 1Password jako Secure Note. W repo `encrypted_dot_config/gh/hosts.yml.age` — czytelny tylko z kluczem.

Patrz 6.4 dla pełnego age setupu.

---

### 3.6 Hardlink/symlink vs tracked file

**Problem:** chcesz żeby plik w `$HOME` był symlinkiem do innej lokalizacji, nie kopią.

**Rozwiązanie:**

W source dir, prefix `symlink_`:
```
symlink_dot_config/zed/settings.json
```

Treść pliku = ścieżka targetu (literalnie tekst tej ścieżki). Chezmoi przy apply utworzy symlink zamiast kopii.

**Typowy use case:** ujednolicenie configów między aplikacjami (vscode insider używa tych samych settings co stable).

---

## 4. Flagi i template inputs

### 4.1 Nowa boolean flaga (promptBoolOnce)

**Problem:** dorzuciłeś nową flagę do `.chezmoi.toml.tmpl`:
```
{{- $disableGatekeeper := promptBoolOnce . "disable_gatekeeper" "Disable Gatekeeper?" false -}}
```

Na żywej maszynie chcesz ją "podchwycić" bez gum re-run'u.

**Rozwiązanie:**
```bash
dotfiles update
dotfiles migrate         # skanuje template, znajduje brakujące flagi, promptuje tylko o nie
dotfiles apply
```

**Dlaczego:** `chezmoi init` byłoby destructive (re-run gum). `migrate` grepuje template za `promptBoolOnce` / `promptStringOnce`, sprawdza obecność w `chezmoi.toml`, prompts tylko o nowe. Gum nietknięty.

**Pułapka:** `migrate` parsuje template prostym regexem — działa tylko dla standardowego stylu `promptBoolOnce . "key" "desc" default`. Skomplikowane wyrażenia może przeoczyć.

**Powiązane:** 4.2

---

### 4.2 Zmiana istniejącej flagi

**Problem:** chcesz wyłączyć debloat (`debloat_macos = false` zamiast `true`).

**Rozwiązanie:**
```bash
dotfiles flag debloat_macos false
dotfiles apply
```

Wrapper robi atomic edit `~/.config/chezmoi/chezmoi.toml` z backup'em `.bak`. Auto-quote'uje stringi, leaves bool/int bare.

Jeśli flaga jest zworą dla skryptu `run_onchange_*`, jego hash się zmieni → re-run.

**Powiązane:** 8.2

---

### 4.3 Nowy gum prompt (NOT incremental — wymaga reinit)

**Problem:** dodajesz całą nową grupę pakietów (np. `"gaming"` w `$groups`).

**Rozwiązanie:**
```bash
dotfiles update
dotfiles reinit          # przelatujesz wszystkie gum ekrany
dotfiles apply
```

**Dlaczego nie ma `dotfiles migrate` dla gum:** gum nie używa `promptBoolOnce` (które chezmoi rozumie). Wywoływany jest przez `output "gum" "choose" ...` — zwykły shell command. Chezmoi nie wie że to "input".

**Wskazówka:** gdy `chezmoi init` re-runuje gum, **defaults pochodzą z `--selected` w template**, nie z twoich poprzednich wyborów. Twoje persisted `packages` zostanie nadpisane.

**Powiązane:** 2.1

---

### 4.4 Karabiner rule toggle

**Problem:** chcesz dodać/usunąć indywidualną rule Karabinera (np. wyłączyć Krux mapping).

**Rozwiązanie:**

Karabiner rules są opt-in flagami w `[data].packages`:
- `karabiner-krux`
- `karabiner-k380`
- `karabiner-coma`

```bash
# Dodanie:
dotfiles flag packages "$(chezmoi data | jq -r '.packages')
karabiner-krux"

# Lub łatwiej:
chezmoi edit-config
# w packages dopisz \nkarabiner-krux przed cudzysłowem zamykającym
dotfiles apply
```

`karabiner.json.tmpl` w repo używa `.chezmoitemplates/karabiner-rule-{krux,k380,coma}.json` + sprig `has` żeby warunkowo wkleić rule.

**Powiązane:** 8.4

---

## 5. Synchronizacja DOM ↔ REPO

### 5.1 Save: lokalna edycja configów → repo

**Problem:** edytowałeś `~/.config/ghostty/config.ghostty` wprost (z aplikacji), chcesz to wciągnąć do repo.

**Rozwiązanie:**
```bash
dotfiles save
```

Robi: `chezmoi re-add` (przekopiowuje zmieniony plik z $HOME do source) + `git status` (żebyś zobaczył co się zmieniło). **NIE commituje.**

Następnie:
```bash
dotfiles commit "tweak ghostty palette"
dotfiles push
```

**Dlaczego nie auto-commit:** żebyś świadomie zobaczył diff przed gitowaniem (sekret może się prześliznąć).

---

### 5.2 Commit + push standardowy flow

**Problem:** masz zmiany w source dir (po `save` albo po `dotfiles edit`), chcesz je wysłać.

**Rozwiązanie:**
```bash
dotfiles commit "your message"   # re-add + git add -A + git commit
dotfiles push                     # git push
```

Albo skrót dla obu:
```bash
dotfiles commit "msg" && dotfiles push
```

**Pułapka:** jeśli SSH agent (1Password) nie działa → "Could not connect to socket". Patrz 7.4.

---

### 5.3 Co jeśli zapomniałem commit i przyleciał update?

**Problem:** masz lokalne zmiany w source dir, nagle `git pull` mówi "would overwrite local changes".

**Rozwiązanie:**
```bash
dfcd                              # cd do source
git stash                         # schowaj zmiany
git pull
git stash pop                     # przywróć — możliwy konflikt do merge
```

Po rozwiązaniu konfliktów:
```bash
dotfiles commit "merge: ..."
dotfiles push
```

---

### 5.4 Drift detection — co odbiega od repo

**Problem:** chcesz wiedzieć które trackowane configi zmieniły się względem repo (np. po długim okresie braku sync).

**Rozwiązanie:**
```bash
dotfiles status               # zwięzła lista plików z różnicami
dotfiles diff                 # pełne diff'y
```

`status` używa `chezmoi status` (krótki summary), `diff` używa `chezmoi diff` (full unified format).

---

### 5.5 chezmoi prompts "file has changed since last write"

**Problem:** podczas apply chezmoi zatrzymuje się i pyta:
```
.config/foo/bar has changed since chezmoi last wrote it.
```

**Co to znaczy:** plik w $HOME różni się od tego co chezmoi by chciał nadpisać (z source). Coś (app, ty, system) go zmodyfikowało.

**Rozwiązanie:**
- `d` — pokaż **diff** (zawsze najpierw to)
- `o` — **overwrite** lokalne, zastosuj wersję z repo
- `s` — **skip**, zostaw lokalne (chezmoi zapyta znów następnym razem)
- `a` — **abort**, przerwij cały apply

Po `d` zdecyduj na podstawie diff'a:
- Twoja zmiana którą chcesz mieć w repo → `s`, potem `dotfiles save`
- Diff tylko trywialne (jak mode 600 → 644 dla OMF) → patrz 3.4 (`create_` prefix)
- Stara śmieć w $HOME, repo ma poprawny stan → `o`

**Pułapka:** **nigdy `o` przed obejrzeniem `d`.**

**Powiązane:** 3.4

---

## 6. Migracja między maszynami

### 6.1 Plan: "Personal data exports" w 1Password

**Strategia:** trzymaj jeden Secure Note w 1Password ze wszystkimi prywatnymi backupami w attachmentach. Na nowej maszynie pobierasz, importujesz.

Sugerowany layout Secure Note "Personal data exports":
- `wallpaper.jpeg` (single tapeta)
- `eqmac-backup.plist` (z `defaults export com.bitgapp.eqmac`)
- `browser-extensions/ublock.txt`, `browser-extensions/sponsorblock.json`
- `claude-archive.tar.gz` (history + plans + settings)
- `age-key.txt` (jeśli używasz encrypted)

**Dlaczego 1Password a nie iCloud Drive:** 1Password ma e2e bez Advanced Data Protection, iCloud nie zawsze.

---

### 6.2 Co przenosić ręcznie

| Co | Skąd | Jak |
|---|---|---|
| Tapeta | `~/Documents/Tapety/` (lub gdzie masz) | manual copy via 1P |
| eqMac config | `defaults export com.bitgapp.eqmac` | plist w 1P |
| uBlock filters | uBlock UI → Backup | .txt w 1P |
| SponsorBlock config | SponsorBlock UI → Export config | .json w 1P |
| Claude Code history | `~/.claude/projects/` + `plans/` + `history.jsonl` | rsync/tar via 1P attachment |
| Notion-CLI auth | `~/.config/notion-cli/` | manual import lub re-auth |
| Karabiner per-machine state | `~/.config/karabiner/automatic_backups/` | **nie przenoś** — per-maszyna |

**Powiązane:** 6.3

---

### 6.3 Co robi to za nas chezmoi

Automatycznie po `chezmoi apply` na fresh maszynie:
- `~/.agents/skills/` z `dot_agents/` (caveman skills itd.)
- Symlinki `~/.claude/skills/*` → `~/.agents/skills/*` (przez `run_after_06`)
- Fish/zsh configi
- Git config
- Karabiner config (jeśli `karabiner-elements` wybrany w gum)
- Ghostty config
- Zed settings + extensions (`auto_install_extensions`)
- LaunchAgent dla cleanup-old-files

**NIE robi:** żadne sekrety, sesje, cache, dane prywatne.

---

### 6.4 Setup age encryption (jeśli kiedyś)

**Problem:** chcesz mieć prywatne pliki w gicie ale zaszyfrowane.

**Setup jednorazowy:**
```bash
brew install age

# 1. Generuj klucz
age-keygen -o ~/.config/chezmoi/key.txt
# Output: "Public key: age1abc..." — zapamiętaj public

# 2. Zabezpiecz private key — wrzuć całą zawartość ~/.config/chezmoi/key.txt
#    do 1Password jako Secure Note "Chezmoi Age Key"

# 3. Konfiguracja chezmoi
cat >> ~/.config/chezmoi/chezmoi.toml <<EOF

encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1abc..."
EOF
```

**Użycie:**
```bash
chezmoi add --encrypt ~/.config/gh/hosts.yml
# W repo pojawi się: encrypted_private_dot_config/gh/hosts.yml.age
```

**Na nowej maszynie:**
```bash
brew install age
# 1Password → pobierz Chezmoi Age Key → zapisz do ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
# chezmoi init/apply rozszyfruje encrypted_* sam
```

---

### 6.5 Path-encoded gotchas

**Problem:** twoje stare Claude Code sesje są pod `~/.claude/projects/-Users-tomaszjanusz-Projekty-dotfilesv2/`. Na nowej maszynie projekt jest w `~/Developer/dotfilesv2`.

**Rozwiązanie:** ukryty symlink `~/Projekty → ~/Developer` (mamy go jako flagę `projekty_symlink`):

```bash
dotfiles flag projekty_symlink true
dotfiles apply
# lub manualnie:
ln -s ~/Developer ~/Projekty && chflags hidden ~/Projekty
```

Claude widzi `~/Projekty/dotfilesv2`, prawdziwe pliki w `~/Developer/dotfilesv2`. Historia działa.

**Powiązane:** 8.1

---

### 6.6 Fresh maszyna step-by-step

```bash
# 1. Bootstrap
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/TomaszJanusz/dotfiles/master/bootstrap.sh)"

# 2. Czekaj — gum zapyta o name/email/grupy/pakiety
# Wszystkie ekrany przejdź świadomie. Defaults z template'u są w większości OK.

# 3. Po skończeniu apply, wyloguj i zaloguj się (chsh fish wchodzi w życie)

# 4. Importy prywatne z 1Password (Personal data exports note):
#    - tapeta → System Settings → Wallpaper
#    - eqMac → defaults import
#    - uBlock/SponsorBlock → app UI
#    - Claude history → rsync do ~/.claude/

# 5. Symlink dla Claude path encoding (jeśli go używasz):
dotfiles flag projekty_symlink true
dotfiles apply

# 6. Manual sidebar Findera (drag-and-drop Developer/Screenshots)
```

Czas total: ~30-60 min (głównie brew bundle).

---

## 7. Troubleshooting

### 7.1 Warning "config file template has changed"

**Problem:**
```
chezmoi: warning: config file template has changed, run chezmoi init to regenerate config file
```

**Co to znaczy:** hash `.chezmoi.toml.tmpl` różni się od stanu zapisanego przy ostatnim init. Czyli template ewoluował (np. dorzucono nowe `promptBoolOnce`).

**Rozwiązanie (non-destructive):**
```bash
dotfiles migrate         # promptuje tylko o nowe promptBoolOnce/StringOnce
```

Jeśli to gum-related (nowa opcja w `gum choose`) — patrz 4.3 (wymaga reinit).

Warning może utrzymywać się aż do pełnego `chezmoi init` (który ustawia hash zapisany). To **kosmetyczne**, nic nie psuje.

---

### 7.2 Skrypt nie odpalił po update

**Problem:** edytowałeś `run_once_after_05-debloat.sh.tmpl`, push'nąłeś, `dotfiles update` ale skrypt się nie odpalił.

**Diagnoza:**
```bash
chezmoi state dump | jq '.scriptState'
# pokaż które skrypty są zarejestrowane jako "done"
```

**Możliwe przyczyny:**

1. **`run_once_*` ran already** — nie odpali się znów. Zmień nazwę na `run_onchange_after_*` LUB:
   ```bash
   dotfiles reset-once  # czyści cały scriptState
   ```

2. **`run_onchange_*` ma stały hash** — twoja edycja nie zmieniła rendered output (np. dodałeś komentarz wewnątrz `{{ if false }}` bloku). Sprawdź:
   ```bash
   chezmoi cat .chezmoiscripts/run_onchange_after_05-debloat.sh.tmpl
   ```

3. **Skrypt jest ignorowany** — sprawdź `.chezmoiignore`.

**Powiązane:** 8.2

---

### 7.3 brew bundle failed mid-way

**Problem:** install się wykrzaczył na środku (network drop, sudo timeout, pakiet bez Gatekeeper signature).

**Rozwiązanie:**
```bash
# 1. Sprawdź który pakiet
brew bundle check --file=~/.Brewfile --verbose | head -20

# 2. Zainstaluj resztę
brew bundle install --file=~/.Brewfile

# 3. Dla problematycznego pakietu — ręczna decyzja
brew install --cask problematic-app --no-quarantine   # jeśli Gatekeeper marudzi
# lub usuń z Brewfile jeśli nie ma już sensu
```

`brew bundle install` jest **idempotentne** — kolejny run pomija już zainstalowane, kontynuuje od niedokończonych.

**Pułapka:** czasem cask w Homebrew zmienił nazwę (np. `helium` → `helium-browser`). Sprawdź `brew info --cask <name>`.

---

### 7.4 SSH agent socket nie odpowiada (1Password)

**Problem:**
```
error: 1Password: Could not connect to socket. Is the agent running?
```

**Diagnoza:**
```bash
echo $SSH_AUTH_SOCK
# Powinno być: ~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock
# Jeśli inna ścieżka (np. /var/run/com.apple.launchd...) — env nie załadowane
```

**Rozwiązania:**

1. **Włącz SSH agent w 1Password app:** Settings → Developer → enable "Use the SSH agent". Plus włącz Touch ID dla auth jeśli chcesz.

2. **Re-export socket dla bieżącej sesji:**
   ```bash
   export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
   ```

3. **Trwale (mamy w `dot_zprofile.tmpl` i fish config):** otwórz nowe okno terminala, env się załaduje.

4. **Verify:**
   ```bash
   ssh-add -l    # powinna pokazać klucze Ed25519 z 1Password
   ```

---

### 7.5 PATH nie widzi nowych narzędzi po brew install

**Problem:** `brew install foo` zakończony, `foo: command not found`.

**Rozwiązanie:**
```bash
# Quick fix dla bieżącej sesji:
eval "$(/opt/homebrew/bin/brew shellenv)"

# Lub direct path:
/opt/homebrew/bin/foo

# Stałe: nowe okno terminala (login shell czyta .zprofile gdzie mamy brew shellenv)
exec zsh -l
```

**Dlaczego:** Brew umieszcza binaria w `/opt/homebrew/bin/`. PATH dodawany przez `~/.zprofile` (zsh login shells) lub fish config. Nie-login-shells (np. zagnieżdżony subshell) nie wczytują tych skryptów.

---

### 7.6 Dock/Spotlight zmiany nie weszły

**Problem:** zmieniłeś `defaults write com.apple.symbolichotkeys ...`, `killall cfprefsd`, ale Spotlight nadal na Cmd+Space.

**Rozwiązanie:** **logout/login** (niezbędne dla symbolichotkeys daemon).

Niektóre `defaults` wystarczy `killall Dock/Finder/SystemUIServer`. Symbolichotkeys to wyjątek — session daemon czyta config tylko przy starcie sesji.

---

### 7.7 dockutil --remove "X" nie znalazł apki

**Problem:** w debloat logach:
```
(skip: 'FaceTime' not in Dock)
```

ale FaceTime jest w Docku.

**Diagnoza:**
```bash
dockutil --list
# Pokaże faktyczne nazwy (mogą być zlokalizowane!)
```

**Rozwiązanie:** jeśli FaceTime jest jako "FaceTime" w polskim macOS, ale plist klucz "FaceTime.app" — dopisz alternatywne nazwy do `DOCK_REMOVE` w `run_onchange_after_05-debloat.sh.tmpl`.

---

### 7.8 Plik się "wraca" przy każdym apply

**Problem:** chezmoi pyta o ten sam plik co apply ("X has changed since last write").

**Diagnoza:** app modyfikuje plik runtime (mode, kolejność kluczy, dopisany komentarz). Twoja wersja w repo i ta w $HOME wiecznie się rozjeżdżają.

**Rozwiązanie:**
- Jeśli zmiany mode-only / kosmetyczne → użyj `create_` prefix (patrz 3.4)
- Jeśli app pisze realne dane → nie trackuj tego pliku, dodaj do `.chezmoiignore`

---

## 8. Architektura — referencyjna ściągawka

### 8.1 Prefiksy chezmoi

W source dir, prefix w nazwie pliku/katalogu determinuje co chezmoi zrobi z target'em:

| Prefix | Efekt na targecie |
|---|---|
| `dot_X` | `~/.X` |
| `private_X` | mode 0700 (dir) lub 0600 (file) |
| `executable_X` | mode +x |
| `readonly_X` | mode 0444 |
| `symlink_X` | utwórz symlink (zawartość pliku = ścieżka targetu) |
| `create_X` | pisz **tylko jeśli nie istnieje** w targecie |
| `modify_X` | uruchom plik jako filter na istniejącej zawartości |
| `encrypted_X` | rozszyfruj przez age/gpg przed zapisem |
| `X.tmpl` | rendered przez Go template engine |

Można kombinować: `private_executable_dot_local/bin/cleanup-old-files.sh` → `~/.local/bin/cleanup-old-files.sh`, mode 0700.

---

### 8.2 Skrypty run_* — typy, kolejność, kiedy używać którego

W `.chezmoiscripts/`:

| Prefix | Kiedy odpala |
|---|---|
| `run_X` | **każdy** apply |
| `run_onchange_X` | gdy rendered content się zmienił (hash diff) |
| `run_once_X` | **raz w życiu** maszyny (po pierwszym sukcesie, nigdy więcej — chyba że `reset-once`) |
| `run_before_X` | przed copy stage (przed zaaplikowaniem plików) |
| `run_after_X` | po copy stage |

Kolejność wewnątrz danego typu = **alfabetyczna** (stąd numerowanie `_01_`, `_02_`).

**Reguły praktyczne:**
- Setup OS (brew install) → `run_once_before_01`
- Install packages → `run_onchange_after_02` (zmienia się gdy Brewfile/packages się zmieniają)
- Setup shell (chsh) → `run_once_after_03` (raz wystarczy)
- macOS defaults z conditional blokami → `run_onchange_after_04` (re-runs gdy flaga się zmieni)
- Symlinki które trzeba odświeżać → `run_after_*` (każdy apply)

---

### 8.3 Brewfile template — has vs contains, kolizje nazw

W `dot_Brewfile.tmpl` warunkowe wpisy używają sprig:

```
{{ if contains "codex" .packages -}}        ← BAD: substring match
cask "codex"
{{ end -}}

{{ if has "codex" (splitList "\n" .packages) -}}    ← GOOD: exact element
cask "codex"
{{ end -}}
```

`contains "codex"` zwróci true gdy `packages` zawiera "codex" albo "codex-app" — kolizja.

`has` + `splitList "\n"` to exact membership — gwarantuje tylko match-y "codex" jako pełnej linii.

**Kiedy ważne:** gdy masz pakiety o podobnych nazwach (`codex` + `codex-app`, hypoteycznie `claude` + `claude-code`).

---

### 8.4 .chezmoitemplates/ — fragmenty do reuse

W source: `.chezmoitemplates/` zawiera fragmenty NIE deploy'owane jako pliki, tylko `includeTemplate`-owalne z innych szablonów.

**Przykład — `karabiner.json.tmpl`:**
```
{{- $rules := list -}}
{{- if has "karabiner-krux" (splitList "\n" .packages) -}}
{{-   $rules = append $rules (includeTemplate "karabiner-rule-krux.json" .) -}}
{{- end -}}
{
  "profiles": [{
    "complex_modifications": { "rules": [{{ join "," $rules }}] }
  }]
}
```

Pliki `karabiner-rule-{krux,k380,coma}.json` w `.chezmoitemplates/` to JSON fragmenty włączane warunkowo.

---

## Appendix: cheat sheet

```
╔════════════════════════════════════════════════════════════════════╗
║                  dotfiles CLI — quick reference                    ║
╠════════════════════════════════════════════════════════════════════╣
║ PULL                  PUSH                  INSPECT                ║
║ update / up           save                  diff / d               ║
║ apply  / a            commit <msg>          status / st            ║
║ sync                  push                  log / l                ║
║                                             path                   ║
║                                                                    ║
║ CONFIG                MAINTENANCE           HELP                   ║
║ flag KEY VAL          reset-once            help                   ║
║ migrate               reinit                                       ║
║ edit FILE                                                          ║
║                                                                    ║
║ RAW CHEZMOI (poza wrapperem)                                       ║
║ chezmoi edit-config    chezmoi managed     chezmoi cat FILE        ║
║ chezmoi state dump     chezmoi source-path chezmoi archive         ║
║ chezmoi execute-template < file                                    ║
╚════════════════════════════════════════════════════════════════════╝
```

**Fish completion:** `dotfiles <TAB>` pokaże komendy + opisy. `dfcd` cd-uje do source dir.
