#!/bin/sh

LAUNCHERS_DIR="$HOME/Scripts/Launchers"
LAST_ENTRY_FILE="$HOME/.cache/.last_selected_launcher"

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
      "$LAUNCHER_PATH" &
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
  "$LAUNCHER_PATH" &
  exit 0  # Exit immediately after launching the game
else
  echo "Selected launcher is not executable: $LAUNCHER_PATH"
  exit 1
fi

