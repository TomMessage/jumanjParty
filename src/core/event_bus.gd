extends Node

signal phase_changed(phase_id: int)
signal seat_replaced_by_bot(seat_id: int)
signal snapshot_applied(version: int)
signal settings_changed


func notify_phase(phase_id: int) -> void:
	phase_changed.emit(phase_id)


func notify_seat_replaced(seat_id: int) -> void:
	seat_replaced_by_bot.emit(seat_id)


func notify_snapshot(version: int) -> void:
	snapshot_applied.emit(version)


func notify_settings() -> void:
	settings_changed.emit()
