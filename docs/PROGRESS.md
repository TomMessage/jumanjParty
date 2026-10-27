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

Ten real-time dioramas, two per world (jungle, desert, haunted, space, volcano): vine rush and lava hurdles (race), sting lanes and candle dodge (reflex), sundial lock and star dial (puzzle), beetle rain and portrait waves (survival), gravy orbit and marshmallow crown (absurd). Each has a scene, card, bot, and test, runs 30–90 seconds, and opens with a fall onto the felt.
The host runs one of those trials after every roll or shop. Every seat is in the ranking, including bots. Places pay 3, then 2, then 1 token, and the night returns to the board. The curtain on the table plays the fall; it does not choose the result.
Tests: one finish test per trial, a bot-versus-reckless check for each genre, a repeated seed, the fall, catalog coverage, the probe over every catalog script, plus a night that queues, plays, pays, and round-trips the ranking.
Risk: the ENet probe still compares a short session, not this night. A diorama whose floor and sky stop contrasting can fail the image guard.
Next: Phase 5, online play. Do not start it in this branch.

## Phase 5 — Multiplayer

The host keeps a lobby of joined seats, ready names, and the start of a night. Clients send rolls and shop choices over ENet. The host still resolves dice, trials, rankings, and tokens, then broadcasts the board. A dropped seat becomes a bot and finishes its turns.
Tests: a guest cannot start the lobby or roll someone else's seat; a two-seat night survives a disconnect and round-trips; the 3-instance probe plays one turn each, replaces one client with a bot, and matches the final board.
Risk: the probe is one short night on localhost, not a long match or a Steam lobby. A client that never sends its roll leaves the host waiting.
Next: Phase 6, Steam. Do not start it in this branch.

## Phase 6 — Steam

`SteamNetwork` talks to GodotSteam when the singleton and `SteamMultiplayerPeer` are present: a friends-only lobby, invites, the overlay invite dialog, and a host-relayed sockets peer. After results the host can request `FIRST_NIGHT`, `TRIAL_CROWN`, `TABLE_SURVIVOR`, and `FULL_TABLE`, and rich presence can publish the phase. None of that is stored or published unless Steam returns success.
Tests: an unready runtime refuses host, join, invite, and relay; asking for Steam falls back to ENet or local and a bot night still ranks a trial; deeds stay pending; presence stays unpublished. The three-instance ENet probe is unchanged.
Risk: this environment has no GodotSteam binary, Steamworks SDK, app id, or logged-in client, so `steamInitEx` is never called. See `docs/BLOCKERS.md`. A green gate here is the fallback, not a live lobby.
Next: Phase 7, the game master. Do not start it in this branch.

## Phase 7 — Game master

The keeper speaks from the snapshot: a wake line, a board event, a pocket every fourth turn, a slide every fifth, and an ending line. The end parchment repeats the worst failure, and the curtain reloads that trial when one was recorded. Ambience, a two-layer drone, and a synthetic gibberish voice sit on the existing buses. Cancel on the seat parchment opens lamp intensity, ink, motion, type size, and the keeper key. Hear pages a four-line lesson. Accept still starts the night.
Tests: a pocket and a slide leave the dice stream alone; an equal failure replaces the replay; two bot nights match with the lamp at 0 and at 1; post intensity scales and still zeroes when effects are off; rebinding the keeper key keeps the joypad button.
Risk: the live Steam lobby is still blocked (`docs/BLOCKERS.md`). This branch does not pretend it is online. A cheat changes tokens, so a night is deterministic only when both sides share the host snapshot.
Next: Phase 8, release readiness. Do not start it in this branch.

## Phase 8 — Release readiness

The frame probe records FPS, draw calls, static memory, and time to first frame for the menu, the match, and Vine Rush, on Forward+ and Compatibility, and it checks that each trial's simulated length stays inside 30–90 seconds. Official Godot 4.7.2 templates export an embedded Linux binary and a Windows exe. Store copy, a demo plan, and a trailer shot list are in `docs/STEAM_RELEASE.md`. No Steam app id is assigned.
Tests: `tools/validate.sh` runs the new probe with the rest of the gate. The Linux build booted headless and stayed up. The Windows file is a PE32+ image and was not executed here.
Risk: llvmpipe does not hold 60 FPS on the candlelit table, and there is no discrete GPU or Steam Deck in this environment, so that target is not claimed. The live Steam lobby is still blocked. Both are in `docs/BLOCKERS.md`.
This is the last planned phase. Do not merge it to main from this branch.
