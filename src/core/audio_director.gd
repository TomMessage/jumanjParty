extends Node

var last_phase_id: int = -1
var last_replaced_seat: int = -1
var last_snapshot_version: int = -1


func _ready() -> void:
	_ensure_bus("Ambience")
	_ensure_bus("Music")
	_ensure_bus("Sfx")
	_ensure_bus("Voice")
	_apply_master()
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.seat_replaced_by_bot.connect(_on_seat_replaced)
	EventBus.snapshot_applied.connect(_on_snapshot_applied)


func has_bus(bus_name: String) -> bool:
	return AudioServer.get_bus_index(bus_name) >= 0


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")


func _apply_master() -> void:
	var linear := maxf(SaveSystem.master_linear, 0.0001)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(linear))


func _on_phase_changed(phase_id: int) -> void:
	last_phase_id = phase_id
	var music := AudioServer.get_bus_index("Music")
	if music < 0:
		return
	var db := -2.0
	if phase_id == GameState.Phase.TRIAL:
		db = -10.0
	AudioServer.set_bus_volume_db(music, db)


func _on_seat_replaced(seat_id: int) -> void:
	last_replaced_seat = seat_id


func _on_snapshot_applied(version: int) -> void:
	last_snapshot_version = version
