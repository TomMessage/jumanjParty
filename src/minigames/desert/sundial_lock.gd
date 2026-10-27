class_name SundialLock
extends TrialBody


func build_bot() -> BotController:
	return SundialLockBot.new()


func _make_field() -> TrialField:
	return PuzzleField.new()


func _card_path() -> String:
	return "res://src/minigames/desert/sundial_lock.tres"
