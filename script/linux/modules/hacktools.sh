#!/usr/bin/env bash

# remove hacking tools/PUPs

hacktools() {
  pkgs=(
    aircrack-ng deluge hashcat hydra john \
    openvpn qbittorrent telnet wireguard nmap \
    zenmap gameconqueror manaplus ophcrack transmission-gtk \
    transmission-qt wireshark wireshark-qt wireshark-gtk 
  )

  case $(get_os) in
    ubuntu | debian )
      apt -s purge "${pkgs[@]}" 2>&1 | sed "/^\(Purg\|WARNING\|$\)/d"
      if prompt "Do you want to continue uninstalling?" "n"; then
        apt -y purge "${pkgs[@]}"
      fi
      ;;
    fedora ) 
      dnf repoquery -deplist "${pkgs[@]}"
      if prompt "Do you want to continue uninstalling?" "n"; then
        dnf -y remove "${pkgs[@]}"
      fi
      ;;
    *)
      case $(get_os_like) in
        *debian* )
          apt -s purge "${pkgs[@]}" 2>&1 | sed "/^\(Purg\|WARNING\|$\)/d"
          if prompt "Do you want to continue uninstalling?" "n"; then
            apt -y purge "${pkgs[@]}"
          fi
          ;;
        *)
          # TODO: add more
          echo "Could not determine OS, skipping hacktools check"
          return
          ;;
      esac
      ;;
  esac

  if [[ $(get_os) == "ubuntu" ]] && command_exists snap; then
    snap_pkgs=( ftpscan )

    for pkg in "${snap_pkgs[@]}"; do
      if snap list "${pkg}" 2>/dev/null; then
        if prompt "Do you want to uninstall this package?" "n"; then
          snap remove --purge "${pkg}"
        fi
      fi
    done
  fi
}