#!/usr/bin/env bash

# find UID 0 users

zerouid() {
  zerouid_users=$(cut -d: -f1,3 /etc/passwd | grep -E ":0$" | sed "1d" | cut -d: -f1) # should* remove actual root

  if grep -q "^\s*$" <<<"${zerouid_users}"; then echo "No UID 0 users found"; return; else echo "UID 0 users found!"; fi

  # unquoted variable here because:tm:
  for user in ${zerouid_users}; do
    lsuser "${user}"
    if prompt "Delete this user?" "n"; then
      # without changing id: `userdel: user <user> is currently used by process 1`
      (sed -i "s/^\(${user}:x:\)[0-9]\+/\1$(( RANDOM + 2000 ))/" /etc/passwd && userdel -f "${user}") || { echo "Error while deleting user"; return; }
    else
      echo "Please change this user's UID so that it does not have root priveleges!"; sleep 0.1
    fi
  done
}