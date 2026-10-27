class_name WorstMoment
extends RefCounted


static func consider(
	state: MatchState, seat_id: int, kind: String, score: int, line: String, scene_path: String
) -> void:
	if score <= 0 or score < state.worst_score:
		return
	state.worst_score = score
	state.worst_seat = seat_id
	state.worst_kind = kind
	state.worst_line = line
	state.worst_scene = scene_path
