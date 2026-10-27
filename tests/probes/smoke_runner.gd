extends SceneTree

var _paths: Array[String] = []
var _index: int = 0
var _frames: int = 0
var _gap: int = 0
var _phase: String = "boot"
var _node: Node = null
var _logger: Logger = null


func _process(_delta: float) -> bool:
	if _phase == "boot":
		_boot()
		return false
	if _phase == "load":
		return _load_next()
	if _phase == "run":
		_frames += 1
		if _frames >= 120:
			_node.queue_free()
			_node = null
			_gap = 0
			_phase = "gap"
		return false
	_gap += 1
	if _gap >= 2:
		_phase = "load"
	return false


func _boot() -> void:
	_paths = PlayableScenes.paths()
	_logger = CaptureLog.new()
	OS.add_logger(_logger)
	_phase = "load"


func _load_next() -> bool:
	if _index >= _paths.size():
		_finish()
		return true
	var path := _paths[_index]
	_index += 1
	if not ResourceLoader.exists(path):
		_fail("missing %s" % path)
		return true
	var packed: Resource = load(path)
	if not packed is PackedScene:
		_fail("not a scene %s" % path)
		return true
	_node = (packed as PackedScene).instantiate()
	root.add_child(_node)
	_frames = 0
	_phase = "run"
	return false


func _finish() -> void:
	var logger := _logger as CaptureLog
	if logger != null and logger.lines.size() > 0:
		_fail(" ".join(logger.lines))
		return
	print("SMOKE_PASS")
	quit(0)


func _fail(reason: String) -> void:
	print("SMOKE_FAIL %s" % reason)
	quit(1)
