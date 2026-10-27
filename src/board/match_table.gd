class_name MatchTable
extends Node

var _prompt: TurnPrompt
var _presenter: BoardPresenter
var _seat_count: int = 3
var _human_count: int = 1
var _row: int = 0
var _shop_index: int = 0


func attach(world: Node3D) -> void:
	_presenter = BoardPresenter.new()
	_presenter.build(world)
	_prompt = TurnPrompt.new()
	_prompt.build(world)
	if not EventBus.snapshot_applied.is_connected(_refresh):
		EventBus.snapshot_applied.connect(_refresh)
	_refresh(GameState.get_version())


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.is_action("view_table") or event.is_action("view_board"):
		return
	if event.is_action("view_keeper") or event.is_action("view_window"):
		return
	var board := GameState.board_view()
	if int(board.get("winner_id", 0)) != 0:
		_result_input(event)
		return
	if not bool(board.get("active", false)):
		_setup_input(event)
		return
	if str(board.get("awaiting", "")) == "shop":
		_shop_input(event, board)
		return
	if str(board.get("awaiting", "")) == "roll" and event.is_action("ui_accept"):
		Network.send_input({"kind": "roll", "seat": int(board.get("turn_seat", 0))})
		get_viewport().set_input_as_handled()


func _setup_input(event: InputEvent) -> void:
	if event.is_action("ui_left"):
		_row = posmod(_row - 1, 3)
	elif event.is_action("ui_right"):
		_row = posmod(_row + 1, 3)
	elif event.is_action("ui_up"):
		_nudge(1)
	elif event.is_action("ui_down"):
		_nudge(-1)
	elif event.is_action("ui_accept"):
		_begin()
	else:
		return
	get_viewport().set_input_as_handled()
	_show_setup()


func _result_input(event: InputEvent) -> void:
	if not event.is_action("ui_accept"):
		return
	_begin()
	get_viewport().set_input_as_handled()


func _shop_input(event: InputEvent, board: Dictionary) -> void:
	var choices := _shop_labels(board)
	if event.is_action("ui_left"):
		_shop_index = posmod(_shop_index - 1, maxi(choices.size(), 1))
	elif event.is_action("ui_right"):
		_shop_index = posmod(_shop_index + 1, maxi(choices.size(), 1))
	elif event.is_action("ui_accept"):
		_send_shop(board)
	else:
		return
	get_viewport().set_input_as_handled()
	_show_turn(board)


func _begin() -> void:
	var names: Array = []
	var bots: Array = []
	var index := 0
	while index < _seat_count:
		var human := index < _human_count
		if human:
			names.append("Seat %d" % [index + 1])
		else:
			names.append("Bot %d" % [index + 1])
		bots.append(not human)
		index += 1
	(
		Network
		. send_input(
			{
				"kind": "start_hotseat",
				"names": names,
				"bots": bots,
				"seed": int(Time.get_ticks_msec() % 100000) + 1,
			}
		)
	)


func _send_shop(board: Dictionary) -> void:
	var ids: Array = board.get("shop_choices", [])
	var item_id := ""
	if _shop_index < ids.size():
		item_id = str(ids[_shop_index])
	(
		Network
		. send_input(
			{
				"kind": "shop",
				"seat": int(board.get("turn_seat", 0)),
				"item": item_id,
			}
		)
	)


func _nudge(step: int) -> void:
	if _row == 0:
		_seat_count = clampi(_seat_count + step, 2, 4)
		_human_count = clampi(_human_count, 1, _seat_count)
		return
	if _row == 1:
		_human_count = clampi(_human_count + step, 1, _seat_count)


func _refresh(_version: int) -> void:
	var board := GameState.board_view()
	_presenter.sync(board)
	if int(board.get("winner_id", 0)) != 0:
		_show_result(board)
		return
	if not bool(board.get("active", false)):
		_show_setup()
		return
	_show_turn(board)


func _show_setup() -> void:
	var bots := _seat_count - _human_count
	var detail := (
		"%d %s, %d %s" % [_human_count, _plural(_human_count, "HUMAN"), bots, _plural(bots, "BOT")]
	)
	_prompt.set_text("HOW MANY SIT", detail)
	(
		_prompt
		. set_choices(
			PackedStringArray(
				[
					"%d SEATS" % _seat_count,
					"%d %s" % [_human_count, _plural(_human_count, "HUMAN")],
					"BEGIN",
				]
			),
			_row,
		)
	)


func _show_turn(board: Dictionary) -> void:
	var seat := GameState.find_seat(int(board.get("turn_seat", 0)))
	var name := "Seat"
	var tokens := 0
	if seat != null:
		name = seat.display_name
		tokens = seat.tokens
	var step := str(board.get("awaiting", "roll"))
	_prompt.set_text("%s   %d TOKENS" % [name, tokens], str(board.get("last_note", "")))
	if step == "shop":
		_prompt.set_choices(_shop_labels(board), _shop_index)
		return
	_prompt.set_choices(PackedStringArray(["ROLL"]), 0)


func _show_result(board: Dictionary) -> void:
	var winner := GameState.find_seat(int(board.get("winner_id", 0)))
	var name := "the table"
	if winner != null:
		name = winner.display_name
	_prompt.set_text("SURVIVOR %s" % name, str(board.get("last_note", "")))
	_prompt.set_choices(PackedStringArray(["AGAIN"]), 0)


func _plural(count: int, word: String) -> String:
	if count == 1:
		return word
	return "%sS" % word


func _shop_labels(board: Dictionary) -> PackedStringArray:
	var labels := PackedStringArray()
	var ids: Array = board.get("shop_choices", [])
	for raw: Variant in ids:
		var item := BoardCatalog.item_by_id(str(raw))
		if item == null:
			labels.append(str(raw))
		else:
			labels.append("%s %d" % [item.title, item.price])
	labels.append("PASS")
	return labels
