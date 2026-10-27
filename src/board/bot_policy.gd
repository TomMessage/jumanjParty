class_name BotPolicy
extends RefCounted


static func choose_item(state: MatchState, seat: PlayerSeat) -> String:
	var index := state.index_of(seat.id)
	if index < 0:
		return ""
	var owned := state.items[index]
	if state.shop_choices.has("shield") and not owned.has("shield"):
		return "shield"
	if state.shop_choices.has("pip") and not owned.has("pip"):
		return "pip"
	if state.shop_choices.has("leap"):
		return "leap"
	return ""
