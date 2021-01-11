#!/usr/bin/env bash

#[[ -n "$XDG_DATA_HOME" ]] && PASSDIR="$XDG_DATA_HOME/pass" || PASSDIR=$HOME/.password-store
PASSDIR="${PASSWORD_STORE_DIR:-$HOME/.password-store/}"
STATES=(FILE_INFO_MODE FIELD_SELECT_MODE)

get_passfile_candidates() {
  find "$PASSDIR" -name '*.gpg' -printf '%P\n' | sed -e 's/.gpg$//gi'
}

get_passfile() {
  PARAMS=$1
  get_passfile_candidates | fzf -q "$PARAMS" --select-1
}

show_help() {
  echo "Usage: $0 [-l] [PARAMS]"
  exit 1
}

is_mode() {
  [[ -n $MODE ]] && [[ $MODE -eq ${STATES[$1]} ]] && echo yes
}

is_not_wsl() {
  echo "$PATH" | sed -e '/\/mnt\/c\/Windows\/system32/!d'
}

while getopts "l" o; do
  case "${o}" in
  l)
    MODE=${STATES[$FILE_INFO_MODE]}
    ;;
  *)
    show_help
    ;;
  esac
done

shift $((OPTIND - 1))
PARAMS="$@"
COMMAND=$(get_passfile "$PARAMS")

if [ -n "$COMMAND" ]; then
  [[ $(is_mode "$FILE_INFO_MODE") ]] && echo "$PASS_SUBDIR$COMMAND" && exit 0
  [[ -n $PASS_SUBDIR ]] && echo "Subdirectory: $PASS_SUBDIR"
  PASSWD=$(pass show "$COMMAND" | sed '1!d') || exit $?
  [[ $(is_not_wsl) ]] && echo "$PASSWD" | clip.exe || pass -c "$COMMAND"
else
  exit 1
fi
