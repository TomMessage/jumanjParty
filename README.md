# Welcome to the Board

A Godot 4.7 party game: a cursed board on a candlelit table. This branch adds ten real-time trials on top of the hot-seat night.

```bash
tools/validate.sh
```

Requires Godot 4.7.x and `gdtoolkit` 4.5 (`gdformat`, `gdlint`) on `PATH`. Play the menu with `godot --path .`. **Sit Down** starts a hot-seat night. Each turn the table falls into a trial, bots play it, and the ranking pays tokens before the board returns. Keys 1–4 look at the table, the board, the game master, and the window. Accept rolls; left and right change a shop or the seat count. Opening a scene under `src/minigames/<world>/` plays that trial on its own. An ENet host can also keep a lobby and start the same night; clients send input, and a dropped seat becomes a bot. Steam lobbies are optional: without GodotSteam the same night stays on ENet or hot-seat. On the match parchment, Hear pages a short lesson and cancel trims effect strength, ink, motion, type, and the keeper key. The hooded keeper speaks in synthetic gibberish, and the end of night repeats the worst failure.
