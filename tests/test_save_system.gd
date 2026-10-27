extends GutTest

var _path: String
var _effects: bool
var _ps1: bool
var _linear: float


func before_each() -> void:
	_path = SaveSystem.settings_path
	_effects = SaveSystem.effects_enabled
	_ps1 = SaveSystem.ps1_enabled
	_linear = SaveSystem.master_linear
	SaveSystem.settings_path = "user://test_settings.cfg"


func after_each() -> void:
	SaveSystem.effects_enabled = _effects
	SaveSystem.ps1_enabled = _ps1
	SaveSystem.master_linear = _linear
	SaveSystem.settings_path = _path
	SaveSystem.save_settings()
	var absolute := ProjectSettings.globalize_path("user://test_settings.cfg")
	DirAccess.remove_absolute(absolute)


func test_settings_round_trip() -> void:
	SaveSystem.effects_enabled = false
	SaveSystem.ps1_enabled = false
	SaveSystem.master_linear = 0.4
	assert_eq(SaveSystem.save_settings(), OK)
	SaveSystem.effects_enabled = true
	SaveSystem.ps1_enabled = true
	SaveSystem.master_linear = 1.0
	SaveSystem.load_settings()
	assert_false(SaveSystem.effects_enabled)
	assert_false(SaveSystem.ps1_enabled)
	assert_almost_eq(SaveSystem.master_linear, 0.4, 0.001)
