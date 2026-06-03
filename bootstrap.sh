#!/bin/bash
set -euo pipefail

echo "=== Dotfiles Bootstrap ==="
echo ""

# 1. Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo ""
    echo "Press any key after Xcode CLT installation completes..."
    read -n 1
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
