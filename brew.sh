#!/bin/bash
echo "Do you wish to install Homebrew?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" break;;
        No ) break;;
    esac
done
# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# GNU core utilities (those that come with OS X are outdated)
brew install coreutils
brew install moreutils
# GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
brew install findutils
# GNU `sed`, overwriting the built-in `sed`
brew install gnu-sed --with-default-names

# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before running `chsh`.
brew install fish
echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish
brew install homebrew/completions/brew-cask-completion
curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher #fisher package manager
cd ~/.config/fisherman && fisher

# run this script when this file changes guy.
brew install entr
brew install z

# mtr - ping & traceroute. best.
brew install mtr

# allow mtr to run without sudo
mtrlocation=$(brew info mtr | grep Cellar | sed -e 's/ (.*//') #  e.g. `/Users/paulirish/.homebrew/Cellar/mtr/0.86`
sudo chmod 4755 $mtrlocation/sbin/mtr
sudo chown root $mtrlocation/sbin/mtr

# Install other useful binaries
brew install the_silver_searcher
brew install fzf

brew install git
brew install imagemagick --with-webp

# Node
brew install node # This installs `npm` too using the recommended installation method
npm install -g yarn

# Ruby & RVM
brew install ruby
curl -sSL https://get.rvm.io | bash

brew install pv
brew install rename
brew install tree
brew install zopfli

brew install pidcat   # colored logcat guy

brew install ncdu # find where your diskspace went
brew install thefuck # find where your command went wrong

# Remove outdated versions from the cellar
brew cleanup
