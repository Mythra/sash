#!/usr/bin/env bash

# Implements the sash_add command.
#
# S.A.S.H. is the main way to add things to your ~/.bashrc and still
# maintain structure.

# _sash_create_or_choose_subcategory(category: String) -> String
#
# Modifies Variables:
#   - _sash_intermediate_choice
#
# allows the user to choose, or create a subcategroy within sash.
_sash_create_or_choose_subcategory() {
  __sash_guard_errors

  local category="$1"
  local choice="$(cd "$category" && _sash_choose_a_directory "." 0)"
  if [[ "$choice" == "New" ]]; then
    read -p "Please Enter the New Category Name: " _sash_intermediate_choice
    mkdir -p "$category/$_sash_intermediate_choice" > /dev/null 2>&1
    echo "$_sash_intermediate_choice"
  else
    echo "$choice"
  fi
}

# sash:add() -> None
#
# Modifies Variables:
#   - _sash_add_filename
#
# allows the user to add content to their ~/.bashrc in a structured
# and sensible way.
sash:add() {
  __sash_guard_errors

  echo "Please Choose a Category: "
  local category="$(_sash_choose_a_directory "$HOME/.bash/plugins/" 0)"
  if [[ "$category" == "New" ]]; then
    read -p "Please Enter the new Category Name: " _sash_add_filename
    mkdir -p "$HOME/.bash/plugins/$_sash_add_filename"
    category="$HOME/.bash/plugins/$_sash_add_filename"
  fi

  local is_post="0"
  if [[ "$category" == "$HOME/.bash/plugins/post" ]]; then
    is_post="1"
  else
    echo "Please Choose a SubCategory: "
    local subcategory="$(_sash_create_or_choose_subcategory $category)"
    subcategory="${subcategory#./}"
  fi

  if ! _sash_get_multiline_input "# Please insert what you want to add to your bashrc below:" ""; then
    exit 1
  fi
  local content_to_add="$sash_multiline_content"

  if ! _sash_get_multiline_input "Please type what you want to be commented above this."; then
    exit 1
  fi
  local content_to_comment="$sash_multiline_content"

  echo "Current Files you can append to are:"
  if [[ "$is_post" == "1" ]]; then
    for _sash_show_existing_filename in $category/*; do
      echo "$(basename "$_sash_show_existing_filename")"
    done
  else
    for _sash_show_existing_filename in $category/$subcategory/*; do
      echo "$(basename "$_sash_show_existing_filename")"
    done
  fi
  read -p "Please Enter a filename to add this content to (should end in .sh): " _sash_add_filename

  local trapped_sigint="$(_sash_get_trapped_text SIGINT)"
  local trapped_sigquit="$(_sash_get_trapped_text SIGQUIT)"
  SAVEIFS=$IFS
  _sash_safe_add_to_trap "IFS=$SAVEIFS" "SIGINT"
  _sash_safe_add_to_trap "IFS=$SAVEIFS" "SIGQUIT"
  IFS=$'\n'
  content_to_comment=($content_to_comment)
  IFS=$SAVEIFS
  if [[ "x$trapped_sigint" != "x" ]]; then
    trap "$trapped_sigint" SIGINT
  else
    trap - SIGINT
  fi
  if [[ "x$trapped_sigquit" != "x" ]]; then
    trap "$trapped_sigquit" SIGQUIT
  else
    trap - SIGQUIT
  fi

  if [[ "$is_post" == "1" ]]; then
    for (( i=0; i<${#content_to_comment[@]}; i++ )); do
      echo "# ${content_to_comment[$i]}" >> "$category/$_sash_add_filename"
    done
    echo "$content_to_add" >> "$category/$_sash_add_filename"
    chmod +x "$category/$_sash_add_filename"
    source "$category/$_sash_add_filename"
  else
    for (( i=0; i<${#content_to_comment[@]}; i++ )); do
      echo "# ${content_to_comment[$i]}" >> "$category/$subcategory/$_sash_add_filename"
    done
    echo "$content_to_add" >> "$category/$subcategory/$_sash_add_filename"
    chmod +x "$category/$subcategory/$_sash_add_filename"
    source "$category/$subcategory/$_sash_add_filename"
  fi

  echo "[+] Added, and sourced!"
}

# sash_add()
#
# alias to sash:add
sash_add() {
  sash:add
  return $?
}
