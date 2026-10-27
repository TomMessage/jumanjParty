class_name BoardMood
extends RefCounted


static func apply(state: MatchState, seats: Array[PlayerSeat]) -> void:
	var events := PackedStringArray(["candles", "tremor", "draft"])
	var mixed := absi(state.rng_seed * 3 + state.turns_taken * 5 + 1)
	state.board_event = events[mixed % events.size()]
	var pocket_line := ""
	if state.turns_taken > 0 and state.turns_taken % 4 == 0:
		pocket_line = KeeperCheat.pocket(state, seats)
	var slide_line := ""
	if state.turns_taken > 0 and state.turns_taken % 5 == 0:
		slide_line = _slide(state, seats)
	state.keeper_line = KeeperLines.pick(state.board_event, state.rng_seed, state.turns_taken)
	if slide_line != "":
		state.keeper_line = slide_line
	if pocket_line != "":
		state.keeper_line = pocket_line


static func _slide(state: MatchState, seats: Array[PlayerSeat]) -> String:
	var index := state.index_of(state.turn_seat)
	if index < 0 or state.positions[index] <= 0:
		return ""
	state.positions[index] -= 1
	var line := "The board slides %s back a space." % _name(seats, state.turn_seat)
	WorstMoment.consider(state, state.turn_seat, "slide", 2, line, "")
	return line


static func _name(seats: Array[PlayerSeat], seat_id: int) -> String:
	for seat: PlayerSeat in seats:
		if seat.id == seat_id:
			return seat.display_name
	return "Someone"
