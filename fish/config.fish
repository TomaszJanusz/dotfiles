source ~/.config/fish/paths.fish
source ~/.config/fish/iterm2_shell_integration.fish
source ~/.config/fish/aliases.fish
source ~/.config/fish/functions.fish

# for things not checked into git..
if test -e "$HOME/.extra.fish";
	source ~/.extra.fish
end

# rvm default