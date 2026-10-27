extends SceneTree

const WARMUP := 20
const SAMPLE := 90

var _phase: String = "boot"
var _scenes: Array[String] = []
var _quiet: Array[bool] = []
var _index: int = 0
var _saved_effects: bool = true
var _muted: bool = false
var _frames: int = 0
var _node: Node = null
var _current: String = ""
var _load_us: int = 0
var _sample_us: int = 0
var _draws: Array[float] = []
var _objects: Array[float] = []
var _lines: PackedStringArray = PackedStringArray()
var _failed: bool = false
var _out: String = ""


func _process(_delta: float) -> bool:
	if _phase == "boot":
		_boot()
		return _phase == "done"
	if _phase == "load":
		_load_next()
		return _phase == "done"
	if _phase == "run":
		_sample()
	return _phase == "done"


func _boot() -> void:
	_out = _output_path()
	if DisplayServer.get_name() == "headless":
		_fail("headless cannot measure draw calls")
		return
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var renderer := RenderingServer.get_current_rendering_method()
	var adapter := RenderingServer.get_video_adapter_name()
	_lines.append("PERF_RENDERER %s" % renderer)
	_lines.append("PERF_ADAPTER %s" % adapter)
	_record_trials()
	_scenes = [
		"res://scenes/menu.tscn",
		"res://scenes/match.tscn",
		"res://src/minigames/jungle/vine_rush.tscn",
		"res://scenes/menu.tscn",
	]
	_quiet = [false, false, false, true]
	_phase = "load"


func _record_trials() -> void:
	for card: TrialCard in TrialCatalog.cards():
		var failure := _play_card(card)
		if failure != "":
			_failed = true
			_lines.append("PERF_TRIAL_FAIL %s" % failure)


func _play_card(card: TrialCard) -> String:
	var trial := _spawn(card.script_path)
	if trial == null:
		return "cannot spawn %s" % card.trial_id
	var players: Array[int] = [1, 2, 3]
	trial.start_trial(players, 11)
	var ticks := 0
	while trial.is_running() and ticks < 2000:
		trial.tick(0.1)
		ticks += 1
	var result := trial.latest_result()
	trial.queue_free()
	if result == null:
		return "no result %s" % card.trial_id
	if result.duration_seconds < 30.0 or result.duration_seconds > 90.0:
		return "%s duration %.2f" % [card.trial_id, result.duration_seconds]
	_lines.append(
		"PERF_TRIAL %s duration_s=%.2f ticks=%d" % [card.trial_id, result.duration_seconds, ticks]
	)
	return ""


func _spawn(path: String) -> MinigameBase:
	if not ResourceLoader.exists(path):
		return null
	var loaded: Variant = load(path)
	if not loaded is Script:
		return null
	var node: Variant = (loaded as Script).new()
	if not node is MinigameBase:
		if node is Node:
			(node as Node).free()
		return null
	var trial := node as MinigameBase
	root.add_child(trial)
	return trial


func _load_next() -> void:
	if _index >= _scenes.size():
		_finish()
		return
	_current = _scenes[_index]
	var quiet := false
	if _index < _quiet.size():
		quiet = _quiet[_index]
	_index += 1
	_apply_quiet(quiet)
	_load_us = Time.get_ticks_usec()
	var packed: Resource = load(_current)
	if not packed is PackedScene:
		_fail("missing %s" % _current)
		return
	_node = (packed as PackedScene).instantiate()
	root.add_child(_node)
	_frames = 0
	_draws.clear()
	_objects.clear()
	_phase = "run"


func _sample() -> void:
	_frames += 1
	if _frames == 1:
		var first_ms := float(Time.get_ticks_usec() - _load_us) / 1000.0
		_lines.append("PERF_LOAD %s first_frame_ms=%.2f" % [_current, first_ms])
	if _frames == WARMUP:
		_sample_us = Time.get_ticks_usec()
	if _frames > WARMUP:
		_draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		_objects.append(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
	if _frames < WARMUP + SAMPLE:
		return
	_emit_scene()
	_node.queue_free()
	_node = null
	_phase = "load"


func _emit_scene() -> void:
	var elapsed := Time.get_ticks_usec() - _sample_us
	var fps := 0.0
	if elapsed > 0:
		fps = float(SAMPLE) * 1000000.0 / float(elapsed)
	var frame_ms := 0.0
	if fps > 0.0:
		frame_ms = 1000.0 / fps
	var mem := Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
	var summary := (
		"fps=%.1f frame_ms=%.2f draws_avg=%.1f draws_max=%.0f"
		% [fps, frame_ms, _mean(_draws), _peak(_draws)]
	)
	var lamp := "on"
	if not _effects_on():
		lamp = "off"
	summary += " objects_avg=%.1f mem_mb=%.1f effects=%s" % [_mean(_objects), mem, lamp]
	_lines.append("PERF_SCENE %s %s" % [_current, summary])
	_restore_effects()


func _mean(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	var total := 0.0
	for value: float in values:
		total += value
	return total / float(values.size())


func _peak(values: Array[float]) -> float:
	var best := 0.0
	for value: float in values:
		best = maxf(best, value)
	return best


func _settings() -> Node:
	if not root.has_node("SaveSystem"):
		return null
	return root.get_node("SaveSystem")


func _effects_on() -> bool:
	var settings := _settings()
	if settings == null:
		return true
	return bool(settings.get("effects_enabled"))


func _apply_quiet(quiet: bool) -> void:
	var settings := _settings()
	if not quiet or _muted or settings == null:
		return
	_saved_effects = bool(settings.get("effects_enabled"))
	settings.set("effects_enabled", false)
	settings.call("save_settings")
	_muted = true


func _restore_effects() -> void:
	var settings := _settings()
	if not _muted or settings == null:
		return
	settings.set("effects_enabled", _saved_effects)
	settings.call("save_settings")
	_muted = false


func _fail(reason: String) -> void:
	_failed = true
	_lines.append("PERF_FAIL %s" % reason)
	_finish()


func _finish() -> void:
	_restore_effects()
	_phase = "done"
	DirAccess.make_dir_recursive_absolute(_out.get_base_dir())
	var file := FileAccess.open(_out, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(_lines) + "\n")
	for line: String in _lines:
		print(line)
	if _failed:
		print("PERF_FAIL")
		quit(1)
		return
	print("PERF_PASS")
	quit(0)


func _output_path() -> String:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			return arg.trim_prefix("--out=")
	return ProjectSettings.globalize_path("res://build/perf/report.txt")
