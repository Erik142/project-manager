SCRATCHPAD_PREFIX="Scratchpad"
SCRATCHPAD_SUBMENU="Create new scratchpad"

function scratchpad_get_prefix() {
  echo "$SCRATCHPAD_PREFIX"
}

function scratchpad_get_capabilities() {
  echo "$CAPABILITY_SUBMENU|$CAPABILITY_BATCH"
}

function scratchpad_get_items() {
  echo "$SCRATCHPAD_SUBMENU"
}

function scratchpad_show_submenu() {
  clear
  read -e -p "Enter name of scratchpad: " -i "scratch" scratchpad_name

  if [ -z "$scratchpad_name" ]; then
    log "$LOG_ERROR" "Scratchpad name is empty."
    exit 1
  fi

  scratchpad_run_batch "$scratchpad_name"
}

function scratchpad_get_session_name() {
  tmux_get_items | grep "$1" | sort -r | head -1
}

function scratchpad_run_batch() {
  scratchpad_name="$1"
  open_existing_scratchpad="n"

  if [ -n "$2" ]; then
    open_existing_scratchpad="$2"
  fi

  session_name=""

  if [ "$open_existing_scratchpad" == "y" ]; then
    session_name="$(scratchpad_get_session_name "$scratchpad_name")"
  fi

  if [ -z "$session_name" ]; then
    session_name="${scratchpad_name}-$(date +%Y%m%d-%H%M%S)"
    tmuxinator start scratchpad -n "$session_name"
  fi

  if [[ "$TERM_PROGRAM" == "tmux" ]]; then
    tmux $TMUX_OPTS switch -t "$session_name"
  else
    tmux $TMUX_OPTS attach-session -t "$session_name"
  fi
}