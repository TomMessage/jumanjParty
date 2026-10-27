class_name ENetDriver
extends Node

var _network: ENetNetwork = null
var _drop_sent: bool = false


func bind_network(network: ENetNetwork) -> void:
	_network = network


func shutdown() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null


func host_on(port: int) -> int:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, 4)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = peer
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if _network != null:
		_network.mark_host(1)
	return OK


func connect_to(address: String, port: int) -> int:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = peer
	if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.connect(_on_connected_to_server)
	return OK


func send_state(snapshot: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	receive_state.rpc(snapshot)


func announce_drop(peer_id: int) -> void:
	if _drop_sent or not multiplayer.is_server():
		return
	_drop_sent = true
	request_drop.rpc(peer_id)


@rpc("authority", "reliable")
func receive_state(snapshot: Dictionary) -> void:
	if _network != null:
		_network.deliver_state(snapshot)


@rpc("authority", "reliable")
func request_drop(peer_id: int) -> void:
	if multiplayer.get_unique_id() != peer_id:
		return
	call_deferred("_drop_self")


func _on_peer_connected(peer_id: int) -> void:
	if _network != null:
		_network.notify_remote(peer_id, true)


func _on_peer_disconnected(peer_id: int) -> void:
	if _network != null:
		_network.notify_remote(peer_id, false)


func _on_connected_to_server() -> void:
	if _network != null:
		_network.mark_client(multiplayer.get_unique_id())


func _drop_self() -> void:
	shutdown()
	if _network != null:
		_network.notify_local_drop()
