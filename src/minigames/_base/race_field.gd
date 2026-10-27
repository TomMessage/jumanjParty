class_name RaceField
extends TrialField

var _distance: Dictionary = {}
var _throttle: Dictionary = {}
var _gates: Array[float] = []


func observe(seat_id: int) -> Dictionary:
	return {
		"kind": "race",
		"gap": _gap(seat_id),
		"distance": float(_distance.get(seat_id, 0.0)),
	}


func apply(seat_id: int, action: Dictionary) -> void:
	_throttle[seat_id] = clampf(float(action.get("throttle", 0.5)), 0.0, 1.0)


func step(delta: float) -> void:
	for seat_id: int in _players:
		var throttle := float(_throttle.get(seat_id, 0.8))
		var speed := (1.5 + throttle * 7.0) * _pace()
		var gap := _gap(seat_id)
		if gap < 1.2 and throttle > 0.5:
			speed = -6.0
		var nxt := maxf(float(_distance.get(seat_id, 0.0)) + speed * delta, 0.0)
		_distance[seat_id] = nxt
		_scores[seat_id] = int(nxt * 10.0)


func visual() -> Dictionary:
	var pawns: Array = []
	var hazards: Array = []
	var slot := 0
	for seat_id: int in _players:
		var along := clampf(float(_distance.get(seat_id, 0.0)) * 0.12, 0.0, 8.0)
		pawns.append(Vector3(-1.2 + float(slot) * 0.8, 0.2, 2.5 - along))
		slot += 1
	for gate: float in _gates:
		hazards.append(Vector3(0.0, 0.35, 2.5 - clampf(gate * 0.12, 0.0, 8.0)))
	return {"pawns": pawns, "hazards": hazards}


func _on_setup() -> void:
	var index := 0
	while index < 7:
		var at := 6.0 + float(index) * 9.0 + _rng.randf_range(0.0, 1.5)
		_gates.append(at)
		index += 1
	for seat_id: int in _players:
		_distance[seat_id] = 0.0
		_throttle[seat_id] = 0.8


func _gap(seat_id: int) -> float:
	var pos := float(_distance.get(seat_id, 0.0))
	var nearest := 99.0
	for gate: float in _gates:
		var gap := gate - pos
		if gap > 0.0 and gap < nearest:
			nearest = gap
	return nearest
