#!/usr/bin/env bash

# Implements a Global Error Stack for Bash.
#
# This script implements an "error-stack" for bash, allowing you to push/pop
# ontop of it. Great, so what does that mean? The idea is to provide a series
# of APIs that act similar to "defer" in Golang. Set an error state at the
# beginning of a function, that gets popped off later.
#
# S.A.S.H. is the main way to add things to your ~/.bashrc and still
# maintain structure.

declare -f __sash_pop_err_mode_stack >/dev/null
__sash_intermediate_check="$?"

if [[ "$__sash_intermediate_check" == "1" ]]; then

# _sash_get_trapped_text(signal: String)
#
# Modifies Variables: None
#
# parses trap output to get you the command for a signal.
_sash_get_trapped_text() {
  local signal="$1"
  echo "$(trap -p "$signal" | sed "s/trap -- '//g; s/' $signal$//g; s/\\\''//g")"
}

# _sash_safe_add_to_trap(signal: String, command: String)
#
# Modifies Variables: None
#
# safely adds a command to a trap.
_sash_safe_add_to_trap() {
  local command_to_add="$1"
  local signal="$2"

  if [[ "x$(trap -p "$signal")" == "x" ]]; then
    trap "$command_to_add" "$signal"
  else
    local trapped_text="$(_sash_get_trapped_text "$signal")"
    echo "$trapped_text" | grep "^.*;" > /dev/null 2>&1
    if [[ "$?" == "0" ]]; then
      trap "$trapped_text $command_to_add;" "$signal"
    else
      trap "$trapped_text; $command_to_add;" "$signal"
    fi
  fi
}

_sash_global_err_mode_stack=()
_sash_initial_err_mode=""
if [[ "$-" =~ "e" ]]; then
  _initial_err_mode="0"
else
  _initial_err_mode="1"
fi

# __sash_reset_initial_stack()
#
# Modifies Variables: None
# Modifies State:
#   * Error Mode
#
# Resets the error-mode to whatever it was originally independent of the stack.
__sash_reset_initial_stack() {
  if [[ "$_sash_initial_err_mode" == "0" ]]; then
    set -e
  else
    set +e
  fi
}

# __sash_push_err_mode_stack(func_name: String, err_mode: (0 || 1))
#
# Modifies Variables:
#   * _sash_global_err_mode_stack
# Modifies State:
#   * Error Mode.
#
# Pushes onto the error stack.
__sash_push_err_mode_stack() {
  local func_name="$1"
  local err_mode="$2"
  _sash_global_err_mode_stack=("${_sash_global_err_mode_stack[@]}" "$func_name|$err_mode")
  if [[ "$err_mode" == "1" ]]; then
    set -e
  else
    set +e
  fi
}

# __sash_pop_err_mode_stack()
#
# Modifies Variables:
#  * _sash_global_err_mode_stack
# Modifies State:
#   * Error Mode
#
# Should be called when a function exits. Checks to see
# if the function exiting had an artificial error_state, and unsets it.
__sash_pop_err_mode_stack() {
  local func_name="${FUNCNAME[1]}"
  local new_arr=()
  local func_iter=
  for func_iter in "${_sash_global_err_mode_stack[@]}"; do
    local func_iter_inner_arr=(${func_iter//|/\ })
    if [[ "${func_iter_inner_arr[0]}" == "$func_name" ]]; then
      local was_enabled_err="${func_iter_inner_arr[1]}"
      if [[ "$was_enabled_err" == "1" ]]; then
        set +e
      else
        set -e
      fi
    else
      new_arr=("${new_arr[@]}" "$func_iter")
    fi
  done
  _sash_global_err_mode_stack=("${new_arr[@]}")
  if [[ "${#_sash_global_err_mode_stack[@]}" == "0" ]]; then
    __sash_reset_initial_stack
  fi
}

set -o functrace
_sash_safe_add_to_trap "__sash_pop_err_mode_stack" "RETURN"

# __sash_allow_errors()
#
# Modifies Variables:
#  * _sash_global_err_mode_stack
#
# sets the error mode to be off for the runtime of this function.
__sash_allow_errors() {
  local func_name="${FUNCNAME[1]}"
  __sash_push_err_mode_stack "$func_name" "0"
}

# __sash_guard_errors()
#
# Modifies Variables:
#  * _sash_global_err_mode_stack
#
# sets the error mode to be on for the runtime of this function.
__sash_guard_errors() {
  local func_name="${FUNCNAME[1]}"
  __sash_push_err_mode_stack "$func_name" "1"
}
fi

unset __sash_intermediate_check
