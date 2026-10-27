#!/usr/bin/env bash
# Gate for Welcome to the Board. Stops at the first failure.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

GODOT="${GODOT:-godot}"

if ! command -v "$GODOT" >/dev/null 2>&1; then
	echo "godot is not on PATH. Install Godot 4.7.x and retry." >&2
	exit 1
fi
if ! command -v gdformat >/dev/null 2>&1 || ! command -v gdlint >/dev/null 2>&1; then
	echo "gdformat/gdlint missing. Install with: pip install gdtoolkit==4.5.0" >&2
	exit 1
fi

visual_with() {
	local method="$1"
	local dest="$2"
	local extra=()
	if [[ "$method" == "forward" ]]; then
		export VK_ICD_FILENAMES="${VK_ICD_FILENAMES:-/usr/share/vulkan/icd.d/lvp_icd.json}"
		extra=(--rendering-driver vulkan --rendering-method forward_plus)
	else
		export LIBGL_ALWAYS_SOFTWARE=1
		extra=(--rendering-driver opengl3 --rendering-method gl_compatibility)
	fi
	timeout 240 "$GODOT" "${extra[@]}" --display-driver x11 --path "$ROOT" \
		--resolution 1280x720 --audio-driver Dummy \
		-s res://tests/probes/visual_qa.gd -- --out="$dest"
}

run_visual() {
	local dest="$1"
	mkdir -p "$dest"
	if visual_with forward "$dest"; then
		echo "visual renderer: forward_plus" | tee "$dest/renderer.txt"
		return 0
	fi
	echo "forward_plus capture failed; retrying the Compatibility renderer" >&2
	if visual_with compatibility "$dest"; then
		echo "visual renderer: gl_compatibility" | tee "$dest/renderer.txt"
		return 0
	fi
	return 1
}

echo "== import =="
"$GODOT" --headless --path "$ROOT" --import

echo "== format =="
gdformat --check src tests

echo "== lint =="
gdlint src tests

echo "== gut =="
"$GODOT" --headless --path "$ROOT" -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit

echo "== smoke =="
"$GODOT" --headless --path "$ROOT" -s res://tests/probes/smoke_runner.gd

echo "== multiplayer =="
OUT="$(mktemp -d)"
PORT="${ENET_PORT:-$((20000 + RANDOM % 20000))}"
"$GODOT" --headless --path "$ROOT" -s res://tests/probes/enet_probe.gd -- \
	--role=host --port="$PORT" --out="$OUT" &
HOST_PID=$!
ready=0
for _ in $(seq 1 100); do
	if [[ -f "$OUT/host_ready" ]]; then
		ready=1
		break
	fi
	if ! kill -0 "$HOST_PID" 2>/dev/null; then
		break
	fi
	sleep 0.1
done
if [[ "$ready" -ne 1 ]]; then
	echo "host did not become ready" >&2
	wait "$HOST_PID" || true
	exit 1
fi
"$GODOT" --headless --path "$ROOT" -s res://tests/probes/enet_probe.gd -- \
	--role=client --port="$PORT" --out="$OUT" &
CLIENT_A=$!
"$GODOT" --headless --path "$ROOT" -s res://tests/probes/enet_probe.gd -- \
	--role=client --port="$PORT" --out="$OUT" &
CLIENT_B=$!
wait "$HOST_PID"
wait "$CLIENT_A"
wait "$CLIENT_B"
python3 "$ROOT/tools/compare_net_state.py" "$OUT"

echo "== trials =="
"$GODOT" --headless --path "$ROOT" -s res://tests/probes/trial_probe.gd

perf_with() {
	local method="$1"
	local dest="$2"
	local extra=()
	if [[ "$method" == "forward" ]]; then
		export VK_ICD_FILENAMES="${VK_ICD_FILENAMES:-/usr/share/vulkan/icd.d/lvp_icd.json}"
		extra=(--rendering-driver vulkan --rendering-method forward_plus)
	else
		export LIBGL_ALWAYS_SOFTWARE=1
		extra=(--rendering-driver opengl3 --rendering-method gl_compatibility)
	fi
	timeout 240 "$GODOT" "${extra[@]}" --display-driver x11 --path "$ROOT" \
		--resolution 1280x720 --audio-driver Dummy \
		-s res://tests/probes/perf_audit.gd -- --out="$dest/report-${method}.txt"
}

echo "== perf =="
PERF_OUT="${PERF_DIR:-$ROOT/build/perf}"
mkdir -p "$PERF_OUT"
perf_with forward "$PERF_OUT"
perf_with compatibility "$PERF_OUT"

echo "== visual =="
VISUAL_OUT="${VISUAL_QA_DIR:-$ROOT/build/visual-qa}"
run_visual "$VISUAL_OUT"

echo "VALIDATE_PASS"
