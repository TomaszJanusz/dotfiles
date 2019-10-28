#!/bin/bash


# Install native apps
brew tap homebrew/cask-versions
brew tap homebrew/cask-drivers
brew tap homebrew/fonts 

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

# Graphics
# brew cask install adobe-creative-cloud
# brew cask install sketch
# brew cask install sketch-toolbox

# browsers
brew cask install google-chrome-canary
brew cask install google-chrome
brew cask install firefox-nightly
brew cask install firefox
brew cask install opera
brew cask install brave-browser-beta
# brew cask install vivaldi-snapshot

# less often
brew cask install gpg-suite
brew cask install docker
brew cask install kitematic

# OSX Quick look
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook qlvideo

# fonts
brew cask install font-fira-code

# brew tap tomick/homebrew-cask-alternatives
brew cask install setapp

echo "Do you wish to install .NET Core SDK?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) brew cask install dotnet-sdk; break;;
        No ) break;;
    esac
done



echo "Do you wish to install Microsoft Office?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) brew cask install microsoft-office; break;;
        No ) break;;
    esac
done


echo "Do you wish to install Logitech Options?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) brew cask install logitech-options; break;;
        No ) break;;
    esac
done

echo "Do you wish to install Brother Printer Drivers?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) brew cask install brotherprinterdrivers; break;;
        No ) break;;
    esac
done
