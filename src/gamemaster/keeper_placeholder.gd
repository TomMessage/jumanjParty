class_name KeeperPlaceholder
extends RefCounted


static func build(parent: Node3D) -> void:
	var root := Node3D.new()
	root.name = "GameMaster"
	root.position = Vector3(0.02, 0.0, -1.68)
	root.rotation.y = 0.15
	parent.add_child(root)
	MeshFactory.place_box(root, Vector3(0.56, 1.28, 0.34), Vector3(0, 0.7, 0), Palette.CLOTH)
	MeshFactory.place_box(root, Vector3(0.82, 0.14, 0.38), Vector3(0, 1.24, 0), Palette.CLOTH)
	MeshFactory.place_box(root, Vector3(0.16, 0.78, 0.06), Vector3(0, 0.86, 0.16), Palette.SASH)
	MeshFactory.place_sphere(root, 0.17, Vector3(0, 1.52, 0), Palette.CLOTH)
	MeshFactory.place_cylinder(root, 0.28, 0.07, Vector3(0, 1.64, 0), Palette.VOID)
	MeshFactory.place_sphere(root, 0.075, Vector3(0, 1.5, 0.12), Palette.VOID)
	MeshFactory.place_cylinder(root, 0.045, 0.7, Vector3(-0.34, 0.95, 0.05), Palette.CLOTH)
	MeshFactory.place_cylinder(root, 0.02, 1.4, Vector3(-0.38, 0.72, 0.1), Palette.WOOD_DARK)
	var lantern := Vector3(0.36, 0.98, 0.16)
	MeshFactory.place_box(
		root, Vector3(0.12, 0.14, 0.1), lantern, Palette.METAL, Palette.FLAME, 2.4
	)
	MeshFactory.place_omni(root, lantern + Vector3(0, 0.08, 0.08), Color(1, 0.64, 0.3), 2.6, 2.6)
	var plaque := Label3D.new()
	plaque.text = "GAME MASTER"
	plaque.font_size = 56
	plaque.pixel_size = 0.0024
	plaque.position = Vector3(0, 0.78, 0.32)
	plaque.modulate = Palette.PARCHMENT
	plaque.outline_size = 10
	plaque.outline_modulate = Palette.INK
	plaque.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plaque.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	plaque.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(plaque)
	KeeperCaption.attach(root)
