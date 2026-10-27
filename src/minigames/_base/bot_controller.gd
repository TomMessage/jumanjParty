class_name BotController
extends RefCounted


func choose_action(observation: Dictionary) -> Dictionary:
	var seat := int(observation.get("seat", 0))
	var seed_value := int(observation.get("seed", 0))
	var effort := absi(seed_value * 13 + seat * 7) % 97 + 1
	return {"effort": effort}
