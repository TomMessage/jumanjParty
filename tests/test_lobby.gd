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


func test_guest_cannot_start_or_rename_the_host() -> void:
	GameState.ensure_seat(1, "Host")
	GameState.ensure_seat(8, "Guest")
	GameState.handle_input(8, {"kind": "lobby_name", "name": "Ada"})
	GameState.handle_input(8, {"kind": "lobby_ready"})
	assert_eq(GameState.find_seat(8).display_name, "Ada")
	assert_eq(GameState.find_seat(1).display_name, "Host")
	var version := GameState.get_version()
	GameState.handle_input(8, {"kind": "start_match", "seed": 3, "turns_each": 0})
	assert_eq(GameState.get_version(), version)
	assert_eq(GameState.find_seat(1).display_name, "Host")
	var ready_seats: Array = GameState.to_snapshot()["lobby"]["ready"]
	assert_true(ready_seats.has(8))
	assert_true(bool(GameState.to_snapshot()["lobby"]["open"]))


func test_dropped_guest_bot_finishes_the_short_night() -> void:
	GameState.ensure_seat(1, "Host")
	GameState.ensure_seat(2, "Guest")
	GameState.handle_input(1, {"kind": "lobby_ready"})
	GameState.handle_input(1, {"kind": "start_match", "seed": 6, "turns_each": 1})
	assert_eq(int(GameState.board_view()["turn_seat"]), 1)
	assert_false(bool(GameState.to_snapshot()["lobby"]["open"]))
	Network.disconnect_peer(2)
	assert_true(GameState.find_seat(2).is_bot)
	GameState.handle_input(1, {"kind": "roll", "seat": 1})
	if str(GameState.board_view().get("awaiting", "")) == "shop":
		GameState.handle_input(1, {"kind": "shop", "seat": 1, "item": ""})
	assert_eq(GameState.get_phase(), GameState.Phase.RESULTS)
	var board: Dictionary = GameState.board_view()
	assert_eq(int(board["turns_taken"]), 2)
	assert_false(str(board["trial_id"]).is_empty())
	var ranking: Array = board["ranking"]
	assert_eq(ranking.size(), 2)
	assert_true(ranking.has(1))
	assert_true(ranking.has(2))
	var snapshot := GameState.to_snapshot()
	GameState.apply_snapshot(snapshot)
	assert_eq(GameState.to_snapshot(), snapshot)


func test_guest_cannot_roll_the_host_seat() -> void:
	GameState.ensure_seat(1, "Host")
	GameState.ensure_seat(2, "Guest")
	GameState.handle_input(1, {"kind": "start_match", "seed": 2, "turns_each": 1})
	var version := GameState.get_version()
	var board: Dictionary = GameState.to_snapshot()["board"]
	GameState.handle_input(2, {"kind": "roll", "seat": 1})
	assert_eq(GameState.get_version(), version)
	assert_eq(GameState.to_snapshot()["board"], board)
