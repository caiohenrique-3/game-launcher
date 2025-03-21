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

# Determine maximum widths for columns dynamically
MAX_GAME_NAME_WIDTH=$(awk -F',' '{ if (length($1) > max) max = length($1) } END { print (max > 20 ? max : 20) }' "$PLAYTIME_DB")
HEADER_PLAYTIME="Total Playtime (hours:minutes:seconds)"
MAX_PLAYTIME_WIDTH=${#HEADER_PLAYTIME}

# Dynamically generate the underline lengths
GAME_NAME_UNDERLINE=$(printf '%*s' "$MAX_GAME_NAME_WIDTH" '' | tr ' ' '-')
PLAYTIME_UNDERLINE=$(printf '%*s' "$MAX_PLAYTIME_WIDTH" '' | tr ' ' '-')

printf "%-*s | %s\n" "$MAX_GAME_NAME_WIDTH" "Game Name" "$HEADER_PLAYTIME"
printf "%-*s | %s\n" "$MAX_GAME_NAME_WIDTH" "$GAME_NAME_UNDERLINE" "$PLAYTIME_UNDERLINE"

# Read and process the database
while IFS=',' read -r GAME_NAME TOTAL_PLAYTIME; do
  HUMAN_READABLE_PLAYTIME=$(convert_playtime "$TOTAL_PLAYTIME")
  printf "%-*s | %s\n" "$MAX_GAME_NAME_WIDTH" "$GAME_NAME" "$HUMAN_READABLE_PLAYTIME"
done < "$PLAYTIME_DB"
