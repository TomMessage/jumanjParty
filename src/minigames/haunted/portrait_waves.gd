class_name PortraitWaves
extends TrialBody


func build_bot() -> BotController:
	return PortraitWavesBot.new()


func _make_field() -> TrialField:
	return WaveField.new()


func _card_path() -> String:
	return "res://src/minigames/haunted/portrait_waves.tres"
