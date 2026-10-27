class_name LavaHurdles
extends TrialBody


func build_bot() -> BotController:
	return LavaHurdlesBot.new()


func _make_field() -> TrialField:
	return RaceField.new()


func _card_path() -> String:
	return "res://src/minigames/volcano/lava_hurdles.tres"
