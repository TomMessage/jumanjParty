class_name PlayableScenes
extends RefCounted


static func paths() -> Array[String]:
	var found: Array[String] = [
		"res://scenes/menu.tscn",
		"res://scenes/table.tscn",
		"res://scenes/board_view.tscn",
		"res://scenes/game_master.tscn",
		"res://scenes/match.tscn",
	]
	for card: TrialCard in TrialCatalog.cards():
		found.append(card.scene_path)
	return found


static func capture_name(path: String) -> String:
	var known := {
		"res://scenes/menu.tscn": "menu.png",
		"res://scenes/table.tscn": "table.png",
		"res://scenes/board_view.tscn": "board-view.png",
		"res://scenes/game_master.tscn": "game-master.png",
		"res://scenes/match.tscn": "match.png",
	}
	if known.has(path):
		return str(known[path])
	var stem := path.get_file().get_basename().replace("_", "-")
	return "%s.png" % stem
