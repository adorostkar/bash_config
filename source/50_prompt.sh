# The bash prompt by Ashkan
#
# Example:
# [master:!?][alidorostkar@Alis-MBP:~/.dotfiles] $
#

# Abort if a prompt is already defined.
[[ "$PROMPT_COMMAND" ]] && return

# ANSI CODES - SEPARATE MULTIPLE VALUES WITH ;
#
#  0  reset          4  underline
#  1  bold           7  inverse
#
# FG  BG  COLOR     FG  BG  COLOR
# 30  40  black     34  44  blue
# 31  41  red       35  45  magenta
# 32  42  green     36  46  cyan
# 33  43  yellow    37  47  white

if [[ ! "${__prompt_colors[@]}" ]]; then
  __prompt_colors=(
    "32" # information color
    "37" # bracket color
    "31" # error color
  )
  if [[ "$SSH_TTY" ]]; then
    # connected via ssh
    __prompt_colors[0]="36"
  elif [[ "$USER" == "root" ]]; then
    # logged in as root
    __prompt_colors[0]="1;35"
  fi
fi

# Change line ending on root as per other shells
___line_ending='\$'
if [[ "$USER" == "root" ]]
then
	___line_ending="#"
fi

# Inside a prompt function, run this alias to setup local $c0-$c9 color vars.
alias __prompt_get_colors='__prompt_colors[9]=; local i; for i in ${!__prompt_colors[@]}; do local c$i="\[\e[0;${__prompt_colors[$i]}m\]"; done'

function __prompt_exit_code() {
  __prompt_get_colors
  [[ $1 != 0 ]] && echo "$c1[$c2$1$c1]$c9"
}

# Git status.
function __prompt_git() {
  __prompt_get_colors
  local branch 
  # Check if we are in git repo
  (git rev-parse --git-dir > /dev/null 2>&1)
  [[ $? != 0 ]] && return 1;
  branch="$(git branch 2>/dev/null | grep '^*' | colrm 1 2)"
  # [[ $? != 0 ]] && return 0;
  echo "$c1($c0$branch$c1)$c9"
}

# Maintain a per-execution call stack.
__prompt_stack=()
trap '__prompt_stack=("${__prompt_stack[@]}" "$BASH_COMMAND")' DEBUG

function __prompt_command() {
  local i exit_code=$?
  # If the first command in the stack is __prompt_command, no command was run.
  # Set exit_code to 0 and reset the stack.
  [[ "${__prompt_stack[0]}" == "__prompt_command" ]] && exit_code=0
  __prompt_stack=()

  # While the simple_prompt environment var is set, disable the awesome prompt.
  [[ "$simple_prompt" ]] && PS1='\h:\w\$ ' && return

  __prompt_get_colors
  # http://twitter.com/cowboy/status/150254030654939137
  # PS1="\n"
  # PS1="$c1[$c0 \T $c1]$c9"
  PS1=""
  # path: [user@host][path]
  PS1="$PS1$c1[ $c0\u$c1@$c0\h$c1:$c0\w$c1 ]$c9"

  PS1="$PS1$(__prompt_git)"

  PS1="$PS1$(__prompt_exit_code "$exit_code")"
  PS1="$PS1\n"
  PS1="$PS1$c1[$c0$(date +"%H$c1:$c0%M$c1:$c0%S")$c1]$c9${___line_ending} "
}

PROMPT_COMMAND="__prompt_command"

