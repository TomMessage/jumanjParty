class_name TrialCurtain
extends Node

var _world: Node3D
var _shown := ""
var _root: Node
var _hold := 0.0


func attach(world: Node3D) -> void:
	_world = world


static func replay_path(board: Dictionary) -> String:
	if int(board.get("winner_id", 0)) == 0:
		return ""
	return str(board.get("worst_scene", ""))


static func replay_stamp(board: Dictionary) -> String:
	var path := replay_path(board)
	if path == "":
		return ""
	return "replay:%s" % path


func show_board(board: Dictionary) -> void:
	var scene_path := str(board.get("trial_scene", ""))
	var stamp := "%s:%d" % [str(board.get("trial_id", "")), int(board.get("turns_taken", 0))]
	if int(board.get("winner_id", 0)) != 0:
		scene_path = replay_path(board)
		stamp = replay_stamp(board)
		if scene_path == "" or SaveSystem.reduce_motion:
			_shown = stamp
			_drop()
			return
	if scene_path == "" or stamp == _shown:
		if scene_path == "":
			_shown = ""
			_drop()
		return
	_shown = stamp
	_spawn(scene_path)


func _process(delta: float) -> void:
	if _root == null or _shown.begins_with("replay:"):
		return
	_hold += delta
	if _hold < 1.1:
		return
	_drop()


func _spawn(scene_path: String) -> void:
	_drop()
	if _world == null:
		return
	var packed: Variant = load(scene_path)
	if not packed is PackedScene:
		return
	_root = (packed as PackedScene).instantiate()
	_world.add_child(_root)
	_hold = 0.0


func _drop() -> void:
	if _root != null:
		_root.free()
		_root = null
	if _world == null:
		return
	var camera := _world.get_node_or_null("SeatedCamera") as Camera3D
	if camera != null:
		camera.current = true
