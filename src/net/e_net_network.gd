class_name ENetNetwork
extends INetwork

var _driver: ENetDriver = null
var _remotes: PackedInt32Array = PackedInt32Array()
var _dropped_locally: bool = false


func mount(parent: Node) -> void:
	if _driver != null:
		return
	_driver = ENetDriver.new()
	_driver.name = "ENetDriver"
	_driver.bind_network(self)
	parent.add_child(_driver)


func start_host(port: int) -> int:
	if _driver == null:
		return ERR_UNCONFIGURED
	return _driver.host_on(port)


func start_client(address: String, port: int) -> int:
	if _driver == null:
		return ERR_UNCONFIGURED
	_hosting = false
	return _driver.connect_to(address, port)


func close_session() -> void:
	_hosting = false
	_remotes = PackedInt32Array()
	if _driver == null:
		return
	_driver.shutdown()
	_driver.queue_free()
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
		_emit_input_received(_self_peer, action)
		return
	if _driver != null:
		_driver.submit_input(action)


func deliver_input(peer_id: int, action: Dictionary) -> void:
	_emit_input_received(peer_id, action)


func disconnect_peer(peer_id: int) -> void:
	_emit_peer_disconnected(peer_id)


func mark_host(peer_id: int) -> void:
	_hosting = true
	_self_peer = peer_id


func mark_client(peer_id: int) -> void:
	_hosting = false
	_self_peer = peer_id


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


func notify_local_drop() -> void:
	_dropped_locally = true


func dropped_locally() -> bool:
	return _dropped_locally


func announce_drop(peer_id: int) -> void:
	if _driver == null:
		return
	_driver.announce_drop(peer_id)
