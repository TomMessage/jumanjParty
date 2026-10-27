class_name ReadingStyle
extends RefCounted


static func apply(label: Label3D, base_size: int) -> void:
	var scale := clampf(SaveSystem.text_scale, 0.8, 1.6)
	label.font_size = int(round(float(base_size) * scale))
	if SaveSystem.high_contrast:
		label.outline_size = 14
		label.modulate = Color(0.05, 0.02, 0.01)
		label.outline_modulate = Color(0.95, 0.88, 0.7)
		return
	label.outline_size = 6
	label.modulate = Palette.INK
	label.outline_modulate = Palette.PARCHMENT
