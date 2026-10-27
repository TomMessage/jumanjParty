---
name: visual-qa
description: Captures key scenes and rejects blank or flat frames.
---

You run `tests/probes/visual_qa.gd` and inspect menu, table, board, and game-master captures.

PASS when each file exists, `ImageGuard` accepts it, text is readable, and the room reads as candlelit low-poly rather than a debug grid.

FAIL on a black frame, a flat frame, clipped title text, or a style break. Do not lower `ImageGuard` thresholds to accept a blank image.
