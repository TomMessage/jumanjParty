extends GutTest


func test_playable_scenes_exist() -> void:
	var paths := PlayableScenes.paths()
	assert_eq(paths.size(), 15)
	for path: String in paths:
		assert_true(ResourceLoader.exists(path), path)
		assert_true(PlayableScenes.capture_name(path).ends_with(".png"))
	assert_eq(PlayableScenes.capture_name("res://scenes/menu.tscn"), "menu.png")
	assert_eq(PlayableScenes.capture_name("res://scenes/table.tscn"), "table.png")
	assert_eq(PlayableScenes.capture_name("res://scenes/board_view.tscn"), "board-view.png")
	assert_eq(PlayableScenes.capture_name("res://scenes/game_master.tscn"), "game-master.png")
	assert_eq(PlayableScenes.capture_name("res://scenes/match.tscn"), "match.png")
	for card: TrialCard in TrialCatalog.cards():
		assert_true(paths.has(card.scene_path), card.trial_id)
		var shot := card.scene_path.get_file().get_basename().replace("_", "-")
		assert_eq(PlayableScenes.capture_name(card.scene_path), "%s.png" % shot)
