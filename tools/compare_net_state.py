#!/usr/bin/env python3
"""Compare host and surviving client snapshots from the ENet probe."""

import json
import sys
from pathlib import Path


def canon(state: dict) -> str:
    seats = sorted(state["seats"], key=lambda seat: seat["id"])
    bots = [seat for seat in seats if seat["is_bot"]]
    if len(seats) != 3:
        print("expected 3 seats", seats)
        sys.exit(1)
    if len(bots) != 1:
        print("expected exactly one bot", seats)
        sys.exit(1)
    payload = {
        "phase": state["phase"],
        "seed": state["seed"],
        "version": state["version"],
        "seats": seats,
        "board": state.get("board", {}),
        "lobby": state.get("lobby", {}),
    }
    return json.dumps(payload, sort_keys=True)


def main() -> None:
    if len(sys.argv) != 2:
        print("usage: compare_net_state.py OUT_DIR")
        sys.exit(2)
    out = Path(sys.argv[1])
    host_path = out / "host_final.json"
    if not host_path.is_file():
        print("missing host_final.json")
        sys.exit(1)
    clients = sorted(out.glob("client_*.json"))
    if len(clients) != 1:
        print(f"expected 1 surviving client snapshot, found {len(clients)}")
        sys.exit(1)
    host = canon(json.loads(host_path.read_text(encoding="utf-8")))
    client = canon(json.loads(clients[0].read_text(encoding="utf-8")))
    if host != client:
        print("STATE MISMATCH")
        print(host)
        print(client)
        sys.exit(1)
    print("ENET_PASS")


if __name__ == "__main__":
    main()
