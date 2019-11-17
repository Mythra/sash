#!/usr/bin/env bash

source "$SASH_DIR/subcommands/sash-add.sh"
source "$SASH_DIR/subcommands/sash-package.sh"
source "$SASH_DIR/subcommands/sash-show.sh"
source "$SASH_DIR/subcommands/sash-time.sh"

SASH_ARGS=("h|help")

sash() {
  __sash_parse_args "$*" "${SASH_ARGS[@]}" || {
    printf 'Failure to parse arguments!\nRemember argument flags should not be between sash and subcommand.'
    return 10
  }

  local split_stdin=($(__sash_split_str "${__sash_parse_results[__STDIN]}" " "))

  if [[ "${split_stdin[0]}" == "add" ]]; then
    sash:add:wrap
    return $?
  fi
  if [[ "${split_stdin[0]}" == "package" ]]; then
    sash:package:wrap "${split_stdin[@]:1}"
    return $?
  fi
  if [[ "${split_stdin[0]}" == "show" ]]; then
    sash:show:wrap "${split_stdin[@]:1}"
    return $?
  fi
  if [[ "${split_stdin[0]}" == "time" ]]; then
    sash:time:wrap
    return $?
  fi

  echo "
Welcome to S.A.S.H.!

S.A.S.H. offers the following subcommands:

  * \`add\` - add something to your bashrc (and automatically source it).
  * \`package\` - package up a particular category
                or subcategory for distribution to
                others.
  * \`show (category) (sub-category)\` - show the contents of a paritcular
                                       subcategory.
  * \`time\` - show the amount of time roughly it takes to source files.

NOTE: anything between: \`()\` above denotes optional arguments.
If you don't provide them, and they're needed, you will be asked inline.
"
    return 0
}
