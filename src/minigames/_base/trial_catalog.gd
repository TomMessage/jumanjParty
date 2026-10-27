class_name TrialCatalog
extends RefCounted


static func script_paths() -> Array[String]:
	var found: Array[String] = ["res://src/minigames/_base/contract_trial.gd"]
	for card: TrialCard in cards():
		found.append(card.script_path)
	return found


static func cards() -> Array[TrialCard]:
	var found: Array[TrialCard] = []
	for path: String in _card_paths():
		var loaded: Variant = load(path)
		if loaded is TrialCard:
			found.append(loaded)
	return found


static func _card_paths() -> Array[String]:
	return [
		"res://src/minigames/jungle/vine_rush.tres",
		"res://src/minigames/jungle/beetle_rain.tres",
		"res://src/minigames/desert/sting_lanes.tres",
		"res://src/minigames/desert/sundial_lock.tres",
		"res://src/minigames/haunted/candle_dodge.tres",
		"res://src/minigames/haunted/portrait_waves.tres",
		"res://src/minigames/space/star_dial.tres",
		"res://src/minigames/space/gravy_orbit.tres",
		"res://src/minigames/volcano/lava_hurdles.tres",
		"res://src/minigames/volcano/marshmallow_crown.tres",
	]
