extends GutTest


func test_contract_trial_ranks_players() -> void:
	var trial := ContractTrial.new()
	add_child(trial)
	var players: Array[int] = [1, 2, 3]
	trial.start_trial(players, 4)
	var ticks := 0
	while trial.is_running() and ticks < 2000:
		trial.tick(0.1)
		ticks += 1
	var result := trial.latest_result()
	assert_not_null(result)
	assert_true(result.is_valid(players))
	assert_eq(result.rankings.size(), 3)
	assert_gte(ticks, 300)
	assert_lte(ticks, 900)
	assert_gte(result.duration_seconds, trial.min_duration_seconds)
	assert_lte(result.duration_seconds, trial.max_duration_seconds)
	remove_child(trial)
	trial.free()


func test_catalog_lists_contract() -> void:
	var paths := TrialCatalog.script_paths()
	assert_false(paths.is_empty())
	for path: String in paths:
		assert_true(ResourceLoader.exists(path), path)


func test_bot_is_deterministic() -> void:
	var bot := BotController.new()
	var first := bot.choose_action({"seat": 2, "seed": 9})
	var second := bot.choose_action({"seat": 2, "seed": 9})
	assert_eq(first["effort"], second["effort"])
