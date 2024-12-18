#!/usr/bin/env bash

# use this script to run modules individually
# ./run-standalone.sh <module>

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

unalias -a

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

! [[ -d tmp ]] && mkdir tmp
! [[ -d log ]] && mkdir log
! [[ -d out ]] && mkdir out

module="$1"; shift
# shellcheck disable=SC1090
source "modules/${module}.sh"
"${module}"

# cd to base dir before removing tmp
cd "${BASEDIR}" || exit
rm -rf tmp
cd "${CURRDIR}" || exit