class_name PixelStage
extends Control

const VIEW_SIZE := Vector2i(640, 360)

var world: Node3D
var post_material: ShaderMaterial


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	_build()
	_fill()
	resized.connect(_fill)
	if get_parent() is Control:
		(get_parent() as Control).resized.connect(_fill)
	if not EventBus.settings_changed.is_connected(apply_settings):
		EventBus.settings_changed.connect(apply_settings)


func _build() -> void:
	var container := SubViewportContainer.new()
	container.name = "PixelContainer"
	container.stretch = true
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.focus_mode = Control.FOCUS_NONE
	add_child(container)
	var viewport := SubViewport.new()
	viewport.name = "LowRes"
	viewport.size = VIEW_SIZE
	viewport.own_world_3d = true
	viewport.transparent_bg = false
	viewport.handle_input_locally = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	world = Node3D.new()
	world.name = "World"
	viewport.add_child(world)
	var post := ColorRect.new()
	post.name = "Post"
	post.mouse_filter = Control.MOUSE_FILTER_IGNORE
	post.focus_mode = Control.FOCUS_NONE
	post_material = ShaderMaterial.new()
	post_material.shader = load("res://src/render/post_process.gdshader")
	post.material = post_material
	add_child(post)
	apply_settings()


func _fill() -> void:
	var parent := get_parent()
	if parent is Control:
		position = Vector2.ZERO
		size = (parent as Control).size
	for child: Node in get_children():
		if child is Control:
			var panel := child as Control
			panel.position = Vector2.ZERO
			panel.size = size


func apply_settings() -> void:
	if post_material == null:
		return
	var settings := SaveSystem.to_render_settings()
	var params := RenderProfile.post_parameters(settings)
	for key: Variant in params.keys():
		post_material.set_shader_parameter(str(key), params[key])
	if is_inside_tree():
		RenderProfile.apply_ps1(get_tree(), RenderProfile.ps1_enabled(settings))
