class_name SpaceResolver
extends RefCounted


static func apply(
	state: MatchState, seats: Array[PlayerSeat], seat: PlayerSeat, space: BoardSpace
) -> String:
	var note := "%s is home" % seat.display_name
	if space.kind == "gain":
		seat.tokens += space.amount
		note = "%s gains %d" % [seat.display_name, space.amount]
	if space.kind == "loss":
		note = _loss(state, seat, space.amount)
	if space.kind == "trap":
		var trapped := state.index_of(seat.id)
		if trapped >= 0:
			state.skip[trapped] = true
		note = "%s is caught" % seat.display_name
	if space.kind == "swap":
		note = PawnMover.swap_with(state, seats, seat, 1)
	if space.kind == "event":
		note = CardResolver.draw(state, seats, seat)
	if space.kind == "shop":
		note = "%s finds the shop" % seat.display_name
	return note


static func _loss(state: MatchState, seat: PlayerSeat, amount: int) -> String:
	var shielded := SeatInventory.has_item(state, seat.id, "shield")
	var lost := SeatInventory.apply_loss(state, seat, amount)
	if shielded:
		return "%s raises a shield" % seat.display_name
	return "%s loses %d" % [seat.display_name, lost]
