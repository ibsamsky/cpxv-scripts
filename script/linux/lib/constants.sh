#!/usr/bin/env bash
# shellcheck disable=SC2034

# existing:
# CURRDIR - directory script was run from
# BASEDIR - base directory of the script; script/linux/

USER_HOME="/home/$(get_current_user)"

s_RESET="$(tput sgr0)"
s_BOLD="$(tput bold)"
s_ITALIC="$(tput sitm)"
s_UNDERLINE="$(tput smul)"

JQ="${BASEDIR}/bin/jq-linux64"