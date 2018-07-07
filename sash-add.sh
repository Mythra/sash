#!/bin/bash

# Implements the sash_add/sash-add commands.
#
# S.A.S.H. is the main way to add things to your ~/.bashrc and still
# maintain structure.

# _sash_create_or_choose_subcategory(category: String) -> String
#
# Modifies Globals:
#   - _sash_intermediate_choice
#
# allows the user to choose, or create a subcategroy within sash.
_sash_create_or_choose_subcategory() {
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

# sash_add() -> None
#
# Modifies Globals:
#   - _sash_add_filename
#
# allows the user to add content to their ~/.bashrc in a structured
# and sensible way.
sash_add() {
  echo "Please Choose a Category: "
  local category="$(_sash_choose_a_directory "$HOME/.bash/plugins/" 0)"
  if [[ "$category" == "New" ]]; then
    read -p "Please Enter the new Category Name: " _sash_add_filename
    mkdir -p "$HOME/.bash/plugins/$_sash_add_filename"
    category="$HOME/.bash/plugins/$_sash_add_filename"
  fi
  echo "Please Choose a SubCategory: "
  local subcategory="$(_sash_create_or_choose_subcategory $category)"
  subcategory="${subcategory#./}"
  if ! _sash_get_multiline_input "# Please insert what you want to add to your bashrc below:\n"; then
    exit 1
  fi
  local content_to_add="$sash_multiline_content"
  if ! _sash_get_multiline_input "Please type what you want to be commented above this."; then
    exit 1
  fi
  local content_to_comment="$sash_multiline_content"
  echo "Current Files you can append to are:"
  for _sash_show_existing_filename in $category/$subcategory/*; do
    echo "$(basename "$_sash_show_existing_filename")"
  done
  read -p "Please Enter a filename to add this content to (should end in .sh): " _sash_add_filename
  SAVEIFS=$IFS
  IFS=$'\n'
  content_to_comment=($content_to_comment)
  IFS=$SAVEIFS
  for (( i=0; i<${#content_to_comment[@]}; i++ )); do
    echo "# ${content_to_comment[$i]}" >> "$category/$subcategory/$_sash_add_filename"
  done
  echo "$content_to_add" >> "$category/$subcategory/$_sash_add_filename"
  source "$category/$subcategory/$_sash_add_filename"
  echo "[+] Added, and sourced!"
}

