class_name TableLesson
extends RefCounted


static func page(index: int) -> String:
	var pages := _pages()
	if pages.is_empty():
		return ""
	return pages[posmod(index, pages.size())]


static func count() -> int:
	return _pages().size()


static func _pages() -> PackedStringArray:
	return PackedStringArray(
		[
			"Roll the die. The pawn walks.",
			"Every turn falls into a trial.",
			"The keeper cheats. Last place sticks.",
			"The richest seat is kept.",
		]
	)
