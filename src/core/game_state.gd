extends Node

enum Phase { MENU, TABLE, BOARD, TRIAL, RESULTS }

var _phase: int = Phase.MENU
var _seed: int = 0
var _version: int = 0
var _seats: Array[PlayerSeat] = []
var _rules: MatchRules = MatchRules.new()
var _lobby: LobbyTable = LobbyTable.new()


func reset_local_mirror() -> void:
	_phase = Phase.MENU
	_seed = 0
	_version = 0
	_seats.clear()
	_rules = MatchRules.new()
	_lobby = LobbyTable.new()


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
	_rules = MatchRules.new()
	_lobby.reset()
	_publish(true)
	return true


func set_phase(next_phase: int) -> bool:
	if not Network.is_host():
		return false
	_phase = next_phase
	_publish(true)
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
	_publish(false)


func replace_with_bot(seat_id: int) -> void:
	if not Network.is_host():
		return
	var seat := find_seat(seat_id)
	if seat == null or seat.is_bot:
		return
	seat.is_bot = true
	_version += 1
	EventBus.notify_seat_replaced(seat_id)
	Network.broadcast_state(to_snapshot())
	if not _rules.state.active:
		return
	_rules.pump(_seats)
	_publish_board()


func handle_input(peer_id: int, action: Dictionary) -> void:
	if not Network.is_host():
		return
	var kind := str(action.get("kind", ""))
	if kind == "grant_token":
		_grant_token(peer_id, action)
	if kind == "lobby_name":
		_lobby_name(peer_id, action)
	if kind == "lobby_ready":
		_lobby_ready(peer_id)
	if kind == "start_hotseat":
		_start_hotseat(peer_id, action)
	if kind == "start_match":
		_start_match(peer_id, action)
	if kind == "roll":
		_roll(peer_id, int(action.get("seat", 0)))
	if kind == "shop":
		_shop(peer_id, int(action.get("seat", 0)), str(action.get("item", "")))


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
	_rules = MatchRules.new()
	if snapshot.get("board", {}) is Dictionary:
		_rules.state = MatchState.from_dict(snapshot.get("board", {}))
	var lobby_raw: Variant = snapshot.get("lobby", {})
	if lobby_raw is Dictionary:
		_lobby = LobbyTable.from_dict(lobby_raw)
	if phase_differs:
		EventBus.notify_phase(_phase)
	EventBus.notify_snapshot(_version)


func to_snapshot() -> Dictionary:
	var seats: Array[Dictionary] = []
	for seat: PlayerSeat in _seats:
		seats.append(seat.to_dict())
	return {
		"phase": _phase,
		"seed": _seed,
		"version": _version,
		"seats": seats,
		"board": _rules.state.to_dict(),
		"lobby": _lobby.to_dict(),
	}


func find_seat(seat_id: int) -> PlayerSeat:
	for seat: PlayerSeat in _seats:
		if seat.id == seat_id:
			return seat
	return null


func board_view() -> Dictionary:
	return _rules.state.to_dict()


func get_phase() -> int:
	return _phase


func get_seed() -> int:
	return _seed


func get_version() -> int:
	return _version


func get_seat_count() -> int:
	return _seats.size()


func _grant_token(peer_id: int, action: Dictionary) -> void:
	var seat := find_seat(int(action.get("seat", peer_id)))
	if seat == null:
		return
	var amount := int(action.get("amount", 0))
	if amount == 0:
		return
	seat.tokens += amount
	_publish(false)


func _start_hotseat(peer_id: int, action: Dictionary) -> void:
	if peer_id != 1:
		return
	var names := _read_names(action.get("names", []))
	if names.size() < 2 or names.size() > 4:
		return
	var seed_value := int(action.get("seed", 1))
	if not configure_local_match(names, seed_value):
		return
	_mark_bots(action.get("bots", []))
	var length := clampi(int(action.get("turns_each", 3)), 0, 8)
	_rules.begin(_seats, seed_value, length)
	_rules.pump(_seats)
	_publish_board()


func _roll(peer_id: int, seat_id: int) -> void:
	if peer_id != seat_id:
		return
	if not _rules.roll(_seats, seat_id, -1):
		return
	_rules.pump(_seats)
	_publish_board()


func _shop(peer_id: int, seat_id: int, item_id: String) -> void:
	if peer_id != seat_id:
		return
	if not _rules.shop(_seats, seat_id, item_id):
		return
	_rules.pump(_seats)
	_publish_board()


func _read_names(raw: Variant) -> PackedStringArray:
	var names := PackedStringArray()
	if not raw is Array:
		return names
	for entry: Variant in raw:
		var seat_name := str(entry).strip_edges()
		if seat_name == "":
			return PackedStringArray()
		names.append(seat_name)
	return names


func _mark_bots(raw: Variant) -> void:
	if not raw is Array:
		return
	var index := 0
	while index < raw.size() and index < _seats.size():
		_seats[index].is_bot = bool(raw[index])
		index += 1


func _lobby_name(peer_id: int, action: Dictionary) -> void:
	if not _lobby.open:
		return
	var seat := find_seat(peer_id)
	if seat == null or seat.is_bot:
		return
	var seat_name := str(action.get("name", "")).strip_edges()
	if seat_name == "":
		return
	seat.display_name = seat_name
	_publish(false)


func _lobby_ready(peer_id: int) -> void:
	if not _lobby.open or find_seat(peer_id) == null:
		return
	_lobby.mark_ready(peer_id)
	_publish(false)


func _start_match(peer_id: int, action: Dictionary) -> void:
	if peer_id != 1 or not _lobby.open:
		return
	if _seats.size() < 2 or _seats.size() > 4:
		return
	var seed_value := int(action.get("seed", 1))
	var length := clampi(int(action.get("turns_each", 1)), 0, 8)
	_seed = seed_value
	_rules.begin(_seats, seed_value, length)
	_rules.pump(_seats)
	_publish_board()


func _publish_board() -> void:
	_lobby.open = false
	var next := Phase.BOARD
	if _rules.is_finished():
		next = Phase.RESULTS
	_phase = next
	_publish(true)


func _publish(announce_phase: bool) -> void:
	_version += 1
	if announce_phase:
		EventBus.notify_phase(_phase)
	Network.broadcast_state(to_snapshot())
