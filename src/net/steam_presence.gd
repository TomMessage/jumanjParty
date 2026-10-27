class_name SteamPresence
extends RefCounted

static var _status: String = ""
static var _display: String = ""
static var _connect: String = ""
static var _published: bool = false


static func note(phase_id: int, connect_token: String) -> bool:
	_status = _status_for(phase_id)
	_display = _display_for(phase_id)
	_connect = connect_token
	_published = _publish()
	return _published


static func published() -> bool:
	return _published


static func last_status() -> String:
	return _status


static func last_display() -> String:
	return _display


static func last_connect() -> String:
	return _connect


static func clear_local() -> void:
	_status = ""
	_display = ""
	_connect = ""
	_published = false


static func _status_for(phase_id: int) -> String:
	if phase_id == GameState.Phase.BOARD:
		return "On the board"
	if phase_id == GameState.Phase.TRIAL:
		return "Inside a trial"
	if phase_id == GameState.Phase.RESULTS:
		return "Counting the tokens"
	return "At the table"


static func _display_for(phase_id: int) -> String:
	if phase_id == GameState.Phase.BOARD:
		return "#OnTheBoard"
	if phase_id == GameState.Phase.TRIAL:
		return "#InsideATrial"
	if phase_id == GameState.Phase.RESULTS:
		return "#CountingTheTokens"
	return "#AtTheTable"


static func _publish() -> bool:
	if not SteamRuntime.ready():
		return false
	var steam: Variant = SteamRuntime.bridge()
	if not steam is Object:
		return false
	var api: Object = steam
	if not api.has_method("setRichPresence"):
		return false
	var status_ok := bool(api.call("setRichPresence", "status", _status))
	var display_ok := bool(api.call("setRichPresence", "steam_display", _display))
	var connect_ok := bool(api.call("setRichPresence", "connect", _connect))
	return status_ok and display_ok and connect_ok
