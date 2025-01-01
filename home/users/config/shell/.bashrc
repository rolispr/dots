#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias ls='ls --color=auto'
# alias grep='grep --color=auto'
# PS1='[\u@\h \W]\$ '

# ANSI escape codes for custom colors
bg_color="\033[48;5;235m"
line_color="\033[38;5;59m"  # New color for the thin line
normal_green="\033[38;5;106m"
normal_yellow="\033[38;5;179m"
normal_grey="\033[38;5;242m"
reset="\033[0m"

# Function to get git status
git_status() {
  git branch &> /dev/null
  if [ $? -eq 0 ]; then
    echo -e "$normal_green$(git symbolic-ref --short HEAD)$reset"
  else
    echo -e ""
  fi
}

# Function to fill the line with spaces (to apply background color)
fill_line() {
  local term_width=$(tput cols)
  printf '%*s' "$term_width" ''
}

# Pre-prompt command to set Git status and align it
# ...set frame title instead
function pop_pre_prompt {
  git_status_var=$(git_status)
  term_width=$(tput cols)
  line=$(printf "%${term_width}s")
  current_path="$PWD"
  trimmed_path=${current_path/#$HOME/\~}
  spaces_needed=$((term_width - ${#trimmed_path} - ${#git_status_var}))
  filler=$(printf "%*s" $spaces_needed " ")
}
PROMPT_COMMAND=pop_pre_prompt

#git_status_var=$(git_status)
#term_width=$(tput cols)
#line=$(printf "%${term_width}s")
#current_path="$PWD"
#trimmed_path=${current_path/#$HOME/\~}
#spaces_needed=$((term_width - ${#trimmed_path} - ${#git_status_var}))
#filler=$(printf "%*s" $spaces_needed " ")
# Main prompt (PS1)
PS1="\[$bg_color\]\[$normal_grey\]\[$normal_yellow\]\w\[$normal_grey\]\$filler\$git_status_var\[$reset\]\n\[$normal_grey\]>>\[$normal_yellow\]> \[$reset\]"
#PS2='reverse-i-search\]: '
#\[$bg_color\]\$(fill_line)\[$reset\]
export PATH="$PATH:$HOME/.roswell/bin"
