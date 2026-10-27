class_name PlayableScenes
extends RefCounted


static func paths() -> Array[String]:
	return [
		"res://scenes/menu.tscn",
		"res://scenes/table.tscn",
		"res://scenes/board_view.tscn",
		"res://scenes/game_master.tscn",
		"res://scenes/match.tscn",
	]


static func capture_name(path: String) -> String:
	if path.ends_with("menu.tscn"):
		return "menu.png"
	if path.ends_with("table.tscn"):
		return "table.png"
	if path.ends_with("board_view.tscn"):
		return "board-view.png"
	if path.ends_with("game_master.tscn"):
		return "game-master.png"
	if path.ends_with("match.tscn"):
		return "match.png"
	return "scene.png"
