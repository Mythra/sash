#!/usr/bin/env bash

# Implements the sash_parse heplers.
#
# sash_parse is a file specifically built to parse out command line flags.
# we want to support these variants of passing in flags:
#
#  `-a` - Short Flag Toggle
#  `-a 10` - Short Flag With Arg
#  `-a "my apples are cool"` - Short Flag with spaced string
#  `-a=10` - Short Flag using Equals with Arg
#  `-a="my apples are cool"` - Short Flag using equals with spaced string
#  `--apples` - Long Flag Toggle
#  `--apples 10` - Long Flag Toggle
#  `--apples "my apples are cool"` - Long Flag with spaced string
#  `--apples=10` - Long flag with equals
#  `--apples="my apples are cool"` - Long flag with equals, and spaced string.
#
# The main function exported is `__sash_parse_args` which gives you back an associative
# array of values. The values for toggles will be: "0". To use it simply pass in an
# array of values that look like: `["short_name|long_name", "short_nam|long_nam", "longg_name"]`.
#
# What about input on STDIN? you may be asking yourself. SASH writes all values to: "__STDIN" that
# are not associated with flags.
#
# Flag Names are not allowed to contain anything besides: `a-zA-Z`. If you try to
# register a flag with an invalid character, sash will just drop it.
#
# S.A.S.H. is the main way to add things to your ~/.bashrc and still
# maintain structure.

# __sash_strip_quotes(to_strip: String) -> String
#
# to_strip:
#   * the string who should have it's quotes stripped.
__sash_strip_quotes() {
  local to_strip="$1"
  if [[ "$to_strip" =~ ^\".*$ ]]; then
    to_strip="$(echo "$to_strip" | cut -c 2-)"
  fi
  if [[ "$to_strip" =~ ^.*\"$ ]]; then
    to_strip="$(echo "$to_strip" | rev | cut -c 2- | rev)"
  fi
  echo "$to_strip"
}

# __sash_split_str(string_to_split: String, split_by: String) -> Array<String>
#
# string_to_split:
#   * the string to split up.
# split_by:
#   * the string to split by.
__sash_split_str() {
  local to_split="$1"
  local split_by="$2"

  local SAVEIFS="$IFS"
  trap "export IFS=$SAVEIFS" SIGINT SIGQUIT SIGTSTP
  IFS=$split_by
  local split
  read -a split <<< "$to_split"
  IFS=$SAVEIFS
  trap - SIGINT SIGQUIT SIGTSTP

  printf '%s ' "${split[@]}"
}

# __sash_check_duplicate__key(key_to_check: String, known_flags: Array<String>) -> Int
#
# key_to_check:
#   * The key that you want to know is duplicated.
# known_flags
#   * an array of known flags.
#
# Returns 0 if the key isn't duplicated, 1 if it is.
__sash_check_duplicate_key() {
  local key_to_check="$1"
  shift
  local flags=("$@")
  local iter

  local split_provided_key=($(__sash_split_str "$key_to_check" "|"))

  # For Each Flag We Know about.
  for iter in "${flags[@]}"; do
    # Split the known flag up.
    local split_known_flag=($(__sash_split_str "$iter" "|"))
    # If the known flag only had it's long arg provided.
    if [[ "${#split_known_flag[@]}" == "1" ]]; then
      if [[ "${#split_provided_key[@]}" == "1" ]]; then
        # If the key we're checking against only had it's long arg provided.
        if [[ "${split_known_flag[0]}" == "${split_provided_key[0]}" ]]; then
          return 1
        fi
      else
        # Otherwise, Check the long key only.
        if [[ "${split_known_flag[0]}" == "${split_provided_key[1]}" ]]; then
          return 1
        fi
      fi

    else
      # If the key we're checking against only has a long arg.
      if [[ "${#split_provided_key[@]}" == "1" ]]; then
        # Only check the long arg.
        if [[ "${split_known_flag[1]}" == "${split_provided_key[0]}" ]]; then
          return 1
        fi
      else
        # Otherwise check both short, and long.
        if [[ "${split_known_flag[0]}" == "${split_provided_key[0]}" ]]; then
          return 1
        fi
        if [[ "${split_known_flag[1]}" == "${split_provided_key[1]}" ]]; then
          return 1
        fi
      fi

    fi
  done

  return 0
}

# __sash_find_key_for_arg(arg_to_match: String, args: Array<String>): Optional<String>
#
# arg_to_match:
#   * the argument to attempt to match.
# args:
#   * the list of sash arguments.
__sash_find_key_for_arg() {
  local key_to_attempt_a_match="$1"
  # Properly match: `-d=arg` arguments.
  local split_by_equals=($(__sash_split_str "$key_to_attempt_a_match" "="))
  key_to_attempt_a_match="${split_by_equals[0]}"
  shift
  local flags=("$@")
  local iter

  # For Each Flag We Know about.
  for iter in "${flags[@]}"; do
    # Split the known flag up.
    local split_known_flags=($(__sash_split_str "$iter" "|"))

    if [[ "${#split_known_flags[@]}" == "1" ]]; then
      if [[ "$key_to_attempt_a_match" =~ ^\-\-.*$ ]]; then
        if [[ "$key_to_attempt_a_match" == "--${split_known_flags[0]}" ]]; then
          echo "${split_known_flags[0]}"
          return 0
        fi
      else
        # This arg doesn't have a short flag and one was provided.
        continue
      fi
    else
      if [[ "$key_to_attempt_a_match" =~ ^\-\-.*$ ]]; then
        if [[ "$key_to_attempt_a_match" == "--${split_known_flags[1]}" ]]; then
          echo "${split_known_flags[1]}"
          return 0
        fi
      else
        if [[ "$key_to_attempt_a_match" == "-${split_known_flags[0]}" ]]; then
          echo "${split_known_flags[1]}"
          return 0
        fi
      fi
    fi
  done

  return 1
}

# __sash_parse_args(to_parse: String, flags: Array<String>) -> Int
#
# Modifies Variables:
#   * __sash_parse_results
#
# Parses the arguments you need to parse, and writes results as an associative array with the name: "__sash_parse_results".
# Use the return value to check if there was an error (non-zero value).
# All results are written using the "long-name".
#
# Error Codes:
#   0 - No Error
#   1 - Flag Provided was invalid in some way.
#   2 - Subset of error code 1, flag was duplicated.
#   3 - User Spacing Error.
#   4 - Got arg when expecting value.
#   5 - Unknown Argument
__sash_parse_args() {
  local to_parse_str="$1"
  local to_parse=($(__sash_split_str "$to_parse_str" " "))

  # easiest way to parse the array is to just shift away the first arg.
  shift

  local flags=("$@")
  local provided_flag

  local sash_known_flags=()

  for provided_flag in "${flags[@]}"; do
    if [[ ! "$provided_flag" =~ [A-Za-z|-]+ ]]; then
      echo "Invalid Argument Flag, Unknown Chars: [ $provided_flag ]!" >&2
      return 1
    fi

    local count_of_pipe="$(echo "$provided_flag" | tr -cd '|' | wc -c)"
    if [[ "$count_of_pipe" != "0" && "$count_of_pipe" != "1" ]]; then
      echo "Invalid Argument Flag, Too Many Pipes: [ $provided_flag ], Count: [ $count_of_pipe ]!" >&2
      return 1
    fi

    __sash_check_duplicate_key "$provided_flag" "${sash_known_flags[@]}"
    local retV=$?
    if [[ "$retV" != "0" ]]; then
      echo "Duplicate Flag: [ $provided_flag ]!" >&2
      return 2
    fi

    if [[ "${#sash_known_flags[@]}" == "0" ]]; then
      sash_known_flags=("$provided_flag")
    else
      sash_known_flags=("$provided_flag" "${sash_known_flags[@]}")
    fi
  done

  # Set up a basic finite state machine.
  # State == 0, default mode.
  # State == 1, expecting a value
  # State == 2, currently inside a quoted string
  # State == 3, currently in stdin
  local state=0
  # Tracking Variables
  local value_to_write_to=""
  local str_buffer=""

  unset __sash_parse_results
  declare -A -g __sash_parse_results

  local current_user_arg
  for current_user_arg in "${to_parse[@]}"; do
    if [[ "$state" == "3" ]]; then
      str_buffer="$str_buffer $current_user_arg"
      continue
    fi

    if [[ "$state" == "2" ]]; then
      if [[ "$current_user_arg" =~ .*\".* ]]; then
        if [[ "$current_user_arg" =~ ^.*\"$ ]]; then
          local stripped="$(__sash_strip_quotes "$current_user_arg")"
          str_buffer="$str_buffer $stripped"

          # Append to array
          __sash_parse_results["$value_to_write_to"]="$str_buffer"
          str_buffer=""
          value_to_write_to=""
          state=0
          continue
        else
          echo "Ran into unknown state at str: [ $current_user_arg ]! Please seperate quoted strings from the next value with a space!" >&2
          return 3
        fi
      else
        # If we don't contain a quote just add to buffer.
        str_buffer="$str_buffer $current_user_arg"
        continue
      fi
    fi

    if [[ "$state" == "1" ]]; then
      if [[ ! "$current_user_arg" =~ ^\-.*$ ]]; then
        if [[ "$current_user_arg" =~ ^\".*$ ]]; then
          if [[ "$current_user_arg" =~ ^\".*\"$ ]]; then
            # If we end with a quote we have a full string.
            local stripped="$(__sash_strip_quotes "$current_user_arg")"
            __sash_parse_results["$value_to_write_to"]="$stripped"
            state=0
            value_to_write_to=""
            continue
          else
            local stripped="$(__sash_strip_quotes "$current_user_arg")"
            state=2
            str_buffer="$stripped"
            continue
          fi
        else
          # We have a value.
          __sash_parse_results["$value_to_write_to"]="$current_user_arg"
          state=0
          value_to_write_to=""
          continue
        fi
      fi
    fi

    if [[ "$current_user_arg" =~ ^\-.* ]]; then
      if [[ "$state" == "1" ]]; then
        __sash_parse_results["$value_to_write_to"]="0"
        state=0
        value_to_write_to=""
      fi
      local split_on_equals=($(__sash_split_str "$current_user_arg" "="))
      local key_to_write_to="$(__sash_find_key_for_arg "$current_user_arg" "${sash_known_flags[@]}")"

      if [[ "x$key_to_write_to" == "x" ]]; then
        echo "Unknown Arg: [ $current_user_arg ]!" >&2
        return 5
      fi

      if [[ "x${split_on_equals[1]}" == "x" ]]; then
        state=1
        value_to_write_to="$key_to_write_to"
        continue
      else
        # We've encountered an equals sign. Could be the start of a string, or a full value.
        # First we combine anything past 1..n
        # incase they have a '=' in their arg, and we split it.
        local equal_sign_buff=""
        local first_flag=0
        local equal_combinator_iter

        for equal_combinator_iter in "${split_on_equals[@]}"; do
          if [[ "$first_flag" == "0" ]]; then
            first_flag=1
            continue
          fi

          if [[ "x$equal_sign_buff" == "x" ]]; then
            equal_sign_buff="$equal_combinator_iter"
          else
            equal_sign_buff="$equal_sign_buff=$equal_combinator_iter"
          fi
        done

        if [[ "$equal_sign_buff" =~ ^\".*$ ]]; then
          local stripped="$(__sash_strip_quotes "$equal_sign_buff")"
          if [[ "$equal_sign_buff" =~ ^\".*\"$ ]]; then
            # We have a full string.
            __sash_parse_results["$key_to_write_to"]="$stripped"
            continue
          else
            value_to_write_to="$key_to_write_to"
            str_buffer="$stripped"
            state=2
            continue
          fi
        else
          # We have a full value.
          __sash_parse_results["$key_to_write_to"]="$equal_sign_buff"
          continue
        fi
      fi
    else
      # No Start of an arg, must be in extra values passed in.
      state=4
      str_buffer="$current_user_arg"
    fi
  done

  if [[ "$state" == "1" ]]; then
    __sash_parse_results["$value_to_write_to"]="0"
    state=0
    value_to_write_to=""
  fi

  __sash_parse_results["__STDIN"]="$str_buffer"
  return 0
}
