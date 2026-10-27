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

## Trials

`MinigameBase` owns a simulated clock. `tick(delta)` accumulates time and finishes at `planned_ms()` (30–90 seconds). `ContractTrial` is the harness fixture registered in `TrialCatalog`: bots score seats, and the result is a total ranking. Phase 4 adds real scenes to the catalog. The probe does not special-case the fixture. It refuses a trial that finishes in one tick or emits an invalid ranking.

## Rendering

`PixelStage` draws the room in a 640×360 `SubViewport` and scales it with nearest filtering. `ps1_spatial.gdshader` does optional vertex snapping and a light affine UV mix. `post_process.gdshader` adds optional grain, dither, vignette, and chromatic aberration. `RenderProfile` turns those uniforms off when settings say so. `Trim Lamp` calls `SaveSystem.toggle_effects()` and refreshes uniforms. It does not touch `GameState`.

Shadows and volumetric fog are off in this slice so the Compatibility renderer and a software GPU still finish a frame. Candle pools come from local omni lights against a low ambient.

## Scenes

`scenes/menu.tscn`, `table.tscn`, `board_view.tscn`, and `game_master.tscn` share `stage_scene.gd`. They differ by camera preset and whether the diegetic menu is interactive. `PlayableScenes` is the list the smoke test and visual probe share.

## Validation

`tools/validate.sh` (and `validate.ps1`) runs import, `gdformat --check`, `gdlint`, GUT, a 120-frame smoke test, the ENet session, the trial probe, then visual captures. A phase is done only when that script exits 0.
