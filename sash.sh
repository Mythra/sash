#!/usr/bin/env bash

# Initiates a S.A.S.H. Shell.
#
# Sash is a plugin system for your .bashrc so that way you don't have to
# scroll through hundreds of lines in your bashrc in order to figure out
# what's going on.
#
# The idea is to provide a simple management system with "groups", and "subgroups".
#
# Groups should be "overarching" things ("languages", "work", "home", etc.).
# Subgroups are things within that, e.g. "Rust", and "Ruby" would be subgroups in "languages"

EDITOR=${EDITOR:-vim}

restore='\033[0m'
black='\033[0;30m'
red='\033[0;31m'
green='\033[0;32m'
brown='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
light_gray='\033[0;37m'
dark_gray='\033[1;30m'
light_red='\033[1;31m'
light_green='\033[1;32m'
yellow='\033[1;33m'
light_blue='\033[1;34m'
light_purple='\033[1;35m'
light_cyan='\033[1;36m'
white='\033[1;37m'

SASH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# _sash_get_multiline_input(text: Option<String>) -> (0 || 1)
#
# Modifies Variables:
#   - sash_multiline_content
#
# Grabs some multiline input through the configured editor (defaulting to nano),
# and stores the result in `sash_multiline_content`.
#
# NOTE: DO NOT LAUNCH THIS IN A SUB SHELL IT WILL WRECK USERS INPUT (open the
# editor without showing the user the editing interface).
#
# Instead you should be using something like:
# ```sh
# if ! _sash_get_multiline_content; then
#   die "bleh"
# fi
# ```
_sash_get_multiline_input() {
  local temp=$(mktemp "${TMPDIR:-/tmp}/sash-input.XXXXXXXXXX") || return 1
  local arg
  for arg in "$@"; do
    echo "$arg" >> "$temp"
  done
  local ret_code
  if "$EDITOR" -- "$temp" && [[ -s $temp ]]; then
    sash_multiline_content=$(<"$temp")
    ret_code=0
  else
    ret_code=1
  fi
  rm -f -- "$temp"
  return "$ret_code"
}

# _sash_choose_from_options(arr: Array<String>) -> String
#
# Modifies Variables: None
#
# Takes an array of options presenting an index'd select menu, and then
# returns the options that the user selects.
#
# NOTE: Arrays in bash are really really hard to "pass" in a function
# since you're just basically echo-ing things from one place to another.
# The correct way to pass an array is like the follows:
#
# ```sh
# option="$(_sash_choose_from_options ${options_to_choose_from[@]})"
# ```
_sash_choose_from_options() {
  select opt in "$@"; do
    echo "$opt"
    return
  done
}

# _sash_choose_a_directory(dir: Option<String>, use_new: Option<(0 || 1)>) -> String
#
# Modifies Variables: None
#
# Lists all directories in the dir you pass in, and lets the user choose one.
# Thus allowing a user to choose a directory.
#
# Note "use_new" has the unfortunate side effect of assuming no one has a
# folder called "New" in the directory you're looking in because that's
# what we return when there is a new option.
_sash_choose_a_directory() {
  local dir="${1:-.}"
  local use_new="${2:-1}"
  local option
  local array_of_lines

  array_of_lines=($(find "$dir" -maxdepth 1 -type d | grep -v "^\.$" | grep -v "^$dir$"))
  if [[ "$use_new" -eq "1" ]]; then
    option="$(_sash_choose_from_options ${array_of_lines[@]})"
  else
    option="$(_sash_choose_from_options ${array_of_lines[@]} New)"
  fi
  echo "$option"
}

# _sash_init_categories() -> None
#
# Modifies Variables:
#  - sash_init_content
#
# Prompts the User to create an initial set of categories.
_sash_init_categories() {
  read -p "Please Enter a Category Name to create (blank for exiting): " sash_init_content
  if [[ "x$sash_init_content" == "x" ]]; then
    return
  else
    mkdir -p "$HOME/.bash/plugins/$sash_init_content"
    echo ""
    _sash_init_categories
  fi
}

# _is_first_sash_run() -> (0 || 1)
#
# Modifies Variables: None
#
# Determines if the is the first run of sash with some really crappy metrics.
_is_first_sash_run() {
  (mkdir -p ~/.bash/plugins || true)
  if [[ -z "$(ls -A ~/.bash/plugins/)" ]]; then
    echo "0"
    return
  else
    echo "1"
    return
  fi
}

if [[ "$(_is_first_sash_run)" -eq "0" ]]; then
  # This is the first sash run, ask to create directories.
  echo -e "${white}[${green}+${white}]${restore} Welcome to S.A.S.H.!"
  echo ""
  echo "Bringing Sensible Groupings to your ~/.bashrc!"
  echo ""
  echo "SASH groups your bashrc into categories, and subcategories."
  echo "Categories are overaching like \"work\", \"language\", and \"home\"."
  echo "Whereas subcategories are like \"ruby\" which is part of \"language\"."
  echo ""
  echo "We're going to go ahead, and setup some categories!"
  echo ""
  _sash_init_categories
  touch "$HOME/.bash/plugins/init-sash"
  mkdir -p "$HOME/.bash/plugins/post"
  echo ""
  echo -e "${white}[${green}+${white}]${restore} S.A.S.H. has been setup!"
fi

export SASH_LOADING=1

_sash_category_dirs=( $(find "$HOME/.bash/plugins/" -maxdepth 1 -type d -printf '%P\n' | grep -v "^\.$" | grep -v "^\.\.$" | grep -v "^$" | grep -v "^post$") )
for __sash_loop_dir in "${_sash_category_dirs[@]}"; do
  _sash_subcategory_dirs=( $(find "$HOME/.bash/plugins/$__sash_loop_dir" -maxdepth 1 -type d -printf '%P\n' | grep -v "^\.$" | grep -v "^\.\.$" | grep -v "^$") )
  for __sash_loop_sub_dir in "${_sash_subcategory_dirs[@]}"; do
    for __sash_filename in $HOME/.bash/plugins/$__sash_loop_dir/$__sash_loop_sub_dir/*.sh; do
      [[ -x $__sash_filename ]] || continue
      [[ -n $SASH_TRACE ]] && echo "\n\nSourcing File: $__sash_filename\n\n"
      [[ -n $SASH_TRACE ]] && set -x
      source $__sash_filename
      [[ -n $SASH_TRACE ]] && set +x
    done
  done
done

unset SASH_LOADING

export SASH_LOADED=1

if [[ -d "$HOME/.bash/plugins/post" ]]; then
  for __sash_filename in $HOME/.bash/plugins/post/*.sh; do
    [[ -x "$__sash_filename" ]] || continue
    [[ -n $SASH_TRACE ]] && echo "\n\nSourcing File: $__sash_filename\n\n"
    [[ -n $SASH_TRACE ]] && set -x
    source $__sash_filename
    [[ -n $SASH_TRACE ]] && set +x
  done
fi

source "$SASH_DIR/sash-libs/sash-parse/sash-parse.sh"

source "$SASH_DIR/sash-add.sh"
source "$SASH_DIR/sash-show.sh"
source "$SASH_DIR/sash-package.sh"

export SASH_RUNNING=1
