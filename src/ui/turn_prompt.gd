class_name TurnPrompt
extends RefCounted

var _status: Label3D
var _detail: Label3D
var _slates: Array[MeshInstance3D] = []
var _labels: Array[Label3D] = []


func build(parent: Node3D) -> void:
	_status = _label(parent, Vector3(0, 1.12, 0.46), 28)
	_detail = _label(parent, Vector3(0, 1.04, 0.46), 18)
	var xs: Array[float] = [-0.34, 0.0, 0.34]
	var index := 0
	while index < xs.size():
		var origin := Vector3(xs[index], 0.96, 0.3)
		var slate := MeshFactory.place_box(
			parent, Vector3(0.3, 0.03, 0.08), origin, Palette.WOOD_DARK
		)
		var caption := _label(parent, origin + Vector3(0, 0.05, 0), 16)
		_slates.append(slate)
		_labels.append(caption)
		index += 1


func set_text(status: String, detail: String) -> void:
	_status.text = status
	_detail.text = detail


func set_choices(labels: PackedStringArray, selected: int) -> void:
	var index := 0
	while index < _slates.size():
		var shown := index < labels.size()
		_slates[index].visible = shown
		_labels[index].visible = shown
		if shown:
			_labels[index].text = labels[index]
			var color := Palette.WOOD_DARK
			if index == selected:
				color = Palette.OCHRE
			_slates[index].material_override = MeshFactory.material(color)
		index += 1


func _label(parent: Node3D, origin: Vector3, size: int) -> Label3D:
	var label := Label3D.new()
	label.position = origin
	label.font_size = size
	label.pixel_size = 0.0015
	label.modulate = Palette.INK
	label.outline_size = 6
	label.outline_modulate = Palette.PARCHMENT
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label
