class_name PawnMover
extends RefCounted


static func advance(state: MatchState, seat: PlayerSeat, steps: int) -> void:
	var index := state.index_of(seat.id)
	if index < 0:
		return
	var pos := state.positions[index]
	var step := 0
	while step < steps:
		pos = posmod(pos + 1, BoardCatalog.LOOP)
		if pos == 0:
			seat.tokens += 1
		step += 1
	state.positions[index] = pos


static func swap_with(
	state: MatchState, seats: Array[PlayerSeat], seat: PlayerSeat, offset: int
) -> String:
	var index := state.index_of(seat.id)
	var count := state.seat_ids.size()
	if index < 0 or count == 0:
		return "The pawns stay put"
	var other_index := posmod(index + offset, count)
	var other := _find(seats, state.seat_ids[other_index])
	var tmp := state.positions[index]
	state.positions[index] = state.positions[other_index]
	state.positions[other_index] = tmp
	if other == null:
		return "%s slides along the loop" % seat.display_name
	return "%s swaps with %s" % [seat.display_name, other.display_name]


static func _find(seats: Array[PlayerSeat], seat_id: int) -> PlayerSeat:
	for seat: PlayerSeat in seats:
		if seat.id == seat_id:
			return seat
	return null
