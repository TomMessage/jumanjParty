class_name RoomSet
extends RefCounted


static func build(parent: Node3D, with_decor: bool = true) -> void:
	_environment(parent)
	_shell(parent)
	_window(parent)
	_table(parent)
	_board(parent, with_decor)
	_candles(parent)
	_props(parent)


static func _environment(parent: Node3D) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.02, 0.018)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.18, 0.12, 0.09)
	env.ambient_light_energy = 0.35
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.12
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	env.fog_density = 0.01
	env.fog_light_color = Color(0.1, 0.06, 0.04)
	env.fog_aerial_perspective = 0.2
	var node := WorldEnvironment.new()
	node.environment = env
	parent.add_child(node)


static func _shell(parent: Node3D) -> void:
	MeshFactory.place_box(parent, Vector3(7.6, 0.2, 7.6), Vector3(0, -0.1, 0), Palette.FLOOR)
	MeshFactory.place_box(parent, Vector3(7.6, 0.16, 7.6), Vector3(0, 2.9, 0), Palette.CEILING)
	MeshFactory.place_box(parent, Vector3(7.4, 2.9, 0.18), Vector3(0, 1.45, -3.4), Palette.WALL)
	MeshFactory.place_box(parent, Vector3(7.4, 2.9, 0.18), Vector3(0, 1.45, 3.4), Palette.WALL)
	MeshFactory.place_box(parent, Vector3(0.18, 2.9, 7.4), Vector3(-3.4, 1.45, 0), Palette.WALL)
	MeshFactory.place_box(parent, Vector3(0.18, 2.9, 2.3), Vector3(3.4, 1.45, -2.2), Palette.WALL)
	MeshFactory.place_box(parent, Vector3(0.18, 2.9, 2.3), Vector3(3.4, 1.45, 2.2), Palette.WALL)
	MeshFactory.place_box(parent, Vector3(0.18, 0.7, 2.05), Vector3(3.4, 2.5, 0), Palette.WALL)
	MeshFactory.place_box(parent, Vector3(0.18, 0.9, 2.05), Vector3(3.4, 0.45, 0), Palette.WALL)
	MeshFactory.place_box(parent, Vector3(2.9, 0.02, 2.0), Vector3(0, 0.012, 0.05), Palette.SASH)


static func _window(parent: Node3D) -> void:
	MeshFactory.place_box(parent, Vector3(0.08, 1.2, 1.75), Vector3(3.75, 1.5, 0), Palette.VOID)
	MeshFactory.place_box(
		parent, Vector3(0.06, 1.25, 0.05), Vector3(3.32, 1.5, 0), Palette.WOOD_DARK
	)
	MeshFactory.place_box(
		parent, Vector3(0.06, 0.05, 1.75), Vector3(3.32, 1.5, 0), Palette.WOOD_DARK
	)
	MeshFactory.place_cone(parent, 0.28, 0.95, Vector3(4.35, 0.48, -0.45), Palette.MOSS)
	MeshFactory.place_cone(parent, 0.22, 0.75, Vector3(4.2, 0.38, 0.42), Palette.GLASS)
	MeshFactory.place_omni(parent, Vector3(4.7, 2.2, 0.1), Palette.MOON, 1.1, 5.0)


static func _table(parent: Node3D) -> void:
	MeshFactory.place_box(parent, Vector3(2.4, 0.1, 1.32), Vector3(0, 0.78, 0.05), Palette.WOOD)
	MeshFactory.place_box(
		parent, Vector3(0.1, 0.74, 0.1), Vector3(-1.02, 0.37, -0.48), Palette.WOOD_DARK
	)
	MeshFactory.place_box(
		parent, Vector3(0.1, 0.74, 0.1), Vector3(1.02, 0.37, -0.48), Palette.WOOD_DARK
	)
	MeshFactory.place_box(
		parent, Vector3(0.1, 0.74, 0.1), Vector3(-1.02, 0.37, 0.58), Palette.WOOD_DARK
	)
	MeshFactory.place_box(
		parent, Vector3(0.1, 0.74, 0.1), Vector3(1.02, 0.37, 0.58), Palette.WOOD_DARK
	)


static func _board(parent: Node3D, with_decor: bool) -> void:
	MeshFactory.place_box(parent, Vector3(1.22, 0.05, 0.82), Vector3(0, 0.855, -0.02), Palette.FELT)
	if not with_decor:
		return
	var cols := 8
	var rows := 5
	var step := 0.12
	var origin := Vector3(-0.42, 0.905, -0.26)
	var row := 0
	while row < rows:
		var col := 0
		while col < cols:
			var edge := row == 0 or row == rows - 1 or col == 0 or col == cols - 1
			if edge:
				var color := Palette.TILE_A
				if (col + row) % 2 == 0:
					color = Palette.TILE_B
				var pos := origin + Vector3(float(col) * step, 0.0, float(row) * step)
				MeshFactory.place_box(parent, Vector3(0.1, 0.03, 0.1), pos, color)
			col += 1
		row += 1
	_pawn(parent, Vector3(-0.42, 0.95, -0.26), Palette.BONE)
	_pawn(parent, Vector3(0.42, 0.95, -0.26), Palette.WINE)
	_pawn(parent, Vector3(-0.42, 0.95, 0.22), Palette.MOSS)
	_pawn(parent, Vector3(0.42, 0.95, 0.22), Palette.OCHRE)


static func _pawn(parent: Node3D, origin: Vector3, color: Color) -> void:
	MeshFactory.place_cylinder(parent, 0.028, 0.08, origin, color)
	MeshFactory.place_sphere(parent, 0.034, origin + Vector3(0, 0.07, 0), color)


static func _candles(parent: Node3D) -> void:
	_candle(parent, Vector3(-0.95, 0.83, 0.42), 0.4)
	_candle(parent, Vector3(0.9, 0.83, -0.36), 1.8)
	MeshFactory.place_omni(parent, Vector3(0, 2.2, 0.05), Color(1.0, 0.78, 0.48), 1.4, 4.8)
	MeshFactory.place_cylinder(
		parent, 0.14, 0.08, Vector3(0, 2.62, 0.05), Palette.METAL, Palette.FLAME, 0.6
	)


static func _candle(parent: Node3D, origin: Vector3, phase: float) -> void:
	MeshFactory.place_cylinder(parent, 0.04, 0.22, origin + Vector3(0, 0.11, 0), Palette.CANDLE)
	var flame := MeshFactory.place_sphere(
		parent, 0.03, origin + Vector3(0, 0.26, 0), Palette.FLAME, Palette.FLAME, 4.0
	)
	var light := MeshFactory.place_omni(
		parent, origin + Vector3(0, 0.32, 0), Color(1.0, 0.72, 0.35), 3.2, 3.8
	)
	var flicker := CandleFlicker.new()
	flicker.phase = phase
	flicker.light = light
	flicker.flame = flame
	flicker.base_energy = 3.2
	parent.add_child(flicker)


static func _props(parent: Node3D) -> void:
	var dice_a := Basis.from_euler(Vector3(0.4, 0.2, 0.5))
	var dice_b := Basis.from_euler(Vector3(0.8, 0.4, 0.15))
	MeshFactory.place_box(
		parent,
		Vector3(0.08, 0.08, 0.08),
		Vector3(0.62, 0.88, 0.32),
		Palette.BONE,
		Color(0, 0, 0),
		0.0,
		dice_a
	)
	MeshFactory.place_box(
		parent,
		Vector3(0.08, 0.08, 0.08),
		Vector3(0.72, 0.88, 0.24),
		Palette.WINE,
		Color(0, 0, 0),
		0.0,
		dice_b
	)
	MeshFactory.place_cylinder(parent, 0.05, 0.1, Vector3(-0.68, 0.89, 0.4), Palette.METAL)
	MeshFactory.place_cone(parent, 0.07, 0.09, Vector3(0.82, 0.9, 0.48), Palette.METAL)
	MeshFactory.place_sphere(parent, 0.018, Vector3(0.82, 0.98, 0.48), Palette.METAL)
	MeshFactory.place_box(
		parent, Vector3(0.24, 0.045, 0.16), Vector3(-0.78, 0.87, -0.2), Palette.SASH
	)
	MeshFactory.place_box(
		parent, Vector3(0.22, 0.02, 0.14), Vector3(-0.78, 0.9, -0.2), Palette.PARCHMENT
	)
	MeshFactory.place_box(
		parent, Vector3(0.28, 0.05, 1.15), Vector3(-3.15, 1.5, -0.35), Palette.WOOD_DARK
	)
	MeshFactory.place_cylinder(parent, 0.05, 0.18, Vector3(-3.08, 1.64, -0.7), Palette.GLASS)
	MeshFactory.place_cylinder(parent, 0.045, 0.22, Vector3(-3.08, 1.66, -0.35), Palette.WINE)
	MeshFactory.place_box(
		parent, Vector3(0.09, 0.18, 0.13), Vector3(-3.08, 1.64, -0.05), Palette.OCHRE
	)
