#!/bin/bash
set -euo pipefail

# Re-attach stdin to controlling TTY when invoked via `curl | bash` —
# otherwise sudo can't prompt for password, gum/chezmoi prompts can't read input,
# and `read` returns immediately on EOF instead of waiting.
if [ ! -t 0 ] && [ -e /dev/tty ]; then
    exec </dev/tty
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
