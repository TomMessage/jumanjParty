extends SceneTree

var _ran: bool = false


func _process(_delta: float) -> bool:
	if _ran:
		return true
	_ran = true
	var reason := _reason()
	if reason != "":
		push_error(reason)
		print("TRIAL_FAIL %s" % reason)
		quit(1)
		return true
	print("TRIAL_PASS")
	quit(0)
	return true


func _reason() -> String:
	var paths := TrialCatalog.script_paths()
	if paths.is_empty():
		return "no trials registered"
	for path: String in paths:
		var failure := _exercise(path)
		if failure != "":
			return failure
	return ""


func _exercise(path: String) -> String:
	var trial := _spawn(path)
	if trial == null:
		return "cannot spawn %s" % path
	var players: Array[int] = [1, 2, 3]
	trial.start_trial(players, 11)
	var ticks := 0
	while trial.is_running() and ticks < 2000:
		trial.tick(0.1)
		ticks += 1
	var result := trial.latest_result()
	var min_s := trial.min_duration_seconds
	var max_s := trial.max_duration_seconds
	trial.queue_free()
	return _judge(result, players, ticks, min_s, max_s, path)


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


func _judge(
	result: MinigameResult,
	players: Array[int],
	ticks: int,
	min_s: float,
	max_s: float,
	path: String,
) -> String:
	if result == null:
		return "no result %s" % path
	if ticks < 300 or ticks > 900:
		return "ticks %d for %s" % [ticks, path]
	if not result.is_valid(players):
		return "invalid ranking %s" % path
	if result.duration_seconds < min_s or result.duration_seconds > max_s:
		return "duration out of range %s" % path
	return ""
