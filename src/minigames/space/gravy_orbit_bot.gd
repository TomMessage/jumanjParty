class_name GravyOrbitBot
extends BotController

const GAIN := 1.0


func choose_action(observation: Dictionary) -> Dictionary:
	var tilt := float(observation.get("tilt", 0.0))
	return {"lean": clampf(-tilt * GAIN, -1.0, 1.0)}
