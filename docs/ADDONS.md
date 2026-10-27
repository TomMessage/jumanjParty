# Addons

| Addon | Version | License | Role |
| --- | --- | --- | --- |
| [GUT](https://github.com/bitwes/Gut) | 9.7.1 | MIT (`addons/gut/LICENSE.md`) | Unit tests. Enabled as `res://addons/gut/plugin.cfg`. |

GodotSteam (GDExtension, MIT) is the intended Steamworks binding for lobbies, invites, and `SteamMultiplayerPeer`. It is not vendored. This environment has no Steamworks SDK redistributable (`libsteam_api`), no app id, and no logged-in client, and a native extension without `libsteam_api` would fail to boot. `SteamRuntime` calls the `Steam` singleton only when that class is loaded. Until then `Network.open_transport("steam")` falls back to ENet or `LocalNetwork`. See `docs/BLOCKERS.md`.
