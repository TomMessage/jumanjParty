class_name TrialNight
extends RefCounted

const FIRST_PRIZE := 3


static func queue(state: MatchState) -> bool:
	var cards := TrialCatalog.cards()
	var count := cards.size()
	if count == 0:
		return false
	var card := cards[_index(state, count)]
	state.awaiting = "trial"
	state.trial_id = card.trial_id
	state.trial_scene = card.scene_path
	state.trial_seed = _seed_for(state)
	state.ranking = []
	return true


static func resolve(state: MatchState, seats: Array[PlayerSeat]) -> bool:
	if state.awaiting != "trial":
		return false
	var players := _ids(seats)
	var result := play(state.trial_id, players, state.trial_seed)
	var ranking := _ranking_or_ids(result, players)
	state.ranking = ranking
	_pay(seats, ranking)
	state.last_note = _note(state.trial_id, ranking, seats)
	_remember_last(state, seats, ranking)
	return true


static func play(trial_id: String, players: Array[int], seed_value: int) -> MinigameResult:
	var card := _find(trial_id)
	if card == null or players.is_empty():
		return null
	var trial := _spawn(card)
	if trial == null:
		return null
	trial.start_trial(players, seed_value)
	var ticks := 0
	while trial.is_running() and ticks < 2000:
		trial.tick(0.1)
		ticks += 1
	var result := trial.latest_result()
	trial.free()
	return result


static func _index(state: MatchState, count: int) -> int:
	var mixed := absi(state.rng_seed * 31 + state.turns_taken * 17 + 5)
	return mixed % count


static func _seed_for(state: MatchState) -> int:
	return absi(state.rng_seed * 1009 + state.turns_taken * 13 + 11)


static func _find(trial_id: String) -> TrialCard:
	for card: TrialCard in TrialCatalog.cards():
		if card.trial_id == trial_id:
			return card
	return null


static func _spawn(card: TrialCard) -> MinigameBase:
	var loaded: Variant = load(card.script_path)
	if not loaded is Script:
		return null
	var node: Variant = (loaded as Script).new()
	if node is MinigameBase:
		return node as MinigameBase
	if node is Node:
		(node as Node).free()
	return null


static func _ids(seats: Array[PlayerSeat]) -> Array[int]:
	var players: Array[int] = []
	for seat: PlayerSeat in seats:
		players.append(seat.id)
	return players


static func _ranking_or_ids(result: MinigameResult, players: Array[int]) -> Array[int]:
	if result != null and result.is_valid(players):
		return result.rankings.duplicate()
	return players.duplicate()


static func _pay(seats: Array[PlayerSeat], ranking: Array[int]) -> void:
	var place := 0
	for seat_id: int in ranking:
		var prize := maxi(FIRST_PRIZE - place, 0)
		var seat := _seat(seats, seat_id)
		if seat != null and prize > 0:
			seat.tokens += prize
		place += 1


static func _remember_last(
	state: MatchState, seats: Array[PlayerSeat], ranking: Array[int]
) -> void:
	if ranking.size() < 2:
		return
	var last_id := ranking[ranking.size() - 1]
	var title := state.trial_id
	var card := _find(state.trial_id)
	if card != null:
		title = card.title
	var line := "%s finishes last in %s." % [_seat_name(seats, last_id), title]
	WorstMoment.consider(state, last_id, "last", 4, line, state.trial_scene)


static func _note(trial_id: String, ranking: Array[int], seats: Array[PlayerSeat]) -> String:
	var title := trial_id
	var card := _find(trial_id)
	if card != null:
		title = card.title
	var names := PackedStringArray()
	for seat_id: int in ranking:
		names.append(_seat_name(seats, seat_id))
	return "%s ranks %s" % [title, ", ".join(names)]


static func _seat_name(seats: Array[PlayerSeat], seat_id: int) -> String:
	var seat := _seat(seats, seat_id)
	if seat == null:
		return str(seat_id)
	return seat.display_name


static func _seat(seats: Array[PlayerSeat], seat_id: int) -> PlayerSeat:
	for seat: PlayerSeat in seats:
		if seat.id == seat_id:
			return seat
	return null
