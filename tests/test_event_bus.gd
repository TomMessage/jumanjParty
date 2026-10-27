extends GutTest


func test_signals_have_listeners() -> void:
	var expected: Array[String] = ["phase_changed", "seat_replaced_by_bot", "snapshot_applied"]
	for signal_name: String in expected:
		var links: Array = EventBus.get_signal_connection_list(signal_name)
		assert_gt(links.size(), 0, signal_name)


func test_phase_signal_reaches_audio() -> void:
	GameState.reset_local_mirror()
	assert_true(GameState.set_phase(GameState.Phase.TRIAL))
	assert_eq(Audio.last_phase_id, GameState.Phase.TRIAL)
