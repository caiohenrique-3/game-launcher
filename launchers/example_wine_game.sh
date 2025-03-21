#!/bin/sh

GAME_EXEC="/path/to/game/executable"
WINE_PREFIX="/path/to/prefix"
WINE_CMD="/path/to/wine/executable"

bubblejail run wine_games sh -c "
    WINEPREFIX=$WINE_PREFIX \
    WINEDEBUG=-all \
    DXVK_LOG_LEVEL=error \
    env -u DISPLAY WAYLAND_DISPLAY=wayland-0 \
    mangohud $WINE_CMD $GAME_EXEC
"
