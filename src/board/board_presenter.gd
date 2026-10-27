class_name BoardPresenter
extends RefCounted

var _pawns: Array[Node3D] = []
var _die_label: Label3D


func build(parent: Node3D) -> void:
	var index := 0
	for space: BoardSpace in BoardCatalog.spaces():
		var spot := BoardSpots.at(index)
		MeshFactory.place_box(
			parent,
			Vector3(0.1, 0.025, 0.1),
			spot + Vector3(0, -0.03, 0),
			BoardSpots.color_for(space.kind)
		)
		index += 1
	var slot := 0
	while slot < 4:
		_pawns.append(_pawn(parent, BoardSpots.pawn_color(slot)))
		slot += 1
	MeshFactory.place_box(parent, Vector3(0.09, 0.09, 0.09), Vector3(0, 0.98, 0), Palette.BONE)
	_die_label = _caption(parent, Vector3(0, 1.08, 0), 42)
	_die_label.text = ""


func sync(board: Dictionary) -> void:
	var ids: Array = board.get("seat_ids", [])
	var positions: Array = board.get("positions", [])
	var slot := 0
	while slot < _pawns.size():
		var pawn := _pawns[slot]
		var shown := slot < ids.size() and slot < positions.size()
		pawn.visible = shown
		if shown:
			var spot := BoardSpots.at(int(positions[slot]))
			pawn.position = spot + Vector3(float(slot) * 0.03, 0.0, 0.0)
		slot += 1
	var face := int(board.get("die_face", 0))
	if face <= 0:
		_die_label.text = ""
		return
	_die_label.text = str(face)


func _pawn(parent: Node3D, color: Color) -> Node3D:
	var root := Node3D.new()
	root.visible = false
	parent.add_child(root)
	MeshFactory.place_cylinder(root, 0.028, 0.08, Vector3(0, 0.04, 0), color)
	MeshFactory.place_sphere(root, 0.034, Vector3(0, 0.11, 0), color)
	return root


func _caption(parent: Node3D, origin: Vector3, size: int) -> Label3D:
	var label := Label3D.new()
	label.position = origin
	label.font_size = size
	label.pixel_size = 0.0018
	label.modulate = Palette.INK
	label.outline_size = 8
	label.outline_modulate = Palette.PARCHMENT
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label
