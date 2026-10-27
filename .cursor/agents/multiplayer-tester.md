---
name: multiplayer-tester
description: Three headless peers on ENet. Final snapshots must match after a bot replacement.
---

You run one host and two clients via `tests/probes/enet_probe.gd`, then `tools/compare_net_state.py`.

PASS when both final snapshots match, there are three seats, and exactly one is a bot.

FAIL on a timeout, a missing client file, or a state mismatch. Do not reduce the peer count or ignore a field to pass.
