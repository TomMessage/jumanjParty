extends Node

var _role: String = "host"
var _port: int = 24642
var _out: String = ""
var _enet: ENetNetwork = null
var _started_ms: int = 0
var _announced: bool = false
var _drop_id: int = 0
var _final_written: bool = false
var _sent_ms: int = 0
var _booted: bool = false


func _process(_delta: float) -> void:
	if not _booted:
		_booted = true
		if not _boot():
			return
	if Time.get_ticks_msec() - _started_ms > 20000:
		print("ENET_FAIL timeout role=%s" % _role)
		get_tree().quit(1)
		return
	if _role == "host":
		_host_frame()
		return
	_client_frame()


func _boot() -> bool:
	_parse()
	DirAccess.make_dir_recursive_absolute(_out)
	_started_ms = Time.get_ticks_msec()
	_enet = ENetNetwork.new()
	Network.use_backend(_enet)
	_enet.mount(Network)
	GameState.reset_local_mirror()
	if _role == "host":
		return _boot_host()
	return _boot_client()


func _boot_host() -> bool:
	var err := _enet.start_host(_port)
	if err != OK:
		print("ENET_FAIL host %d" % err)
		get_tree().quit(1)
		return false
	_enet.peer_connected.connect(_on_peer_connected)
	GameState.ensure_seat(1, "Host")
	_write_text("host_ready", "ok")
	print("ENET_HOST_READY %d" % _port)
	return true


func _boot_client() -> bool:
	var err := _enet.start_client("127.0.0.1", _port)
	if err != OK:
		print("ENET_FAIL client %d" % err)
		get_tree().quit(1)
		return false
	print("ENET_CLIENT_START")
	return true


func _on_peer_connected(peer_id: int) -> void:
	GameState.ensure_seat(peer_id, "Guest %d" % peer_id)
	print("ENET_PEER %d" % peer_id)


func _host_frame() -> void:
	if not _announced and _enet.remote_count() >= 2:
		_announced = true
		_drop_id = _highest_remote()
		_enet.announce_drop(_drop_id)
		print("ENET_DROP %d" % _drop_id)
	if _announced and not _final_written and _seat_is_bot(_drop_id):
		_final_written = true
		_sent_ms = Time.get_ticks_msec()
		_write_json("host_final.json", GameState.to_snapshot())
		print("ENET_HOST_FINAL")
	if _final_written and Time.get_ticks_msec() > _sent_ms + 2000:
		get_tree().quit(0)


func _client_frame() -> void:
	if _enet.dropped_locally():
		print("ENET_DROPPED")
		get_tree().quit(0)
		return
	if _final_written or _enet.get_peer_id() == 0:
		return
	if not _any_bot():
		return
	_final_written = true
	var filename := "client_%d.json" % _enet.get_peer_id()
	_write_json(filename, GameState.to_snapshot())
	print("ENET_CLIENT_FINAL %s" % filename)
	get_tree().quit(0)


func _highest_remote() -> int:
	var best := 0
	for peer_id: int in _enet.remote_ids():
		if peer_id > best:
			best = peer_id
	return best


func _seat_is_bot(seat_id: int) -> bool:
	var seat := GameState.find_seat(seat_id)
	if seat == null:
		return false
	return seat.is_bot


func _any_bot() -> bool:
	var snapshot := GameState.to_snapshot()
	var seats: Array = snapshot.get("seats", [])
	for raw: Variant in seats:
		if raw is Dictionary and bool((raw as Dictionary).get("is_bot", false)):
			return true
	return false


func _parse() -> void:
	_out = ProjectSettings.globalize_path("res://build/enet")
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--role="):
			_role = arg.trim_prefix("--role=")
		if arg.begins_with("--port="):
			_port = int(arg.trim_prefix("--port="))
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")


func _write_text(name: String, body: String) -> void:
	var file := FileAccess.open(_out.path_join(name), FileAccess.WRITE)
	if file == null:
		print("ENET_FAIL write %s" % name)
		get_tree().quit(1)
		return
	file.store_string(body)


func _write_json(filename: String, data: Dictionary) -> void:
	_write_text(filename, JSON.stringify(data))
