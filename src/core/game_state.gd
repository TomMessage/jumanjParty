extends Node

enum Phase { MENU, TABLE, BOARD, TRIAL, RESULTS }

var _phase: int = Phase.MENU
var _seed: int = 0
var _version: int = 0
var _seats: Array[PlayerSeat] = []


func reset_local_mirror() -> void:
	_phase = Phase.MENU
	_seed = 0
	_version = 0
	_seats.clear()


func configure_local_match(names: PackedStringArray, seed_value: int) -> bool:
	if not Network.is_host():
		return false
	_seats.clear()
	var next_id := 1
	for seat_name: String in names:
		var seat := PlayerSeat.new()
		seat.id = next_id
		seat.display_name = seat_name
		seat.is_bot = false
		seat.tokens = 0
		_seats.append(seat)
		next_id += 1
	_seed = seed_value
	_phase = Phase.TABLE
	_version += 1
	EventBus.phase_changed.emit(_phase)
	Network.broadcast_state(to_snapshot())
	return true


func set_phase(next_phase: int) -> bool:
	if not Network.is_host():
		return false
	_phase = next_phase
	_version += 1
	EventBus.phase_changed.emit(_phase)
	Network.broadcast_state(to_snapshot())
	return true


func ensure_seat(seat_id: int, seat_name: String) -> void:
	if not Network.is_host():
		return
	if find_seat(seat_id) != null:
		return
	var seat := PlayerSeat.new()
	seat.id = seat_id
	seat.display_name = seat_name
	seat.is_bot = false
	seat.tokens = 0
	_seats.append(seat)
	_version += 1
	Network.broadcast_state(to_snapshot())


func replace_with_bot(seat_id: int) -> void:
	if not Network.is_host():
		return
	var seat := find_seat(seat_id)
	if seat == null or seat.is_bot:
		return
	seat.is_bot = true
	_version += 1
	EventBus.seat_replaced_by_bot.emit(seat_id)
	Network.broadcast_state(to_snapshot())


func handle_input(peer_id: int, action: Dictionary) -> void:
	if not Network.is_host():
		return
	if str(action.get("kind", "")) != "grant_token":
		return
	var seat := find_seat(int(action.get("seat", peer_id)))
	if seat == null:
		return
	var amount := int(action.get("amount", 0))
	if amount == 0:
		return
	seat.tokens += amount
	_version += 1
	Network.broadcast_state(to_snapshot())


func apply_snapshot(snapshot: Dictionary) -> void:
	var next_phase := int(snapshot.get("phase", _phase))
	var phase_differs := next_phase != _phase
	_phase = next_phase
	_seed = int(snapshot.get("seed", _seed))
	_version = int(snapshot.get("version", _version))
	_seats.clear()
	var raw_seats: Array = snapshot.get("seats", [])
	for raw: Variant in raw_seats:
		if raw is Dictionary:
			_seats.append(PlayerSeat.from_dict(raw))
	if phase_differs:
		EventBus.phase_changed.emit(_phase)
	EventBus.snapshot_applied.emit(_version)


func to_snapshot() -> Dictionary:
	var seats: Array[Dictionary] = []
	for seat: PlayerSeat in _seats:
		seats.append(seat.to_dict())
	return {
		"phase": _phase,
		"seed": _seed,
		"version": _version,
		"seats": seats,
	}


func find_seat(seat_id: int) -> PlayerSeat:
	for seat: PlayerSeat in _seats:
		if seat.id == seat_id:
			return seat
	return null


func get_phase() -> int:
	return _phase


func get_seed() -> int:
	return _seed


func get_version() -> int:
	return _version


func get_seat_count() -> int:
	return _seats.size()
