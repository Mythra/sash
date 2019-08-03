#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../../sash-err-stack/sash-err-stack.sh"
source "$SCRIPT_DIR/../../sash-parse.sh"

set -e

ARR=("a|aa" "b|bb" "a|aa")
__sash_parse_args "-a 10" "${ARR[@]}"
