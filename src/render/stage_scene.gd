extends Control

@export var view_name: String = "table"
@export var interactive_menu: bool = false

var _stage: PixelStage
var _camera: Camera3D
var _menu: TableMenu


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	InputBindings.ensure()
	_stage = PixelStage.new()
	_stage.name = "PixelStage"
	add_child(_stage)
	_build_world()
	_stage.apply_settings()


func _build_world() -> void:
	var world := _stage.world
	RoomSet.build(world)
	KeeperPlaceholder.build(world)
	_camera = Camera3D.new()
	_camera.name = "SeatedCamera"
	_camera.fov = 50.0
	_camera.near = 0.05
	_camera.far = 40.0
	world.add_child(_camera)
	_apply_view(view_name)
	_camera.current = true
	if not interactive_menu:
		return
	_menu = TableMenu.new()
	add_child(_menu)
	_menu.attach(world, _stage)


func _unhandled_input(event: InputEvent) -> void:
	if _camera == null or not event.is_pressed() or event.is_echo():
		return
	if event.is_action("view_table"):
		_apply_view("table")
		get_viewport().set_input_as_handled()
		return
	if event.is_action("view_board"):
		_apply_view("board")
		get_viewport().set_input_as_handled()
		return
	if event.is_action("view_keeper"):
		_apply_view("keeper")
		get_viewport().set_input_as_handled()
		return
	if event.is_action("view_window"):
		_apply_view("window")
		get_viewport().set_input_as_handled()


func _apply_view(next: String) -> void:
	if _camera == null:
		return
	var aim := CameraFraming.aim(next)
	_camera.global_position = aim["origin"]
	_camera.look_at(aim["target"], Vector3.UP)
