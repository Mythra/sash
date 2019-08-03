#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../../../sash-err-stack/sash-err-stack.sh"
source "$SCRIPT_DIR/../../sash-parse.sh"

set -e

ARR=("a|apples" "b|bacon" "c|choco" "d|dark-choco" "e|eclair" "flags" "going" "home" "in" "j|jackets")
__sash_parse_args "-a -b 10 -c \"is good\" -d=hey -e=\"a value with spaces\" --flags --going 10 --home \"or are they\" --in=10 --jackets=\"possibly maybe\" here is some extra flags" "${ARR[@]}"

echo "${!__sash_parse_results[@]}" | grep "jackets" | grep "apples" | grep "__STDIN" | grep "dark-choco" | grep "in" | grep "flags" | grep "going" | grep "choco" | grep "bacon" | grep "eclair" | grep "home" >/dev/null 2>&1
echo "${__sash_parse_results[apples]}"
echo "${__sash_parse_results[bacon]}"
echo "${__sash_parse_results[choco]}"
echo "${__sash_parse_results[dark-choco]}"
echo "${__sash_parse_results[eclair]}"
echo "${__sash_parse_results[flags]}"
echo "${__sash_parse_results[going]}"
echo "${__sash_parse_results[home]}"
echo "${__sash_parse_results[in]}"
echo "${__sash_parse_results[jackets]}"
echo "${__sash_parse_results[__STDIN]}"
