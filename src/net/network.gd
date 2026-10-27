extends Node

var _backend: INetwork = null


func _ready() -> void:
	var local := LocalNetwork.new()
	use_backend(local)
	if local.start_host(0) != OK:
		push_error("LocalNetwork failed to start")


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
