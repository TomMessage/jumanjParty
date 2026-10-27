class_name KeeperLines
extends RefCounted


static func pick(tag: String, seed_value: int, turn: int) -> String:
	var pages := _pages(tag)
	if pages.is_empty():
		return ""
	var index := absi(seed_value * 13 + turn * 7 + pages.size()) % pages.size()
	return pages[index]


static func _pages(tag: String) -> PackedStringArray:
	if tag == "candles":
		return PackedStringArray(["The candles lean in to listen.", "Wax remembers who flinched."])
	if tag == "tremor":
		return PackedStringArray(
			["The table shivers under the pawns.", "Something under the felt turns over."]
		)
	if tag == "draft":
		return PackedStringArray(["A draft walks the loop.", "The window breathes on the dice."])
	if tag == "ending":
		return PackedStringArray(
			[
				"I keep the richest seat.",
				"Count them. I already did.",
				"The night keeps what it wants."
			]
		)
	return PackedStringArray(
		[
			"The lamp knows your names.",
			"Sit. The board is already awake.",
			"I kept your chair warm."
		]
	)
