#!/usr/bin/env bash

# configure display manager

displaymgr() {
  configure_lightdm() {
    lightdm_conf="/etc/lightdm/lightdm.conf"
    [[ -f "${lightdm_conf}" ]] || echo "[SeatDefaults]" > "${lightdm_conf}"
    cp "${lightdm_conf}" "${lightdm_conf}.bak"

    # disable guest session
    replace_or_append '^#\?allow-guest=' 'allow-guest=false' "${lightdm_conf}"

    # disable user list
    replace_or_append '^#\?greeter-hide-users=' 'greeter-hide-users=true' "${lightdm_conf}"
    replace_or_append '^#\?greeter-show-manual-login=' 'greeter-show-manual-login=true' "${lightdm_conf}"
  }

  # no idea if this works at all
  configure_gdm() {
    readarray -t conf_files < <(grep -r "\\[org/gnome/login-screen\\]" "/etc/dconf/db/" | grep -v 'distro\|ibus' | cut -d: -f1)
    dconf_file="/etc/dconf/db/gdm.d/00-security-settings"

    mkdir -p "$(dirname -- "${dconf_file}")"

    if [[ "${#conf_files[@]}" -eq 0 ]]; then
      echo "[org/gnome/login-screen]" > "${dconf_file}"
      echo "disable-user-list=true" >> "${dconf_file}"
    else
      if grep -q '^disable-user-list=' "${conf_files[@]}"; then
        replace_or_append '^disable-user-list=' 'disable-user-list=true' "${conf_files[@]}"
      else
        sed -i '/\[org\/gnome\/login-screen\]/a disable-user-list=true' "${conf_files[@]}"
      fi
    fi
  }

  # TODO: find a better way to detect display manager
  case "$(systemctl show display-manager.service --property=Id | cut -d= -f2-)" in
    lightdm.service ) configure_lightdm ;;
    gdm.service|gdm3.service ) configure_gdm ;;
  esac
}