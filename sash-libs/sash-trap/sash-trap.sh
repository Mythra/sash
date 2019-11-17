#!/usr/bin/env bash

# _sash_get_trapped_text(signal: String)
#
# Modifies Variables: None
#
# parses trap output to get you the command for a signal.
_sash_get_trapped_text() {
  printf '%s' "$(trap -p "$1" | sed "s/trap -- '//g; s/' $1$//g; s/\\\''//g")"
}

# _sash_safe_add_to_trap(command: String, signal: String)
#
# Modifies Variables: None
#
# safely adds a command to a trap.
#
# NOTE: command should not end with a: `;`
_sash_safe_add_to_trap() {
  local command_to_add="$1"
  local signal="$2"

  local trapped_text="$(_sash_get_trapped_text "$signal")"
  if [[ "x$trapped_text" == "x" ]]; then
    trap "$command_to_add" "$signal"
  elif [[ ! "$trapped_text" =~ \;$ ]]; then
    trap "$trapped_text; $command_to_add;" "$signal"
  else
    trap "$trapped_text $command_to_add;" "$signal"
  fi
}
