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
