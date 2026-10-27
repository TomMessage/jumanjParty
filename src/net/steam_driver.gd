class_name SteamDriver
extends Node

var _network: SteamNetwork = null
var _drop_sent: bool = false


func bind_network(network: SteamNetwork) -> void:
	_network = network


func shutdown() -> void:
	_unbind_signals()
	var peer := multiplayer.multiplayer_peer
	if peer != null and peer.get_class() == "SteamMultiplayerPeer":
		peer.close()
		multiplayer.multiplayer_peer = null


func host_lobby(opened_lobby: int) -> int:
	var peer := _make_peer()
	if peer == null:
		return ERR_UNAVAILABLE
	var err := _host_peer(peer, opened_lobby)
	if err != OK:
		return err
	_adopt(peer)
	if _network != null:
		_network.mark_host(1)
	return OK


func join_owner(owner_id: int) -> int:
	if owner_id <= 0:
		return ERR_INVALID_PARAMETER
	var peer := _make_peer()
	if peer == null:
		return ERR_UNAVAILABLE
	if not peer.has_method("create_client"):
		return ERR_UNAVAILABLE
	_set_relay(peer)
	var err := int(peer.call("create_client", owner_id, 0))
	if err != OK:
		return err
	_set_relay(peer)
	_adopt(peer)
	return OK


func relay_open() -> bool:
	var peer := multiplayer.multiplayer_peer
	if peer == null or peer.get_class() != "SteamMultiplayerPeer":
		return false
	return bool(peer.get("server_relay"))


func send_state(snapshot: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	receive_state.rpc(snapshot)


func submit_input(action: Dictionary) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	receive_input.rpc_id(1, action)


func announce_drop(peer_id: int) -> void:
	if _drop_sent or not multiplayer.is_server():
		return
	_drop_sent = true
	request_drop.rpc(peer_id)


@rpc("authority", "reliable")
func receive_state(snapshot: Dictionary) -> void:
	if _network != null:
		_network.deliver_state(snapshot)


@rpc("any_peer", "reliable")
func receive_input(action: Dictionary) -> void:
	if _network == null or not multiplayer.is_server():
		return
	_network.deliver_input(multiplayer.get_remote_sender_id(), action)


@rpc("authority", "reliable")
func request_drop(peer_id: int) -> void:
	if multiplayer.get_unique_id() != peer_id:
		return
	call_deferred("_drop_self")


func _make_peer() -> MultiplayerPeer:
	if not ClassDB.class_exists("SteamMultiplayerPeer"):
		return null
	var created: Variant = ClassDB.instantiate("SteamMultiplayerPeer")
	if created is MultiplayerPeer:
		return created
	return null


func _host_peer(peer: MultiplayerPeer, opened_lobby: int) -> int:
	_set_relay(peer)
	if peer.has_method("host_with_lobby"):
		var hosted := int(peer.call("host_with_lobby", opened_lobby))
		if hosted != OK:
			return hosted
		_set_relay(peer)
		return OK
	if peer.has_method("create_host"):
		var created := int(peer.call("create_host", 0))
		if created != OK:
			return created
		_set_relay(peer)
		return OK
	return ERR_UNAVAILABLE


func _set_relay(peer: MultiplayerPeer) -> void:
	peer.set("server_relay", true)


func _adopt(peer: MultiplayerPeer) -> void:
	multiplayer.multiplayer_peer = peer
	_bind_signals()


func _bind_signals() -> void:
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.connect(_on_connected_to_server)


func _unbind_signals() -> void:
	if multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.disconnect(_on_peer_connected)
	if multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)
	if multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.disconnect(_on_connected_to_server)


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
