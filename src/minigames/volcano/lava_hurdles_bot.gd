class_name LavaHurdlesBot
extends BotController

const BRAKE_GAP := 2.2


func choose_action(observation: Dictionary) -> Dictionary:
	var gap := float(observation.get("gap", 9.0))
	var throttle := 1.0
	if gap < BRAKE_GAP:
		throttle = 0.12
	return {"throttle": throttle}
