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

## Phase 3 — Hot-seat board

Playable 16-space loop on the same candlelit table: dice, pawns, gain/loss/trap/swap/shop/event spaces, three items, six event cards, bots, and a diegetic end of night. The host resolves every result. Sit Down opens the match; the earlier beauty shots stay decorative.
Tests: catalog coverage, seeded bot nights, human turns, shop buys, shield, swap, cards, snapshot round-trip, and a disconnect that lets the bot finish.
Risk: the ENet probe still compares a short session, not this full night. A long hot-seat with every seat skipping can end before a human rolls again, which is intended.
Next: Phase 4, the trials. Do not start it in this branch.

## Phase 4 — Trials

Ten real-time dioramas, two per world (jungle, desert, haunted, space, volcano): vine rush and lava hurdles (race), sting lanes and candle dodge (reflex), sundial lock and star dial (puzzle), beetle rain and portrait waves (survival), gravy orbit and marshmallow crown (absurd). Each has a scene, card, bot, and test, runs 30–90 seconds, and opens with a fall onto the felt. The trial builds the ranking. The hot-seat night does not enter a trial yet.
Tests: one finish test per trial, a bot-versus-reckless check for each genre, a repeated seed, the fall, catalog coverage, and the probe over every catalog script.
Risk: these trials are not synced into the match or the ENet session. A diorama whose floor and sky stop contrasting can fail the image guard.
Next: Phase 5, online play. Do not start it in this branch.
