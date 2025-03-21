#!/bin/sh

GAME_EXEC="/path/to/game/executable"
GAME_DIR=$(dirname "$GAME_EXEC")

bubblejail run native_games sh -c "
    cd $GAME_DIR &&
    $GAME_EXEC
"
