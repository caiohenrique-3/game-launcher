#!/bin/sh

# Retrieves the user chosen name of a game from name_map.

SCRIPT_DIR="$(dirname "$(dirname "$0")")"
NAME_MAP="$SCRIPT_DIR/config/name_map"

GAME="$1"
PRETTY_NAME=$(grep "^$GAME," "$NAME_MAP" | cut -d',' -f2)

if [ -n "$PRETTY_NAME" ]; then
  echo "$PRETTY_NAME"
else
  echo "$GAME" # Fallback to the original name if no mapping exists
fi
