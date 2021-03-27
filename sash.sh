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

export SASH_IS_WINDOWS=0
case "$(uname -s)" in
  CYGWIN*)
    SASH_IS_WINDOWS=1
    ;;
  MINGW*)
    SASH_IS_WINDOWS=1
    ;;
  *)
    ;;
esac

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

# __ensure_find_type()
#
# Modifies Variables:
#  - SASH_FIND_FLAVOR
#
# Determines the sash find flavor (gnu/bsd)
__ensure_find_type() {
  if [[ "x$SASH_FIND_FLAVOR" == "x" ]]; then
    if find "$HOME/.bash/plugins/" -maxdepth 1 -type d -printf '%P\n' >/dev/null 2>&1 ; then
      export SASH_FIND_FLAVOR="gnu"
    else
      export SASH_FIND_FLAVOR="bsd"
    fi
  fi
}

# __grab_initial_files() -> Array<String>
#
# Modifies Variables: None
#
# Grab an array of the initial directories to scan for plugins.
__grab_initial_files() {
  __ensure_find_type
  if [[ "$SASH_FIND_FLAVOR" == "gnu" ]] ; then
    find "$HOME/.bash/plugins/" -maxdepth 1 -type d -printf '%P\n' | grep -v "^\.$" | grep -v "^\.\.$" | grep -v "^$" | grep -v "^post$"
  else
    find "$HOME/.bash/plugins/"  -maxdepth 1 -type d -print0 | xargs -0r stat -f '%N' | sed "s,$HOME/.bash/plugins/,," | grep -v "^\.$" | grep -v "^\.\.^" | grep -v "^$" | grep -v "^post$"
  fi
}

# __grab_subdir_files(subdir: string) -> Array<String>
#
# Modifies Variables:
#  - __sash_loop_dir: expects to be set
#
# Grabs all of the directories under a category.
__grab_subdir_files() {
  __ensure_find_type
  if [[ "$SASH_FIND_FLAVOR" == "gnu" ]]; then
    find "$HOME/.bash/plugins/$1" -maxdepth 1 -type d -printf '%P\n' | grep -v "^\.$" | grep -v "^\.\.$" | grep -v "^$"
  else
    find "$HOME/.bash/plugins/$1" -maxdepth 1 -type d -print0 | xargs -0r stat -f '%N' | sed "s,$HOME/.bash/plugins/$1/,," | grep -v "$HOME/.bash/plugins/$1" | grep -v "^\.$" | grep -v "^\.\.$" | grep -v "^$"
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
  echo "# Kept so certain bash shells don't error out when no files in post directory." > "$HOME/.bash/plugins/post/keep.sh"
  chmod +x "$HOME/.bash/plugins/post/keep.sh"
  echo ""
  echo -e "${white}[${green}+${white}]${restore} S.A.S.H. has been setup!"
fi

__sash_global_startup_time="$SECONDS"
export SASH_LOADING=1

_sash_category_dirs=( $(__grab_initial_files)  )
for __sash_loop_dir in "${_sash_category_dirs[@]}"; do
  _sash_subcategory_dirs=( $(__grab_subdir_files "$__sash_loop_dir") )
  for __sash_loop_sub_dir in "${_sash_subcategory_dirs[@]}"; do
    for __sash_filename in $HOME/.bash/plugins/$__sash_loop_dir/$__sash_loop_sub_dir/*.sh; do
      [[ -x $__sash_filename ]] || [ "$SASH_IS_WINDOWS" -eq 1 ] || continue
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
    [[ -x "$__sash_filename" ]] || [ "$SASH_IS_WINDOWS" -eq 1 ] || continue
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
