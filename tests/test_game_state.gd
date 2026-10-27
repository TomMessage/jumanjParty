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


func test_host_configures_three_seats() -> void:
	var names := PackedStringArray(["Ada", "Bo", "Cid"])
	assert_true(GameState.configure_local_match(names, 5))
	assert_eq(GameState.get_seat_count(), 3)
	assert_eq(GameState.get_seed(), 5)
	assert_eq(GameState.get_phase(), GameState.Phase.TABLE)
	var snapshot := GameState.to_snapshot()
	assert_eq(int(snapshot["version"]), GameState.get_version())


func test_disconnect_marks_bot() -> void:
	var names := PackedStringArray(["Ada", "Bo", "Cid"])
	GameState.configure_local_match(names, 2)
	Network.disconnect_peer(3)
	var replaced := GameState.find_seat(3)
	assert_not_null(replaced)
	assert_true(replaced.is_bot)
	assert_false(GameState.find_seat(1).is_bot)
	assert_eq(Audio.last_replaced_seat, 3)
	var snapshot := GameState.to_snapshot()
	GameState.apply_snapshot(snapshot)
	assert_eq(GameState.to_snapshot(), snapshot)


func test_client_cannot_mutate() -> void:
	var names := PackedStringArray(["Ada", "Bo"])
	GameState.configure_local_match(names, 1)
	var version := GameState.get_version()
	var tokens := GameState.find_seat(1).tokens
	Network.use_backend(ClientStub.new())
	assert_false(GameState.set_phase(GameState.Phase.BOARD))
	GameState.handle_input(1, {"kind": "grant_token", "seat": 1, "amount": 4})
	assert_eq(GameState.get_version(), version)
	assert_eq(GameState.find_seat(1).tokens, tokens)


func test_host_grants_tokens() -> void:
	GameState.configure_local_match(PackedStringArray(["Ada"]), 1)
	GameState.handle_input(1, {"kind": "grant_token", "seat": 1, "amount": 3})
	assert_eq(GameState.find_seat(1).tokens, 3)


func test_seat_round_trip() -> void:
	var seat := PlayerSeat.new()
	seat.id = 4
	seat.display_name = "North"
	seat.is_bot = true
	seat.tokens = 2
	var restored := PlayerSeat.from_dict(seat.to_dict())
	assert_eq(restored.id, 4)
	assert_eq(restored.display_name, "North")
	assert_true(restored.is_bot)
	assert_eq(restored.tokens, 2)
