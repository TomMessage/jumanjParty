class_name MatchState
extends RefCounted

var active: bool = false
var awaiting: String = ""
var turn_seat: int = 0
var turns_taken: int = 0
var turns_each: int = 3
var die_face: int = 0
var winner_id: int = 0
var last_note: String = ""
var last_card: String = ""
var rng_seed: int = 0
var rng_state: int = 0
var seat_ids: Array[int] = []
var positions: Array[int] = []
var skip: Array[bool] = []
var items: Array[PackedStringArray] = []
var deck: Array[String] = []
var shop_choices: Array[String] = []


func index_of(seat_id: int) -> int:
	return seat_ids.find(seat_id)


func to_dict() -> Dictionary:
	return {
		"active": active,
		"awaiting": awaiting,
		"turn_seat": turn_seat,
		"turns_taken": turns_taken,
		"turns_each": turns_each,
		"die_face": die_face,
		"winner_id": winner_id,
		"last_note": last_note,
		"last_card": last_card,
		"rng_seed": rng_seed,
		"rng_state": rng_state,
		"seat_ids": _plain_ints(seat_ids),
		"positions": _plain_ints(positions),
		"skip": _plain_bools(skip),
		"items": _plain_items(items),
		"deck": _plain_strings(deck),
		"shop_choices": _plain_strings(shop_choices),
	}


static func from_dict(data: Dictionary) -> MatchState:
	var state := MatchState.new()
	state.active = bool(data.get("active", false))
	state.awaiting = str(data.get("awaiting", ""))
	state.turn_seat = int(data.get("turn_seat", 0))
	state.turns_taken = int(data.get("turns_taken", 0))
	state.turns_each = int(data.get("turns_each", 3))
	state.die_face = int(data.get("die_face", 0))
	state.winner_id = int(data.get("winner_id", 0))
	state.last_note = str(data.get("last_note", ""))
	state.last_card = str(data.get("last_card", ""))
	state.rng_seed = int(data.get("rng_seed", 0))
	state.rng_state = int(data.get("rng_state", 0))
	state.seat_ids = _read_ints(data.get("seat_ids", []))
	state.positions = _read_ints(data.get("positions", []))
	state.skip = _read_bools(data.get("skip", []))
	state.items = _read_items(data.get("items", []))
	state.deck = _read_strings(data.get("deck", []))
	state.shop_choices = _read_strings(data.get("shop_choices", []))
	return state


static func _plain_ints(values: Array[int]) -> Array:
	var plain: Array = []
	for value: int in values:
		plain.append(value)
	return plain


static func _plain_bools(values: Array[bool]) -> Array:
	var plain: Array = []
	for value: bool in values:
		plain.append(value)
	return plain


static func _plain_strings(values: Array[String]) -> Array:
	var plain: Array = []
	for value: String in values:
		plain.append(value)
	return plain


static func _plain_items(values: Array[PackedStringArray]) -> Array:
	var plain: Array = []
	for row: PackedStringArray in values:
		var copy: Array = []
		for entry: String in row:
			copy.append(entry)
		plain.append(copy)
	return plain


static func _read_ints(raw: Variant) -> Array[int]:
	var values: Array[int] = []
	if raw is Array:
		for entry: Variant in raw:
			values.append(int(entry))
	return values


static func _read_bools(raw: Variant) -> Array[bool]:
	var values: Array[bool] = []
	if raw is Array:
		for entry: Variant in raw:
			values.append(bool(entry))
	return values


static func _read_strings(raw: Variant) -> Array[String]:
	var values: Array[String] = []
	if raw is Array:
		for entry: Variant in raw:
			values.append(str(entry))
	return values


static func _read_items(raw: Variant) -> Array[PackedStringArray]:
	var values: Array[PackedStringArray] = []
	if not raw is Array:
		return values
	for row: Variant in raw:
		var packed := PackedStringArray()
		if row is Array:
			for entry: Variant in row:
				packed.append(str(entry))
		values.append(packed)
	return values
