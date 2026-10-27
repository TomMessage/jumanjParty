class_name WaveField
extends TrialField

var _aim: Dictionary = {}
var _bugs: Array[Vector2] = []
var _clock := 0.0


func observe(seat_id: int) -> Dictionary:
	return {"kind": "waves", "aim": _closest_x(), "seat": seat_id}


func apply(seat_id: int, action: Dictionary) -> void:
	_aim[seat_id] = clampf(float(action.get("aim", 0.0)), -3.5, 3.5)


func step(delta: float) -> void:
	_clock += delta * _pressure()
	if _clock >= 1.6:
		_clock = 0.0
		var side := _rng.randf_range(-3.0, 3.0)
		_bugs.append(Vector2(side, 7.0))
	var kept: Array[Vector2] = []
	for bug: Vector2 in _bugs:
		var nxt := Vector2(bug.x, bug.y - delta * 2.2 * _pace())
		if nxt.y <= 0.4:
			_swat(nxt.x)
		else:
			kept.append(nxt)
	_bugs = kept


func visual() -> Dictionary:
	var pawns: Array = []
	var marks: Array = []
	var slot := 0
	for seat_id: int in _players:
		var aim := float(_aim.get(seat_id, 0.0))
		pawns.append(Vector3(aim, 0.25, 1.8 - float(slot) * 0.12))
		slot += 1
	for bug: Vector2 in _bugs:
		marks.append(Vector3(bug.x, 0.3, bug.y - 3.5))
	return {"pawns": pawns, "hazards": marks}


func _on_setup() -> void:
	for seat_id: int in _players:
		_aim[seat_id] = 0.0
	_bugs.append(Vector2(0.2, 3.5))
	_bugs.append(Vector2(-1.4, 5.5))


func _closest_x() -> float:
	var best := 0.0
	var nearest := 99.0
	for bug: Vector2 in _bugs:
		if bug.y < nearest:
			nearest = bug.y
			best = bug.x
	return best


func _swat(x: float) -> void:
	for seat_id: int in _players:
		var aim := float(_aim.get(seat_id, 0.0))
		if absf(aim - x) <= 0.7:
			_gain(seat_id, 4)
