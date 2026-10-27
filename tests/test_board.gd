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


func test_catalog_covers_every_kind() -> void:
	var spaces := BoardCatalog.spaces()
	assert_eq(spaces.size(), BoardCatalog.LOOP)
	var kinds: Array[String] = []
	for space: BoardSpace in spaces:
		if not kinds.has(space.kind):
			kinds.append(space.kind)
	for kind: String in ["start", "gain", "loss", "trap", "swap", "event", "shop"]:
		assert_true(kinds.has(kind), kind)
	assert_eq(BoardCatalog.cards().size(), 6)
	assert_eq(BoardCatalog.items().size(), 3)
	assert_ne(BoardSpots.at(0), BoardSpots.at(1))
	assert_eq(BoardSpots.at(BoardCatalog.LOOP), BoardSpots.at(0))


func test_client_cannot_start_or_roll() -> void:
	_start([false, true], 4)
	var version := GameState.get_version()
	var board: Dictionary = GameState.to_snapshot()["board"]
	Network.use_backend(ClientStub.new())
	GameState.handle_input(1, {"kind": "roll", "seat": 1})
	GameState.handle_input(1, {"kind": "start_hotseat", "names": ["A", "B"], "seed": 1})
	assert_eq(GameState.get_version(), version)
	assert_eq(GameState.to_snapshot()["board"], board)


func test_bots_finish_the_same_night_twice() -> void:
	var first := _night(9)
	GameState.reset_local_mirror()
	var local := LocalNetwork.new()
	Network.use_backend(local)
	local.start_host(0)
	var second := _night(9)
	assert_eq(first, second)
	assert_eq(int(first["phase"]), GameState.Phase.RESULTS)
	_assert_winner(first)


func test_same_seed_differs_from_another_seed() -> void:
	var first := _night(3)
	GameState.reset_local_mirror()
	var local := LocalNetwork.new()
	Network.use_backend(local)
	local.start_host(0)
	var second := _night(8)
	assert_ne(first["board"], second["board"])


func test_human_turn_waits_and_bots_follow() -> void:
	_start([false, true, true], 5)
	var board: Dictionary = GameState.board_view()
	assert_eq(str(board["awaiting"]), "roll")
	assert_eq(int(board["turn_seat"]), 1)
	assert_false(GameState.find_seat(1).is_bot)
	var version := GameState.get_version()
	GameState.handle_input(1, {"kind": "roll", "seat": 2})
	assert_eq(GameState.get_version(), version)
	GameState.handle_input(1, {"kind": "roll", "seat": 1})
	assert_gt(GameState.get_version(), version)
	if GameState.get_phase() != GameState.Phase.RESULTS:
		assert_eq(int(GameState.board_view()["turn_seat"]), 1)
		assert_false(GameState.find_seat(1).is_bot)


func test_disconnect_during_turn_lets_the_bot_finish() -> void:
	_start([false, true], 6)
	Network.disconnect_peer(1)
	assert_true(GameState.find_seat(1).is_bot)
	assert_eq(GameState.get_phase(), GameState.Phase.RESULTS)
	_assert_winner(GameState.to_snapshot())


func test_snapshot_round_trip() -> void:
	_start([false, true], 2)
	GameState.handle_input(1, {"kind": "roll", "seat": 1})
	var snapshot := GameState.to_snapshot()
	GameState.apply_snapshot(snapshot)
	assert_eq(GameState.to_snapshot(), snapshot)


func test_tie_keeps_the_lowest_id() -> void:
	var rules := MatchRules.new()
	var seats := _players([false, false])
	rules.begin(seats, 1, 0)
	assert_eq(rules.state.winner_id, 1)
	assert_false(rules.state.active)


func test_pass_start_pays_a_token() -> void:
	var rules := MatchRules.new()
	var seats := _players([false, false])
	rules.begin(seats, 1, 3)
	rules.state.positions[0] = BoardCatalog.LOOP - 1
	assert_true(rules.roll(seats, 1, 1))
	assert_eq(seats[0].tokens, 1)
	assert_eq(rules.state.positions[0], 0)


func test_shield_blocks_a_loss() -> void:
	var rules := MatchRules.new()
	var seats := _players([false, false])
	rules.begin(seats, 1, 3)
	seats[0].tokens = 3
	rules.state.items[0] = PackedStringArray(["shield"])
	rules.state.positions[0] = 1
	assert_true(rules.roll(seats, 1, 1))
	assert_eq(seats[0].tokens, 3)
	assert_false(rules.state.items[0].has("shield"))


func test_shop_rejects_a_poor_seat() -> void:
	var rules := MatchRules.new()
	var seats := _players([false, false])
	rules.begin(seats, 1, 3)
	seats[0].tokens = 0
	rules.state.positions[0] = 5
	var before := rules.state.to_dict()
	assert_true(rules.roll(seats, 1, 1))
	assert_ne(rules.state.awaiting, "shop")
	assert_eq(seats[0].tokens, 0)
	assert_ne(rules.state.to_dict(), before)


func test_shop_buys_and_passes() -> void:
	var rules := MatchRules.new()
	var seats := _players([false, false])
	rules.begin(seats, 1, 3)
	seats[0].tokens = 6
	rules.state.positions[0] = 5
	assert_true(rules.roll(seats, 1, 1))
	assert_eq(rules.state.awaiting, "shop")
	var broken := rules.state.to_dict()
	assert_false(rules.shop(seats, 1, "crown"))
	assert_eq(rules.state.to_dict(), broken)
	assert_true(rules.shop(seats, 1, "shield"))
	assert_eq(seats[0].tokens, 2)
	assert_true(rules.state.items[0].has("shield"))


func test_swap_and_event_cards() -> void:
	var seats := _players([false, true])
	var state := MatchState.new()
	state.seat_ids = [1, 2]
	state.positions = [8, 0]
	state.skip = [false, false]
	state.items = [PackedStringArray(), PackedStringArray()]
	state.deck = ["boots"]
	var swap_note := PawnMover.swap_with(state, seats, seats[0], 1)
	assert_eq(state.positions[0], 0)
	assert_eq(state.positions[1], 8)
	assert_true(swap_note.find(seats[1].display_name) >= 0)
	state.deck = ["candle"]
	seats[0].tokens = 0
	var note := CardResolver.draw(state, seats, seats[0])
	assert_eq(seats[0].tokens, 3)
	assert_eq(state.last_card, "candle")
	assert_true(note.find("Kind Candle") >= 0)
	state.deck = ["tips"]
	seats[0].tokens = 2
	seats[1].tokens = 2
	CardResolver.draw(state, seats, seats[0])
	assert_eq(seats[0].tokens, 1)
	assert_eq(seats[1].tokens, 1)


func test_effects_do_not_move_the_board() -> void:
	_start([false, true], 1)
	var version := GameState.get_version()
	SaveSystem.toggle_effects()
	assert_eq(GameState.get_version(), version)
	SaveSystem.toggle_effects()


func _night(seed_value: int) -> Dictionary:
	_start([true, true, true], seed_value)
	return GameState.to_snapshot()


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


func _players(bots: Array[bool]) -> Array[PlayerSeat]:
	var seats: Array[PlayerSeat] = []
	var index := 0
	while index < bots.size():
		var seat := PlayerSeat.new()
		seat.id = index + 1
		seat.display_name = "P%d" % seat.id
		seat.is_bot = bots[index]
		seats.append(seat)
		index += 1
	return seats


func _assert_winner(snapshot: Dictionary) -> void:
	var board: Dictionary = snapshot["board"]
	var winner := int(board["winner_id"])
	assert_gt(winner, 0)
	var best := -1
	for raw: Variant in snapshot["seats"]:
		var seat: Dictionary = raw
		best = maxi(best, int(seat["tokens"]))
		assert_gte(int(seat["tokens"]), 0)
	for raw: Variant in snapshot["seats"]:
		var seat: Dictionary = raw
		if int(seat["id"]) == winner:
			assert_eq(int(seat["tokens"]), best)
