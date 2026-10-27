class_name CardResolver
extends RefCounted


static func draw(state: MatchState, seats: Array[PlayerSeat], seat: PlayerSeat) -> String:
	if state.deck.is_empty():
		state.deck = BoardCatalog.shuffled_ids(state)
	if state.deck.is_empty():
		return "The deck is blank"
	var card_id := state.deck[0]
	state.deck.remove_at(0)
	state.last_card = card_id
	var card := BoardCatalog.card_by_id(card_id)
	if card == null:
		return "A blank card"
	return _apply(state, seats, seat, card)


static func _apply(
	state: MatchState, seats: Array[PlayerSeat], seat: PlayerSeat, card: EventCard
) -> String:
	var note := card.title
	if card.kind == "all_loss":
		note = _all_loss(state, seats, card.amount)
	elif card.kind == "gain":
		seat.tokens += card.amount
		note = "%s gains %d" % [seat.display_name, card.amount]
	elif card.kind == "swap_back":
		note = PawnMover.swap_with(state, seats, seat, -1)
	elif card.kind == "gift_item":
		note = _gift_item(state, seat)
	elif card.kind == "skip":
		var skipped := state.index_of(seat.id)
		if skipped >= 0:
			state.skip[skipped] = true
		note = "%s will sit out" % seat.display_name
	elif card.kind == "gift_poor":
		note = _gift_poor(seats, seat, card.amount)
	return "%s. %s" % [card.title, note]


static func _all_loss(state: MatchState, seats: Array[PlayerSeat], amount: int) -> String:
	for seated: PlayerSeat in seats:
		SeatInventory.apply_loss(state, seated, amount)
	return "Everyone pays %d" % amount


static func _gift_item(state: MatchState, seat: PlayerSeat) -> String:
	if SeatInventory.add_item(state, seat.id, "pip"):
		return "%s pockets a pip" % seat.display_name
	seat.tokens += 1
	return "%s finds a spare token" % seat.display_name


static func _gift_poor(seats: Array[PlayerSeat], seat: PlayerSeat, amount: int) -> String:
	var poorest: PlayerSeat = null
	for other: PlayerSeat in seats:
		if other.id == seat.id:
			continue
		if poorest == null or other.tokens < poorest.tokens:
			poorest = other
		elif other.tokens == poorest.tokens and other.id < poorest.id:
			poorest = other
	if poorest == null:
		return "No one is poorer"
	poorest.tokens += amount
	return "%s receives %d" % [poorest.display_name, amount]
