# Welcome to the Board

A Godot 4.7 party game: a cursed board on a candlelit table. This branch adds ten real-time trials on top of the hot-seat night.

```bash
tools/validate.sh
```

Requires Godot 4.7.x and `gdtoolkit` 4.5 (`gdformat`, `gdlint`) on `PATH`. Play the menu with `godot --path .`. **Sit Down** starts a hot-seat night. Each turn the table falls into a trial, bots play it, and the ranking pays tokens before the board returns. Keys 1–4 look at the table, the board, the game master, and the window. Accept rolls; left and right change a shop or the seat count. Opening a scene under `src/minigames/<world>/` plays that trial on its own.
