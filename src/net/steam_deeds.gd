class_name SteamDeeds
extends RefCounted

const FIRST_NIGHT := "FIRST_NIGHT"
const TRIAL_CROWN := "TRIAL_CROWN"
const TABLE_SURVIVOR := "TABLE_SURVIVOR"
const FULL_TABLE := "FULL_TABLE"

static var _pending: Array[String] = []
static var _granted: Array[String] = []


static func consider(snapshot: Dictionary, peer_id: int) -> void:
	if int(snapshot.get("phase", -1)) != GameState.Phase.RESULTS:
		return
	_remember(FIRST_NIGHT)
	var board: Variant = snapshot.get("board", {})
	if board is Dictionary:
		_from_board(board, peer_id)
	var seats: Variant = snapshot.get("seats", [])
	if seats is Array and (seats as Array).size() >= 4:
		_remember(FULL_TABLE)
	_flush()


static func unlock(deed_id: String) -> bool:
	if not _known(deed_id):
		return false
	_remember(deed_id)
	_flush()
	return _granted.has(deed_id)


static func granted(deed_id: String) -> bool:
	return _granted.has(deed_id)


static func pending_has(deed_id: String) -> bool:
	return _pending.has(deed_id)


static func stored_count() -> int:
	return _granted.size()


static func clear_local() -> void:
	_pending.clear()
	_granted.clear()


static func _from_board(board: Dictionary, peer_id: int) -> void:
	if int(board.get("winner_id", 0)) == peer_id:
		_remember(TABLE_SURVIVOR)
	var ranking: Variant = board.get("ranking", [])
	if ranking is Array and not (ranking as Array).is_empty():
		if int((ranking as Array)[0]) == peer_id:
			_remember(TRIAL_CROWN)


static func _remember(deed_id: String) -> void:
	if not _known(deed_id) or _pending.has(deed_id) or _granted.has(deed_id):
		return
	_pending.append(deed_id)


static func _known(deed_id: String) -> bool:
	return (
		deed_id == FIRST_NIGHT
		or deed_id == TRIAL_CROWN
		or deed_id == TABLE_SURVIVOR
		or deed_id == FULL_TABLE
	)


static func _flush() -> void:
	if not SteamRuntime.ready():
		return
	var steam: Variant = SteamRuntime.bridge()
	if not steam is Object:
		return
	var api: Object = steam
	if not api.has_method("setAchievement") or not api.has_method("storeStats"):
		return
	var armed := _arm(api)
	if armed.is_empty():
		return
	if not bool(api.call("storeStats")):
		return
	for deed_id: String in armed:
		_pending.erase(deed_id)
		if not _granted.has(deed_id):
			_granted.append(deed_id)


static func _arm(api: Object) -> Array[String]:
	var armed: Array[String] = []
	var queued: Array[String] = []
	for deed_id: String in _pending:
		queued.append(deed_id)
	for deed_id: String in queued:
		if bool(api.call("setAchievement", deed_id)):
			armed.append(deed_id)
	return armed
