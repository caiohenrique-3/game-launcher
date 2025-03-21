#!/bin/sh

LOG_FILE="$HOME/.local/share/game-launcher/game_time_log"
LAUNCHERS_DIR="$HOME/Scripts/Launchers"
LAST_ENTRY_FILE="$HOME/.local/share/game-launcher/last_selected_launcher"

if [ ! -d "$LAUNCHERS_DIR" ]; then
  echo "Launchers directory not found: $LAUNCHERS_DIR"
  exit 1
fi

if [ -f "$LAST_ENTRY_FILE" ]; then
  LAST_SELECTED_LAUNCHER=$(cat "$LAST_ENTRY_FILE")
  echo "Launch $LAST_SELECTED_LAUNCHER? (y/n) \c"
  read -n 1 choice
  echo
  if [ "$choice" = "y" ]; then
    LAUNCHER_PATH="$LAUNCHERS_DIR/$LAST_SELECTED_LAUNCHER"
    if [ -x "$LAUNCHER_PATH" ]; then
      echo "$(date): Starting $LAST_SELECTED_LAUNCHER" >> "$LOG_FILE"
      START_TIME=$(date +%s)
      
      "$LAUNCHER_PATH" &
      wait $!

      END_TIME=$(date +%s)
      PLAYTIME=$((END_TIME - START_TIME))
      echo "$(date): Finished $LAST_SELECTED_LAUNCHER after $PLAYTIME seconds" >> "$LOG_FILE"
      exit 0
    else
      echo "Selected launcher is not executable: $LAUNCHER_PATH"
      exit 1
    fi
  fi
fi

SELECTED_LAUNCHER=$(find "$LAUNCHERS_DIR" -type f ! -name "*example*" -exec basename {} \; | fzf --prompt="Select a game: ")

if [ -z "$SELECTED_LAUNCHER" ]; then
  echo "No game selected. Exiting."
  exit 0
fi

echo "$SELECTED_LAUNCHER" > "$LAST_ENTRY_FILE"
LAUNCHER_PATH="$LAUNCHERS_DIR/$SELECTED_LAUNCHER"

if [ -x "$LAUNCHER_PATH" ]; then
  echo "$(date): Starting $SELECTED_LAUNCHER" >> "$LOG_FILE"
  START_TIME=$(date +%s)
  
  "$LAUNCHER_PATH" &
  wait $!

  END_TIME=$(date +%s)
  PLAYTIME=$((END_TIME - START_TIME))
  echo "$(date): Finished $SELECTED_LAUNCHER after $PLAYTIME seconds" >> "$LOG_FILE"
  exit 0
else
  echo "Selected launcher is not executable: $LAUNCHER_PATH"
  exit 1
fi
