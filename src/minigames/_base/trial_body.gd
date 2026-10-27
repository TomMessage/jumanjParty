class_name TrialBody
extends MinigameBase

var _card: TrialCard
var _field: TrialField
var _view: TrialView
var _step := 0.1
var _scores: Dictionary = {}


func tick(delta: float) -> void:
	_step = delta
	super.tick(delta)


func planned_ms() -> int:
	if _card == null:
		_load_card()
	if _card == null:
		return 45000
	return int(round(_card.duration_seconds * 1000.0))


func _ready() -> void:
	_load_card()
	_boot_preview()


func _on_start() -> void:
	_load_card()
	_field = _make_field()
	_field.setup(_players, _seed, _card)
	_ensure_view()
	if _view != null:
		_view.play_fall()
		_view.sync(_field.visual())
	_scores = _field.scores()


func _on_tick() -> void:
	if _field == null:
		return
	var bot := build_bot()
	for seat_id: int in _players:
		var obs := _field.observe(seat_id)
		obs["seat"] = seat_id
		obs["seed"] = _seed
		_field.apply(seat_id, bot.choose_action(obs))
	_field.step(_step)
	_scores = _field.scores()
	if _view != null:
		_view.sync(_field.visual())


func _build_result() -> MinigameResult:
	return MinigameResult.from_scores(_scores, float(planned_ms()) / 1000.0)


func _make_field() -> TrialField:
	return TrialField.new()


func _card_path() -> String:
	return ""


func _load_card() -> void:
	if _card != null:
		return
	var loaded: Variant = load(_card_path())
	if loaded is TrialCard:
		_card = loaded


func _boot_preview() -> void:
	if _card == null:
		return
	_field = _make_field()
	var seats: Array[int] = [1, 2, 3]
	_field.setup(seats, _card.salt, _card)
	_ensure_view()
	_view.sync(_field.visual())


func _ensure_view() -> void:
	if _view != null or _card == null or not is_inside_tree():
		return
	_view = TrialView.new()
	_view.name = "TrialView"
	add_child(_view)
	_view.build(_card)
