# OSX-only stuff. Abort if not OSX.
is_osx || return 1

e_arrow "Instaling brew and packages"

# Install Homebrew.
if [[ ! "$(type -P brew)" ]]; then
  e_header "Installing Homebrew"
  true | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Exit if, for some reason, Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Homebrew failed to install." && return 1

e_header "Updating Homebrew"
brew doctor
brew update

e_header "Loading homebrew with the saved bundle dump"
brew bundle --file=~/.cache/Brewfile

cat<<BASHCFG>>~/.bashrc.user
############## F U N C T I O N S ##############
brewv(){ 
        brew list --versions | grep $1 | sed 's/'$1' //g'
    }

################# E N D    F U N C T I O N S ##################
# Unset the PROMPT_COMMAND otherwise in terminal.app itutomatically set to update_terminal_cwd
# This causes the prompt.sh to not set the prompt 
unset PROMPT_COMMAND
export PATH="/usr/local/bin:$(path_remove /usr/local/bin)"
export PATH="/usr/local/sbin:$PATH"

# A L I A S E S
alias ctags='/usr/local/bin/ctags' # Installed with homebrew
alias grep='ggrep' # Installed with homebrew
alias skim='open -a Skim' # Installed with homebrew
BASHCFG
