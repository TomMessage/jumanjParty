class_name SeatInventory
extends RefCounted


static func has_item(state: MatchState, seat_id: int, item_id: String) -> bool:
	var index := state.index_of(seat_id)
	if index < 0:
		return false
	return state.items[index].has(item_id)


static func consume(state: MatchState, seat_id: int, item_id: String) -> bool:
	var index := state.index_of(seat_id)
	if index < 0:
		return false
	var row := state.items[index]
	var found := row.find(item_id)
	if found < 0:
		return false
	row.remove_at(found)
	state.items[index] = row
	return true


static func add_item(state: MatchState, seat_id: int, item_id: String) -> bool:
	var index := state.index_of(seat_id)
	if index < 0:
		return false
	var row := state.items[index]
	if row.size() >= 2:
		return false
	row.append(item_id)
	state.items[index] = row
	return true


static func apply_loss(state: MatchState, seat: PlayerSeat, amount: int) -> int:
	if consume(state, seat.id, "shield"):
		return 0
	var lost := mini(amount, seat.tokens)
	seat.tokens -= lost
	return lost


static func try_buy(state: MatchState, seat: PlayerSeat, item_id: String) -> bool:
	var item := BoardCatalog.item_by_id(item_id)
	if item == null:
		return false
	if seat.tokens < item.price:
		return false
	if not add_item(state, seat.id, item_id):
		return false
	seat.tokens -= item.price
	return true
