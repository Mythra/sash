#!/usr/bin/env bash

# Implements the sash_time command.
#
# S.A.S.H. is the main way to add things to your ~/.bashrc and still
# maintain structure.

# sash:time() -> None
#
# Modifies Variables: None
#
# prints out timing info gathered during startup.
sash:time() {
  local readonly keys=("${!__sash_timing_info[@]}")

  local key=
  for key in "${keys[@]}"; do
    local time_taken_in_seconds="${__sash_timing_info["$key"]}"
    echo "$key, took about: $time_taken_in_seconds second(s) to load into your shell."
  done | sort -k4,4nr -k1,1
}

# sash_time()
#
# alias to sash:time
sash_time() {
  sash:time
  return $?
}
