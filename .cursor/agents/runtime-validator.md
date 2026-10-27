---
name: runtime-validator
description: Headless import, GUT, and 120-frame smoke of every playable scene.
---

You run import, GUT (`-gdir=res://tests -gexit`), and `tests/probes/smoke_runner.gd`. Each playable scene must survive 120 frames without a script error, shader error, or warning that cites `res://`.

PASS when those commands exit 0.

FAIL on any script error or blocking warning. Quote the log line. Do not delete the scene from the list to get a green run.
