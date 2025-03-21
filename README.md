# Game Launcher

A tool for launching games and keeping track of their playtime. I created this because I needed something simple to launch my game scripts, which run inside a Bubblejail sandbox, and I wanted playtime tracking as well. 

## Directory Structure

```
game-launcher/
├── bin/
│   ├── launcher.sh       # Script to launch games
│   ├── update_db.sh      # Script to update the playtime database
│   ├── pretty_name.sh    # Script to get a pretty name for stats.sh
├── config/
│   ├── name_map          # File containing mappings for pretty names
├── data/
│   ├── game_time_log     # Log of game session start/stop times
│   ├── playtime_db       # Database of cumulative playtime
│   ├── last_selected     # Last selected game
├── launchers/            # Directory containing game launcher scripts
├── stats/
│   ├── stats.sh          # Script to display total playtime of your games
```

## How To Use

1. Place your game launcher scripts in the `launchers/` directory.
2. Use `launcher.sh` to launch your games, track playtime, and log session details.
3. Customize the `name_map` file in `config/` to associate the filenames of your game launcher scripts with more descriptive names, displayed by `stats.sh`.
4. Use `stats.sh` to view total playtime of all games in your `data/playtime_db`.

## How It Works

- The `launcher.sh` script handles game selection via `fzf`.
- Logs playtime data in `data/game_time_log` and updates the cumulative database (`data/playtime_db`).
- Keeps track of the last played game to make future launches quicker by recalling the most recently played game.
