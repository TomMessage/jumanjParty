extends Node

var _backend: INetwork = null
var _transport_note: String = ""


func _ready() -> void:
	EventBus.phase_changed.connect(_on_phase_changed)
	_boot_transport()


func use_backend(next: INetwork) -> void:
	_detach()
	_backend = next
	_attach()


func get_backend() -> INetwork:
	return _backend


func is_host() -> bool:
	if _backend == null:
		return false
	return _backend.is_host()


func get_peer_id() -> int:
	if _backend == null:
		return 0
	return _backend.get_peer_id()


func remote_count() -> int:
	if _backend == null:
		return 0
	return _backend.remote_count()


func broadcast_state(snapshot: Dictionary) -> void:
	if _backend == null:
		return
	_backend.broadcast_state(snapshot)


func send_input(action: Dictionary) -> void:
	if _backend == null:
		return
	_backend.send_input(action)


func disconnect_peer(peer_id: int) -> void:
	if _backend == null:
		return
	_backend.disconnect_peer(peer_id)


func open_transport(kind: String, port: int) -> String:
	if kind == "local":
		_transport_note = ""
		return _start_local()
	if kind == "enet":
		_transport_note = ""
		return _start_enet(port)
	if kind == "steam":
		return _start_steam(port)
	_transport_note = "Unknown transport. Fell back to local."
	return _start_local()


func connect_steam(lobby_id: int) -> int:
	var target := lobby_id
	if target == 0:
		target = _invite_argument()
	if target == 0:
		_start_local()
		_transport_note = "No Steam lobby id to join. Fell back to local."
		return ERR_UNAVAILABLE
	var steam := SteamNetwork.new()
	steam.mount(self)
	use_backend(steam)
	var err := steam.start_client(str(target), 0)
	if err == OK:
		_transport_note = ""
		return OK
	var why := steam.blocker()
	steam.close_session()
	_start_local()
	_transport_note = "Steam join unavailable (%s). Fell back to local." % why
	return ERR_UNAVAILABLE


func open_invite(steam_id: int, overlay: bool) -> int:
	if not _backend is SteamNetwork:
		_transport_note = "Invites need Steam, which is not the active transport."
		return ERR_UNAVAILABLE
	return (_backend as SteamNetwork).invite(steam_id, overlay)


func transport_name() -> String:
	if _backend is SteamNetwork:
		return "steam"
	if _backend is ENetNetwork:
		return "enet"
	if _backend is LocalNetwork:
		return "local"
	return ""


func transport_note() -> String:
	return _transport_note


func _boot_transport() -> void:
	var invite := _invite_argument()
	if invite != 0:
		connect_steam(invite)
		return
	var asked := OS.get_environment("BOARD_TRANSPORT").strip_edges().to_lower()
	var port := _boot_port()
	if asked == "steam":
		open_transport("steam", port)
		return
	if asked == "enet":
		open_transport("enet", port)
		return
	_start_local()


func _boot_port() -> int:
	return _positive_port(OS.get_environment("BOARD_PORT"))


func _invite_argument() -> int:
	var from_engine := SteamRuntime.lobby_from_args(OS.get_cmdline_args())
	if from_engine != 0:
		return from_engine
	return SteamRuntime.lobby_from_args(OS.get_cmdline_user_args())


func _positive_port(token: String) -> int:
	var trimmed := token.strip_edges()
	if trimmed.is_valid_int() and int(trimmed) > 0:
		return int(trimmed)
	return 0


func _start_local() -> String:
	var local := LocalNetwork.new()
	use_backend(local)
	if local.start_host(0) != OK:
		push_error("LocalNetwork failed to start")
	return "local"


func _start_enet(port: int) -> String:
	var enet := ENetNetwork.new()
	enet.mount(self)
	use_backend(enet)
	if enet.start_host(port) == OK:
		return "enet"
	enet.close_session()
	_transport_note = "ENet could not bind. Fell back to local."
	return _start_local()


func _start_steam(port: int) -> String:
	var steam := SteamNetwork.new()
	steam.mount(self)
	use_backend(steam)
	var err := steam.start_host(port)
	if err == OK:
		_transport_note = ""
		return "steam"
	var why := steam.blocker()
	steam.close_session()
	if port > 0:
		var used := _start_enet(port)
		if used == "enet":
			_note_fallback(why, "ENet")
			return "enet"
		_note_fallback(why, "local")
		return "local"
	_start_local()
	_note_fallback(why, "local")
	return "local"


func _note_fallback(why: String, landed: String) -> void:
	_transport_note = "Steam unavailable (%s). Fell back to %s." % [why, landed]


func _connect_token() -> String:
	if not _backend is SteamNetwork:
		return ""
	var lobby := (_backend as SteamNetwork).lobby_id()
	if lobby == 0:
		return ""
	return "+connect_lobby %d" % lobby


func _on_phase_changed(phase_id: int) -> void:
	SteamPresence.note(phase_id, _connect_token())
	if phase_id != GameState.Phase.RESULTS:
		return
	SteamDeeds.consider(GameState.to_snapshot(), get_peer_id())


func _attach() -> void:
	if _backend == null:
		return
	_backend.peer_disconnected.connect(_on_peer_disconnected)
	_backend.state_received.connect(GameState.apply_snapshot)
	_backend.input_received.connect(GameState.handle_input)


func _detach() -> void:
	if _backend == null:
		return
	if _backend.peer_disconnected.is_connected(_on_peer_disconnected):
		_backend.peer_disconnected.disconnect(_on_peer_disconnected)
	if _backend.state_received.is_connected(GameState.apply_snapshot):
		_backend.state_received.disconnect(GameState.apply_snapshot)
	if _backend.input_received.is_connected(GameState.handle_input):
		_backend.input_received.disconnect(GameState.handle_input)


func _on_peer_disconnected(peer_id: int) -> void:
	if not is_host():
		return
	GameState.replace_with_bot(peer_id)
