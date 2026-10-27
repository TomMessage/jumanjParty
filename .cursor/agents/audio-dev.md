---
name: audio-dev
description: Buses, ambience, layered music, synthetic game-master voice.
---

You own `src/core/audio_director.gd` and future streams. Listen to `EventBus`. Do not change seats, phase, or scores except by reading them.

PASS when Ambience, Music, Sfx, and Voice buses exist and a phase change can duck music without touching gameplay data.

FAIL when audio code writes `GameState` or when a missing device crashes a headless run.
