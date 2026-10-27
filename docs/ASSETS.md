# Assets

No third-party models, textures, audio, or fonts are imported. Everything in the slice is built in engine.

| Asset | Source | License |
| --- | --- | --- |
| Room, table, board, pawns, candles, game master | Procedural meshes in `src/render/room_set.gd` and `src/gamemaster/keeper_placeholder.gd` | Original, project code |
| Trial dioramas | Procedural meshes in `src/minigames` | Original, project code |
| PS1 and post shaders | `src/render/*.gdshader` | Original, project code |
| Menu and plaque text | Godot default `Label3D` font (engine built-in) | Godot Engine, MIT |
| Window icon | `icon.svg` | Original, project code |
| Ambience, drone, keeper voice | Runtime samples in `src/core/tone_loop.gd` and `src/core/gibberish_voice.gd` | Original, project code |

A file scan of the repo, skipping `.godot/`, `build/`, and `addons/gut/`, found no imported models, textures, audio files, or fonts. `assets/` is an empty placeholder. Editor font caches under `.godot/editor/` are not game content and are not a shipping dependency. GUT is the only vendored addon; its MIT license is `addons/gut/LICENSE.md`, and the export presets leave it out of the pack.

Do not add a pack without a row here for its name, URL, and license. Nothing from Inscryption or other commercial games.
