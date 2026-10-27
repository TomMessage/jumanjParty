class_name TrialField
extends RefCounted

var _scores: Dictionary = {}
var _players: Array[int] = []
var _card: TrialCard
var _rng := RandomNumberGenerator.new()


func setup(players: Array[int], seed_value: int, card: TrialCard) -> void:
	_players = players.duplicate()
	_card = card
	_scores.clear()
	var salt := 1
	if card != null:
		salt = card.salt
	_rng.seed = seed_value + salt * 17
	for seat_id: int in _players:
		_scores[seat_id] = 0
	_on_setup()


func scores() -> Dictionary:
	return _scores.duplicate()


func observe(_seat_id: int) -> Dictionary:
	return {}


func apply(_seat_id: int, _action: Dictionary) -> void:
	return


func step(_delta: float) -> void:
	return


func visual() -> Dictionary:
	return {"pawns": [], "hazards": []}


func _on_setup() -> void:
	return


func _gain(seat_id: int, amount: int) -> void:
	_scores[seat_id] = maxi(int(_scores.get(seat_id, 0)) + amount, 0)


func _pace() -> float:
	if _card == null:
		return 1.0
	return maxf(_card.pace, 0.2)


func _pressure() -> float:
	if _card == null:
		return 1.0
	return maxf(_card.pressure, 0.2)
