#!/bin/sh
brew install fish

mkdir -p ~/.config
ln -Fs ~/dotfiles/fish ~/.config

curl -L https://get.oh-my.fish > install
fish install --path=~/dotfiles/omf/install --config=~/dotfiles/omf
rm ./install
