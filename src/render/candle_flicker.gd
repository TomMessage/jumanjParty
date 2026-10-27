class_name CandleFlicker
extends Node

var light: OmniLight3D
var flame: MeshInstance3D
var phase: float = 0.0
var base_energy: float = 2.2


func _process(_delta: float) -> void:
	if SaveSystem.reduce_motion:
		if light != null:
			light.light_energy = base_energy
		if flame != null:
			flame.scale = Vector3.ONE
		return
	var t := float(Time.get_ticks_msec()) * 0.001
	var wobble := sin(t * 11.0 + phase) * 0.12
	wobble += sin(t * 23.0 + phase * 2.0) * 0.05
	if light != null:
		light.light_energy = base_energy + wobble
	if flame != null:
		var scale := 1.0 + wobble * 0.2
		flame.scale = Vector3(scale, scale, scale)
