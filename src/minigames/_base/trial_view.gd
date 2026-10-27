class_name TrialView
extends Node3D

var _camera: Camera3D
var _pawns: Array[Node3D] = []
var _hazards: Array[MeshInstance3D] = []
var _fall := 0.0


func build(card: TrialCard) -> void:
	_environment(card.sky)
	MeshFactory.place_box(self, Vector3(16, 0.24, 16), Vector3(0, -0.12, 0), card.ground)
	MeshFactory.place_box(self, Vector3(2.4, 0.08, 1.5), Vector3(0, 0.02, 3.4), Palette.FELT)
	_dress(card.accent)
	var slot := 0
	while slot < 4:
		_pawns.append(_pawn(BoardSpots.pawn_color(slot)))
		slot += 1
	var mark := 0
	while mark < 8:
		var box := MeshFactory.place_box(
			self, Vector3(0.38, 0.38, 0.38), Vector3(0, -3, 0), card.accent, card.accent, 0.55
		)
		box.visible = false
		_hazards.append(box)
		mark += 1
	_title(card.title)
	_camera = Camera3D.new()
	_camera.fov = 52.0
	_camera.near = 0.05
	_camera.far = 40.0
	add_child(_camera)
	_camera.current = true
	MeshFactory.place_omni(self, Vector3(0.2, 3.4, 2.2), Color(1, 0.86, 0.62), 2.4, 14.0)
	_place_camera()


func sync(board: Dictionary) -> void:
	_place_nodes(_pawns, board.get("pawns", []))
	_place_meshes(_hazards, board.get("hazards", []))


func play_fall() -> void:
	_fall = 0.0
	_place_camera()


func advance_fall(delta: float) -> void:
	if SaveSystem.reduce_motion:
		_fall = 1.0
		_place_camera()
		return
	if _fall >= 1.0:
		return
	_fall = minf(_fall + maxf(delta * 3.0, 0.08), 1.0)
	_place_camera()


func camera_height() -> float:
	if _camera == null:
		return 0.0
	return _camera.position.y


func _process(delta: float) -> void:
	advance_fall(delta)


func _place_camera() -> void:
	if _camera == null:
		return
	var origin := Vector3(0.05, 7.2, 6.2).lerp(Vector3(0.1, 2.45, 4.6), _fall)
	_camera.position = origin
	_camera.look_at(Vector3(0.0, 0.35, 0.4), Vector3.UP)


func _place_nodes(nodes: Array[Node3D], points: Variant) -> void:
	var marks: Array = points if points is Array else []
	var index := 0
	while index < nodes.size():
		var shown := index < marks.size()
		nodes[index].visible = shown
		if shown:
			nodes[index].position = marks[index] as Vector3
		index += 1


func _place_meshes(nodes: Array[MeshInstance3D], points: Variant) -> void:
	var marks: Array = points if points is Array else []
	var index := 0
	while index < nodes.size():
		var shown := index < marks.size()
		nodes[index].visible = shown
		if shown:
			nodes[index].position = marks[index] as Vector3
		index += 1


func _environment(sky: Color) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.74, 0.66, 0.54)
	env.ambient_light_energy = 1.2
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)


func _dress(accent: Color) -> void:
	MeshFactory.place_box(self, Vector3(0.5, 1.4, 0.5), Vector3(-3.2, 0.7, -1.5), accent)
	MeshFactory.place_box(self, Vector3(0.4, 1.1, 0.4), Vector3(3.0, 0.55, -0.6), Palette.WOOD_DARK)
	MeshFactory.place_cylinder(self, 0.08, 0.5, Vector3(-1.6, 0.4, 2.2), Palette.CANDLE)
	MeshFactory.place_sphere(
		self, 0.08, Vector3(-1.6, 0.72, 2.2), Palette.FLAME, Palette.FLAME, 2.0
	)


func _pawn(color: Color) -> Node3D:
	var root := Node3D.new()
	root.visible = false
	add_child(root)
	MeshFactory.place_cylinder(root, 0.12, 0.28, Vector3(0, 0.14, 0), color)
	MeshFactory.place_sphere(root, 0.1, Vector3(0, 0.36, 0), color)
	return root


func _title(text: String) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = Vector3(0, 1.15, -1.2)
	label.font_size = 42
	label.pixel_size = 0.012
	label.modulate = Palette.PARCHMENT
	label.outline_size = 8
	label.outline_modulate = Palette.INK
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	add_child(label)
