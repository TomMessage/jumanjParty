class_name BeetleRainBot
extends BotController

const LEAD := 0.0


func choose_action(observation: Dictionary) -> Dictionary:
	return {"aim": float(observation.get("aim", 0.0)) + LEAD}
