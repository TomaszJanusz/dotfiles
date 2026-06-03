# dotfiles

macOS development environment managed with [chezmoi](https://www.chezmoi.io/).

## Quick start

On a fresh macOS, run:

```bash
curl -fsSL https://raw.githubusercontent.com/TomaszJanusz/dotfiles/master/bootstrap.sh | bash
```

Or step by step:

```bash
# Install Homebrew, gum, and chezmoi
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gum chezmoi

# Initialize and apply dotfiles (interactive package selector)
chezmoi init --apply https://github.com/TomaszJanusz/dotfiles.git
```

## What's included

**Shell:** Fish + Oh My Fish (robbyrussell theme, bang-bang, bass, brew)

**Core tools:** git, gh, fzf, ripgrep, fd, zoxide, tree, GNU coreutils/findutils/sed

**Runtimes:** Node, Bun, Deno

**Core apps:** Ghostty, Raycast, OrbStack, Fork, 1Password

**Optional groups** (selected during setup via interactive TUI):
- Dev tools (WebStorm, Zed, VS Code, VS Code Insiders, Karabiner, Dash, Go, Alfred)
- Productivity (Obsidian, Notion, MailMate, Claude, ChatGPT, PopClip, Rectangle Pro)
- Media (VLC, HandBrake, Transmission, Downie, Camtasia, Snagit, eqMac)
- Security (GPG Suite, LuLu, Signal, TunnelBear, Windscribe)
- Utils (tmux, cmux, ncdu, thefuck, Pearcleaner, Cyberduck, balenaEtcher)
- macOS extras (QuickLook plugins, App Store apps via mas — incl. Infuse)
- Browsers (Google Chrome, Google Chrome Dev, Firefox, Firefox Developer Edition, Brave Browser Beta)
- AI (OpenCode, Gemini CLI, Codex, Claude Code)
- Design (Affinity v3, Inkscape)

## Usage

```bash
# Re-run setup (won't re-prompt, uses saved config)
chezmoi apply

# Update from remote
chezmoi update

# Add a new dotfile
chezmoi add ~/.some-config

# Edit a managed file
chezmoi edit ~/.config/fish/config.fish

# See what would change
chezmoi diff

# Re-run interactive setup (change package selections)
chezmoi init
chezmoi apply
```

## Post-migration verification

After the first `chezmoi apply`, run this quick checklist to confirm the migrated setup matches the machine state and can be applied repeatedly without drift.

```bash
# No unexpected changes between source state and target files
chezmoi diff

# Dry-run the next apply with verbose output
chezmoi apply -n -v

# Verify Fish environment
fish -c 'echo $PATH'
fish -c 'echo $SSH_AUTH_SOCK'

# Verify Git identity and signing settings
git config --global user.email
git config --global gpg.format

# Verify tmux defaults
tmux show-option -g mouse

# Verify Oh My Fish packages
fish -c 'omf list'

# Verify Homebrew bundle state
brew bundle check --global

# Idempotency test: running apply again should not introduce unexpected changes
chezmoi apply -v
```

## Structure

```
.chezmoi.toml.tmpl          # Interactive setup prompts (gum TUI)
dot_gitconfig.tmpl          # Git config with 1Password SSH signing
dot_Brewfile.tmpl           # Homebrew packages (conditional per selection)
bootstrap.sh                # One-command setup for fresh macOS
private_dot_config/         # ~/.config/ managed files
  fish/                     # Fish shell config
  omf/                      # Oh My Fish packages
  tmux/                     # tmux config
dot_agents/                 # ~/.agents/ — Vercel skills source of truth
  skills/                   # Skill folders (caveman-*, copywriting, etc.)
.chezmoiscripts/            # Automated setup scripts
  run_once_before_01-*      # Install Homebrew
  run_once_before_02-*      # Install packages (brew bundle)
  run_once_after_03-*       # Setup Fish shell + OMF
  run_once_after_04-*       # Configure macOS defaults
  run_once_after_05-*       # Debloat macOS (opt-in)
  run_once_after_06-*       # Symlink ~/.agents/skills/ into per-agent dirs
```

## Agent skills (`~/.agents/`)

Skille z `~/.agents/skills/` są źródłem prawdy ([Vercel layout](https://github.com/vercel-labs/skills/blob/main/AGENTS.md)). Po `chezmoi apply`:

- pliki lądują w `~/.agents/skills/{nazwa}/`
- skrypt `run_once_after_06` tworzy symlinki `~/.{claude,codex,cursor,opencode,zed,gemini-cli,antigravity}/skills/{nazwa}` → `~/.agents/skills/{nazwa}`
- `.skill-lock.json` jest **ignorowany** — to runtime state z absolutnymi ścieżkami Commander Marketplace, generuje go `npx skills` lokalnie

Żeby dodać nowy skill: skopiuj folder do `dot_agents/skills/` i `chezmoi apply` — symlinki odświeżą się automatycznie.

## macOS debloat (opt-in)

Włączane promptem `debloat_macos` przy `chezmoi init`. Skrypt `run_once_after_05`:

- czyści Dock z bloatu (Mail, Maps, TV, News, Stocks, Freeform, App Store...) przez `dockutil`
- wyłącza background daemony (`com.apple.newsd`, `stocksd`, `gamed`, `parsecd`, podcast service) przez `launchctl disable` (reversible)
- wyłącza Siri i Spotlight Suggestions
- wycina bloat z wyników Spotlight (Music, Movies, Fonts, ...)

**Uwaga:** na Apple Silicon **nie usuwamy** plików `.app` — Signed System Volume to blokuje, a próby psują OS updates. Apps zostają zainstalowane, ale są wyciszone.

## iPhone Mirroring w EU

Apple blokuje iPhone Mirroring w UE z powodu DMA. Istnieje workaround ([timi2506/iphone-mirroring-eu-activate](https://github.com/timi2506/iphone-mirroring-eu-activate)) edytujący `/private/var/db/os_eligibility/eligibility.plist`, ale wymaga:

- wyłączenia SIP (recovery boot + `csrutil disable`)
- ręcznego `Get Info → Locked` w Finderze, żeby plist nie został nadpisany
- patcha po stronie iPhone'a (SparseRestore / TrollRestore)
- pełnego ponownego setupu po każdym OS update

**Świadomie nie integrujemy tego z chezmoi** — wymaga reboota do recovery, manual UI step, wyłącza Apple Pay i część DRM, nie jest idempotentne. Jeśli zdecydujesz się włączyć, zrób to jednorazowo poza pipeline i akceptuj koszt re-aplikowania przy update'ach.
