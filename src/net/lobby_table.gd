class_name LobbyTable
extends RefCounted

var open: bool = true
var ready_ids: Array[int] = []


func reset() -> void:
	open = true
	ready_ids = []


func mark_ready(seat_id: int) -> void:
	if ready_ids.has(seat_id):
		return
	ready_ids.append(seat_id)
	ready_ids.sort()


func to_dict() -> Dictionary:
	return {"open": open, "ready": _plain(ready_ids)}


static func from_dict(data: Dictionary) -> LobbyTable:
	var lobby := LobbyTable.new()
	lobby.open = bool(data.get("open", true))
	lobby.ready_ids = _read(data.get("ready", []))
	lobby.ready_ids.sort()
	return lobby


static func _plain(values: Array[int]) -> Array:
	var plain: Array = []
	for value: int in values:
		plain.append(value)
	return plain


static func _read(raw: Variant) -> Array[int]:
	var values: Array[int] = []
	if raw is Array:
		for entry: Variant in raw:
			values.append(int(entry))
	return values
