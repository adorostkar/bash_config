# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# SSH auto-completion based on entries in known_hosts.
if [[ -e ~/.ssh/known_hosts ]]; then
  complete -o default -W "$(cat ~/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')" ssh scp sftp
fi

if [[ -e ~/.ssh/config ]]; then
  complete -o default -W "$(cat ~/.ssh/config | grep '[Hh]ost ' | sed 's/[Hh]ost //' | xargs -n1 | sort | uniq)" ssh scp sftp
fi

# Directory listing
if [[ "$(type -P tree)" ]]; then
  alias ll='tree --dirsfirst -aLpughDFiC 1'
else
  alias ll='ls -al'
fi

# Easier navigation: .., ..., -
alias ..='cd ..'
alias ...='cd ../..'

if [[ "$(type -P rsync)" ]]
then
	alias scp='rsync -uaz --progress'
fi


