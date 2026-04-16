# dotfiles

macOS development environment managed with [chezmoi](https://www.chezmoi.io/).

## Quick start

On a fresh macOS, run:

```bash
curl -fsSL https://raw.githubusercontent.com/tjanuszdev/dotfiles/master/bootstrap.sh | bash
```

Or step by step:

```bash
# Install Homebrew, gum, and chezmoi
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gum chezmoi

# Initialize and apply dotfiles (interactive package selector)
chezmoi init --apply tjanuszdev
```

## What's included

**Shell:** Fish + Oh My Fish (robbyrussell theme, bang-bang, bass, brew)

**Core tools:** git, gh, fzf, ripgrep, fd, zoxide, tree, GNU coreutils/findutils/sed

**Runtimes:** Node, Bun, Deno

**Apps:** Ghostty, Raycast, OrbStack, Fork, 1Password, Chrome, Firefox

**Optional groups** (selected during setup via interactive TUI):
- Dev tools (WebStorm, Zed, VS Code, Karabiner, Dash, Go, Alfred)
- Productivity (Obsidian, Notion, MailMate, Claude, ChatGPT, PopClip, Rectangle Pro)
- Media (VLC, HandBrake, Transmission, Downie, Camtasia, Snagit)
- Security (GPG Suite, LuLu, Signal, TunnelBear, Windscribe)
- Utils (tmux, ncdu, thefuck, Pearcleaner, Cyberduck, balenaEtcher)
- macOS extras (QuickLook plugins, App Store apps via mas)

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
.chezmoiscripts/            # Automated setup scripts
  run_once_before_01-*      # Install Homebrew
  run_once_before_02-*      # Install packages (brew bundle)
  run_once_after_03-*       # Setup Fish shell + OMF
  run_once_after_04-*       # Configure macOS defaults
```
