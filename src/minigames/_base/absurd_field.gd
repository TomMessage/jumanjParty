class_name AbsurdField
extends TrialField

var _lean: Dictionary = {}
var _tilt := 0.0
var _time := 0.0


func observe(_seat_id: int) -> Dictionary:
	return {"kind": "absurd", "tilt": _tilt}


func apply(seat_id: int, action: Dictionary) -> void:
	_lean[seat_id] = clampf(float(action.get("lean", 0.0)), -1.0, 1.0)


func step(delta: float) -> void:
	_time += delta
	var wobble := sin(_time * 2.4 * _pressure()) * 0.75
	var kick := sin(_time * 0.6 + float(_card.salt)) * 0.25
	_tilt = wobble + kick
	for seat_id: int in _players:
		var error := absf(_tilt + float(_lean.get(seat_id, 0.0)))
		if error <= 0.9:
			_gain(seat_id, 1)


func visual() -> Dictionary:
	var pawns: Array = []
	var marks: Array = []
	var slot := 0
	for seat_id: int in _players:
		var lean := float(_lean.get(seat_id, 0.0))
		pawns.append(Vector3(lean * 1.6, 0.25, 1.4 + float(slot) * 0.2))
		slot += 1
	marks.append(Vector3(_tilt * 1.8, 0.85, -0.2))
	return {"pawns": pawns, "hazards": marks}


func _on_setup() -> void:
	for seat_id: int in _players:
		_lean[seat_id] = 0.0
