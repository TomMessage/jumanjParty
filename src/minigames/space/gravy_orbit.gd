class_name GravyOrbit
extends TrialBody


func build_bot() -> BotController:
	return GravyOrbitBot.new()


func _make_field() -> TrialField:
	return AbsurdField.new()


func _card_path() -> String:
	return "res://src/minigames/space/gravy_orbit.tres"
