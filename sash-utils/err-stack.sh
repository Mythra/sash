#!/usr/bin/env bash

_sash_global_err_mode_stack=()
_sash_initial_err_mode=""
if [[ "$-" =~ "e" ]]; then
  _initial_err_mode="0"
else
  _initial_err_mode="1"
fi

__sash_reset_initial_stack() {
  if [[ "$initial_err_mode" == "0" ]]; then
    set -e
  else
    set +e
  fi
}

__sash_push_err_mode_stack() {
  local func_name="$1"
  local err_mode="$2"
  _global_err_mode_stack=("${_global_err_mode_stack[@]}" "$func_name|$err_mode")
  if [[ "$err_mode" == "1" ]]; then
    set -e
  else
    set +e
  fi
}

__sash_pop_err_mode_stack() {
  local func_name="${FUNCNAME[1]}"
  local func_iter=
  for func_iter in "${_global_err_mode_stack[@]}"; do
    local func_iter_inner_arr=(${func_iter//|/\ })
    if [[ "${func_iter_inner_arr[0]}" == "$func_name" ]]; then
      local was_enabled_err="${func_iter_inner_arr[1]}"
      if [[ "$was_enabled_err" == "1" ]]; then
        set +e
      else
        set -e
      fi
    fi
  done
}

set -o functrace
trap __sash_reset_initial_stack SIGINT SIGQUIT
trap __sash_pop_err_mode_stack RETURN

__sash_allow_errors() {
  local func_name="${FUNCNAME[1]}"
  __sash_push_err_mode_stack "$func_name" "0"
}

__sash_guard_errors() {
  local func_name="${FUNCNAME[1]}"
  __sash_push_err_mode_stack "$func_name" "1"
}

