class_name MinigameBase
extends Node

signal trial_finished(result: MinigameResult)

@export var min_duration_seconds: float = 30.0
@export var max_duration_seconds: float = 90.0

var _players: Array[int] = []
var _seed: int = 0
var _elapsed_ms: int = 0
var _running: bool = false
var _result: MinigameResult


func start_trial(players: Array[int], seed_value: int) -> void:
	_players = players.duplicate()
	_seed = seed_value
	_elapsed_ms = 0
	_running = true
	_result = null
	_on_start()


func tick(delta: float) -> void:
	if not _running:
		return
	_elapsed_ms += int(round(delta * 1000.0))
	_on_tick()
	if _elapsed_ms < planned_ms():
		return
	_running = false
	_result = _build_result()
	trial_finished.emit(_result)


func is_running() -> bool:
	return _running


func planned_ms() -> int:
	return 45000


func latest_result() -> MinigameResult:
	return _result


func build_bot() -> BotController:
	return BotController.new()


func _on_start() -> void:
	return


func _on_tick() -> void:
	return


func _build_result() -> MinigameResult:
	return MinigameResult.from_scores({}, 0.0)
