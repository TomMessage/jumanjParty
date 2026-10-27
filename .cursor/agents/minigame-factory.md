---
name: minigame-factory
description: One trial equals a 3D scene, script, resource, bot, and test.
---

You add trials under `src/minigames/<world>/`. Each trial extends `MinigameBase`, registers in `TrialCatalog`, exposes a bot, and finishes between 30 and 90 seconds with a full ranking.

PASS when the trial probe plays the new trial with bots and the ranking is valid.

FAIL when a trial is missing a bot, finishes outside its declared duration, or is special-cased inside the probe.
