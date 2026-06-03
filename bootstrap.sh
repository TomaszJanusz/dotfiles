#!/bin/bash
set -euo pipefail

# IMPORTANT: this script must be invoked via `bash -c "$(curl ...)"` — NOT
# `curl ... | bash`. In the pipe form, bash reads its script body from stdin,
# so we can't redirect stdin to /dev/tty for sudo/gum/chezmoi prompts without
# truncating the script itself.
if [ ! -t 0 ]; then
    echo "stdin is not a TTY." >&2
    echo "Run via: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/TomaszJanusz/dotfiles/master/bootstrap.sh)\"" >&2
    exit 1
fi

echo "=== Dotfiles Bootstrap ==="
echo ""

# 1. Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install >/dev/null 2>&1 || true

    echo "Waiting for Xcode CLT installation to finish (this can take 5–15 minutes)..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    echo "Xcode CLT installed."
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for this session
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# 3. Install gum (TUI toolkit) and chezmoi
echo "Installing gum and chezmoi..."
brew install gum chezmoi

# 4. Initialize and apply dotfiles
echo ""
echo "Starting dotfiles setup..."
echo ""
chezmoi init --apply https://github.com/TomaszJanusz/dotfiles.git

echo ""
echo "=== Bootstrap complete! ==="
echo "Open a new terminal to start using fish shell."
