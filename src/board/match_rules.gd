class_name MatchRules
extends RefCounted

var state: MatchState = MatchState.new()


func begin(seats: Array[PlayerSeat], seed_value: int, turns_each: int = 3) -> void:
	state = MatchState.new()
	state.turns_each = maxi(turns_each, 0)
	state.rng_seed = seed_value
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	state.rng_state = rng.state
	var ids: Array[int] = []
	for seat: PlayerSeat in seats:
		ids.append(seat.id)
	ids.sort()
	state.seat_ids = ids
	for _id: int in ids:
		state.positions.append(0)
		state.skip.append(false)
		state.items.append(PackedStringArray())
	if ids.is_empty():
		return
	state.deck = BoardCatalog.shuffled_ids(state)
	if state.turns_each == 0:
		_finish(seats)
		return
	state.active = true
	state.awaiting = "roll"
	state.turn_seat = ids[0]
	state.last_note = "The board wakes"


func roll(seats: Array[PlayerSeat], seat_id: int, forced_face: int = -1) -> bool:
	if not _can_act(seat_id, "roll"):
		return false
	var seat := _seat(seats, seat_id)
	if seat == null:
		return false
	var face := forced_face
	if face < 1:
		face = _next_face()
	if SeatInventory.consume(state, seat_id, "pip"):
		face += 1
	var steps := face
	var leaped := SeatInventory.consume(state, seat_id, "leap")
	if leaped:
		steps += 1
	state.die_face = face
	PawnMover.advance(state, seat, steps)
	var space := BoardCatalog.space_at(state.positions[state.index_of(seat_id)])
	var note := SpaceResolver.apply(state, seats, seat, space)
	state.last_note = "%s rolls %d. %s" % [seat.display_name, face, note]
	if leaped:
		state.last_note = "%s rolls %d and leaps. %s" % [seat.display_name, face, note]
	if space.kind == "shop":
		return _open_shop(seats, seat)
	_enter_trial(seats)
	return true


func shop(seats: Array[PlayerSeat], seat_id: int, item_id: String) -> bool:
	if not _can_act(seat_id, "shop"):
		return false
	var seat := _seat(seats, seat_id)
	if seat == null:
		return false
	if item_id != "":
		if not state.shop_choices.has(item_id):
			return false
		if not SeatInventory.try_buy(state, seat, item_id):
			return false
		var bought := BoardCatalog.item_by_id(item_id)
		state.last_note = "%s buys %s" % [seat.display_name, bought.title]
	else:
		state.last_note = "%s leaves the shop" % seat.display_name
	state.shop_choices = []
	_enter_trial(seats)
	return true


func resolve_trial(seats: Array[PlayerSeat]) -> bool:
	if not TrialNight.resolve(state, seats):
		return false
	_complete_turn(seats)
	return true


func pump(seats: Array[PlayerSeat]) -> void:
	var guard := 0
	while state.active and guard < 160:
		guard += 1
		if state.awaiting == "trial":
			if not resolve_trial(seats):
				return
			continue
		var seat := _seat(seats, state.turn_seat)
		if seat == null or not seat.is_bot:
			return
		if state.awaiting == "roll" and not roll(seats, seat.id, -1):
			return
		if state.awaiting != "shop":
			continue
		var pick := BotPolicy.choose_item(state, seat)
		if not state.shop_choices.has(pick):
			pick = ""
		if not shop(seats, seat.id, pick):
			return


func is_finished() -> bool:
	return state.winner_id != 0


func _can_act(seat_id: int, step: String) -> bool:
	if not state.active or state.awaiting != step:
		return false
	return state.turn_seat == seat_id


func _open_shop(seats: Array[PlayerSeat], seat: PlayerSeat) -> bool:
	var index := state.index_of(seat.id)
	var offers := BoardCatalog.offers_for(seat.tokens, state.items[index])
	if offers.is_empty():
		state.last_note += " The shop is shut."
		_enter_trial(seats)
		return true
	state.awaiting = "shop"
	state.shop_choices = offers
	return true


func _next_face() -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = state.rng_seed
	rng.state = state.rng_state
	var face := rng.randi_range(1, 6)
	state.rng_state = rng.state
	return face


func _enter_trial(seats: Array[PlayerSeat]) -> void:
	state.shop_choices = []
	if TrialNight.queue(state):
		return
	_complete_turn(seats)


func _complete_turn(seats: Array[PlayerSeat]) -> void:
	state.shop_choices = []
	state.turns_taken += 1
	if state.turns_taken >= state.seat_ids.size() * state.turns_each:
		_finish(seats)
		return
	_advance_seat()
	_open_turn(seats)


func _open_turn(seats: Array[PlayerSeat]) -> void:
	var guard := 0
	var limit := state.seat_ids.size() + 1
	while state.active and guard < limit:
		guard += 1
		var index := state.index_of(state.turn_seat)
		if index < 0 or not state.skip[index]:
			state.awaiting = "roll"
			return
		state.skip[index] = false
		var seat := _seat(seats, state.turn_seat)
		var who := "Someone"
		if seat != null:
			who = seat.display_name
		state.last_note = "%s sits this one out" % who
		state.turns_taken += 1
		if state.turns_taken >= state.seat_ids.size() * state.turns_each:
			_finish(seats)
			return
		_advance_seat()
	state.awaiting = "roll"


func _advance_seat() -> void:
	var index := state.index_of(state.turn_seat)
	var next := posmod(index + 1, state.seat_ids.size())
	state.turn_seat = state.seat_ids[next]


func _finish(seats: Array[PlayerSeat]) -> void:
	state.active = false
	state.awaiting = "done"
	state.shop_choices = []
	var best_id := 0
	var best_tokens := -1
	for seat: PlayerSeat in seats:
		var richer := seat.tokens > best_tokens
		var tie := seat.tokens == best_tokens and (best_id == 0 or seat.id < best_id)
		if richer or tie:
			best_tokens = seat.tokens
			best_id = seat.id
	state.winner_id = best_id
	var winner := _seat(seats, best_id)
	var name := "the table"
	if winner != null:
		name = winner.display_name
	state.last_note = "The night keeps %s" % name


func _seat(seats: Array[PlayerSeat], seat_id: int) -> PlayerSeat:
	for seat: PlayerSeat in seats:
		if seat.id == seat_id:
			return seat
	return null
