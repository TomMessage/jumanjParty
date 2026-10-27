class_name RenderProfile
extends RefCounted


static func post_parameters(settings: Dictionary) -> Dictionary:
	var master := bool(settings.get("effects_enabled", true))
	return {
		"effects_enabled": master,
		"grain_strength": _amount(master and bool(settings.get("grain_enabled", true)), 0.05),
		"vignette_strength": _amount(master and bool(settings.get("vignette_enabled", true)), 0.36),
		"dither_strength": _amount(master and bool(settings.get("dither_enabled", true)), 0.4),
		"chroma_strength": _amount(master and bool(settings.get("chroma_enabled", true)), 0.0006),
	}


static func ps1_enabled(settings: Dictionary) -> bool:
	var master := bool(settings.get("effects_enabled", true))
	return master and bool(settings.get("ps1_enabled", true))


static func apply_ps1(tree: SceneTree, enabled: bool) -> void:
	for node: Node in tree.get_nodes_in_group("ps1_surface"):
		if node is MeshInstance3D:
			var mat: Material = (node as MeshInstance3D).material_override
			if mat is ShaderMaterial:
				(mat as ShaderMaterial).set_shader_parameter("ps1_enabled", enabled)


static func _amount(enabled: bool, value: float) -> float:
	if not enabled:
		return 0.0
	return value
