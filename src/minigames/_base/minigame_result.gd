class_name MinigameResult
extends RefCounted

var rankings: Array[int] = []
var scores: Dictionary = {}
var duration_seconds: float = 0.0


static func from_scores(raw_scores: Dictionary, duration: float) -> MinigameResult:
	var result := MinigameResult.new()
	result.duration_seconds = duration
	result.scores = raw_scores.duplicate()
	result.rankings = _sorted_ids(raw_scores)
	return result


func is_valid(expected_ids: Array[int]) -> bool:
	if rankings.size() != expected_ids.size():
		return false
	if duration_seconds < 30.0 or duration_seconds > 90.0:
		return false
	for seat_id: int in expected_ids:
		if not rankings.has(seat_id) or not scores.has(seat_id):
			return false
	return true


static func _sorted_ids(raw_scores: Dictionary) -> Array[int]:
	var ids: Array[int] = []
	for key: Variant in raw_scores.keys():
		ids.append(int(key))
	var index := 1
	while index < ids.size():
		var current := ids[index]
		var previous := index - 1
		while previous >= 0 and _worse(ids[previous], current, raw_scores):
			ids[previous + 1] = ids[previous]
			previous -= 1
		ids[previous + 1] = current
		index += 1
	return ids


static func _worse(left: int, right: int, raw_scores: Dictionary) -> bool:
	var left_score := int(raw_scores[left])
	var right_score := int(raw_scores[right])
	if left_score == right_score:
		return left > right
	return left_score < right_score
