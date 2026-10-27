extends SceneTree

var _started: bool = false


func _process(_delta: float) -> bool:
	if _started:
		return false
	_started = true
	var session := (load("res://tests/probes/enet_session.gd") as Script).new() as Node
	root.add_child(session)
	return false
