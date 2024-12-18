#!/usr/bin/env bash

# run lynis scan

lynis() {
  cd tmp || return
  # assume git installed
  git clone https://github.com/CISOfy/lynis
  
  cd lynis || return
  ./lynis audit system

  mv -f /var/log/lynis.log "${BASEDIR}/log/"
  chown "$(get_current_user):$(get_current_user)" "${BASEDIR}/log/lynis.log"
}