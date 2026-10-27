class_name KeeperCaption
extends RefCounted


static func attach(root: Node3D) -> Label3D:
	var label := Label3D.new()
	label.name = "KeeperCaption"
	label.position = Vector3(0, 1.92, 0.12)
	label.pixel_size = 0.0012
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = ""
	ReadingStyle.apply(label, 20)
	root.add_child(label)
	return label


static func show_line(root: Node3D, line: String) -> void:
	var label := root.get_node_or_null("KeeperCaption") as Label3D
	if label == null:
		label = attach(root)
	label.text = line
	ReadingStyle.apply(label, 20)
