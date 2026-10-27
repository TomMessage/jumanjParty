class_name INetwork
extends RefCounted

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal state_received(snapshot: Dictionary)
signal input_received(peer_id: int, action: Dictionary)

var _hosting: bool = false
var _peer_id: int = 0


func start_host(_port: int) -> int:
	return ERR_UNAVAILABLE


func start_client(_address: String, _port: int) -> int:
	return ERR_UNAVAILABLE


func close_session() -> void:
	_hosting = false


func is_host() -> bool:
	return _hosting


func get_peer_id() -> int:
	return _peer_id


func remote_count() -> int:
	return 0


func remote_ids() -> PackedInt32Array:
	return PackedInt32Array()


func send_input(_action: Dictionary) -> void:
	return


func broadcast_state(_snapshot: Dictionary) -> void:
	return


func disconnect_peer(_dropped_id: int) -> void:
	return


func _emit_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id)


func _emit_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id)


func _emit_state_received(snapshot: Dictionary) -> void:
	state_received.emit(snapshot)


func _emit_input_received(peer_id: int, action: Dictionary) -> void:
	input_received.emit(peer_id, action)
