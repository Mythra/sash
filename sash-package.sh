#!/usr/bin/env bash

# Implements the sash_package command.
#
# S.A.S.H. is the main way to add things to your ~/.bashrc and still
# maintain structure.

# _sash_package_subcategory(full_category: String, checks: (0 || 1)) -> int
#
# full_category:
#   * the full path to the category to package.
# checks:
#   * Whether or not to run checks for secrets.
_sash_package_subcategory() {
  __sash_allow_errors

  local full_category_path="${1%/}"
  local run_checks="$2"

  if [[ ! -d "$full_category_path" ]]; then
    echo "[-] Can't find category at: [ $full_category_path ]!" >&2
    return 1
  fi

  local temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/sash-package-subcategory.XXXXXXXXXX") || return 1

  local filename=""
  for filename in $full_category_path/*.sh; do
    [[ -x $filename ]] || continue

    if [[ "$run_checks" == "1" ]]; then
      local options=("YES" "NO")
      echo ""
      echo "###############################################################"
      echo "# Content from: $filename"
      echo "###############################################################"
      echo ""
      cat $filename
      echo ""
      echo ""
      echo "Would you like to filter this file to remove secrets?: "
      local option="$(_sash_choose_from_options ${options[@]})"
      if [[ "$option" == "YES" ]]; then
        if ! _sash_get_multiline_input "$(cat $filename)"; then
          echo "[-] Couldn't get content! Exiting"
          return 2
        fi
        echo "$sash_multiline_content" > "$temp_dir/${filename##*/}"
      else
        cat "$filename" > "$temp_dir/${filename##*/}"
      fi
    else
      cat "$filename" > "$temp_dir/${filename##*/}"
    fi
  done

  local current_dir="$(pwd)"
  (cd "$temp_dir" && tar cfJ "$current_dir/${full_category_path##*/}.tar.xz" .) || return 10
  rm -r "$temp_dir"
  return 0
}

# _sash_package_category(category: String, checks: (0 || 1)) -> int
#
# category:
#   * the category to package.
# checks:
#   * whether or not to run checks on files for secrets.
_sash_package_category() {
  __sash_allow_errors

  local full_category_path="${1%/}"
  local run_checks="$2"

  if [[ ! -d "$full_category_path" ]]; then
    echo "[-] Can't find category at: [ $full_category_path ]!" >&2
    return 1
  fi

  local temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/sash-package-category.XXXXXXXXXX") || return 1
  local subcategories=( $(find "$full_category_path" -maxdepth 1 -type d -printf '%P\n' | grep -v "^\.$" | grep -v "^\.\.$" | grep -v "^$") )

  local subcategory=""
  local filename=""
  for subcategory in "${subcategories[@]}"; do
    mkdir -p "$temp_dir/$subcategory"
    for filename in $full_category_path/$subcategory/*.sh; do
      [[ -x $filename ]] || continue

      if [[ "$run_checks" == "1" ]]; then
        local options=("YES" "NO")
        echo ""
        echo "###############################################################"
        echo "# Content from: $filename"
        echo "###############################################################"
        echo ""
        cat $filename
        echo ""
        echo ""
        echo "Would you like to filter this file to remove secrets?: "
        local option="$(_sash_choose_from_options ${options[@]})"
        if [[ "$option" == "YES" ]]; then
          if ! _sash_get_multiline_input "$(cat $filename)"; then
            echo "[-] Couldn't get content! Exiting"
            return 2
          fi
          echo "$sash_multiline_content" > "$temp_dir/$subcategory/${filename##*/}"
        else
          cat "$filename" > "$temp_dir/$subcategory/${filename##*/}"
        fi
      else
        cat "$filename" > "$temp_dir/$subcategory/${filename##*/}"
      fi
    done
  done

  local current_dir="$(pwd)"
  (cd "$temp_dir" && tar cfJ "$current_dir/${full_category_path##*/}.tar.xz" .) || return 10
  rm -r "$temp_dir"
  return 0
}

__sash_append_to_root_of_tar_xz() {
  __sash_guard_errors

  local tarxz_file="$1"
  local file="$2"

  local my_dir="$(pwd)"
  local temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/sash-tmp-add-to-tar.XXXXXXXXXX")
  tar xJf "$tarxz_file" -C "$temp_dir"
  cp "$file" "$temp_dir"
  (cd "$temp_dir" && tar cfJ "$my_dir/tmp.tar.xz" .)
  rm "$tarxz_file"
  mv "$my_dir/tmp.tar.xz" "$tarxz_file"
}

# sash_package(args: Array<String>) -> Int
#
# sash_package will package up a category, or sub category for you to distribute to your
# friends. Note: Sash package will give you an option to filter out content for each file
# incase of secrets, unless you specify: `--package-without-checks`.
sash_package() {
  __sash_guard_errors

  local arguments="${@}"
  local flags=("package-without-checks" "c|category" "s|subcategory" "f|full-category" "u|keybase-user" "unsafe-no-sign")

  if ! __sash_parse_args "$arguments" "${flags[@]}" ; then
    echo "Failed to parse arguments for sash_package" >&2
    return 1
  fi

  if [[ "${__sash_parse_results[unsafe-no-sign]}" != "0" ]]; then
    if ! hash keybase 2>/dev/null; then
      die "Please install the Keybase CLI for generating packages."
    fi
  fi

  local category=""
  local subcategory=""
  local is_full_category=""
  local run_checks="1"
  local final_result=""

  if [[ "${__sash_parse_results[package-without-checks]}" == "0" ]]; then
    run_checks="0"
  fi
  if [[ "x${__sash_parse_results[category]}" == "x" ]]; then
    echo "[/] Please Choose a Category to Package: "
    category="$(_sash_choose_a_directory "$HOME/.bash/plugins/")"
  else
    category="$HOME/.bash/plugins/${__sash_parse_results[category]}"
  fi
  if [[ ! -d "$category" ]]; then
    echo -e "${white}[${red}-${white}]${restore} Category: [$1] doesn't exist!"
  fi

  if [[ "$category" == "$HOME/.bash/plugins/post" ]]; then
    echo "[+] Packaing Post Section..."
    final_result="$(pwd)/${category##*/}.tar.xz"
    _sash_package_subcategory "$category" "$run_checks"

    if [[ "$?" != "0" ]]; then
      die "Failed to package subcategory!"
    fi
  else
    if [[ "${__sash_parse_results[full-category]}" == "0" ]]; then
      echo "[+] Packaging Category: $category..."
      final_result="$(pwd)/${category##*/}.tar.xz"
      _sash_package_category "$category" "$run_checks"

      if [[ "$?" != "0" ]]; then
        die "Failed to package subcategory!"
      fi
    else
      if [[ "x${__sash_parse_results[subcategory]}" == "x" ]]; then
        echo "[/] Please Choose a Subcategory to Package: "
        subcategory="$(cd "$category" && _sash_choose_a_directory ".")"
      else
        subcategory="${__sash_parse_results[subcategory]}"
      fi

      local tmp_cat_subcat="$category/$subcategory"
      echo "Packaging Subcategory: $tmp_cat_subcat"
      final_result="$(pwd)/${tmp_cat_subcat##*/}.tar.xz"
      _sash_package_subcategory "$tmp_cat_subcat" "$run_checks"

      if [[ "$?" != "0" ]]; then
        die "Failed to package!"
      fi
    fi
  fi

  if [[ "${__sash_parse_results[unsafe-no-sign]}" == "0" ]]; then
    echo "[+] Generated unsafe, non signed package."
    return 0
  fi

  if [[ "x${__sash_parse_results[keybase-user]}" != "x" ]]; then
    local user="${__sash_parse_results[keybase-user]}"
    echo "[+] Ensuring keybase user exists before signing."
    keybase id "$user"
    echo "[+] PGP Encrypting for user."
    keybase pgp encrypt "$user" -i "$final_result" -o "${final_result}.asc"
    rm "$final_result"
    echo "[+] Encrypted. Encrypted tar.xz is at: ${final_result}.asc"
    return 0
  else
    echo "[+] Creating signature file for package."
    keybase pgp sign -i "$final_result" --detached > "sig.asc"
    __sash_append_to_root_of_tar_xz "$final_result" "sig.asc"
    rm "sig.asc"
    keybase id 2>&1 | head -n1 | awk '{ print $NF }' | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g' > "sig.usr"
    __sash_append_to_root_of_tar_xz "$final_result" "sig.usr"
    rm "sig.usr"
  fi
}
