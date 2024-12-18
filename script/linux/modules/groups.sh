#!/usr/bin/env bash

# group management

groups() {
  IFS="," read -ra to_add -p "Groups to add (comma separated): "
  if [[ -n "${to_add[*]}" ]]; then
    for group in "${to_add[@]}"; do
      echo "Adding ${group}"
      groupadd "${group}" || { echo "Error adding group: ${group}"; return; }
      if ! prompt "Add users to group?" "y"; then continue; fi
      IFS="," read -ra group_members -p "Users to add (comma separated): "
      if [[ -n "${group_members[*]}" ]]; then
        for user in "${group_members[@]}"; do
          echo "Adding ${user} to ${group}"
          useradd -aG "${group}" "${user}" || { echo "Error adding user: ${user}"; return; }
        done
      fi
    done
  fi
}