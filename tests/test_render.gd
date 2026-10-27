extends GutTest


func test_black_image_is_rejected() -> void:
	var image := Image.create(64, 64, false, Image.FORMAT_RGB8)
	image.fill(Color(0, 0, 0))
	assert_ne(ImageGuard.assess(image), "")


func test_flat_image_is_rejected() -> void:
	var image := Image.create(64, 64, false, Image.FORMAT_RGB8)
	image.fill(Color(0.4, 0.4, 0.4))
	assert_ne(ImageGuard.assess(image), "")


func test_varied_image_is_accepted() -> void:
	var image := Image.create(64, 64, false, Image.FORMAT_RGB8)
	for y: int in range(64):
		for x: int in range(64):
			var value := float(x) / 63.0
			image.set_pixel(x, y, Color(value, value * 0.45, 0.05))
	assert_eq(ImageGuard.assess(image), "")


func test_master_off_zeros_post() -> void:
	var params := RenderProfile.post_parameters({"effects_enabled": false, "grain_enabled": true})
	assert_false(bool(params["effects_enabled"]))
	assert_eq(float(params["grain_strength"]), 0.0)
	assert_false(RenderProfile.ps1_enabled({"effects_enabled": false, "ps1_enabled": true}))


func test_grain_can_be_disabled_alone() -> void:
	var params := (
		RenderProfile
		. post_parameters(
			{
				"effects_enabled": true,
				"grain_enabled": false,
				"vignette_enabled": true,
				"dither_enabled": true,
				"chroma_enabled": true,
			}
		)
	)
	assert_eq(float(params["grain_strength"]), 0.0)
	assert_gt(float(params["vignette_strength"]), 0.0)


func test_views_are_distinct() -> void:
	var menu := CameraFraming.aim("menu")
	var board := CameraFraming.aim("board")
	var keeper := CameraFraming.aim("keeper")
	var window := CameraFraming.aim("window")
	assert_ne(menu["origin"], board["origin"])
	assert_ne(keeper["origin"], window["origin"])
	assert_gt(menu["origin"].distance_to(menu["target"]), 0.2)


func test_menu_wraps() -> void:
	var menu := MenuSelection.new()
	menu.move(-1)
	assert_eq(menu.action(), "leave")
	assert_eq(menu.label(), "LEAVE")
	menu.move(1)
	assert_eq(menu.action(), "sit")


func test_toggle_effects_does_not_change_match() -> void:
	var previous := SaveSystem.effects_enabled
	GameState.reset_local_mirror()
	assert_true(GameState.configure_local_match(PackedStringArray(["Ada"]), 1))
	var version := GameState.get_version()
	SaveSystem.toggle_effects()
	assert_eq(GameState.get_version(), version)
	SaveSystem.effects_enabled = previous
	SaveSystem.save_settings()


func test_actions_include_joypad() -> void:
	InputBindings.ensure()
	assert_true(_has_joy("ui_accept"))
	assert_true(_has_joy("view_board"))
	assert_true(InputMap.has_action("view_keeper"))
	assert_true(InputMap.has_action("view_window"))
	assert_true(InputMap.has_action("view_table"))


func _has_joy(action: String) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			return true
	return false
