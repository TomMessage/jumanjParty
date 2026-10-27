extends GutTest


func test_catalog_covers_worlds_and_kinds() -> void:
	var cards := TrialCatalog.cards()
	assert_eq(cards.size(), 10)
	var worlds := {"jungle": 0, "desert": 0, "haunted": 0, "space": 0, "volcano": 0}
	var kinds := {"race": 0, "dodge": 0, "puzzle": 0, "waves": 0, "absurd": 0}
	var ids: Array[String] = []
	for card: TrialCard in cards:
		assert_true(worlds.has(card.world_name), card.world_name)
		assert_true(kinds.has(card.kind), card.kind)
		worlds[card.world_name] = int(worlds[card.world_name]) + 1
		kinds[card.kind] = int(kinds[card.kind]) + 1
		assert_false(ids.has(card.trial_id), card.trial_id)
		ids.append(card.trial_id)
		assert_gte(card.duration_seconds, 30.0)
		assert_lte(card.duration_seconds, 90.0)
		assert_true(ResourceLoader.exists(card.scene_path), card.scene_path)
		assert_true(ResourceLoader.exists(card.script_path), card.script_path)
		var bot_path := card.script_path.replace(".gd", "_bot.gd")
		assert_true(ResourceLoader.exists(bot_path), bot_path)
	for world: Variant in worlds.keys():
		assert_eq(int(worlds[world]), 2, str(world))
	for kind: Variant in kinds.keys():
		assert_eq(int(kinds[kind]), 2, str(kind))
	var scripts := TrialCatalog.script_paths()
	assert_eq(scripts.size(), 11)
	assert_eq(scripts[0], "res://src/minigames/_base/contract_trial.gd")


func test_vine_rush_finishes() -> void:
	_finish(VineRush.new(), "VineRushBot")


func test_beetle_rain_finishes() -> void:
	_finish(BeetleRain.new(), "BeetleRainBot")


func test_sting_lanes_finishes() -> void:
	_finish(StingLanes.new(), "StingLanesBot")


func test_sundial_lock_finishes() -> void:
	_finish(SundialLock.new(), "SundialLockBot")


func test_candle_dodge_finishes() -> void:
	_finish(CandleDodge.new(), "CandleDodgeBot")


func test_portrait_waves_finishes() -> void:
	_finish(PortraitWaves.new(), "PortraitWavesBot")


func test_star_dial_finishes() -> void:
	_finish(StarDial.new(), "StarDialBot")


func test_gravy_orbit_finishes() -> void:
	_finish(GravyOrbit.new(), "GravyOrbitBot")


func test_lava_hurdles_finishes() -> void:
	_finish(LavaHurdles.new(), "LavaHurdlesBot")


func test_marshmallow_crown_finishes() -> void:
	_finish(MarshmallowCrown.new(), "MarshmallowCrownBot")


func test_brake_beats_a_reckless_throttle() -> void:
	var card := _card("res://src/minigames/jungle/vine_rush.tres")
	var careful := _race_score(card, true)
	var reckless := _race_score(card, false)
	assert_gt(careful, reckless)


func test_lane_change_beats_standing_still() -> void:
	var card := _card("res://src/minigames/desert/sting_lanes.tres")
	var moving := _dodge_score(card, true)
	var stuck := _dodge_score(card, false)
	assert_gt(moving, stuck)


func test_matching_symbol_scores() -> void:
	var card := _card("res://src/minigames/desert/sundial_lock.tres")
	var field := PuzzleField.new()
	var seats: Array[int] = [1]
	field.setup(seats, 3, card)
	var step := 0
	while step < 40:
		var symbol := int(field.observe(1)["symbol"])
		field.apply(1, {"symbol": symbol})
		field.step(0.1)
		step += 1
	assert_gt(int(field.scores()[1]), 0)


func test_aimed_swat_beats_a_wild_aim() -> void:
	var card := _card("res://src/minigames/jungle/beetle_rain.tres")
	var aimed := _wave_score(card, true)
	var wild := _wave_score(card, false)
	assert_gt(aimed, wild)


func test_counter_lean_beats_standing_still() -> void:
	var card := _card("res://src/minigames/space/gravy_orbit.tres")
	var balanced := _absurd_score(card, true)
	var still := _absurd_score(card, false)
	assert_gt(balanced, still)


func test_camera_falls_onto_the_board() -> void:
	var view := TrialView.new()
	add_child(view)
	view.build(_card("res://src/minigames/jungle/vine_rush.tres"))
	var high := view.camera_height()
	view.advance_fall(1.0)
	assert_lt(view.camera_height(), high)
	assert_lt(view.camera_height(), 3.0)
	remove_child(view)
	view.free()


func test_same_seed_repeats_the_ranking() -> void:
	var first := _outcome(VineRush.new(), 11)
	var second := _outcome(VineRush.new(), 11)
	assert_eq(first["rank"], second["rank"])
	assert_eq(first["scores"], second["scores"])


func _finish(trial: TrialBody, bot_name: String) -> void:
	add_child(trial)
	var bot := trial.build_bot()
	assert_eq(str(bot.get_script().get_global_name()), bot_name)
	var players: Array[int] = [1, 2, 3]
	trial.start_trial(players, 11)
	var ticks := 0
	while trial.is_running() and ticks < 2000:
		trial.tick(0.1)
		ticks += 1
	var result := trial.latest_result()
	assert_not_null(result)
	assert_true(result.is_valid(players))
	assert_gte(ticks, 300)
	assert_lte(ticks, 900)
	assert_gte(result.duration_seconds, 30.0)
	assert_lte(result.duration_seconds, 90.0)
	remove_child(trial)
	trial.free()


func _outcome(trial: TrialBody, seed_value: int) -> Dictionary:
	var result := _played(trial, seed_value)
	return {
		"rank": result.rankings.duplicate(),
		"scores": result.scores.duplicate(),
	}


func _played(trial: TrialBody, seed_value: int) -> MinigameResult:
	add_child(trial)
	var players: Array[int] = [1, 2, 3]
	trial.start_trial(players, seed_value)
	while trial.is_running():
		trial.tick(0.1)
	var result := trial.latest_result()
	remove_child(trial)
	trial.free()
	return result


func _card(path: String) -> TrialCard:
	return load(path) as TrialCard


func _race_score(card: TrialCard, careful: bool) -> int:
	var field := RaceField.new()
	var seats: Array[int] = [1]
	field.setup(seats, 4, card)
	var bot := VineRushBot.new()
	var step := 0
	while step < 120:
		var obs := field.observe(1)
		obs["seat"] = 1
		obs["seed"] = 4
		var action := {"throttle": 1.0}
		if careful:
			action = bot.choose_action(obs)
		field.apply(1, action)
		field.step(0.1)
		step += 1
	return int(field.scores()[1])


func _dodge_score(card: TrialCard, moving: bool) -> int:
	var field := DodgeField.new()
	var seats: Array[int] = [1]
	field.setup(seats, 4, card)
	var bot := StingLanesBot.new()
	var step := 0
	while step < 40:
		var obs := field.observe(1)
		obs["seat"] = 1
		obs["seed"] = 4
		var action := {"lane": 0}
		if moving:
			action = bot.choose_action(obs)
		field.apply(1, action)
		field.step(0.1)
		step += 1
	return int(field.scores()[1])


func _wave_score(card: TrialCard, aimed: bool) -> int:
	var field := WaveField.new()
	var seats: Array[int] = [1]
	field.setup(seats, 4, card)
	var bot := BeetleRainBot.new()
	var step := 0
	while step < 80:
		var obs := field.observe(1)
		obs["seat"] = 1
		obs["seed"] = 4
		var action := {"aim": 3.4}
		if aimed:
			action = bot.choose_action(obs)
		field.apply(1, action)
		field.step(0.1)
		step += 1
	return int(field.scores()[1])


func _absurd_score(card: TrialCard, balanced: bool) -> int:
	var field := AbsurdField.new()
	var seats: Array[int] = [1]
	field.setup(seats, 4, card)
	var bot := GravyOrbitBot.new()
	var step := 0
	while step < 160:
		var obs := field.observe(1)
		obs["seat"] = 1
		obs["seed"] = 4
		var action := {"lean": 0.0}
		if balanced:
			action = bot.choose_action(obs)
		field.apply(1, action)
		field.step(0.1)
		step += 1
	return int(field.scores()[1])
