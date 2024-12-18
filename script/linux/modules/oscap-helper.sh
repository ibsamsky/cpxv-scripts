#!/usr/bin/env bash

# helper script for OpenSCAP on ubuntu

oscap-helper() {
  # return if not on ubuntu
  [[ $(get_os) == "ubuntu" ]] || { echo "This module should only be run on Ubuntu!"; return; }

  report_file="${BASEDIR}/out/oscap-report.html"
  scap_dir="/usr/share/xml/scap/ssg/content"

  # get latest ssg content from github api using jq
  touch "${BASEDIR}/tmp/ssg.zip"
  curl -fsL "https://api.github.com/repos/ComplianceAsCode/content/releases/latest" \
  | "${JQ}" -r '.assets[] | select(.content_type == "application/zip") | .browser_download_url' \
  | grep -v "oval" \
  | wget --show-progress -O "${BASEDIR}/tmp/ssg.zip" -qi -

  # extract ssg content to /usr/share/xml/scap/ssg/content/
  unzip -qq -o "${BASEDIR}/tmp/ssg.zip" -d "${BASEDIR}/tmp/ssg"
  rm -rf "/usr/share/xml/scap/ssg/" && mkdir -p "${scap_dir}"
  mv -f "${BASEDIR}"/tmp/ssg/scap-security-guide*/* "${scap_dir}/"

  # clean up
  rm -rf "${BASEDIR}/tmp/ssg" "${BASEDIR}/tmp/ssg.zip"

  # install oscap
  apt install -y libopenscap8

  # prompt for scan
  if prompt "Run OpenSCAP scan now?" "n"; then
    oscap_args=""
    if prompt "Remediate found issues?" "n"; then
      oscap_args+="--remediate "
    fi
    if prompt "Generate HTML report?" "y"; then
      oscap_args+="--report ${report_file} " && generate_report=1
    fi
    oscap_args+="--profile xccdf_org.ssgproject.content_profile_cis_level1_workstation "
    oscap_args+="${scap_dir}/ssg-ubuntu$(get_os_version_short | tr -d .)-ds.xml"

    # run oscap scan
    # shellcheck disable=SC2086 # args need to be split
    oscap xccdf eval ${oscap_args}

    [[ generate_report -eq 1 ]] && chown "$(get_current_user):$(get_current_user)" "${report_file}"
    if [[ generate_report -eq 1 ]] && prompt "Open HTML report?" "y"; then
      sudo -u "$(get_current_user)" xdg-open "${report_file}" & disown || { echo "Could not open HTML report, it can be found at ${report_file}"; return; }
    fi
  fi
}