class_name SundialLockBot
extends BotController

const SLIP := 4


func choose_action(observation: Dictionary) -> Dictionary:
	var symbol := int(observation.get("symbol", 0))
	var seat := int(observation.get("seat", 0))
	var seed_value := int(observation.get("seed", 0))
	if posmod(seed_value + seat, SLIP) == 0:
		symbol = posmod(symbol + 1, 4)
	return {"symbol": symbol}
