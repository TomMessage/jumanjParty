class_name CameraFraming
extends RefCounted


static func aim(view_name: String) -> Dictionary:
	if view_name == "menu":
		return _pair(Vector3(0.0, 1.28, 1.62), Vector3(0.0, 1.0, 0.05))
	if view_name == "board":
		return _pair(Vector3(0.05, 1.72, 0.72), Vector3(0.0, 0.86, -0.05))
	if view_name == "keeper" or view_name == "game_master":
		return _pair(Vector3(0.62, 1.18, -0.28), Vector3(0.02, 1.12, -1.68))
	if view_name == "window":
		return _pair(Vector3(-0.2, 1.4, 0.15), Vector3(3.2, 1.5, 0.0))
	if view_name == "cards":
		return _pair(Vector3(-0.45, 1.15, 0.95), Vector3(-0.1, 0.92, 0.15))
	return _pair(Vector3(0.08, 1.32, 1.85), Vector3(0.0, 0.92, -0.35))


static func _pair(origin: Vector3, target: Vector3) -> Dictionary:
	return {"origin": origin, "target": target}
