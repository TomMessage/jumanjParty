class_name SteamNetwork
extends INetwork

const SEATS := 4

var _driver: SteamDriver = null
var _lobby: SteamLobby = null
var _remotes: PackedInt32Array = PackedInt32Array()
var _blocker: String = ""
var _dropped_locally: bool = false


func mount(parent: Node) -> void:
	if _driver != null:
		return
	_driver = SteamDriver.new()
	_driver.name = "SteamDriver"
	_driver.bind_network(self)
	parent.add_child(_driver)
	_lobby = SteamLobby.new()
	_lobby.name = "SteamLobby"
	_lobby.lobby_ready.connect(_on_lobby)
	_lobby.lobby_failed.connect(_on_lobby_failed)
	parent.add_child(_lobby)


func start_host(_port: int) -> int:
	_hosting = false
	SteamRuntime.ensure()
	if not SteamRuntime.ready():
		_blocker = SteamRuntime.reason()
		return ERR_UNAVAILABLE
	if _driver == null or _lobby == null:
		_blocker = "Steam relay node is not mounted."
		return ERR_UNCONFIGURED
	var lobby_err := _lobby.create_friends(SEATS)
	if lobby_err != OK:
		_blocker = _lobby.last_error()
		return lobby_err
	_blocker = ""
	return OK


func start_client(address: String, _port: int) -> int:
	_hosting = false
	SteamRuntime.ensure()
	if not SteamRuntime.ready():
		_blocker = SteamRuntime.reason()
		return ERR_UNAVAILABLE
	if _driver == null or _lobby == null:
		_blocker = "Steam relay node is not mounted."
		return ERR_UNCONFIGURED
	if not address.is_valid_int():
		_blocker = "Steam join needs a lobby id."
		return ERR_INVALID_PARAMETER
	var lobby_err := _lobby.join(int(address))
	if lobby_err != OK:
		_blocker = _lobby.last_error()
		return lobby_err
	_blocker = ""
	return OK


func close_session() -> void:
	_hosting = false
	_peer_id = 0
	_dropped_locally = false
	_remotes = PackedInt32Array()
	if _lobby != null:
		_lobby.leave()
		_lobby.detach()
		_free_node(_lobby)
		_lobby = null
	if _driver != null:
		_driver.shutdown()
		_free_node(_driver)
		_driver = null


func remote_count() -> int:
	return _remotes.size()


func remote_ids() -> PackedInt32Array:
	return _remotes.duplicate()


func broadcast_state(snapshot: Dictionary) -> void:
	if not _hosting:
		return
	if _driver != null:
		_driver.send_state(snapshot)
	_emit_state_received(snapshot)


func send_input(action: Dictionary) -> void:
	if _hosting:
		_emit_input_received(_peer_id, action)
		return
	if _driver != null:
		_driver.submit_input(action)


func disconnect_peer(peer_id: int) -> void:
	if _driver != null and relay_open():
		_driver.announce_drop(peer_id)
	_emit_peer_disconnected(peer_id)


func blocker() -> String:
	return _blocker


func lobby_id() -> int:
	if _lobby == null:
		return 0
	return _lobby.current_id()


func relay_open() -> bool:
	if _driver == null:
		return false
	return _driver.relay_open()


func invite(steam_id: int, overlay: bool) -> int:
	SteamRuntime.ensure()
	if not SteamRuntime.ready():
		_blocker = SteamRuntime.reason()
		return ERR_UNAVAILABLE
	if _lobby == null:
		_blocker = "Steam lobby node is not mounted."
		return ERR_UNCONFIGURED
	if overlay:
		return _lobby.open_overlay()
	return _lobby.invite(steam_id)


func mark_host(peer_id: int) -> void:
	_hosting = true
	_peer_id = peer_id


func mark_client(peer_id: int) -> void:
	_hosting = false
	_peer_id = peer_id


func notify_remote(peer_id: int, connected: bool) -> void:
	if connected:
		if not _remotes.has(peer_id):
			_remotes.append(peer_id)
		_emit_peer_connected(peer_id)
		return
	var index := _remotes.find(peer_id)
	if index >= 0:
		_remotes.remove_at(index)
	_emit_peer_disconnected(peer_id)


func deliver_state(snapshot: Dictionary) -> void:
	_emit_state_received(snapshot)


func deliver_input(peer_id: int, action: Dictionary) -> void:
	_emit_input_received(peer_id, action)


func notify_local_drop() -> void:
	_dropped_locally = true
	_hosting = false


func dropped_locally() -> bool:
	return _dropped_locally


func _on_lobby(opened_id: int, hosting: bool) -> void:
	if relay_open():
		return
	if hosting:
		_host_relay(opened_id)
		return
	_join_relay()


func _on_lobby_failed(code: int) -> void:
	_hosting = false
	_blocker = "Steam lobby failed (%d)." % code


func _host_relay(opened_id: int) -> void:
	if _driver == null:
		_blocker = "Steam relay node is not mounted."
		return
	var err := _driver.host_lobby(opened_id)
	if err != OK:
		_blocker = "Steam relay refused the lobby (%d)." % err


func _join_relay() -> void:
	if _driver == null or _lobby == null:
		_blocker = "Steam relay node is not mounted."
		return
	var err := _driver.join_owner(_lobby.owner_id())
	if err != OK:
		_blocker = "Steam relay refused the host (%d)." % err


func _free_node(node: Node) -> void:
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.free()
