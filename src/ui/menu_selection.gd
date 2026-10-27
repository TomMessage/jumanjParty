class_name MenuSelection
extends RefCounted

const LABELS: Array[String] = ["SIT DOWN", "TRIM LAMP", "LEAVE"]

var index: int = 0


func move(step: int) -> void:
	index = posmod(index + step, LABELS.size())


func label() -> String:
	return LABELS[index]


func action() -> String:
	if index == 0:
		return "sit"
	if index == 1:
		return "trim"
	return "leave"
