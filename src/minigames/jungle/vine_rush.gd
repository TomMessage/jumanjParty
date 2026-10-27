class_name VineRush
extends TrialBody


func build_bot() -> BotController:
	return VineRushBot.new()


func _make_field() -> TrialField:
	return RaceField.new()


func _card_path() -> String:
	return "res://src/minigames/jungle/vine_rush.tres"
