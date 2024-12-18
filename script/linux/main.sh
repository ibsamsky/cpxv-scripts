#!/usr/bin/env bash

# add or remove modules from array to change what gets run
modules=(
  # hello
  # TODO: firefox
  hacktools
  # TODO: malware
  sources
  update
  groups # WIP maybe
  users # WIP but likely replaces zerouid
  media
  firewall # WIP
  cron
  zerouid
  passwords
  lynis
  # displaymgr
  oscap-helper
)

# maybe bad lol, depends
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

unalias -a
# make relative paths work
CURRDIR=$(pwd)
export CURRDIR
cd "$(dirname -- "$0")" || { echo "Could not cd to $(dirname -- "$0")" >&2; exit 1; }
BASEDIR=$(pwd)
export BASEDIR

# shellcheck source=script/linux/lib/util.sh
source lib/util.sh
# shellcheck source=script/linux/lib/constants.sh
source lib/constants.sh

if [[ $(id -u) -ne 0 ]]; then
  err_exit "Please run as root!" 1
fi

# shellcheck disable=SC1090
for module in "${modules[@]}"; do source "modules/${module}.sh"; done

[[ -d tmp ]] || mkdir tmp
[[ -d log ]] || mkdir log
[[ -d out ]] || mkdir out

for module in "${modules[@]}"; do
  echo -e "${s_BOLD}Running ${module}${s_RESET}\n"
  
  # run
  "${module}"
  echo -e "${s_BOLD}Finished ${module}${s_RESET}"
  
  # reset to base dir
  # shellcheck disable=SC2164
  cd "${BASEDIR}"
done

echo -e "\n${s_BOLD}Done!${s_RESET}"
rm -rf tmp

cd "${CURRDIR}" || exit
