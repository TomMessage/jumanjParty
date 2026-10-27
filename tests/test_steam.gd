extends GutTest

var _backend: INetwork


func before_each() -> void:
	_backend = Network.get_backend()
	SteamDeeds.clear_local()
	SteamPresence.clear_local()
	GameState.reset_local_mirror()


func after_each() -> void:
	var current := Network.get_backend()
	if current != _backend and (current is ENetNetwork or current is SteamNetwork):
		current.close_session()
	Network.use_backend(_backend)
	GameState.reset_local_mirror()
	SteamDeeds.clear_local()
	SteamPresence.clear_local()


func test_steam_request_falls_back_to_a_local_night() -> void:
	var used := Network.open_transport("steam", 0)
	assert_eq(used, "local")
	assert_eq(Network.transport_name(), "local")
	assert_true(Network.is_host())
	assert_false(SteamRuntime.ready())
	assert_true(Network.transport_note().contains("Fell back to local"))
	var action := {
		"kind": "start_hotseat",
		"names": ["Ada", "Bo"],
		"seed": 3,
		"turns_each": 1,
		"bots": [true, true],
	}
	GameState.handle_input(1, action)
	assert_eq(GameState.get_phase(), GameState.Phase.RESULTS)
	var board: Dictionary = GameState.board_view()
	assert_false(str(board["trial_id"]).is_empty())
	var ranking: Array = board["ranking"]
	assert_eq(ranking.size(), 2)
	assert_eq(SteamDeeds.stored_count(), 0)
	assert_false(SteamDeeds.granted(SteamDeeds.FIRST_NIGHT))
	assert_true(SteamDeeds.pending_has(SteamDeeds.FIRST_NIGHT))
	assert_false(SteamPresence.published())
	assert_eq(SteamPresence.last_status(), "Counting the tokens")
	var snapshot := GameState.to_snapshot()
	GameState.apply_snapshot(snapshot)
	assert_eq(GameState.to_snapshot(), snapshot)


func test_steam_request_falls_back_to_enet() -> void:
	var port := 40000 + (OS.get_process_id() % 20000)
	var used := Network.open_transport("steam", port)
	assert_eq(used, "enet")
	assert_true(Network.get_backend() is ENetNetwork)
	assert_true(Network.is_host())
	assert_false(SteamRuntime.ready())
	assert_true(Network.transport_note().contains("Fell back to ENet"))
	var backend := Network.get_backend()
	if backend is ENetNetwork:
		(backend as ENetNetwork).close_session()
	await get_tree().process_frame
	assert_eq(Network.open_transport("local", 0), "local")


func test_join_without_steam_stays_local() -> void:
	assert_eq(Network.connect_steam(99), ERR_UNAVAILABLE)
	assert_eq(Network.transport_name(), "local")
	assert_true(Network.is_host())
	assert_true(Network.transport_note().contains("Fell back to local"))
	assert_eq(Network.connect_steam(0), ERR_UNAVAILABLE)
	assert_eq(Network.transport_name(), "local")
	assert_true(Network.transport_note().contains("lobby id"))


func test_invite_is_refused_on_the_fallback() -> void:
	assert_eq(Network.open_transport("steam", 0), "local")
	assert_eq(Network.open_invite(12, false), ERR_UNAVAILABLE)
	assert_eq(Network.open_invite(0, true), ERR_UNAVAILABLE)
	var steam := SteamNetwork.new()
	assert_eq(steam.invite(12, true), ERR_UNAVAILABLE)
	assert_false(steam.relay_open())
	assert_eq(steam.lobby_id(), 0)


func test_deeds_stay_pending_offline() -> void:
	var seats: Array = [{"id": 1}, {"id": 2}, {"id": 3}, {"id": 4}]
	var snapshot := {
		"phase": GameState.Phase.RESULTS,
		"seats": seats,
		"board": {"winner_id": 1, "ranking": [1, 2, 3, 4]},
	}
	SteamDeeds.consider(snapshot, 1)
	assert_eq(SteamDeeds.stored_count(), 0)
	assert_true(SteamDeeds.pending_has(SteamDeeds.FIRST_NIGHT))
	assert_true(SteamDeeds.pending_has(SteamDeeds.TRIAL_CROWN))
	assert_true(SteamDeeds.pending_has(SteamDeeds.TABLE_SURVIVOR))
	assert_true(SteamDeeds.pending_has(SteamDeeds.FULL_TABLE))
	assert_false(SteamDeeds.granted(SteamDeeds.FIRST_NIGHT))
	assert_false(SteamDeeds.unlock("NOT_A_DEED"))
	assert_false(SteamDeeds.pending_has("NOT_A_DEED"))


func test_presence_is_not_published() -> void:
	assert_false(SteamPresence.note(GameState.Phase.TRIAL, "+connect_lobby 1"))
	assert_false(SteamPresence.published())
	assert_eq(SteamPresence.last_status(), "Inside a trial")
	assert_eq(SteamPresence.last_display(), "#InsideATrial")
	assert_eq(SteamPresence.last_connect(), "+connect_lobby 1")
	assert_false(SteamPresence.note(GameState.Phase.MENU, ""))
	assert_eq(SteamPresence.last_status(), "At the table")
	assert_eq(SteamPresence.last_display(), "#AtTheTable")


func test_lobby_id_from_connect_argument() -> void:
	var args := PackedStringArray(["--headless", "+connect_lobby", "42"])
	assert_eq(SteamRuntime.lobby_from_args(args), 42)
	var glued := PackedStringArray(["+connect_lobby=77"])
	assert_eq(SteamRuntime.lobby_from_args(glued), 77)
	var junk := PackedStringArray(["+connect_lobby", "nope", "--path"])
	assert_eq(SteamRuntime.lobby_from_args(junk), 0)
	assert_eq(SteamRuntime.lobby_from_args(PackedStringArray()), 0)
