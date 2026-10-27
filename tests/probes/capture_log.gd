class_name CaptureLog
extends Logger

var lines: Array[String] = []


func _log_message(message: String, error: bool) -> void:
	if error or _blocking(message):
		lines.append(message)


func _log_error(
	function: String,
	file: String,
	line: int,
	code: String,
	rationale: String,
	_editor_notify: bool,
	_error_type: int,
	_script_backtraces: Array,
) -> void:
	lines.append("%s:%d %s %s %s" % [file, line, function, code, rationale])


func _blocking(message: String) -> bool:
	if message.find("SCRIPT ERROR") >= 0:
		return true
	if message.find("SHADER ERROR") >= 0:
		return true
	if message.find("Parse Error") >= 0:
		return true
	if message.find("res://") >= 0 and message.find("WARNING") >= 0:
		return true
	return false
