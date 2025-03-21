#!/bin/sh

SCRIPT_DIR="$HOME/.local/share/game-launcher"
PLAYTIME_DB="$SCRIPT_DIR/game_playtime_db"

if [ ! -f "$PLAYTIME_DB" ]; then
  echo "No playtime database found: $PLAYTIME_DB"
  exit 1
fi

convert_playtime() {
  SECONDS="$1"
  HOURS=$((SECONDS / 3600))
  MINUTES=$(((SECONDS % 3600) / 60))
  SECONDS=$((SECONDS % 60))
  printf "%d:%02d:%02d" "$HOURS" "$MINUTES" "$SECONDS"
}

printf "%-20s | %-25s\n" "Game Name" "Total Playtime (hours:minutes:seconds)"
printf "%-20s | %-25s\n" "--------------------" "--------------------------"

# Read and process the database
while IFS=',' read -r GAME_NAME TOTAL_PLAYTIME; do
  HUMAN_READABLE_PLAYTIME=$(convert_playtime "$TOTAL_PLAYTIME")
  printf "%-20s | %-25s\n" "$GAME_NAME" "$HUMAN_READABLE_PLAYTIME"
done < "$PLAYTIME_DB"
