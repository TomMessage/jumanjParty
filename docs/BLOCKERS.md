# Blockers

## Phase 6 — Steam session

Live Steam lobbies, invites, the relay, achievement storage, and rich presence were not run. `SteamRuntime.ensure()` stops before `steamInitEx` because `SteamRuntime.diagnose()` reports:

> GodotSteam is not loaded (no Steam singleton); SteamMultiplayerPeer is absent, so the relay cannot open; no Steam app id in STEAM_APP_ID or res://steam_appid.txt.

Checked on this machine:

- `Engine.has_singleton("Steam")` is false and `ClassDB` has no `SteamMultiplayerPeer`. The GodotSteam GDExtension is not in `addons/`.
- No `libsteam_api.so` and no `steam` client binary were found under `/usr`, `/opt`, or `/home`.
- `STEAM_APP_ID` is unset and `res://steam_appid.txt` does not exist, so there is no app id and no logged-on Steam user to ask.

`SteamNetwork.start_host` and `start_client` return `ERR_UNAVAILABLE`. They do not report a lobby id or an open relay. Invites return `ERR_UNAVAILABLE`. Achievements stay in the local pending list and `stored_count` stays 0. Rich presence keeps the status string locally and `published` stays false. `Network.open_transport("steam", port)` uses ENet when `port` is positive and `LocalNetwork` otherwise. Hot-seat and the three-instance ENet probe still match.

Do not mark this done by stubbing `steamInitEx` or by treating the fallback as a Steam lobby. When a real GodotSteam build, Steamworks redistributable, app id, and logged-on client are present, replace the unavailable assertions with a live lobby test.

## Phase 8 — 60 FPS was not shown on hardware

The candlelit table did not hold 60 FPS on this machine, and this machine is not a modest GPU or a Steam Deck. `RenderingServer.get_video_adapter_name()` is `llvmpipe (LLVM 20.1.2, 256 bits)` for both Forward+ (Vulkan, software) and Compatibility (Mesa llvmpipe). At 1280×720 with vsync off, the menu sat at 28.9 FPS on Forward+ and 50.1 FPS on Compatibility in the `tools/validate.sh` sample. Draw calls stayed at 79 for the menu, 54 for the match, and 21 for Vine Rush. Turning effects off left the draw count unchanged and did not make the table a 60 FPS scene. Static memory stayed under 60 MB. The numbers are in `docs/PERF.md`.

Do not write a store claim that the game holds 60 FPS on Steam Deck or on a modest GPU. That run has not happened. The miss is the software rasterizer and the missing hardware, not a trial over 90 seconds: every catalog trial finished between 32 and 72 simulated seconds.
