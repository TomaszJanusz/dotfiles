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
brew cask install adobe-creative-cloud
brew cask install sketch
brew cask install sketch-toolbox

# browsers
brew cask install google-chrome-canary
brew cask install google-chrome
brew cask install firefoxnightly
brew cask install firefox
brew cask install opera
brew cask install vivaldi-snapshot

# less often
brew cask install gpgtools
brew cask install docker
brew cask install kitematic

# fonts
brew tap caskroom/fonts 
brew cask install font-fira-code

# brew tap tomick/homebrew-cask-alternatives
brew cask install setapp

echo "Do you wish to install .NET Core SDK?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) brew cask install dotnet-sdk; break;;
        No ) exit;;
    esac
done



echo "Do you wish to install Microsoft Office?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) brew cask install microsoft-office; break;;
        No ) exit;;
    esac
done


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
