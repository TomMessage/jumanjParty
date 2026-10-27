#!/usr/bin/env bash
# Release export for Linux and Windows. Not part of the headless gate.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

GODOT="${GODOT:-godot}"
TEMPLATES="${GODOT_TEMPLATES:-$HOME/.local/share/godot/export_templates/4.7.2.stable}"

if ! command -v "$GODOT" >/dev/null 2>&1; then
	echo "godot is not on PATH." >&2
	exit 1
fi
if [[ ! -f "$TEMPLATES/version.txt" ]]; then
	echo "Export templates missing at $TEMPLATES" >&2
	echo "Install Godot 4.7.2 stable templates. Do not invent a version." >&2
	exit 1
fi

mkdir -p "$ROOT/build/export/linux" "$ROOT/build/export/windows"
"$GODOT" --headless --path "$ROOT" --export-release "Linux" \
	"$ROOT/build/export/linux/WelcomeToTheBoard.x86_64"
"$GODOT" --headless --path "$ROOT" --export-release "Windows Desktop" \
	"$ROOT/build/export/windows/WelcomeToTheBoard.exe"

test -s "$ROOT/build/export/linux/WelcomeToTheBoard.x86_64"
test -s "$ROOT/build/export/windows/WelcomeToTheBoard.exe"
echo "EXPORT_LINUX $ROOT/build/export/linux/WelcomeToTheBoard.x86_64"
echo "EXPORT_WINDOWS $ROOT/build/export/windows/WelcomeToTheBoard.exe"
