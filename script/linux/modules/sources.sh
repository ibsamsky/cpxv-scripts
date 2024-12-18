#!/usr/bin/env bash

# check package manager sources

sources() {
  replaced=0

  apt_sources() {
    echo "/etc/apt/sources.list:"
    sed '/^\(#\|\s*$\)/d' /etc/apt/sources.list
    if [[ $(get_os) == "ubuntu" ]] && prompt "Do you want to replace sources.list with the default?" "y"; then
      if [[ $(get_os_version_short) == 22* ]]; then
        cp "${BASEDIR}/static/sources.list.22.default" "/etc/apt/sources.list" && replaced=1
      elif [[ $(get_os_version_short) == 20* ]]; then
        cp "${BASEDIR}/static/sources.list.20.default" "/etc/apt/sources.list" && replaced=1
      else 
        echo "Could not determine OS version, skipping replacement"
      fi
    fi
  }

  dnf_sources() {
    echo "/etc/yum.repos.d:"
    dnf repolist --all
    if prompt "Do you want to replace all repos with the default?" "y"; then
      # assume fedora 36
      rm -f /etc/yum.repos.d/*
      tar -xJf "${BASEDIR}/static/yum.repos.d.36.default.tar.xz" -C "/etc/yum.repos.d/" && replaced=1
    fi
  }

  case $(get_os) in
    ubuntu | debian )
      apt_sources
      ;;
    fedora ) 
      dnf_sources
      ;;
    *)
      case $(get_os_like) in
        *debian* )
          apt_sources
          ;;
        *)
          # TODO: add more
          echo "Could not determine OS, skipping source check"
          return
          ;;
      esac
      ;;
  esac

  [[ $replaced -eq 0 ]] && echo -e "\nPlease open another shell and remove any malicious repos before continuing"
  pause
}