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
- `SteamNetwork` — returns `ERR_UNAVAILABLE` until Phase 6. No GodotSteam addon yet.

`tools/validate.sh` launches one host and two clients on localhost, drops one client, and checks that the surviving client's snapshot matches the host, including exactly one bot seat. That is a session contract, not a full match. The full match comparison arrives with Phase 5.

## Board

Hot-seat rules live in `MatchRules` (`src/board/match_rules.gd`). `GameState` is the only caller. A client snapshot cannot start a turn, roll, or buy. The board is a 16-space loop loaded from `src/data/spaces`, `cards`, and `items` resources. Dice, shops, and card order use the match seed stored in the `board` snapshot key, so a replay of the same seed ends on the same tokens.

Turns are hot-seat on `LocalNetwork`. Bots roll and shop through `BotPolicy` on the host. A dropped seat is marked `is_bot` and, if a match is active, the host finishes that seat's remaining turns before broadcasting. Landing effects are gain, loss, trap, swap, event card, or shop. Items (pip, leap, shield) change the next roll or the next loss. The night ends after three turns each. The winner is the richest seat, lowest id on a tie. `MatchTable` and `TurnPrompt` only display that snapshot and send input. They do not decide results. The decorative table in the menu, wide shot, board view, and game-master scenes is unchanged.

## Trials

`MinigameBase` owns a simulated clock. `tick(delta)` accumulates time and finishes at `planned_ms()` (30–90 seconds). `TrialCatalog` lists `ContractTrial` plus ten `TrialCard` resources. Each card points at a scene, a `TrialBody` script, and a duration. The body builds a field (race, dodge, puzzle, waves, or absurd), asks that trial's bot for every seat, and ranks the scores. The ranking is built inside the trial. The field does not read render settings, so turning effects off does not change it.

`TrialView` is the diorama. The camera starts above the felt and lands within a few frames. That fall is presentation only. The probe still instantiates each catalog script with `Script.new()`, plays it with bots, and refuses a one-tick finish or an invalid ranking. It does not special-case `ContractTrial`. The hot-seat board does not enter these trials yet. Phase 5 is where a round would sync one.

## Rendering

`PixelStage` draws the room in a 640×360 `SubViewport` and scales it with nearest filtering. `ps1_spatial.gdshader` does optional vertex snapping and a light affine UV mix. `post_process.gdshader` adds optional grain, dither, vignette, and chromatic aberration. `RenderProfile` turns those uniforms off when settings say so. `Trim Lamp` calls `SaveSystem.toggle_effects()` and refreshes uniforms. It does not touch `GameState`.

Shadows and volumetric fog are off in this slice so the Compatibility renderer and a software GPU still finish a frame. Candle pools come from local omni lights against a low ambient.

## Scenes

`scenes/menu.tscn`, `table.tscn`, `board_view.tscn`, and `game_master.tscn` share `stage_scene.gd`. They differ by camera preset and whether the diegetic menu is interactive. `PlayableScenes` is the list the smoke test and visual probe share. It includes the room shots, the match, and each trial scene from `TrialCatalog`.

## Validation

`tools/validate.sh` (and `validate.ps1`) runs import, `gdformat --check`, `gdlint`, GUT, a 120-frame smoke test, the ENet session, the trial probe, then visual captures. A phase is done only when that script exits 0.
