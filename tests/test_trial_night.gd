extends GutTest

var _backend: INetwork


func before_each() -> void:
	_backend = Network.get_backend()
	var local := LocalNetwork.new()
	Network.use_backend(local)
	local.start_host(0)
	GameState.reset_local_mirror()


func after_each() -> void:
	Network.use_backend(_backend)
	GameState.reset_local_mirror()


func test_a_roll_queues_a_catalog_trial() -> void:
	var rules := MatchRules.new()
	var seats := _players()
	rules.begin(seats, 4, 3)
	assert_true(rules.roll(seats, 1, 1))
	assert_eq(rules.state.awaiting, "trial")
	assert_true(_catalog_ids().has(rules.state.trial_id))
	assert_true(rules.state.trial_scene.ends_with(".tscn"))
	assert_gt(rules.state.trial_seed, 0)
	var first_seed := rules.state.trial_seed
	assert_true(rules.resolve_trial(seats))
	assert_true(rules.roll(seats, 2, 1))
	assert_ne(rules.state.trial_seed, first_seed)


func test_resolve_pays_the_played_ranking() -> void:
	var rules := MatchRules.new()
	var seats := _players()
	rules.begin(seats, 4, 3)
	assert_true(rules.roll(seats, 1, 3))
	var players: Array[int] = [1, 2]
	var expected := TrialNight.play(rules.state.trial_id, players, rules.state.trial_seed)
	assert_not_null(expected)
	assert_true(expected.is_valid(players))
	var before: Array[int] = [seats[0].tokens, seats[1].tokens]
	assert_true(rules.resolve_trial(seats))
	assert_eq(rules.state.ranking, expected.rankings)
	var first := seats[0].tokens - before[0]
	var second := seats[1].tokens - before[1]
	assert_eq(first + second, 5)
	assert_true(first == 3 or second == 3)
	assert_ne(rules.state.awaiting, "trial")


func test_bot_night_returns_with_a_ranking() -> void:
	_start([true, true, true], 9)
	var snapshot := GameState.to_snapshot()
	var board: Dictionary = snapshot["board"]
	assert_eq(int(snapshot["phase"]), GameState.Phase.RESULTS)
	assert_eq(int(board["turns_taken"]), 9)
	assert_true(_catalog_ids().has(str(board["trial_id"])))
	var ranking: Array = board["ranking"]
	assert_eq(ranking.size(), 3)
	assert_true(ranking.has(1))
	assert_true(ranking.has(2))
	assert_true(ranking.has(3))
	assert_true(str(board["trial_scene"]).ends_with(".tscn"))


func test_effects_do_not_change_the_ranking() -> void:
	var players: Array[int] = [1, 2, 3]
	var first := TrialNight.play("vine_rush", players, 11)
	SaveSystem.toggle_effects()
	var second := TrialNight.play("vine_rush", players, 11)
	SaveSystem.toggle_effects()
	assert_not_null(first)
	assert_not_null(second)
	assert_eq(first.rankings, second.rankings)
	assert_eq(first.scores, second.scores)


func _catalog_ids() -> Array[String]:
	var ids: Array[String] = []
	for card: TrialCard in TrialCatalog.cards():
		ids.append(card.trial_id)
	return ids


func _players() -> Array[PlayerSeat]:
	var seats: Array[PlayerSeat] = []
	var index := 0
	while index < 2:
		var seat := PlayerSeat.new()
		seat.id = index + 1
		seat.display_name = "P%d" % seat.id
		seat.is_bot = false
		seats.append(seat)
		index += 1
	return seats


func _start(bots: Array[bool], seed_value: int) -> void:
	var names: Array = []
	var index := 0
	while index < bots.size():
		names.append("P%d" % [index + 1])
		index += 1
	(
		GameState
		. handle_input(
			1,
			{
				"kind": "start_hotseat",
				"names": names,
				"bots": bots,
				"seed": seed_value,
			}
		)
	)
