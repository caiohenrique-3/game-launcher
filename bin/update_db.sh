#!/bin/sh

# Updates the playtime database.

SCRIPT_DIR="$(dirname "$(dirname "$0")")"
PLAYTIME_DB="$SCRIPT_DIR/data/playtime_db"
NAME_MAP="$SCRIPT_DIR/config/name_map"
PRETTY_NAME_SCRIPT="$SCRIPT_DIR/bin/pretty_name.sh"

GAME="$1"
PLAYTIME="$2"
PRETTY_NAME=$("$PRETTY_NAME_SCRIPT" "$GAME")

if grep -q "^$PRETTY_NAME," "$PLAYTIME_DB"; then
  CURRENT_PLAYTIME=$(grep "^$PRETTY_NAME," "$PLAYTIME_DB" | cut -d',' -f2)
  TOTAL_PLAYTIME=$((CURRENT_PLAYTIME + PLAYTIME))
  sed -i "s/^$PRETTY_NAME,.*/$PRETTY_NAME,$TOTAL_PLAYTIME/" "$PLAYTIME_DB"
else
  echo "$PRETTY_NAME,$PLAYTIME" >> "$PLAYTIME_DB"
fi
