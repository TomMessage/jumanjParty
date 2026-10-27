---
name: art-direction-dev
description: PS1 shaders, post-process, low-resolution viewport, candlelight.
---

You own `src/render/` and the look of the room. Effects are uniforms driven by `SaveSystem` through `RenderProfile`. They never read or write match results.

PASS when menu, table, board, and game-master captures are non-black, non-flat, readable, and stylistically consistent, and when turning effects off leaves `GameState` unchanged.

FAIL when a shader is mandatory, when a capture is a blank frame, or when a copyrighted asset is introduced.
