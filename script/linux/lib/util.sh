#!/usr/bin/env bash

# utility functions

err_exit() {
  echo >&2 "$1"
  exit "$2"
}

command_exists() {
  command -v "$1" >/dev/null && return || return 1
}

gen_password() {
  tr -cd '[:alnum:]!-/' < /dev/urandom | head -c "$1"
}

# https://stackoverflow.com/a/11525897
array_contains() {
  local item="$1"; shift
  for e in "$@"; do
    if [[ "${e}" == "${item}" ]]; then return; fi
  done
  return 1
}

get_users() {
  awk -F: '{ if ($3 >= 1000 && $3 < 65534) print $1 }' /etc/passwd
}

get_all_users() {
  awk -F: '!/nologin/ { print $1 }' /etc/passwd
}

get_os() {
  grep -ioP '^ID=\K.+' "$([[ -r /etc/os-release ]] && echo "/etc/os-release" || echo "/usr/lib/os-release")" | tr -d \"
}

get_os_like() {
  grep -ioP '^ID_LIKE=\K.+' "$([[ -r /etc/os-release ]] && echo "/etc/os-release" || echo "/usr/lib/os-release")" | tr -d \"
}

get_os_version_short() {
  grep -ioP '^VERSION_ID=\K.+' "$([[ -r /etc/os-release ]] && echo "/etc/os-release" || echo "/usr/lib/os-release")" | tr -d \"
}

pause() {
  read -rsn1 -p $'Press any key to continue...\n' _ignored
}

prompt() {
  if [[ "$2" == "y" ]]; then
    prompt_text="$1 [Y/n]: "
  elif [[ "$2" == "n" ]]; then
    prompt_text="$1 [y/N]: "
  else
    prompt_text="$1 [y/n]: "
  fi

  while true; do
    read -rp "${prompt_text}" response

    case "${response}" in
      [yY][eE][sS]|[yY])
        return
        ;;
      [nN][oO]|[nN])
        return 1
        ;;
      "")
        if [[ "$2" == "y" ]]; then return
        elif [[ "$2" == "n" ]]; then return 1
        else echo "Invalid response"
        fi
        ;;
      *)
        echo "Invalid response"
        ;;
    esac
  done
}

# 1=match 2=replace 3=file
replace_or_append() {
  if grep -Eq "$1" "$3"; then
    sed -Ei "s@$1@$2@g" "$3"
  else
    echo "$2" >> "$3"
  fi
}

get_current_user() {
  echo "${SUDO_USER:-$(logname)}"
}

lsuser() {
  # gname - user's primary group name
  # memberof - groups of user, minus primary group (usually user's group)
  awk -F: \
  -v pattern="^$1:" \
  -v gname="$(id -ng "$1")" \
  -v memberof="$(id -nG "$1" | sed "s/^$(id -ng "$1") \?\(.*\)/\1/; s/ /, /g; s/^\s*$/[none]/")" '
    $0 ~ pattern {
      print $1,
      "UID: " $3,
      "Primary GID: " $4 " (" gname ")",
      "Member of: " memberof,
      "Comment: " (match($5, /[^ ]/) ? $5 : "[none]"),
      "Home: " $6,
      "Shell: " $7
    }
  ' OFS="\n  " /etc/passwd
}

is_admin() {
  admingroups=( sudo admin wheel )
  for group in "${admingroups[@]}"; do
    getent group "${group}" >/dev/null || continue
    if id -nG "$1" | grep -qw "${group}"; then return; else continue; fi
  done
  return 1
}

# remove from all groups
# sed -i "s/\(.*\),\?$user[^:]*$/\1/g" /etc/group
