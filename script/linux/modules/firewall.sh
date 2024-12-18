#!/usr/bin/env bash

# firewall config

firewall() {
  apt -yqq install ufw

  yes | ufw reset
  ufw default allow outgoing
  ufw default deny incoming
  while read -rp $'\nUFW rule to add (leave blank to continue): ' rule && [[ -n $rule ]]; do
    # shellcheck disable=SC2086 # quoting breaks ufw command parsing
    ufw $rule
  done

  ufw logging on
  ufw enable
  service ufw start
  ufw status
}