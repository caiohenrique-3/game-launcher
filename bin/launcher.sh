#!/bin/sh

# Handles game selection and launching, along with session tracking.

SCRIPT_DIR="$(dirname "$(dirname "$0")")"
LOG_FILE="$SCRIPT_DIR/data/game_time_log"
LAST_ENTRY_FILE="$SCRIPT_DIR/data/last_selected"
LAUNCHERS_DIR="$SCRIPT_DIR/launchers"
UPDATE_DB_SCRIPT="$SCRIPT_DIR/bin/update_db.sh"

touch "$LAST_ENTRY_FILE"

launch_game() {
  local launcher=$1
  local path="$LAUNCHERS_DIR/$launcher"

  if [ ! -x "$path" ]; then
    echo "Selected launcher is not executable: $path"
    exit 1
  fi

  local start_time=$(date +%s)
  "$path" &
  wait $!
  local end_time=$(date +%s)
  local playtime=$((end_time - start_time))

  [ $playtime -ge 5 ] && {
    echo "$(date): Starting $launcher" >> "$LOG_FILE"
    echo "$(date): Finished $launcher after $playtime seconds" >> "$LOG_FILE"
    "$UPDATE_DB_SCRIPT" "$launcher" "$playtime"
  }
}

if [ -s "$LAST_ENTRY_FILE" ]; then
  last_selected_launcher=$(cat "$LAST_ENTRY_FILE")
  echo "Launch $last_selected_launcher? (y/n) \c"
  read -n 1 choice
  echo
  [ "$choice" = "y" ] && launch_game "$last_selected_launcher" && exit 0
fi

[ ! -d "$LAUNCHERS_DIR" ] && { echo "Launchers directory not found: $LAUNCHERS_DIR"; exit 1; }

selected_launcher=$(find "$LAUNCHERS_DIR" -type f ! -name "*example*" -exec basename {} \; | fzf --prompt="Select a game: ")
[ -z "$selected_launcher" ] && { echo "No game selected. Exiting."; exit 0; }

echo "$selected_launcher" > "$LAST_ENTRY_FILE"
launch_game "$selected_launcher"
