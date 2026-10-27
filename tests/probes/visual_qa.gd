extends SceneTree

const SETTLE_FRAMES := 30

var _paths: Array[String] = []
var _index: int = 0
var _frames: int = 0
var _phase: String = "boot"
var _node: Node = null
var _out: String = ""
var _logger: Logger = null
var _failed: bool = false
var _current: String = ""


func _process(_delta: float) -> bool:
	if _phase == "boot":
		_boot()
		return false
	if _phase == "load":
		return _load_next()
	if _phase == "run":
		_frames += 1
		if _frames >= SETTLE_FRAMES:
			_phase = "grab"
		return false
	if _phase == "grab":
		_capture()
		_node.queue_free()
		_node = null
		_phase = "gap"
		_frames = 0
		return false
	_frames += 1
	if _frames < 2:
		return false
	_phase = "load"
	return false


func _boot() -> void:
	_paths = PlayableScenes.paths()
	_out = _output_dir()
	DirAccess.make_dir_recursive_absolute(_out)
	_logger = CaptureLog.new()
	OS.add_logger(_logger)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var method := RenderingServer.get_current_rendering_method()
	print("RENDERER %s" % method)
	_phase = "load"


func _output_dir() -> String:
	var env := OS.get_environment("VISUAL_QA_DIR")
	if env != "":
		return env
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			return arg.trim_prefix("--out=")
	return ProjectSettings.globalize_path("res://build/visual-qa")


func _load_next() -> bool:
	if _index >= _paths.size():
		_finish()
		return true
	_current = _paths[_index]
	_index += 1
	var packed: Resource = load(_current)
	if not packed is PackedScene:
		_failed = true
		print("VISUAL_FAIL missing %s" % _current)
		_finish()
		return true
	_node = (packed as PackedScene).instantiate()
	root.add_child(_node)
	_frames = 0
	_phase = "run"
	return false


func _capture() -> void:
	RenderingServer.force_draw()
	var image: Image = null
	var texture := root.get_texture()
	if texture != null:
		image = texture.get_image()
	var shot_name := PlayableScenes.capture_name(_current)
	var reason := ImageGuard.assess(image)
	if reason != "":
		_failed = true
		print("VISUAL_FAIL %s %s" % [shot_name, reason])
		return
	var dest := _out.path_join(shot_name)
	var err := image.save_png(dest)
	if err != OK:
		_failed = true
		print("VISUAL_FAIL save %s %d" % [dest, err])
		return
	print("VISUAL_PASS %s" % dest)


func _finish() -> void:
	var logger := _logger as CaptureLog
	if logger != null and logger.lines.size() > 0:
		_failed = true
		print("VISUAL_FAIL log %s" % " ".join(logger.lines))
	if _failed:
		quit(1)
		return
	print("VISUAL_OK")
	quit(0)
