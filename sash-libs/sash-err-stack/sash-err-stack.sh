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

_sash_initial_err_mode=""

if [[ "$-" =~ "e" ]]; then
  _sash_initial_err_mode="0"
else
  _sash_initial_err_mode="1"
fi

set +e

declare -f _sash_safe_add_to_trap >/dev/null
__sash_trap_intermediate_check="$?"

if [[ "$__sash_trap_intermediate_check" == "1" ]]; then
  if [[ "x$SASH_TRAP_DIR" == "x" ]]; then
    source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../sash-trap/sash-trap.sh"
  else
    source "$SASH_TRAP_DIR/sash-trap.sh"
  fi
fi

unset __sash_trap_intermediate_check


declare -f __sash_pop_err_mode_stack >/dev/null
__sash_intermediate_check="$?"

if [[ "$__sash_intermediate_check" == "1" ]]; then

_sash_global_err_mode_stack_key=()
_sash_global_err_mode_stack_value=()

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
  _sash_global_err_mode_stack_key=("${_sash_global_err_mode_stack_key[@]}" "$1")
  _sash_global_err_mode_stack_value=("${_sash_global_err_mode_stack_value[@]}" "$2")

  if [[ "$2" == "1" ]]; then
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
  local readonly func_name="${FUNCNAME[1]}"

  local readonly stack_size="${#_sash_global_err_mode_stack_key[@]}"
  if [[ "$stack_size" == "0" ]]; then
    return 0
  fi
  local readonly stack_le_index=$(( stack_size - 1 ))

  local readonly stack_last_element="${_sash_global_err_mode_stack_key[$stack_le_index]}"
  if [[ "$stack_last_element" == "$func_name" ]]; then
    if [[ "$stack_size" == "1" ]]; then
      __sash_reset_initial_stack
      _sash_global_err_mode_stack_key=()
      _sash_global_err_mode_stack_value=()
      return 0
    fi

    if [[ "${_sash_global_err_mode_stack_value[$stack_le_index]}" == "1" ]]; then
      set +e
    else
      set -e
    fi

    unset '_sash_global_err_mode_stack_key[-1]'
    unset '_sash_global_err_mode_stack_value[-1]'
  else
    if [[ "${_sash_global_err_mode_stack_value[$stack_le_index]}" == "1" ]]; then
      set -e
    else
      set +e
    fi
  fi

  return 0
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
  __sash_push_err_mode_stack "${FUNCNAME[1]}" "0"
}

# __sash_guard_errors()
#
# Modifies Variables:
#  * _sash_global_err_mode_stack
#
# sets the error mode to be on for the runtime of this function.
__sash_guard_errors() {
  __sash_push_err_mode_stack "${FUNCNAME[1]}" "1"
}
fi

unset __sash_intermediate_check
__sash_reset_initial_stack
