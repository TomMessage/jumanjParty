extends GutTest


func test_buses_exist() -> void:
	assert_true(Audio.has_bus("Ambience"))
	assert_true(Audio.has_bus("Music"))
	assert_true(Audio.has_bus("Sfx"))
	assert_true(Audio.has_bus("Voice"))


func test_trial_phase_ducks_music() -> void:
	var music := AudioServer.get_bus_index("Music")
	GameState.reset_local_mirror()
	assert_true(GameState.set_phase(GameState.Phase.MENU))
	var menu_db := AudioServer.get_bus_volume_db(music)
	assert_true(GameState.set_phase(GameState.Phase.TRIAL))
	var trial_db := AudioServer.get_bus_volume_db(music)
	assert_lt(trial_db, menu_db)
