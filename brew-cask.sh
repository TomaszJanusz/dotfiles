#!/bin/bash


# Install native apps
brew tap caskroom/versions
brew tap caskroom/drivers

# daily
brew cask install 1password
brew cask install alfred
brew cask install mailmate
brew cask install wire

# dev
brew cask install iterm2-beta
curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash

brew cask install imagealpha
brew cask install imageoptim
brew cask install tower
brew cask install visual-studio-code
brew cask install dash

# Grapic
brew cask install adobe-photoshop-cc
brew cask install adobe-illustrator-cc
brew cask install sketch
brew cask install sketch-toolbox

# browsers
brew cask install google-chrome-canary
brew cask install firefoxnightly
# brew cask install webkit-nightly
# brew cask install chromium
# brew cask install torbrowser

# less often
brew cask install gpgtools

# pleasure 
brew cask install spotify

# fonts
brew tap caskroom/fonts 
brew cask install font-fira-code

brew tap tomick/homebrew-cask-alternatives
brew cask install setapp




echo "Do you wish to install Logitech Options?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) brew cask install logitech-options; break;;
        No ) exit;;
    esac
done

echo "Do you wish to install Brother Printer Drivers?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) brew cask install brotherprinterdrivers; break;;
        No ) exit;;
    esac
done


# Wire @TODO: https://github.com/caskroom/homebrew-cask/issues/23884
