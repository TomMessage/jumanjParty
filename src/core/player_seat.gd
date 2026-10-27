class_name PlayerSeat
extends RefCounted

var id: int = 0
var display_name: String = ""
var is_bot: bool = false
var tokens: int = 0


func to_dict() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"is_bot": is_bot,
		"tokens": tokens,
	}


static func from_dict(data: Dictionary) -> PlayerSeat:
	var seat := PlayerSeat.new()
	seat.id = int(data.get("id", 0))
	seat.display_name = str(data.get("display_name", ""))
	seat.is_bot = bool(data.get("is_bot", false))
	seat.tokens = int(data.get("tokens", 0))
	return seat
