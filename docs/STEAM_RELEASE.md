# Steam release

No Steam app id is assigned. Do not put `480`, or any other stand-in, in `STEAM_APP_ID` or `res://steam_appid.txt`. The lobby, the relay, achievements, and rich presence stay unwired until GodotSteam, the Steamworks redistributable, a real app id, and a logged-on client are all present. That gap is `docs/BLOCKERS.md`. The text below is store copy for that future app. It is not a live Steamworks configuration, and it does not claim a 60 FPS Deck result.

## Store page

**Welcome to the Board**

A candlelit table, a short night, and a hooded keeper who is not on your side.

Two to four players sit a hot-seat night, or join a host over ENet. Each turn the pawns walk a sixteen-space loop, then the whole table falls into a short trial. The richest seat is kept. The keeper pockets a token on their own schedule and, at the end, the parchment repeats the worst failure.

- Hot-seat on one machine, and a host-authoritative ENet lobby.
- Ten trials, two each in the jungle, the desert, the haunted house, space, and the volcano. Each one runs 30–90 seconds.
- Dice, a shop, event cards, and bots that finish a seat when someone leaves.
- A diegetic table: no HUD. Look at the board, the keeper, or the window.
- The lamp, the ink, motion, type size, and the keeper key can be changed from the match parchment. Effects do not change who wins.
- Keyboard and gamepad.

Steam lobbies, invites, and the relay are implemented behind GodotSteam and are not live in this build. Do not list "online via Steam" as a shipping feature until `docs/BLOCKERS.md` is cleared.

Tags worth proposing later: local multiplayer, party, board game, indie. Content notes: comic fantasy peril, no gore. Language: English.

## Machines

The shipping presets are Linux x86_64 and Windows x86_64. The game asks for Vulkan (Forward+) and can fall back to OpenGL 4.5 Compatibility. The picture is drawn at 640×360 and shown nearest-filtered in a 1280×720 window. The audit process reported under 60 MB of Godot static memory. That is not a recommended-RAM figure for a store page, and it is not a Steam Deck test.

## Demo

There is no demo depot and no demo app id. When a real app exists, the demo should be the same hot-seat night with a shorter turn count: the candlelit menu, the lesson on the parchment, two trials, one keeper line, and the end parchment. It must run with Steam absent. Do not ship a demo that pretends a lobby came online.

## Trailer and GIFs

No trailer and no GIF are in the repo. Cut them from this build, at 1280×720, and do not borrow footage from another game. A useful sequence:

1. The menu: the candlelit table and the three slates, Sit Down, Trim Lamp, Leave.
2. The match parchment: How Many Sit, and one line of the lesson.
3. A pawn walking the loop after a roll.
4. The fall into a trial. Vine Rush is the shortest jungle scene; one beat from each world is enough.
5. The hooded keeper and the lantern. The silhouette stays faceless.
6. The end parchment naming the seat the night keeps, with the worst failure on the page.

Still frames from the visual probe are checks for a blank image. They are not the trailer.

## Builds

Official export templates `4.7.2.stable`, installed locally, not committed. From the repo:

```bash
tools/export_release.sh
```

That writes:

- `build/export/linux/WelcomeToTheBoard.x86_64`
- `build/export/windows/WelcomeToTheBoard.exe`

Both packs embed the game. Tests, GUT, docs, and `build/` are excluded. On the audit machine the Linux file was a 64-bit ELF that printed the Godot 4.7.2 banner and stayed running under `--headless` until it was stopped. The Windows file was a PE32+ GUI executable and was not launched here.

## Achievements

The host can ask for these once Steam is actually up. None of them are stored today:

- `FIRST_NIGHT`
- `TRIAL_CROWN`
- `TABLE_SURVIVOR`
- `FULL_TABLE`

Rich presence strings are the same ones already in the seam (`At the table`, `On the board`, `Inside a trial`, `Counting the tokens`). They stay unpublished while Steam is absent.
