source ~/.config/fish/paths.fish
source ~/.config/fish/iterm2_shell_integration.fish
source ~/.config/fish/aliases.fish
source ~/.config/fish/functions.fish

set -U fish_path $HOME/dotfiles/fisherman
set fish_function_path $fish_path/functions $fish_function_path
set fish_complete_path $fish_path/completions $fish_complete_path

for file in $fish_path/{functions,conf.d,completions}/*.fish
    source $file
end

# for things not checked into git..
if test -e "$HOME/.extra.fish";
	source ~/.extra.fish
end

# rvm default