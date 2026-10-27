# Welcome to the Board

A dark, low-poly party game. Two to four players sit at a cursed board in a candlelit room. A hidden-faced host comments, cheats, and keeps the night moving. The tone is light black comedy: defeats are funny, never gory.

Inscryption is an atmosphere reference only. No names, characters, cards, or assets are taken from it.

## Pillars

- The board is alive. It flickers, lies, and changes the room.
- Play is a party: dice, pawns, spaces, strange shops, and short trials.
- The interface lives on the table. Scores, choices, and rules are objects, not a HUD.
- The host is authoritative. Clients send input. They do not decide results.
- Every trial can be played by a bot, so a dropped player does not stop the night.

## Match shape (later phases)

1. Sit down at the table and form a party of 2–4 (hot-seat now, online later).
2. Take turns moving pawns on the board. Spaces pay, punish, swap, trap, or open a shop.
3. Each round, everyone enters a 30–90 second trial. Rank pays tokens.
4. The last survivor, or the richest seat when the board says so, wins.

The hot-seat night is playable. After each roll or shop, the whole table falls into one of the ten trials. Bots play it, the ranking pays tokens, and the night returns to the board.

## What you can do in this slice

- Sit at the main menu, which is the near side of the table.
- Choose **Sit Down** (starts the hot-seat night), **Trim Lamp** (post and PS1 effects on or off), or **Leave**.
- Look around with keys 1–4 or the gamepad shoulders / face buttons: table, board, game master, window.
- See the hooded game master placeholder. The role has no borrowed name.
- Sit down into a hot-seat night: pick 2–4 seats and how many are human. The rest are bots. Roll, buy from the shop, draw event cards, fall into a trial, and see who the night keeps.
- Open a scene under `src/minigames/<world>/` to play that trial. The camera falls onto the felt, then bots run the 30–90 second diorama.

## Out of scope until later phases

Steam, voice, and the release build. GodotSteam is still a stub.
