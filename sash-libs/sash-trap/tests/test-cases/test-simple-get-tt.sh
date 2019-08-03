#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../sash-trap.sh"

function onTrap() {
  echo "onTrap"
}

( \
  trap - "SIGALRM" && \
  _sash_safe_add_to_trap "onTrap" "SIGALRM" && \
  _sash_safe_add_to_trap "onTrap" "SIGALRM" && \
  _sash_safe_add_to_trap "onTrap" "SIGALRM" && \
  _sash_get_trapped_text "SIGALRM"
)
