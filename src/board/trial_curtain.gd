class_name TrialCurtain
extends Node

var _world: Node3D
var _shown := ""
var _root: Node
var _hold := 0.0


func attach(world: Node3D) -> void:
	_world = world


func show_board(board: Dictionary) -> void:
	var scene_path := str(board.get("trial_scene", ""))
	var stamp := "%s:%d" % [str(board.get("trial_id", "")), int(board.get("turns_taken", 0))]
	if scene_path == "" or stamp == _shown:
		return
	_shown = stamp
	_drop()
	var packed: Variant = load(scene_path)
	if not packed is PackedScene:
		return
	_root = (packed as PackedScene).instantiate()
	_world.add_child(_root)
	_hold = 0.0


func _process(delta: float) -> void:
	if _root == null:
		return
	_hold += delta
	if _hold < 1.1:
		return
	_drop()


func _drop() -> void:
	if _root != null:
		_root.free()
		_root = null
	if _world == null:
		return
	var camera := _world.get_node_or_null("SeatedCamera") as Camera3D
	if camera != null:
		camera.current = true
