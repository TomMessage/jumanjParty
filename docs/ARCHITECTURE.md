# Architecture

Godot 4.7, GDScript with static types, Forward+ by default. The Compatibility renderer is a tested fallback for machines without Vulkan. Visual effects never feed gameplay.

## Autoloads

Only these five, in this order:

| Name | Role |
| --- | --- |
| `EventBus` | Signals other systems may listen to. No rules. |
| `Network` | Active `INetwork` backend. Forwards input and snapshots. |
| `GameState` | Authoritative seats, phase, seed, version. |
| `SaveSystem` | Settings file, including effect toggles. |
| `Audio` | Buses and cues driven by `EventBus`. |

`Audio` is last so it can read settings and subscribe once the others exist. `Network` starts a `LocalNetwork` host during boot, so menu and tests run with no sockets.

## Authority

`GameState.configure_local_match`, `set_phase`, `ensure_seat`, `replace_with_bot`, and `handle_input` return immediately unless `Network.is_host()`. Clients may only `apply_snapshot`. Broadcasting a snapshot is how the host publishes truth. The sample action `grant_token` exists to lock that rule in tests; the board will replace it in Phase 3.

A disconnected seat is marked `is_bot` on the host and that snapshot is broadcast. Bots are not a second rules engine.

## Network seam

`INetwork` is the contract (`src/net/i_network.gd`). Implementations:

- `LocalNetwork` — hot-seat and unit tests, in-process.
- `ENetNetwork` — host-authoritative peers. The driver node is mounted at `/root/Network/ENetDriver` so RPCs share one path. Filename `e_net_network.gd` keeps the `ENet` acronym while satisfying the linter's snake-to-Pascal rule.
- `SteamNetwork` — GodotSteam lobbies, invites, and the relay. Without the addon it returns `ERR_UNAVAILABLE`.

`tools/validate.sh` launches one host and two clients on localhost. The host opens a lobby on the connected seats, starts a one-turn night, drops one client, and the replacement bot finishes that seat. The surviving client sends its own roll or shop. The host resolves dice, trials, and tokens. Final snapshots match, including the board and the lobby, with exactly one bot seat.

`SteamRuntime` is the only door to GodotSteam. It looks for the `Steam` singleton and `SteamMultiplayerPeer`, then calls `steamInitEx` with the app id from `STEAM_APP_ID` or `res://steam_appid.txt`. A missing piece stops there: nothing is marked ready, and `steamInitEx` is not called. When init does succeed and the client is logged on, the host creates a friends-only lobby and `SteamDriver` opens `SteamMultiplayerPeer.host_with_lobby` with `server_relay`, so session traffic rides Steam's relay through the host. Invites use `inviteUserToLobby` or the overlay dialog. A launch argument `+connect_lobby <id>` is a join. Clients still only send input.

`SteamDeeds` can ask Steam to store `FIRST_NIGHT`, `TRIAL_CROWN`, `TABLE_SURVIVOR`, and `FULL_TABLE` after a results snapshot. `SteamPresence` can publish `status`, `steam_display`, and `connect`. Both keep the request locally and stay unpublished until Steam returns success. They do not change tokens, rankings, or the snapshot.

`Network.open_transport("steam", port)` uses that seam. If it is not ready, a positive port falls back to `ENetNetwork` and port 0 falls back to `LocalNetwork`. `BOARD_TRANSPORT=steam` or `enet` selects the boot transport; an unset variable stays on the local host. Gameplay never waits on Steam. The live lobby cannot be opened in an environment with no GodotSteam binary, Steamworks SDK, app id, or logged-on client. That gap is `docs/BLOCKERS.md`.

## Board

Hot-seat rules live in `MatchRules` (`src/board/match_rules.gd`). `GameState` is the only caller. A client snapshot cannot start a turn, roll, or buy. The board is a 16-space loop loaded from `src/data/spaces`, `cards`, and `items` resources. Dice, shops, and card order use the match seed stored in the `board` snapshot key, so a replay of the same seed ends on the same tokens.

Turns are hot-seat on `LocalNetwork`. Bots roll and shop through `BotPolicy` on the host. A dropped seat is marked `is_bot` and, if a match is active, the host finishes that seat's remaining turns before broadcasting. Landing effects are gain, loss, trap, swap, event card, or shop. Items (pip, leap, shield) change the next roll or the next loss. The night ends after three turns each. The winner is the richest seat, lowest id on a tie. `MatchTable` and `TurnPrompt` only display that snapshot and send input. They do not decide results. The decorative table in the menu, wide shot, board view, and game-master scenes is unchanged.

## Trials

`MinigameBase` owns a simulated clock. `tick(delta)` accumulates time and finishes at `planned_ms()` (30–90 seconds). `TrialCatalog` lists `ContractTrial` plus ten `TrialCard` resources. Each card points at a scene, a `TrialBody` script, and a duration. The body builds a field (race, dodge, puzzle, waves, or absurd), asks that trial's bot for every seat, and ranks the scores. The ranking is built inside the trial. The field does not read render settings, so turning effects off does not change it.

`TrialView` is the diorama. The camera starts above the felt and lands within a few frames. That fall is presentation only. The probe still instantiates each catalog script with `Script.new()`, plays it with bots, and refuses a one-tick finish or an invalid ranking. It does not special-case `ContractTrial`.

After each board action the host queues one of the ten cards from the match seed and the turn count, without touching the dice stream. `TrialNight` runs that trial for every seat, bots included, checks the ranking, and pays 3, 2, then 1 token by place. The night then returns to the board. `TrialCurtain` shows the fall on the table; it does not decide the ranking. A dropped seat still becomes a bot and the host finishes the remaining turns, trials included. That board snapshot, trial id and ranking included, is what the host broadcasts.

## Game master

`KeeperLines` picks a short line from the match seed and the turn. `BoardMood` names the turn's board event (`candles`, `tremor`, or `draft`) from that same pair, then may pocket one token or slide the current pawn. Those beats use the turn count, not `rng_state`, so the dice stream stays put. The pocket and the slide are host rules: they are in the snapshot, and a client only displays them. Every fourth completed turn pockets one token from the richest seat that still has one (lowest id on a tie). Every fifth turn slides that pawn back one space when it is not on the start tile. Last place in a trial, a real token loss, a trap, a pocket, and a slide can replace `worst_line`. A higher score wins; an equal score keeps the later failure. The end parchment shows that line. If `worst_scene` is set, `TrialCurtain` loads it again and holds it until the next night. `reduce_motion` skips that reload. The text remains.

`Audio` keeps the four buses. Ambience is a seeded rustle loop. Music is a drone plus a second loop on the same bus; only that layer's player volume moves between the table, a trial, and the result. The Music bus itself still drops from -2 dB to -10 dB in a trial. The keeper's line is a short synthetic tone built from the letters, played on Voice. It is not speech. Options live on the match parchment (cancel while choosing seats): effect intensity, high contrast, reduced motion, text scale, and the keeper key. Intensity scales the existing post amounts and defaults to 1. Missing intensity in an old settings file is 1. High contrast and text scale restyle parchment labels only. They are not shader uniforms. `SaveSystem.save_settings` emits `settings_changed` after a successful write. Effects, accessibility, and the remap never write `GameState`.

The menu stays three slates: Sit Down, Trim Lamp, Leave. The hooded figure is unchanged. A caption sits above the hood. The third match slate is Hear; up and down page a four-line lesson, and accept still starts the night.

## Rendering

`PixelStage` draws the room in a 640×360 `SubViewport` and scales it with nearest filtering. `ps1_spatial.gdshader` does optional vertex snapping and a light affine UV mix. `post_process.gdshader` adds optional grain, dither, vignette, and chromatic aberration. `RenderProfile` turns those uniforms off when settings say so, and multiplies the amounts by `effect_intensity` (0–1, default 1). `Trim Lamp` calls `SaveSystem.toggle_effects()` and refreshes uniforms. It does not touch `GameState`. Intensity, contrast, motion, and type live on the match parchment, not on a fourth menu slate.

Shadows and volumetric fog are off in this slice so the Compatibility renderer and a software GPU still finish a frame. Candle pools come from local omni lights against a low ambient.

## Scenes

`scenes/menu.tscn`, `table.tscn`, `board_view.tscn`, and `game_master.tscn` share `stage_scene.gd`. They differ by camera preset and whether the diegetic menu is interactive. `PlayableScenes` is the list the smoke test and visual probe share. It includes the room shots, the match, and each trial scene from `TrialCatalog`.

## Validation

`tools/validate.sh` (and `validate.ps1`) runs import, `gdformat --check`, `gdlint`, GUT, a 120-frame smoke test, the ENet session, the trial probe, a frame-cost probe on Forward+ and Compatibility, then visual captures. A phase is done only when that script exits 0.

## Release

`export_presets.cfg` has two shipping presets, Linux and Windows Desktop, both x86_64, with the pack embedded. They exclude `tests/`, `addons/gut/`, `build/`, and `docs/`. `tools/export_release.sh` runs both against the official Godot 4.7.2 export templates. Templates are not committed. The binaries land in `build/export/`, which is gitignored. There is no Steam app id in the presets or in the repo. Store copy, the demo plan, and the trailer shot list are `docs/STEAM_RELEASE.md`. Measured frame cost is `docs/PERF.md`. The license and rule pass is `docs/REVIEW.md`.
