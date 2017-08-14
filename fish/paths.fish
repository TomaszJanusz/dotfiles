# Grab my $PATHs from ~/.extra
# set -l PATH_DIRS (cat "$HOME/.extra" | grep "^PATH" | \
#     # clean up bash PATH setting pattern
#     sed "s/PATH=//" | sed "s/\\\$PATH://" | \
#     # rewrite ~/ to use {$HOME}
#     sed "s/~\//{\$HOME}\//")


set -l PA $PATH

set -l paths "

"

for entry in (string split \n $paths)
    # resolve the {$HOME} substitutions
    set -l resolved_path (eval echo $entry)
    if test -d "$resolved_path";
        set PA $PA "$resolved_path"
    end
end

set --export PATH $PA