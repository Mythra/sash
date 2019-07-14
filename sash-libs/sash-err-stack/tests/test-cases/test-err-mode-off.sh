#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../sash-err-stack.sh"

function passThrough() {
  __sash_allow_errors
  false
  echo "hey"
}

passThrough
