#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../sash-err-stack.sh"

function succeeds() {
  __sash_guard_errors
  true
  echo "hey"
}

succeeds
