function rvm -d 'Ruby enVironment Manager'
  # run RVM and capture the resulting environment
  set -l env_file (mktemp -t rvm.fish.XXXXXXXXXX)

  bash -c '[ -e ~/.rvm/scripts/rvm ] && source ~/.rvm/scripts/rvm || \
           source /usr/local/rvm/scripts/rvm; rvm "$@"; status=$?; \
           env > "$0"; exit $status' $env_file $argv

  # clear GEM_* variables
  and begin; eval ( printenv | cut -f 1 -d '=' | grep GEM_ | sed -e 's|^\(.*\)|set -ge \1; |' ); end

  # grep the rvm_* *PATH RUBY_* GEM_* variables from the captured environment
  # exclude lines with _clr and _debug
  # apply rvm_* *PATH RUBY_* GEM_* variables from the captured environment
  and eval ( \
    grep '^rvm\|^[^=]*PATH\|^RUBY_\|^GEM_' $env_file | \
    grep -v _clr | grep -v _debug | \
    sed '/^PATH/y/:/ /; s/^/set -xg /; s/=/ /; s/$/ ;/; s/(//; s/)//' \
  )

  # Add gemset bin dir to $PATH
  set -xg GEM_BIN_DIR $GEM_HOME/bin
  if not contains -i $GEM_BIN_DIR $PATH
    set -xg PATH $PATH $GEM_BIN_DIR
  end

  # clean up
  rm -f $env_file
end

function __handle_rvmrc_stuff --on-variable PWD

  # Source a .rvmrc file in a directory after changing to it, if it exists.
  # To disable this feature, set rvm_project_rvmrc=0 in $HOME/.rvmrc
  if test "$rvm_project_rvmrc" != 0
    set -l cwd $PWD
    while true
      if contains $cwd "" $HOME "/"
        if test "$rvm_project_rvmrc_default" = 1
          rvm default 1>/dev/null 2>&1
        end
        break
      else
        if test -e .rvmrc -o -e .ruby-version -o -e .ruby-gemset
          eval "rvm reload" > /dev/null
          eval "rvm rvmrc load" >/dev/null
          break
        else
          set cwd (dirname "$cwd")
          set PATH (string match -v $GEM_BIN_DIR $PATH)
          set -e GEM_BIN_DIR
        end
      end
    end
    set -e cwd
  end
end
  