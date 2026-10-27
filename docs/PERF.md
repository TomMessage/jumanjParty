# Performance

Sampled by `tests/probes/perf_audit.gd` on this machine. Window 1280×720, vsync off, 20 warmup frames, then 90 frames. The 3D view inside that window is still 640×360. The adapter for both renderers was `llvmpipe (LLVM 20.1.2, 256 bits)`. That is a software rasterizer, not a modest GPU and not a Steam Deck.

The table is the sample from the `tools/validate.sh` run on this machine, not a hardware certification. A repeat can move by a frame or two. Vine Rush on Forward+ sat just under 60 in that run and just over 60 in the run before it, so it is not a stable 60 FPS result either.

## Frames

| Scene | Renderer | Effects | FPS | Frame | Draws | Static memory | First frame |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Menu | Forward+ | on | 28.9 | 34.64 ms | 79 | 57.2 MB | 468 ms |
| Match | Forward+ | on | 27.8 | 35.98 ms | 54 | 57.8 MB | 78 ms |
| Vine Rush | Forward+ | on | 59.8 | 16.73 ms | 21 | 56.4 MB | 21 ms |
| Menu | Forward+ | off | 29.7 | 33.71 ms | 79 | 58.2 MB | 51 ms |
| Menu | Compatibility | on | 50.1 | 19.97 ms | 79 | 44.4 MB | 132 ms |
| Match | Compatibility | on | 49.4 | 20.25 ms | 54 | 45.1 MB | 31 ms |
| Vine Rush | Compatibility | on | 176.0 | 5.68 ms | 21 | 44.0 MB | 12 ms |
| Menu | Compatibility | off | 56.8 | 17.61 ms | 79 | 45.2 MB | 24 ms |

Draw counts do not change when the lamp is trimmed. The post pass is not what keeps the table under 60 FPS here. The open point is the missing hardware run, recorded in `docs/BLOCKERS.md`.

## Trial length

Each catalog trial was played with three bots at seed 11. Duration is simulated time, the same clock the night uses. All ten landed inside 30–90 seconds.

| Trial | Seconds | Ticks of 0.1 s |
| --- | ---: | ---: |
| Vine Rush | 36 | 360 |
| Beetle Rain | 48 | 480 |
| Sting Lanes | 32 | 320 |
| Sundial Lock | 40 | 400 |
| Candle Dodge | 44 | 440 |
| Portrait Waves | 58 | 580 |
| Star Dial | 52 | 520 |
| Gravy Orbit | 64 | 640 |
| Lava Hurdles | 42 | 420 |
| Marshmallow Crown | 72 | 720 |
