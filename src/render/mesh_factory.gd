class_name MeshFactory
extends RefCounted

const PS1_SHADER := preload("res://src/render/ps1_spatial.gdshader")


static func material(
	color: Color, emission: Color = Color(0, 0, 0), energy: float = 0.0
) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = PS1_SHADER
	mat.set_shader_parameter("albedo_color", Vector3(color.r, color.g, color.b))
	mat.set_shader_parameter("emission_color", Vector3(emission.r, emission.g, emission.b))
	mat.set_shader_parameter("emission_energy", energy)
	var settings := SaveSystem.to_render_settings()
	mat.set_shader_parameter("ps1_enabled", RenderProfile.ps1_enabled(settings))
	return mat


static func place_box(
	parent: Node3D,
	size: Vector3,
	origin: Vector3,
	color: Color,
	emission: Color = Color(0, 0, 0),
	energy: float = 0.0,
	basis: Basis = Basis.IDENTITY,
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _place(parent, mesh, Transform3D(basis, origin), color, emission, energy)


static func place_cylinder(
	parent: Node3D,
	radius: float,
	height: float,
	origin: Vector3,
	color: Color,
	emission: Color = Color(0, 0, 0),
	energy: float = 0.0,
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	return _place(parent, mesh, Transform3D(Basis.IDENTITY, origin), color, emission, energy)


static func place_cone(
	parent: Node3D,
	radius: float,
	height: float,
	origin: Vector3,
	color: Color,
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	return _place(parent, mesh, Transform3D(Basis.IDENTITY, origin), color, Color(0, 0, 0), 0.0)


static func place_sphere(
	parent: Node3D,
	radius: float,
	origin: Vector3,
	color: Color,
	emission: Color = Color(0, 0, 0),
	energy: float = 0.0,
) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 6
	return _place(parent, mesh, Transform3D(Basis.IDENTITY, origin), color, emission, energy)


static func place_omni(
	parent: Node3D,
	origin: Vector3,
	color: Color,
	energy: float,
	radius: float,
) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.position = origin
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	light.shadow_enabled = false
	parent.add_child(light)
	return light


static func _place(
	parent: Node3D,
	mesh: Mesh,
	xform: Transform3D,
	color: Color,
	emission: Color,
	energy: float,
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.transform = xform
	instance.material_override = material(color, emission, energy)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
	instance.add_to_group("ps1_surface")
	return instance
