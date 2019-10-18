set -g -x PATH $PATH /usr/local/bin
set -xg OMF_CONFIG $HOME/dotfiles/omf
set -g -x fish_greeting ''
set -g -x DOTFILES_DIR $HOME/dotfiles
set -g -x EDITOR 'nano'
set -g -x GOPATH $HOME/Projekty/go
set -g -x GO15VENDOREXPERIMENT 1set -g fish_user_paths "/usr/local/opt/node@10/bin" $fish_user_paths
set -g -x ANDROID_HOME $HOME/Library/Android/sdk