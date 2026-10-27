class_name KeeperCheat
extends RefCounted


static func pocket(state: MatchState, seats: Array[PlayerSeat]) -> String:
	var richest := _richest(seats)
	if richest == null:
		return ""
	richest.tokens -= 1
	var line := "The keeper pockets a token from %s." % richest.display_name
	WorstMoment.consider(state, richest.id, "cheat", 3, line, "")
	return line


static func _richest(seats: Array[PlayerSeat]) -> PlayerSeat:
	var richest: PlayerSeat = null
	for seat: PlayerSeat in seats:
		if seat.tokens <= 0:
			continue
		if _prefer(seat, richest):
			richest = seat
	return richest


static func _prefer(seat: PlayerSeat, richest: PlayerSeat) -> bool:
	if richest == null:
		return true
	if seat.tokens > richest.tokens:
		return true
	return seat.tokens == richest.tokens and seat.id < richest.id
