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
  __sash_guard_errors

  local readonly keys=("${!__sash_timing_info[@]}")

  local key=
  for key in "${keys[@]}"; do
    local time_taken_in_seconds="${__sash_timing_info["$key"]}"
    echo "$key, took about: $time_taken_in_seconds second(s) to load into your shell."
  done | sort -k4,4nr -k1,1
}

# sash:time:wrap() -> None
#
# Modifies Variables: None
#
# Wraps sash:time in a subshell to ensure the shell is not exited.
sash:time:wrap() {
  __sash_allow_errors

  (           \
    sash:time \
  )

  local readonly rc="$?"
  if [[ "$rc" -ne "0" ]]; then
    (>&2 echo -e "Failed to run sash:time!")
  fi
  return "$rc"
}

# sash_time()
#
# alias to sash:time:wrap
sash_time() {
  sash:time:wrap
  return $?
}
