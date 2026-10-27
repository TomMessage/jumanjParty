class_name StingLanes
extends TrialBody


func build_bot() -> BotController:
	return StingLanesBot.new()


func _make_field() -> TrialField:
	return DodgeField.new()


func _card_path() -> String:
	return "res://src/minigames/desert/sting_lanes.tres"
