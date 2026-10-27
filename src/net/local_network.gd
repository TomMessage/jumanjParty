class_name LocalNetwork
extends INetwork

var _last_snapshot: Dictionary = {}


func start_host(_port: int) -> int:
	_hosting = true
	_peer_id = 1
	return OK


func close_session() -> void:
	_hosting = false


func send_input(action: Dictionary) -> void:
	var sender := int(action.get("seat", _peer_id))
	_emit_input_received(sender, action)


func broadcast_state(snapshot: Dictionary) -> void:
	if not _hosting:
		return
	_last_snapshot = snapshot.duplicate(true)
	_emit_state_received(_last_snapshot)


func disconnect_peer(peer_id: int) -> void:
	_emit_peer_disconnected(peer_id)


func last_snapshot() -> Dictionary:
	return _last_snapshot
