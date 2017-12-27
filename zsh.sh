#!/bin/sh
brew install zsh
brew install zsh-autosuggestions
brew install zsh-completions
export ZSH="$HOME/dotfiles/oh-my-zsh"; sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install zsh-syntax-highlighting
brew install zsh-history-substring-search
brew install zsh-navigation-tools
brew install zsh-syntax-highlighting
