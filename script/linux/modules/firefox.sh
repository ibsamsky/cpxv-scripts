#!/usr/bin/env bash

# firefox config

firefox() {
  local firefox_folder

  firefox_paths=(
    "${USER_HOME}/.mozilla/firefox"
    "${USER_HOME}/.var/app/org.mozilla.firefox/.mozilla/firefox"
    "${USER_HOME}/snap/firefox/common/.mozilla/firefox"
  )

  for path in "${firefox_paths[@]}"; do
    if [[ -d "${path}" ]]; then
      firefox_folder="${path}"
    fi
  done

  echo "${firefox_folder}"

  # who knows if user.js works for scoring ill just do this later ig
  # https://github.com/arkenfox/user.js/blob/master/updater.sh
}