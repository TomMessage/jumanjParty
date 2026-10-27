class_name BeetleRain
extends TrialBody


func build_bot() -> BotController:
	return BeetleRainBot.new()


func _make_field() -> TrialField:
	return WaveField.new()


func _card_path() -> String:
	return "res://src/minigames/jungle/beetle_rain.tres"
