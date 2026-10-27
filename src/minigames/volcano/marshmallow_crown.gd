class_name MarshmallowCrown
extends TrialBody


func build_bot() -> BotController:
	return MarshmallowCrownBot.new()


func _make_field() -> TrialField:
	return AbsurdField.new()


func _card_path() -> String:
	return "res://src/minigames/volcano/marshmallow_crown.tres"
