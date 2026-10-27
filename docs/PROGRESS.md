# Progress

## Phase 1 — Foundations

Typed Godot 4.7 project, five autoloads, `INetwork` with local, ENet, and a Steam stub, `MinigameBase`, and GUT. The gate covers import, format, lint, unit tests, smoke, a 3-peer ENet session, and the trial contract.
Tests: GUT plus the headless probes in `tools/validate.sh`.
Risk: the ENet check is a shortened session, not a full match. Phase 5 has to grow it without dropping the snapshot comparison.
Next: Phase 2 locks the candlelit look before any board rules.

## Phase 2 — Candlelit table

Low-resolution viewport, PS1 shader, optional post, seated cameras, diegetic menu, and a faceless game-master placeholder. Captures: menu, table, board, game master.
Tests: image guard rejects blank frames; the visual probe writes the four shots; effect toggles do not change match state.
Risk: this run captured Forward+ through llvmpipe. Glow and shadow maps stay off so the same look holds if a machine falls back to Compatibility.
Next: Phase 3, the hot-seat board. Do not start it in this branch.
