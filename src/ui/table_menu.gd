class_name TableMenu
extends Node

var selection: MenuSelection = MenuSelection.new()

var _slates: Array[MeshInstance3D] = []
var _labels: Array[Label3D] = []
var _stage: PixelStage
var _busy: bool = false


func attach(world: Node3D, stage: PixelStage) -> void:
	_stage = stage
	_build_parchment(world)
	_build_slates(world)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if _busy or not event.is_pressed() or event.is_echo():
		return
	var viewport: Variant = null
	if is_inside_tree():
		viewport = get_viewport()
	if event.is_action("ui_left") or event.is_action("ui_up"):
		selection.move(-1)
		_refresh()
		_consume(viewport)
		return
	if event.is_action("ui_right") or event.is_action("ui_down"):
		selection.move(1)
		_refresh()
		_consume(viewport)
		return
	if event.is_action("ui_accept"):
		_consume(viewport)
		_activate()


func _consume(viewport: Variant) -> void:
	if viewport == null:
		return
	viewport.call("set_input_as_handled")


func _build_parchment(world: Node3D) -> void:
	MeshFactory.place_box(
		world, Vector3(1.05, 0.02, 0.48), Vector3(0, 1.02, 0.02), Palette.PARCHMENT
	)
	world.add_child(_label("WELCOME", Vector3(0, 1.16, 0.18), 48))
	world.add_child(_label("TO THE BOARD", Vector3(0, 1.05, 0.18), 36))


func _build_slates(world: Node3D) -> void:
	var xs: Array[float] = [-0.46, 0.0, 0.46]
	var index := 0
	while index < MenuSelection.LABELS.size():
		var origin := Vector3(xs[index], 0.86, 0.58)
		var slate := MeshFactory.place_box(
			world, Vector3(0.38, 0.04, 0.12), origin, Palette.WOOD_DARK
		)
		var label := _label(MenuSelection.LABELS[index], origin + Vector3(0, 0.07, 0.04), 22)
		label.modulate = Palette.PARCHMENT
		world.add_child(label)
		_slates.append(slate)
		_labels.append(label)
		index += 1


func _label(text: String, origin: Vector3, size: int) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = size
	label.pixel_size = 0.00135
	label.position = origin
	label.modulate = Palette.INK
	label.outline_size = 6
	label.outline_modulate = Color(0.95, 0.88, 0.72)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _refresh() -> void:
	var index := 0
	while index < _slates.size():
		var selected := index == selection.index
		var color := Palette.WOOD_DARK
		if selected:
			color = Palette.OCHRE
		_slates[index].material_override = MeshFactory.material(color)
		var lift := 0.0
		if selected:
			lift = 0.035
		_slates[index].position.y = 0.86 + lift
		_labels[index].position.y = 0.93 + lift
		_labels[index].modulate = Palette.PARCHMENT
		if selected:
			_labels[index].modulate = Palette.INK
		index += 1


func _activate() -> void:
	var action := selection.action()
	if action == "trim":
		SaveSystem.toggle_effects()
		if _stage != null:
			_stage.apply_settings()
		_refresh()
		return
	_busy = true
	if action == "sit":
		get_tree().change_scene_to_file("res://scenes/match.tscn")
		return
	get_tree().quit()
