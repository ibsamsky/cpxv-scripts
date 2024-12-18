#!/usr/bin/env bash

# change user passwords

passwords() {
  rm -f "${BASEDIR}/log/password.log"

  if [[ $# -eq 0 ]]; then
    # if no users supplied, add all uid >= 1000 users from /etc/passwd
    readarray -t users <<<"$(get_users)"
  else
    # stdin as array
    users=( "${@}" )
  fi

  for user in "${users[@]}"; do
    # check if user exists
    if ! id -u "${user}" >/dev/null 2>&1; then
      echo "User \`${user}\` does not exist, skipping"
      continue
    fi

    # confirm for members of privileged groups
    # modern Ubuntu uses the `sudo` group
    # Ubuntu versions before 12.04 use the `admin` group
    # Fedora uses the `wheel` group
    # /^.*?\b(sudo|admin|wheel)\b.*?$/
    privileged_groups=( sudo admin wheel )
    # shellcheck disable=SC2001
    privileged_groups_regex="^.*\?\b\($(sed "s/ /\\\|/g" <<<"${privileged_groups[@]}")\)\b.*\?$"

    user_privileged_group=$(id -nG "${user}" | sed -n "s/${privileged_groups_regex}/\1/p")
    if [[ -n "${user_privileged_group}" ]]; then
      if ! prompt "User \`${user}\` is in the \`${user_privileged_group}\` group, are you sure?" "n"; then
        echo "Skipping \`${user}\`"
        continue
      fi
    fi

    # set password
    password=$(gen_password 20)

    if command_exists chpasswd; then
      if ! chpasswd <<<"${user}:${password}"; then
        err_exit "Error setting password for \`${user}\`" 2
      fi
    else
      # --stdin exists but isn't universal, so use heredoc
      if ! passwd "${user}" >/dev/null <<EOF
${password}
${password}
EOF
      then
        err_exit "Error setting password for \`${user}\`" 2
      fi
    fi
    echo "Set password for \`${user}\` to \`${password}\`"
    echo "${user}:${password}" >> "${BASEDIR}/log/password.log"
  done
}
