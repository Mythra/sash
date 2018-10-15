#!/bin/bash

# sash-show.sh
#
# sash_show takes a category, and subcategory (either through args, or by
# letting the user choose) and prints out a "materialized view" of those files
# or them concatenated together with filenames.

# _sash_materialize_view(category: String, subcategory: String) -> String
#
# Modifies Globals: None
#
# Materializes a view for a category, and subcategory.
_sash_materialize_view() {
  local category="$1"
  local sub_category="${2#./}"
  local dir=""

  if [[ "$category" == "$HOME/.bash/plugins/post" ]]; then
    dir="$category"
  else
    if [[ ! -d "$category/$sub_category" ]]; then
      echo -e "${white}[${red}-${white}]${restore} Can't find category!"
      echo "Cateogory is: [ $category/$sub_category ]."
      return 1
    fi
    dir="$category/$sub_category"
  fi

  for filename in $dir/*.sh; do
    [[ -x $filename ]] || continue
    echo ""
    echo "###############################################################"
    echo "# Content from: $filename"
    echo "###############################################################"
    echo ""
    cat $filename
  done
}

# sash_show(category: Option<String>, subcategory: Option<String>) -> String
sash_show() {
  if [[ -n "$1" ]]; then
    local full_category="$HOME/.bash/plugins/$1"
    if [[ ! -d $full_category ]]; then
      echo -e "${white}[${red}-${white}]${restore} Category doesn't exist!"
    fi
    if [[ -n "$2" ]]; then
      _sash_materialize_view "$full_category" "$2"
    else
      if [[ "$full_category" == "$HOME/.bash/plugins/post" ]]; then
        _sash_materialize_view "$full_category" "none"
      else
        echo "Please Choose a SubCategory:"
        local choice="$(cd "$full_category" && _sash_choose_a_directory "." 1)"
        _sash_materialize_view "$full_category" "$choice"
      fi
    fi
    return
  fi
  echo "Please Choose a Category:"
  local category="$(_sash_choose_a_directory "$HOME/.bash/plugins/" 1)"
  if [[ "$category" == "$HOME/.bash/plugins/post" ]]; then
    _sash_materialize_view "$category" "none"
  else
    echo "Please Choose a SubCategory:"
    local choice="$(cd "$category" && _sash_choose_a_directory "." 1)"
    _sash_materialize_view "$category" "$choice"
  fi
}
