class_name BoardCatalog
extends RefCounted

const LOOP := 16


static func spaces() -> Array[BoardSpace]:
	var found: Array[BoardSpace] = []
	var index := 0
	while index < LOOP:
		var loaded: Resource = load("res://src/data/spaces/space_%02d.tres" % index)
		if loaded is BoardSpace:
			found.append(loaded)
		index += 1
	return found


static func space_at(index: int) -> BoardSpace:
	var all := spaces()
	return all[posmod(index, all.size())]


static func cards() -> Array[EventCard]:
	var found: Array[EventCard] = []
	for path: String in _card_paths():
		var loaded: Resource = load(path)
		if loaded is EventCard:
			found.append(loaded)
	found.sort_custom(_card_before)
	return found


static func card_by_id(card_id: String) -> EventCard:
	for card: EventCard in cards():
		if card.card_id == card_id:
			return card
	return null


static func items() -> Array[ItemDef]:
	var found: Array[ItemDef] = []
	for path: String in _item_paths():
		var loaded: Resource = load(path)
		if loaded is ItemDef:
			found.append(loaded)
	found.sort_custom(_item_before)
	return found


static func item_by_id(item_id: String) -> ItemDef:
	for item: ItemDef in items():
		if item.item_id == item_id:
			return item
	return null


static func offers_for(tokens: int, owned: PackedStringArray) -> Array[String]:
	var offers: Array[String] = []
	if owned.size() >= 2:
		return offers
	for item: ItemDef in items():
		if tokens >= item.price:
			offers.append(item.item_id)
	return offers


static func shuffled_ids(board: MatchState) -> Array[String]:
	var rng := RandomNumberGenerator.new()
	rng.seed = board.rng_seed
	rng.state = board.rng_state
	var deck: Array[String] = []
	for card: EventCard in cards():
		deck.append(card.card_id)
	var index := deck.size() - 1
	while index > 0:
		var swap := rng.randi_range(0, index)
		var tmp := deck[index]
		deck[index] = deck[swap]
		deck[swap] = tmp
		index -= 1
	board.rng_state = rng.state
	return deck


static func _card_before(a: EventCard, b: EventCard) -> bool:
	return a.card_id < b.card_id


static func _item_before(a: ItemDef, b: ItemDef) -> bool:
	return a.price < b.price


static func _card_paths() -> Array[String]:
	return [
		"res://src/data/cards/boots.tres",
		"res://src/data/cards/candle.tres",
		"res://src/data/cards/favor.tres",
		"res://src/data/cards/pocket.tres",
		"res://src/data/cards/tips.tres",
		"res://src/data/cards/wine.tres",
	]


static func _item_paths() -> Array[String]:
	return [
		"res://src/data/items/leap.tres",
		"res://src/data/items/pip.tres",
		"res://src/data/items/shield.tres",
	]
