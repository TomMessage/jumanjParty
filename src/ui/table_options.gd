class_name TableOptions
extends RefCounted

const LAMPS: Array[float] = [0.0, 0.5, 1.0]
const SCALES: Array[float] = [1.0, 1.25, 1.5]
const ROWS := 5

var row: int = 0


func move(step: int) -> void:
	row = posmod(row + step, ROWS)


func nudge(step: int) -> void:
	if row == 0:
		SaveSystem.effect_intensity = _cycle(LAMPS, SaveSystem.effect_intensity, step)
	if row == 1:
		SaveSystem.high_contrast = step > 0
	if row == 2:
		SaveSystem.reduce_motion = step > 0
	if row == 3:
		SaveSystem.text_scale = _cycle(SCALES, SaveSystem.text_scale, step)
	if row == 4:
		_cycle_key(step)
	SaveSystem.save_settings()


func slates() -> PackedStringArray:
	var all := _rows()
	var start := clampi(row - 1, 0, all.size() - 3)
	return PackedStringArray([all[start], all[start + 1], all[start + 2]])


func selected() -> int:
	var all := _rows()
	return row - clampi(row - 1, 0, all.size() - 3)


func detail() -> String:
	if row == 0:
		return "How hard the lamp burns."
	if row == 1:
		return "Ink against the parchment."
	if row == 2:
		return "Hold the flames still."
	if row == 3:
		return "How large the writing is."
	return "Which key looks at the keeper."


func _rows() -> PackedStringArray:
	return PackedStringArray(
		[
			"LAMP %s" % _lamp_word(),
			"INK %s" % _mark(SaveSystem.high_contrast),
			"MOTION %s" % _mark(not SaveSystem.reduce_motion),
			"TYPE %s" % _scale_word(),
			"KEY %s" % _key_word(),
		]
	)


func _cycle(values: Array[float], current: float, step: int) -> float:
	var best := 0
	var gap := 999.0
	var index := 0
	while index < values.size():
		var next := absf(current - values[index])
		if next < gap:
			gap = next
			best = index
		index += 1
	return values[posmod(best + step, values.size())]


func _cycle_key(step: int) -> void:
	var keys := _keys()
	var current := _keeper_key()
	var index := keys.find(current)
	if index < 0:
		index = 0
	var next: Key = keys[posmod(index + step, keys.size())]
	SaveSystem.keeper_key = int(next)
	InputBindings.rebind_key("view_keeper", next)


func _keys() -> Array[Key]:
	var keys: Array[Key] = [KEY_3, KEY_5, KEY_6, KEY_7]
	return keys


func _keeper_key() -> Key:
	if SaveSystem.keeper_key == 0:
		return KEY_3
	return SaveSystem.keeper_key as Key


func _lamp_word() -> String:
	var words := PackedStringArray(["OFF", "LOW", "FULL"])
	return words[_nearest(LAMPS, SaveSystem.effect_intensity)]


func _scale_word() -> String:
	var words := PackedStringArray(["1", "1.25", "1.5"])
	return words[_nearest(SCALES, SaveSystem.text_scale)]


func _key_word() -> String:
	var words := PackedStringArray(["3", "5", "6", "7"])
	var index := _keys().find(_keeper_key())
	if index < 0:
		return "3"
	return words[index]


func _nearest(values: Array[float], current: float) -> int:
	var best := 0
	var gap := 999.0
	var index := 0
	while index < values.size():
		var next := absf(current - values[index])
		if next < gap:
			gap = next
			best = index
		index += 1
	return best


func _mark(enabled: bool) -> String:
	if enabled:
		return "ON"
	return "OFF"
