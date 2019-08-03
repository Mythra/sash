#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../../sash-err-stack/sash-err-stack.sh"
source "$SCRIPT_DIR/../../sash-parse.sh"

ARR=("@|@@")
__sash_parse_args "-@ 10" "${ARR[@]}"
retV=$?
if [[ "$retV" != "1" ]]; then
  echo "@ wasn't marked as invalid!" >&2
  exit 10
fi

ARR=("a|apples|allples")
__sash_parse_args "-a 10" "${ARR[@]}"
retV=$?
if [[ "$retV" != "1" ]]; then
  echo "too many pipes wasn't marked as invalid!" >&2
  exit 10
fi
