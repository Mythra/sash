#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../sash-err-stack.sh"

function messWithGlobalErrorMode() {
  set +e
  false
  echo "hey"
}

function guard() {
  __sash_guard_errors
  messWithGlobalErrorMode
  false
  echo "hello world"
}

guard
