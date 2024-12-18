#!/usr/bin/env bash

# secure cron access

cron() {
  # crontab -r
  
  # shellcheck disable=SC2164
  cd /etc/
  rm -f cron.deny at.deny

  uid0=$(getent passwd 0 | cut -d: -f1)
  echo "${uid0}" > cron.allow
  echo "${uid0}" > at.allow
  chown 0:0 cron* at*
  chmod go-rwx cron* at*
}
