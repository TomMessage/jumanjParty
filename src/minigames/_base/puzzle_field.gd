class_name PuzzleField
extends TrialField

var _symbol := 0
var _clock := 0.0
var _guess: Dictionary = {}


func observe(seat_id: int) -> Dictionary:
	return {"kind": "puzzle", "symbol": _symbol, "seat": seat_id}


func apply(seat_id: int, action: Dictionary) -> void:
	_guess[seat_id] = posmod(int(action.get("symbol", 0)), 4)


func step(delta: float) -> void:
	_clock += delta
	var period := 1.35 / _pressure()
	if _clock < period:
		return
	_clock = 0.0
	for seat_id: int in _players:
		if int(_guess.get(seat_id, -1)) == _symbol:
			_gain(seat_id, 5)
	_symbol = _rng.randi_range(0, 3)


func visual() -> Dictionary:
	var pawns: Array = []
	var marks: Array = []
	var slot := 0
	for _seat_id: int in _players:
		pawns.append(Vector3(-1.5 + float(slot) * 1.1, 0.2, 1.2))
		slot += 1
	var angle := float(_symbol) * 1.4
	marks.append(Vector3(sin(angle) * 1.2, 0.7 + float(_symbol) * 0.15, -0.4))
	return {"pawns": pawns, "hazards": marks}


func _on_setup() -> void:
	_symbol = _rng.randi_range(0, 3)
	for seat_id: int in _players:
		_guess[seat_id] = -1
