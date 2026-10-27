class_name CandleDodgeBot
extends BotController

const PREFER := 2


func choose_action(observation: Dictionary) -> Dictionary:
	var threat := int(observation.get("threat", 0))
	var lane := PREFER
	if lane == threat:
		lane = posmod(lane + 1, 3)
	return {"lane": lane}
