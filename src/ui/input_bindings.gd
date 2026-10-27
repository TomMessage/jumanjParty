class_name InputBindings
extends RefCounted


static func ensure() -> void:
	_ensure_action("view_table", KEY_1, JOY_BUTTON_LEFT_SHOULDER)
	_ensure_action("view_board", KEY_2, JOY_BUTTON_RIGHT_SHOULDER)
	_ensure_keeper()
	_ensure_action("view_window", KEY_4, JOY_BUTTON_X)
	_ensure_joy("ui_accept", JOY_BUTTON_A)
	_ensure_joy("ui_cancel", JOY_BUTTON_B)
	_ensure_joy("ui_left", JOY_BUTTON_DPAD_LEFT)
	_ensure_joy("ui_right", JOY_BUTTON_DPAD_RIGHT)
	_ensure_joy("ui_up", JOY_BUTTON_DPAD_UP)
	_ensure_joy("ui_down", JOY_BUTTON_DPAD_DOWN)


static func _ensure_action(action: String, keycode: Key, button: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	_add_key(action, keycode)
	_add_joy(action, button)


static func rebind_key(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var kept: Array[InputEvent] = []
	for event: InputEvent in InputMap.action_get_events(action):
		if not event is InputEventKey:
			kept.append(event)
	InputMap.action_erase_events(action)
	for kept_event: InputEvent in kept:
		InputMap.action_add_event(action, kept_event)
	_add_key(action, keycode)


static func has_key(action: String, keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).keycode == keycode:
			return true
	return false


static func apply_keeper() -> void:
	var keycode := KEY_3
	if SaveSystem.keeper_key != 0:
		keycode = SaveSystem.keeper_key as Key
	rebind_key("view_keeper", keycode)
	_add_joy("view_keeper", JOY_BUTTON_Y)


static func _ensure_keeper() -> void:
	if not InputMap.has_action("view_keeper"):
		InputMap.add_action("view_keeper")
	_add_joy("view_keeper", JOY_BUTTON_Y)
	if _any_key("view_keeper"):
		return
	var keycode := KEY_3
	if SaveSystem.keeper_key != 0:
		keycode = SaveSystem.keeper_key as Key
	_add_key("view_keeper", keycode)


static func _any_key(action: String) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			return true
	return false


static func _ensure_joy(action: String, button: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	_add_joy(action, button)


static func _add_key(action: String, keycode: Key) -> void:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).keycode == keycode:
			return
	var key := InputEventKey.new()
	key.keycode = keycode
	InputMap.action_add_event(action, key)


static func _add_joy(action: String, button: JoyButton) -> void:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			var joy := event as InputEventJoypadButton
			if joy.button_index == button:
				return
	var joy_event := InputEventJoypadButton.new()
	joy_event.button_index = button
	InputMap.action_add_event(action, joy_event)
