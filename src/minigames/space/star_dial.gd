class_name StarDial
extends TrialBody


func build_bot() -> BotController:
	return StarDialBot.new()


func _make_field() -> TrialField:
	return PuzzleField.new()


func _card_path() -> String:
	return "res://src/minigames/space/star_dial.tres"
