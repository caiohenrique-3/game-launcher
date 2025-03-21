#!/bin/sh

SCRIPT_DIR="$HOME/.local/share/game-launcher"
LOG_FILE="$SCRIPT_DIR/game_time_log"
PLAYTIME_DB="$SCRIPT_DIR/game_playtime_db"
LAUNCHERS_DIR="$HOME/Scripts/Launchers"
LAST_ENTRY_FILE="$SCRIPT_DIR/last_selected_launcher"

if [ ! -d "$SCRIPT_DIR" ]; then
  mkdir -p "$SCRIPT_DIR"
fi

if [ ! -d "$LAUNCHERS_DIR" ]; then
  echo "Launchers directory not found: $LAUNCHERS_DIR"
  exit 1
fi

if [ ! -f "$PLAYTIME_DB" ]; then
  touch "$PLAYTIME_DB"
fi

update_playtime_db() {
  GAME="$1"
  PLAYTIME="$2"

  if grep -q "^$GAME," "$PLAYTIME_DB"; then
    CURRENT_PLAYTIME=$(grep "^$GAME," "$PLAYTIME_DB" | cut -d',' -f2)
    TOTAL_PLAYTIME=$((CURRENT_PLAYTIME + PLAYTIME))
    sed -i "s/^$GAME,.*/$GAME,$TOTAL_PLAYTIME/" "$PLAYTIME_DB"
  else
    echo "$GAME,$PLAYTIME" >> "$PLAYTIME_DB"
  fi
}

if [ -f "$LAST_ENTRY_FILE" ]; then
  LAST_SELECTED_LAUNCHER=$(cat "$LAST_ENTRY_FILE")
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
        update_playtime_db "$LAST_SELECTED_LAUNCHER" $PLAYTIME
      fi
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
  START_TIME=$(date +%s)

  "$LAUNCHER_PATH" &
  wait $!

  END_TIME=$(date +%s)
  PLAYTIME=$((END_TIME - START_TIME))

  if [ $PLAYTIME -ge 5 ]; then
    echo "$(date): Starting $SELECTED_LAUNCHER" >> "$LOG_FILE"
    echo "$(date): Finished $SELECTED_LAUNCHER after $PLAYTIME seconds" >> "$LOG_FILE"
    update_playtime_db "$SELECTED_LAUNCHER" $PLAYTIME
  fi
  exit 0
else
  echo "Selected launcher is not executable: $LAUNCHER_PATH"
  exit 1
fi
