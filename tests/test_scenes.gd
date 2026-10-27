extends GutTest


func test_playable_scenes_exist() -> void:
	var paths := PlayableScenes.paths()
	assert_eq(paths.size(), 4)
	for path: String in paths:
		assert_true(ResourceLoader.exists(path), path)
		assert_true(PlayableScenes.capture_name(path).ends_with(".png"))
	assert_eq(PlayableScenes.capture_name("res://scenes/menu.tscn"), "menu.png")
	assert_eq(PlayableScenes.capture_name("res://scenes/table.tscn"), "table.png")
	assert_eq(PlayableScenes.capture_name("res://scenes/board_view.tscn"), "board-view.png")
	assert_eq(PlayableScenes.capture_name("res://scenes/game_master.tscn"), "game-master.png")
