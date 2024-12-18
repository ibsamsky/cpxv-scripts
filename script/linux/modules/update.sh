#!/usr/bin/env bash

# update packages

update() {
  # debian -> apt
  # fedora -> yum/dnf
  # rhel -> yum/dnf
  # arch -> pacman
  # https://distrowatch.com/dwres.php?resource=package-management

  # packages to install
  pkgs=( git wget curl )

  apt_update() {
    if prompt "Configure automatic updates?" "y"; then
      apt_periodic="/etc/apt/apt.conf.d/10periodic"
      apt_auto="/etc/apt/apt.conf.d/20auto-upgrades"

      replace_or_append '^APT::Periodic::Update-Package-Lists\s+"[0-9]+";' 'APT::Periodic::Update-Package-Lists "1";' "${apt_periodic}"
      replace_or_append '^APT::Periodic::Unattended-Upgrade\s+"[0-9]+";' 'APT::Periodic::Unattended-Upgrade "1";' "${apt_periodic}"
      replace_or_append '^APT::Periodic::Download-Upgradeable-Packages\s+"[0-9]+";' 'APT::Periodic::Download-Upgradeable-Packages "1";' "${apt_periodic}"
      replace_or_append '^APT::Periodic::AutocleanInterval\s+"[0-9]+";' 'APT::Periodic::AutocleanInterval "7";' "${apt_periodic}"

      cp -f "${apt_periodic}" "${apt_auto}"
      echo "Configured automatic updates!"
    fi

    apt update
    (export DEBIAN_FRONTEND=noninteractive 
      apt upgrade -y
      apt autoremove -y
      apt install -y "${pkgs[@]}"
    )
  }

  snap_update() {
    snap refresh
    snap set system refresh.timer 00:00-24:00/24
  }

  prompt "Reboot after update?" "n"; reboot_resp=$?

  case $(get_os) in
    ubuntu | debian )
      apt_update
      if [[ $(get_os) == "ubuntu" ]] && command_exists snap; then
        snap_update
      fi
      ;;
    fedora ) 
      dnf check-update
      dnf upgrade -y
      dnf clean all
      dnf install -y "${pkgs[@]}"
      ;;
    *)
      case $(get_os_like) in
        *debian* )
          apt_update
          ;;
        *)
          # TODO: add more
          echo "Could not determine OS, skipping update"
          return
          ;;
      esac
      ;;
  esac

  if [[ $reboot_resp -eq 0 ]]; then reboot; fi
}