#!/usr/bin/env bash

TMUX_PREFIX="Tmux"

TMUX_OPTS=""

function tmux_init() {
  TMUX_OPTS="$(config_get_item "$CONFIG_TMUX_EXTRA_OPTIONS")"
  if [ -n "$TMUX_OPTS" ]; then
    log "$LOG_DEBUG" "Extra tmux options are: '$TMUX_OPTS'"
  fi
}

function tmux_get_prefix() {
  echo "$TMUX_PREFIX"
}

function tmux_get_capabilities() {
  echo "$CAPABILITY_ITEM_REMOVAL|$CAPABILITY_REQUIRE_INIT"
}

function tmux_get_items() {
  log "$LOG_DEBUG" "Executing command 'tmux $TMUX_OPTS ls'"
  eval tmux "$TMUX_OPTS" ls | cut -d: -f1
}

function tmux_session_exists() {
  session_exists=n
  mapfile -t tmux_sessions < <(tmux_get_items)

  for session in "${tmux_sessions[@]}";
  do
    if [[ "$session" == "$1" ]]; then
      session_exists=y
      break
    fi
  done

  echo "$session_exists"
}

function tmux_select_item() {
  session_exists="$(tmux_session_exists "$1")"

  if [ "$session_exists" != "y" ]; then
    log "$LOG_ERROR" "The tmux session '$1' does not exist"
    exit 1
  fi

  if [[ "$TERM_PROGRAM" == "tmux" ]]; then
    eval tmux "$TMUX_OPTS" switch -t "$1" > /dev/null 2>&1
  else
    eval tmux "$TMUX_OPTS" attach-session -t "$1" > /dev/null 2>&1
  fi
}

function tmux_remove_item() {
  session_exists="$(tmux_session_exists "$1")"

  if [ "$session_exists" == "n" ]; then
    log "$LOG_ERROR" "The tmux session '$1' does not exist"
    exit 1
  fi

  eval tmux "$TMUX_OPTS" kill-session -t "$1" > /dev/null 2>&1
}
