extends GutTest

var _backend: INetwork
var _path: String
var _intensity: float
var _contrast: bool
var _motion: bool
var _scale: float
var _key: int


func before_each() -> void:
	_backend = Network.get_backend()
	var local := LocalNetwork.new()
	Network.use_backend(local)
	local.start_host(0)
	GameState.reset_local_mirror()
	_path = SaveSystem.settings_path
	_intensity = SaveSystem.effect_intensity
	_contrast = SaveSystem.high_contrast
	_motion = SaveSystem.reduce_motion
	_scale = SaveSystem.text_scale
	_key = SaveSystem.keeper_key
	SaveSystem.settings_path = "user://test_keeper.cfg"


func after_each() -> void:
	SaveSystem.effect_intensity = _intensity
	SaveSystem.high_contrast = _contrast
	SaveSystem.reduce_motion = _motion
	SaveSystem.text_scale = _scale
	SaveSystem.keeper_key = _key
	SaveSystem.settings_path = _path
	InputBindings.apply_keeper()
	SaveSystem.save_settings()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_keeper.cfg"))
	Network.use_backend(_backend)
	GameState.reset_local_mirror()


func test_turn_four_pockets_the_richest() -> void:
	var state := _mood_state(4, 0)
	var seats := _players()
	seats[0].tokens = 2
	seats[1].tokens = 5
	var rng := state.rng_state
	BoardMood.apply(state, seats)
	assert_eq(seats[1].tokens, 4)
	assert_eq(seats[0].tokens, 2)
	assert_eq(state.rng_state, rng)
	assert_true(_events().has(state.board_event))
	assert_ne(state.keeper_line, "")
	assert_eq(state.worst_kind, "cheat")


func test_turn_five_slides_back() -> void:
	var state := _mood_state(5, 3)
	var seats := _players()
	seats[0].tokens = 1
	seats[1].tokens = 1
	BoardMood.apply(state, seats)
	assert_eq(state.positions[0], 2)
	assert_eq(seats[0].tokens, 1)
	assert_eq(seats[1].tokens, 1)
	assert_ne(state.keeper_line.find("slides"), -1)
	assert_ne(state.worst_kind, "cheat")


func test_pocket_wins_when_the_board_also_slides() -> void:
	var state := _mood_state(20, 4)
	var seats := _players()
	seats[0].tokens = 3
	seats[1].tokens = 1
	var rng := state.rng_state
	BoardMood.apply(state, seats)
	assert_eq(state.positions[0], 3)
	assert_eq(seats[0].tokens, 2)
	assert_eq(state.rng_state, rng)
	assert_ne(state.keeper_line.find("pockets"), -1)


func test_later_equal_failure_replaces() -> void:
	var state := MatchState.new()
	WorstMoment.consider(state, 1, "trap", 3, "first", "res://a.tscn")
	WorstMoment.consider(state, 2, "cheat", 2, "weaker", "res://b.tscn")
	assert_eq(state.worst_line, "first")
	assert_eq(state.worst_scene, "res://a.tscn")
	WorstMoment.consider(state, 2, "loss", 3, "second", "")
	assert_eq(state.worst_line, "second")
	assert_eq(state.worst_seat, 2)
	assert_eq(state.worst_scene, "")
	WorstMoment.consider(state, 1, "last", 4, "harder", "")
	assert_eq(state.worst_line, "harder")
	assert_eq(state.worst_scene, "")


func test_options_do_not_change_the_night() -> void:
	SaveSystem.effect_intensity = 0.0
	SaveSystem.high_contrast = true
	SaveSystem.reduce_motion = true
	SaveSystem.text_scale = 1.5
	SaveSystem.save_settings()
	var changed := _night(9)
	SaveSystem.effect_intensity = 1.0
	SaveSystem.high_contrast = false
	SaveSystem.reduce_motion = false
	SaveSystem.text_scale = 1.0
	SaveSystem.save_settings()
	_rehost()
	var plain := _night(9)
	assert_eq(changed["board"], plain["board"])
	assert_eq(changed["seats"], plain["seats"])
	var board: Dictionary = plain["board"]
	assert_ne(str(board["keeper_line"]), "")
	assert_ne(str(board["worst_line"]), "")
	assert_gt(int(board["worst_score"]), 0)
	assert_true(Audio.voice_ready)
	assert_ne(Audio.last_spoken, "")
	assert_true(Audio.ambience_on())
	assert_eq(Audio.music_layer_bus(), "Music")


func test_intensity_scales_post_and_can_zero_it() -> void:
	var full := _post(1.0, true)
	var half := _post(0.5, true)
	assert_almost_eq(
		float(half["vignette_strength"]), float(full["vignette_strength"]) * 0.5, 0.0001
	)
	var dark := _post(0.0, true)
	assert_eq(float(dark["grain_strength"]), 0.0)
	var off := _post(1.0, false)
	assert_eq(float(off["grain_strength"]), 0.0)
	assert_eq(float(off["vignette_strength"]), 0.0)


func test_rebind_keeps_the_joypad() -> void:
	InputBindings.ensure()
	InputBindings.rebind_key("view_keeper", KEY_5)
	InputBindings.ensure()
	assert_true(InputBindings.has_key("view_keeper", KEY_5))
	assert_false(InputBindings.has_key("view_keeper", KEY_3))
	assert_true(_has_joy("view_keeper"))
	InputBindings.rebind_key("view_keeper", KEY_3)


func test_lesson_wraps_and_voice_is_not_speech() -> void:
	assert_eq(TableLesson.page(0), TableLesson.page(TableLesson.count()))
	assert_ne(TableLesson.page(0), "")
	var spoken := GibberishVoice.stream_for("The keeper pockets a token.")
	assert_gt(spoken.data.size(), 0)
	assert_eq(GibberishVoice.stream_for("").data.size(), 0)
	var rustle := ToneLoop.rustle()
	assert_eq(rustle.loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_gt(rustle.loop_end, 0)


func test_replay_stamp_is_pure() -> void:
	var ended := {
		"winner_id": 2, "worst_scene": "res://scenes/x.tscn", "trial_scene": "res://other.tscn"
	}
	assert_eq(TrialCurtain.replay_path(ended), "res://scenes/x.tscn")
	assert_eq(TrialCurtain.replay_stamp(ended), "replay:res://scenes/x.tscn")
	var playing := {"winner_id": 0, "worst_scene": "res://scenes/x.tscn"}
	assert_eq(TrialCurtain.replay_path(playing), "")
	assert_eq(TrialCurtain.replay_stamp(playing), "")


func _post(intensity: float, enabled: bool) -> Dictionary:
	return (
		RenderProfile
		. post_parameters(
			{
				"effects_enabled": enabled,
				"grain_enabled": true,
				"vignette_enabled": true,
				"dither_enabled": true,
				"chroma_enabled": true,
				"effect_intensity": intensity,
			}
		)
	)


func _mood_state(turn: int, position: int) -> MatchState:
	var state := MatchState.new()
	state.rng_seed = 3
	state.rng_state = 99
	state.turns_taken = turn
	state.seat_ids = [1, 2]
	state.positions = [position, 0]
	state.turn_seat = 1
	return state


func _events() -> PackedStringArray:
	return PackedStringArray(["candles", "tremor", "draft"])


func _night(seed_value: int) -> Dictionary:
	_start([true, true, true], seed_value)
	return GameState.to_snapshot()


func _rehost() -> void:
	GameState.reset_local_mirror()
	var local := LocalNetwork.new()
	Network.use_backend(local)
	local.start_host(0)


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


func _players() -> Array[PlayerSeat]:
	var seats: Array[PlayerSeat] = []
	var index := 0
	while index < 2:
		var seat := PlayerSeat.new()
		seat.id = index + 1
		seat.display_name = "P%d" % seat.id
		seats.append(seat)
		index += 1
	return seats


func _has_joy(action: String) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			return true
	return false
