class_name SteamRuntime
extends RefCounted

const INIT_OK := 0
const RESULT_OK := 1
const ENTER_OK := 1
const FRIENDS_LOBBY := 1
const NO_SINGLETON := "GodotSteam is not loaded (no Steam singleton)"
const NO_PEER := "SteamMultiplayerPeer is absent, so the relay cannot open"
const NO_APP := "no Steam app id in STEAM_APP_ID or res://steam_appid.txt"

static var _checked: bool = false
static var _ready: bool = false
static var _reason: String = ""


static func bridge() -> Variant:
	if Engine.has_singleton("Steam"):
		return Engine.get_singleton("Steam")
	return null


static func ready() -> bool:
	return _ready


static func reason() -> String:
	return _reason


static func app_id() -> int:
	var from_env := _positive_int(OS.get_environment("STEAM_APP_ID"))
	if from_env != 0:
		return from_env
	if not FileAccess.file_exists("res://steam_appid.txt"):
		return 0
	var text := FileAccess.get_file_as_string("res://steam_appid.txt")
	var lines: PackedStringArray = text.split("\n")
	if lines.is_empty():
		return 0
	return _positive_int(lines[0])


static func diagnose() -> String:
	var missing := PackedStringArray()
	if bridge() == null:
		missing.append(NO_SINGLETON)
	if not ClassDB.class_exists("SteamMultiplayerPeer"):
		missing.append(NO_PEER)
	if app_id() == 0:
		missing.append(NO_APP)
	if missing.is_empty():
		return ""
	return "; ".join(missing) + "."


static func ensure() -> bool:
	if _checked:
		return _ready
	_checked = true
	var missing := diagnose()
	if missing != "":
		_reason = missing
		_ready = false
		return false
	return _open_api()


static func lobby_from_args(args: PackedStringArray) -> int:
	var index := 0
	while index < args.size():
		var token := args[index]
		if token == "+connect_lobby" and index + 1 < args.size():
			return _positive_int(args[index + 1])
		if token.begins_with("+connect_lobby="):
			return _positive_int(token.trim_prefix("+connect_lobby="))
		index += 1
	return 0


static func _positive_int(token: String) -> int:
	var trimmed := token.strip_edges()
	if trimmed.is_valid_int() and int(trimmed) > 0:
		return int(trimmed)
	return 0


static func _open_api() -> bool:
	var steam: Variant = bridge()
	if not steam is Object:
		_fail(NO_SINGLETON + ".")
		return false
	var api: Object = steam
	if not api.has_method("steamInitEx"):
		_fail("GodotSteam is loaded without steamInitEx.")
		return false
	var outcome: Variant = api.call("steamInitEx", app_id(), true)
	if not outcome is Dictionary:
		_fail("steamInitEx returned no status.")
		return false
	var body: Dictionary = outcome
	var status := int(body.get("status", -1))
	if status != INIT_OK:
		_fail(_verbal(body, status))
		return false
	if api.has_method("loggedOn") and not bool(api.call("loggedOn")):
		_fail("Steam client is not logged on.")
		return false
	_reason = ""
	_ready = true
	return true


static func _verbal(body: Dictionary, status: int) -> String:
	var verbal := str(body.get("verbal", "")).strip_edges()
	if verbal != "":
		return verbal
	return "steamInitEx status %d." % status


static func _fail(message: String) -> void:
	_reason = message
	_ready = false
