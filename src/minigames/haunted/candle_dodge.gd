class_name CandleDodge
extends TrialBody


func build_bot() -> BotController:
	return CandleDodgeBot.new()


func _make_field() -> TrialField:
	return DodgeField.new()


func _card_path() -> String:
	return "res://src/minigames/haunted/candle_dodge.tres"
