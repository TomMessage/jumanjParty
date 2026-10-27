class_name SteamLobby
extends Node

signal lobby_ready(lobby_id: int, hosting: bool)
signal lobby_failed(code: int)

var _api: Variant = null
var _lobby_id: int = 0
var _error: String = ""


func create_friends(slots: int) -> int:
	var attached := _attach()
	if attached != OK:
		return attached
	var api: Object = _api
	if not api.has_method("createLobby"):
		_error = "GodotSteam cannot create lobbies."
		return ERR_UNAVAILABLE
	api.call("createLobby", SteamRuntime.FRIENDS_LOBBY, slots)
	return OK


func join(lobby_id: int) -> int:
	if lobby_id <= 0:
		_error = "Steam join needs a lobby id."
		return ERR_INVALID_PARAMETER
	var attached := _attach()
	if attached != OK:
		return attached
	var api: Object = _api
	if not api.has_method("joinLobby"):
		_error = "GodotSteam cannot join lobbies."
		return ERR_UNAVAILABLE
	api.call("joinLobby", lobby_id)
	return OK


func invite(steam_id: int) -> int:
	if _lobby_id == 0:
		_error = "Steam lobby is not open."
		return ERR_UNCONFIGURED
	if steam_id <= 0:
		_error = "Steam invite needs a friend id."
		return ERR_INVALID_PARAMETER
	if not _api is Object:
		_error = SteamRuntime.diagnose()
		return ERR_UNAVAILABLE
	var api: Object = _api
	if not api.has_method("inviteUserToLobby"):
		_error = "GodotSteam cannot send lobby invites."
		return ERR_UNAVAILABLE
	if not bool(api.call("inviteUserToLobby", _lobby_id, steam_id)):
		_error = "Steam refused the invite."
		return ERR_CANT_CONNECT
	return OK


func open_overlay() -> int:
	if _lobby_id == 0:
		_error = "Steam lobby is not open."
		return ERR_UNCONFIGURED
	if not _api is Object:
		_error = SteamRuntime.diagnose()
		return ERR_UNAVAILABLE
	var api: Object = _api
	if not api.has_method("activateGameOverlayInviteDialog"):
		_error = "GodotSteam cannot open the invite dialog."
		return ERR_UNAVAILABLE
	api.call("activateGameOverlayInviteDialog", _lobby_id)
	return OK


func leave() -> void:
	if _lobby_id != 0 and _api is Object:
		var api: Object = _api
		if api.has_method("leaveLobby"):
			api.call("leaveLobby", _lobby_id)
	_lobby_id = 0


func detach() -> void:
	if not _api is Object:
		return
	var api: Object = _api
	if api.is_connected("lobby_created", _on_lobby_created):
		api.disconnect("lobby_created", _on_lobby_created)
	if api.is_connected("lobby_joined", _on_lobby_joined):
		api.disconnect("lobby_joined", _on_lobby_joined)
	_api = null


func current_id() -> int:
	return _lobby_id


func owner_id() -> int:
	if _lobby_id == 0 or not _api is Object:
		return 0
	var api: Object = _api
	if not api.has_method("getLobbyOwner"):
		return 0
	return int(api.call("getLobbyOwner", _lobby_id))


func last_error() -> String:
	return _error


func _attach() -> int:
	var steam: Variant = SteamRuntime.bridge()
	if not steam is Object:
		_error = SteamRuntime.diagnose()
		return ERR_UNAVAILABLE
	var api: Object = steam
	if not api.has_signal("lobby_created") or not api.has_signal("lobby_joined"):
		_error = "GodotSteam is missing lobby signals."
		return ERR_UNAVAILABLE
	if not api.is_connected("lobby_created", _on_lobby_created):
		api.connect("lobby_created", _on_lobby_created)
	if not api.is_connected("lobby_joined", _on_lobby_joined):
		api.connect("lobby_joined", _on_lobby_joined)
	_api = api
	return OK


func _on_lobby_created(result: int, lobby_id: int) -> void:
	if result != SteamRuntime.RESULT_OK:
		_error = "Steam lobby create failed (%d)." % result
		lobby_failed.emit(result)
		return
	_remember(lobby_id)
	lobby_ready.emit(lobby_id, true)


func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response != SteamRuntime.ENTER_OK:
		_error = "Steam lobby join failed (%d)." % response
		lobby_failed.emit(response)
		return
	_remember(lobby_id)
	var owner := owner_id()
	if owner == 0:
		_error = "Steam lobby has no host."
		lobby_failed.emit(ERR_UNCONFIGURED)
		return
	lobby_ready.emit(lobby_id, owner == _steam_id())


func _remember(lobby_id: int) -> void:
	_lobby_id = lobby_id
	if not _api is Object:
		return
	var api: Object = _api
	if api.has_method("setLobbyJoinable"):
		api.call("setLobbyJoinable", lobby_id, true)
	if api.has_method("setLobbyData"):
		api.call("setLobbyData", lobby_id, "name", "Candlelit table")


func _steam_id() -> int:
	if not _api is Object:
		return 0
	var api: Object = _api
	if not api.has_method("getSteamID"):
		return 0
	return int(api.call("getSteamID"))
