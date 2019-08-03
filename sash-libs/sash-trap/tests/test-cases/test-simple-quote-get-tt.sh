#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../sash-trap.sh"

( \
  trap - "SIGALRM" && \
  _sash_safe_add_to_trap "echo 'hey \"hello\" \\\"sup\\\"'" "SIGALRM" && \
  _sash_get_trapped_text "SIGALRM"
)
