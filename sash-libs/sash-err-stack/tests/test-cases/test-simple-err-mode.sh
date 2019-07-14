#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../sash-err-stack.sh"

function fails() {
  __sash_guard_errors
  false # causes script exit.
  echo "hey"
}

fails
