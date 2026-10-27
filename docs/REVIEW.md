# Review

Final pass against `docs/ARCHITECTURE.md`, `.cursor/rules/project.mdc`, `docs/ASSETS.md`, and `docs/ADDONS.md`.

**Result: PASS**, with two open items that are already written in `docs/BLOCKERS.md` and are not code defects: the live Steam session, and the 60 FPS reading on a real GPU.

## What was checked

- GDScript stays typed. `gdlint` and `gdformat --check` are part of `tools/validate.sh`.
- The autoload list is still the five names in the architecture doc: EventBus, Network, GameState, SaveSystem, Audio.
- `GameState` still returns before it mutates seats, phase, or the night unless `Network.is_host()` is true. Clients apply snapshots.
- The longest gameplay scripts are under the 300-line guide (`src/core/game_state.gd`, `src/board/match_table.gd`).
- Effects can be turned off. The frame probe keeps the same draw counts with the lamp off, and the existing tests still require a repeated seed to match.
- No test was removed or skipped to clear the gate.
- `docs/ASSETS.md` covers the procedural meshes, the shaders, the runtime audio, the built-in font, and `icon.svg`. A scan found no imported models, textures, audio files, or fonts. GUT remains MIT and is excluded from the export pack.
- No Inscryption asset, character, or copied line. The name is used only as an atmosphere warning in the docs.
- No Steam app id was added. `480` is not in the repo.

## Not rewritten

The review did not need a gameplay change. The frame-rate gap is a missing hardware measurement, documented with the llvmpipe numbers, not a scene that has to be flattened to satisfy a software rasterizer.
