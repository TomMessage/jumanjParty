extends GutTest


func test_local_broadcast_keeps_snapshot() -> void:
	var net := LocalNetwork.new()
	assert_eq(net.start_host(0), OK)
	assert_true(net.is_host())
	assert_eq(net.get_peer_id(), 1)
	net.broadcast_state({"version": 3, "seats": []})
	assert_eq(int(net.last_snapshot()["version"]), 3)


func test_local_client_does_not_broadcast() -> void:
	var net := LocalNetwork.new()
	net.broadcast_state({"version": 1})
	assert_eq(net.last_snapshot().size(), 0)


func test_steam_is_unavailable() -> void:
	var steam := SteamNetwork.new()
	assert_eq(steam.start_host(1), ERR_UNAVAILABLE)
	assert_eq(steam.start_client("127.0.0.1", 1), ERR_UNAVAILABLE)
	assert_false(steam.is_host())
	assert_false(SteamRuntime.ready())
	assert_false(steam.relay_open())
	assert_eq(steam.current_lobby(), 0)
	assert_false(steam.blocker().is_empty())
	assert_eq(steam.blocker(), SteamRuntime.reason())
