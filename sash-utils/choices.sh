#!/usr/bin/env bash

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
