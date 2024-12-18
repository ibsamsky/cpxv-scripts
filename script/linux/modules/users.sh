#!/usr/bin/env bash

# manage users

users() {
  IFS="," read -ra to_remove -p "Users to remove (comma separated): "
  if [[ -n "${to_remove[*]}" ]]; then
    for user in "${to_remove[@]}"; do
      echo "Removing ${user}"
      userdel -r "${user}" || { echo "Error removing user: ${user}"; return; }
    done
  fi

  IFS="," read -ra to_add -p "Users to add (comma separated): "
  if [[ -n "${to_add[*]}" ]]; then
    for user in "${to_add[@]}"; do
      echo "Adding ${user}"
      # created locked, changing password unlocks the account
      useradd "${user}" || { echo "Error adding user: ${user}"; return; }
    done
  fi

  readarray -t all_users <<<"$(get_all_users)"
  for user in "${all_users[@]}"; do
    echo
    lsuser "${user}"
    if ! prompt "Edit this user?" "n"; then continue; fi
    if prompt "Should this user be an administrator?" "n"; then
      case $(get_os) in
        ubuntu )
          usermod -aG sudo "${user}"
          ;;
        fedora )
          usermod -aG wheel "${user}"
          ;;
        *)
          # TODO: add more
          echo "Could not determine OS, skipping marking user as administrator"
          ;;
      esac
    else
      admingroups=( sudo admin wheel lpadmin sambashare ) # last 2 probably fine but idc
      for group in "${admingroups[@]}"; do
        # group exists
        getent group "${group}" >/dev/null || continue
        # user in group
        id -nG "${user}" | grep -qw "${group}" || continue
        # remove from group
        gpasswd -d "${user}" "${group}"
      done
    fi
    read -eri "$(id -nG "${user}" | sed "s/^$(id -ng "${user}") \?\(.*\)/\1/; s/ /,/g")" -p "User groups (comma separated): " newgroups
    # set, not append, so leave off -a
    usermod -G "${newgroups}" "${user}"
  done
}