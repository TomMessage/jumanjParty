class_name DodgeField
extends TrialField

var _lane: Dictionary = {}
var _hazards: Array[Vector2] = []
var _spawn := 0.0


func observe(seat_id: int) -> Dictionary:
	var threat := _nearest()
	return {
		"kind": "dodge",
		"lane": int(_lane.get(seat_id, 0)),
		"threat": int(threat.x),
		"threat_z": threat.y,
	}


func apply(seat_id: int, action: Dictionary) -> void:
	_lane[seat_id] = posmod(int(action.get("lane", 0)), 3)


func step(delta: float) -> void:
	_spawn += delta * _pressure()
	if _spawn >= 1.35:
		_spawn = 0.0
		var lane := _rng.randi_range(0, 2)
		_hazards.append(Vector2(float(lane), 7.5))
	var kept: Array[Vector2] = []
	for hazard: Vector2 in _hazards:
		var nxt := Vector2(hazard.x, hazard.y - delta * 3.4 * _pace())
		if nxt.y <= 0.15:
			_resolve(int(nxt.x))
		else:
			kept.append(nxt)
	_hazards = kept


func visual() -> Dictionary:
	var pawns: Array = []
	var marks: Array = []
	var slot := 0
	for seat_id: int in _players:
		var lane := int(_lane.get(seat_id, 0))
		pawns.append(Vector3(_lane_x(lane), 0.25, 1.6 + float(slot) * 0.15))
		slot += 1
	for hazard: Vector2 in _hazards:
		marks.append(Vector3(_lane_x(int(hazard.x)), 0.3, hazard.y - 4.0))
	return {"pawns": pawns, "hazards": marks}


func _on_setup() -> void:
	for seat_id: int in _players:
		_lane[seat_id] = 0
	_hazards.append(Vector2(0.0, 4.2))
	_hazards.append(Vector2(0.0, 6.4))


func _resolve(lane: int) -> void:
	for seat_id: int in _players:
		if int(_lane.get(seat_id, 0)) == lane:
			_gain(seat_id, -4)
		else:
			_gain(seat_id, 3)


func _nearest() -> Vector2:
	var best := Vector2(0, 99)
	for hazard: Vector2 in _hazards:
		if hazard.y < best.y:
			best = hazard
	return best


func _lane_x(lane: int) -> float:
	return -1.4 + float(lane) * 1.4
