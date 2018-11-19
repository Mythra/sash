#!/usr/bin/env bash

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