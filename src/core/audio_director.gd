extends Node

var last_phase_id: int = -1
var last_replaced_seat: int = -1
var last_snapshot_version: int = -1
var last_spoken: String = ""
var voice_ready: bool = false

var _ambience: AudioStreamPlayer
var _bed: AudioStreamPlayer
var _layer: AudioStreamPlayer
var _voice: AudioStreamPlayer


func _ready() -> void:
	_ensure_bus("Ambience")
	_ensure_bus("Music")
	_ensure_bus("Sfx")
	_ensure_bus("Voice")
	_apply_master()
	_ambience = _player("Ambience", ToneLoop.rustle(), -22.0)
	_bed = _player("Music", ToneLoop.drone(), -12.0)
	_layer = _player("Music", ToneLoop.layer(), -16.0)
	_voice = _player("Voice", null, -4.0)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.seat_replaced_by_bot.connect(_on_seat_replaced)
	EventBus.snapshot_applied.connect(_on_snapshot_applied)
	EventBus.settings_changed.connect(_apply_master)
	_on_phase_changed(GameState.get_phase())


func has_bus(bus_name: String) -> bool:
	return AudioServer.get_bus_index(bus_name) >= 0


func ambience_on() -> bool:
	return _ambience != null and _ambience.playing


func music_layer_bus() -> String:
	if _layer == null:
		return ""
	return _layer.bus


func _player(bus_name: String, stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus_name
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	if stream != null:
		player.play()
	return player


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
	_fit_layer(phase_id)


func _fit_layer(phase_id: int) -> void:
	if _layer == null:
		return
	var db := -16.0
	if phase_id == GameState.Phase.TRIAL:
		db = -24.0
	if phase_id == GameState.Phase.BOARD or phase_id == GameState.Phase.RESULTS:
		db = -10.0
	_layer.volume_db = db


func _on_seat_replaced(seat_id: int) -> void:
	last_replaced_seat = seat_id


func _on_snapshot_applied(version: int) -> void:
	last_snapshot_version = version
	var board := GameState.board_view()
	var line := str(board.get("keeper_line", ""))
	if int(board.get("winner_id", 0)) != 0:
		var worst := str(board.get("worst_line", ""))
		if worst != "":
			line = worst
	_speak(line)


func _speak(line: String) -> void:
	if _voice == null or line == "" or line == last_spoken:
		return
	var stream := GibberishVoice.stream_for(line)
	if stream.data.size() == 0:
		return
	_voice.stream = stream
	_voice.play()
	last_spoken = line
	voice_ready = true
