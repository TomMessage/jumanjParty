class_name ContractTrial
extends MinigameBase


func planned_ms() -> int:
	return 45000


func _build_result() -> MinigameResult:
	var raw_scores: Dictionary = {}
	var bot := build_bot()
	for seat_id: int in _players:
		var action := bot.choose_action({"seat": seat_id, "seed": _seed})
		raw_scores[seat_id] = int(action.get("effort", 0))
	return MinigameResult.from_scores(raw_scores, float(planned_ms()) / 1000.0)
