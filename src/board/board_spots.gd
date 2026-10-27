class_name BoardSpots
extends RefCounted


static func at(index: int) -> Vector3:
	var spots := _spots()
	return spots[posmod(index, spots.size())]


static func color_for(kind: String) -> Color:
	var colors := {
		"gain": Palette.MOSS,
		"loss": Palette.WINE,
		"trap": Palette.WOOD_DARK,
		"swap": Palette.OCHRE,
		"event": Palette.BONE,
		"shop": Palette.METAL,
	}
	if colors.has(kind):
		return colors[kind] as Color
	return Palette.PARCHMENT


static func pawn_color(slot: int) -> Color:
	var colors: Array[Color] = [Palette.BONE, Palette.WINE, Palette.MOSS, Palette.OCHRE]
	return colors[posmod(slot, colors.size())]


static func _spots() -> Array[Vector3]:
	return [
		Vector3(-0.40, 0.94, 0.24),
		Vector3(-0.20, 0.94, 0.24),
		Vector3(0.00, 0.94, 0.24),
		Vector3(0.20, 0.94, 0.24),
		Vector3(0.40, 0.94, 0.24),
		Vector3(0.50, 0.94, 0.08),
		Vector3(0.50, 0.94, -0.08),
		Vector3(0.40, 0.94, -0.24),
		Vector3(0.20, 0.94, -0.24),
		Vector3(0.00, 0.94, -0.24),
		Vector3(-0.20, 0.94, -0.24),
		Vector3(-0.40, 0.94, -0.24),
		Vector3(-0.50, 0.94, -0.08),
		Vector3(-0.50, 0.94, 0.08),
		Vector3(-0.50, 0.94, 0.20),
		Vector3(-0.50, 0.94, 0.00),
	]
