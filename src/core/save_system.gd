extends Node

var settings_path: String = "user://settings.cfg"
var effects_enabled: bool = true
var grain_enabled: bool = true
var vignette_enabled: bool = true
var dither_enabled: bool = true
var chroma_enabled: bool = true
var ps1_enabled: bool = true
var master_linear: float = 0.8


func _ready() -> void:
	load_settings()


func to_render_settings() -> Dictionary:
	return {
		"effects_enabled": effects_enabled,
		"grain_enabled": grain_enabled,
		"vignette_enabled": vignette_enabled,
		"dither_enabled": dither_enabled,
		"chroma_enabled": chroma_enabled,
		"ps1_enabled": ps1_enabled,
	}


func toggle_effects() -> void:
	effects_enabled = not effects_enabled
	save_settings()


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(settings_path) != OK:
		return
	effects_enabled = bool(cfg.get_value("render", "effects_enabled", true))
	grain_enabled = bool(cfg.get_value("render", "grain_enabled", true))
	vignette_enabled = bool(cfg.get_value("render", "vignette_enabled", true))
	dither_enabled = bool(cfg.get_value("render", "dither_enabled", true))
	chroma_enabled = bool(cfg.get_value("render", "chroma_enabled", true))
	ps1_enabled = bool(cfg.get_value("render", "ps1_enabled", true))
	master_linear = float(cfg.get_value("audio", "master_linear", 0.8))


func save_settings() -> int:
	var cfg := ConfigFile.new()
	cfg.set_value("render", "effects_enabled", effects_enabled)
	cfg.set_value("render", "grain_enabled", grain_enabled)
	cfg.set_value("render", "vignette_enabled", vignette_enabled)
	cfg.set_value("render", "dither_enabled", dither_enabled)
	cfg.set_value("render", "chroma_enabled", chroma_enabled)
	cfg.set_value("render", "ps1_enabled", ps1_enabled)
	cfg.set_value("audio", "master_linear", master_linear)
	return cfg.save(settings_path)
