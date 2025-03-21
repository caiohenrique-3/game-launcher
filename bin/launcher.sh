#!/bin/sh

# Handles game selection and launching, along with session tracking.

SCRIPT_DIR="$(dirname "$(dirname "$0")")"
LOG_FILE="$SCRIPT_DIR/data/game_time_log"
LAST_ENTRY_FILE="$SCRIPT_DIR/data/last_selected"
LAUNCHERS_DIR="$HOME/Scripts/Launchers"
UPDATE_DB_SCRIPT="$SCRIPT_DIR/bin/update_db.sh"

if [ ! -f "$LAST_ENTRY_FILE" ]; then
  touch "$LAST_ENTRY_FILE"
fi

# Prompt to launch the last selected game if available
if [ -f "$LAST_ENTRY_FILE" ]; then
  LAST_SELECTED_LAUNCHER=$(cat "$LAST_ENTRY_FILE")
  if [ -n "$LAST_SELECTED_LAUNCHER" ]; then
    echo "Launch $LAST_SELECTED_LAUNCHER? (y/n) \c"
    read -n 1 choice
    echo
    if [ "$choice" = "y" ]; then
      LAUNCHER_PATH="$LAUNCHERS_DIR/$LAST_SELECTED_LAUNCHER"
      if [ -x "$LAUNCHER_PATH" ]; then
        START_TIME=$(date +%s)

        "$LAUNCHER_PATH" &
        wait $!

        END_TIME=$(date +%s)
        PLAYTIME=$((END_TIME - START_TIME))

        if [ $PLAYTIME -ge 5 ]; then
          echo "$(date): Starting $LAST_SELECTED_LAUNCHER" >> "$LOG_FILE"
          echo "$(date): Finished $LAST_SELECTED_LAUNCHER after $PLAYTIME seconds" >> "$LOG_FILE"
          "$UPDATE_DB_SCRIPT" "$LAST_SELECTED_LAUNCHER" "$PLAYTIME"
        fi
        exit 0
      else
        echo "Selected launcher is not executable: $LAUNCHER_PATH"
        exit 1
      fi
    fi
  fi
fi

# Use fzf to select a new launcher
if [ ! -d "$LAUNCHERS_DIR" ]; then
  echo "Launchers directory not found: $LAUNCHERS_DIR"
  exit 1
fi

SELECTED_LAUNCHER=$(find "$LAUNCHERS_DIR" -type f ! -name "*example*" -exec basename {} \; | fzf --prompt="Select a game: ")

if [ -z "$SELECTED_LAUNCHER" ]; then
  echo "No game selected. Exiting."
  exit 0
fi

LAUNCHER_PATH="$LAUNCHERS_DIR/$SELECTED_LAUNCHER"

if [ -x "$LAUNCHER_PATH" ]; then
  echo "$SELECTED_LAUNCHER" > "$LAST_ENTRY_FILE"

  START_TIME=$(date +%s)

  "$LAUNCHER_PATH" &
  wait $!

  END_TIME=$(date +%s)
  PLAYTIME=$((END_TIME - START_TIME))

  if [ $PLAYTIME -ge 5 ]; then
    echo "$(date): Starting $SELECTED_LAUNCHER" >> "$LOG_FILE"
    echo "$(date): Finished $SELECTED_LAUNCHER after $PLAYTIME seconds" >> "$LOG_FILE"
    "$UPDATE_DB_SCRIPT" "$SELECTED_LAUNCHER" "$PLAYTIME"
  fi
  exit 0
else
  echo "Selected launcher is not executable: $LAUNCHER_PATH"
  exit 1
fi
