class_name PortraitWavesBot
extends BotController

const LEAD := 0.35


func choose_action(observation: Dictionary) -> Dictionary:
	return {"aim": float(observation.get("aim", 0.0)) + LEAD}
