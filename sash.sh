#!/usr/bin/env bash

# Initiates a S.A.S.H. Shell.
#
# Sash is a plugin system for your .bashrc so that way you don't have to
# scroll through hundreds of lines in your bashrc in order to figure out
# what's going on.
#
# The idea is to provide a simple management system with "groups", and "subgroups".
#
# Groups should be "overarching" things ("languages", "work", "home", etc.).
# Subgroups are things within that, e.g. "Rust", and "Ruby" would be subgroups in "languages"

EDITOR=${EDITOR:-vim}
export SASH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Used to grab timing info for how long sourcing each file took.
declare -A -g __sash_timing_info

source "$SASH_DIR/sash-libs/sash-trap/sash-trap.sh"
source "$SASH_DIR/sash-libs/sash-err-stack/sash-err-stack.sh"
source "$SASH_DIR/sash-utils/sash-utils.sh"

# _sash_init_categories() -> None
#
# Modifies Variables:
#  - sash_init_content
#
# Prompts the User to create an initial set of categories.
_sash_init_categories() {
  read -p "Please Enter a Category Name to create (blank for exiting): " sash_init_content
  if [[ "x$sash_init_content" == "x" ]]; then
    return
  else
    mkdir -p "$HOME/.bash/plugins/$sash_init_content"
    echo ""
    _sash_init_categories
  fi
}

# _is_first_sash_run() -> (0 || 1)
#
# Modifies Variables: None
#
# Determines if the is the first run of sash with some really crappy metrics.
_is_first_sash_run() {
  (mkdir -p ~/.bash/plugins || true)
  if [[ -z "$(ls -A ~/.bash/plugins/)" ]]; then
    echo "0"
    return
  else
    echo "1"
    return
  fi
}

if [[ "$(_is_first_sash_run)" -eq "0" ]]; then
  # This is the first sash run, ask to create directories.
  echo -e "${white}[${green}+${white}]${restore} Welcome to S.A.S.H.!"
  echo ""
  echo "Bringing Sensible Groupings to your ~/.bashrc!"
  echo ""
  echo "SASH groups your bashrc into categories, and subcategories."
  echo "Categories are overaching like \"work\", \"language\", and \"home\"."
  echo "Whereas subcategories are like \"ruby\" which is part of \"language\"."
  echo ""
  echo "We're going to go ahead, and setup some categories!"
  echo ""
  _sash_init_categories
  touch "$HOME/.bash/plugins/init-sash"
  mkdir -p "$HOME/.bash/plugins/post"
  echo ""
  echo -e "${white}[${green}+${white}]${restore} S.A.S.H. has been setup!"
fi

__sash_global_startup_time="$SECONDS"
export SASH_LOADING=1

_sash_category_dirs=( $(find "$HOME/.bash/plugins/" -maxdepth 1 -type d -printf '%P\n' | grep -v "^\.$" | grep -v "^\.\.$" | grep -v "^$" | grep -v "^post$") )
for __sash_loop_dir in "${_sash_category_dirs[@]}"; do
  _sash_subcategory_dirs=( $(find "$HOME/.bash/plugins/$__sash_loop_dir" -maxdepth 1 -type d -printf '%P\n' | grep -v "^\.$" | grep -v "^\.\.$" | grep -v "^$") )
  for __sash_loop_sub_dir in "${_sash_subcategory_dirs[@]}"; do
    for __sash_filename in $HOME/.bash/plugins/$__sash_loop_dir/$__sash_loop_sub_dir/*.sh; do
      [[ -x $__sash_filename ]] || continue
      [[ -n $SASH_TRACE ]] && echo "\n\nSourcing File: $__sash_filename\n\n"
      [[ -n $SASH_TRACE ]] && set -x
      start_time="$SECONDS"
      source $__sash_filename
      end_time="$SECONDS"
      __sash_timing_info["$__sash_filename"]="$(( end_time - start_time ))"
      [[ -n $SASH_TRACE ]] && set +x
    done
  done
done

unset SASH_LOADING

export SASH_LOADED=1

if [[ -d "$HOME/.bash/plugins/post" ]]; then
  for __sash_filename in $HOME/.bash/plugins/post/*.sh; do
    [[ -x "$__sash_filename" ]] || continue
    [[ -n $SASH_TRACE ]] && echo "\n\nSourcing File: $__sash_filename\n\n"
    [[ -n $SASH_TRACE ]] && set -x
    start_time="$SECONDS"
    source $__sash_filename
    end_time="$SECONDS"
    __sash_timing_info["$__sash_filename"]="$(( end_time - start_time ))"
    [[ -n $SASH_TRACE ]] && set +x
  done
fi

source "$SASH_DIR/sash-libs/sash-parse/sash-parse.sh"
source "$SASH_DIR/sash-command-handler.sh"

__sash_global_end_time="$SECONDS"
__sash_timing_info["Sash Total Time"]="$(( __sash_global_end_time - __sash_global_startup_time ))"
export SASH_RUNNING=1
