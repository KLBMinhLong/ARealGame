extends RefCounted
## Manages persistent player progress (best survival time and win stats).
## Uses standard JSON with schema versioning and safe fallback for missing/corrupted files.

const Config = preload("res://scripts/core/game_config.gd")
const DEFAULT_SAVE_PATH: String = "user://save_data.json"
const CURRENT_SCHEMA_VERSION: int = 1

var save_path: String = DEFAULT_SAVE_PATH
var schema_version: int = CURRENT_SCHEMA_VERSION
var best_survival_seconds: float = 0.0
var win_count: int = 0
var total_runs: int = 0

func _init(custom_path: String = "") -> void:
	if not custom_path.is_empty():
		save_path = custom_path

func to_dict() -> Dictionary:
	return {
		"schema_version": schema_version,
		"best_survival_seconds": best_survival_seconds,
		"win_count": win_count,
		"total_runs": total_runs
	}

func reset_to_defaults() -> void:
	schema_version = CURRENT_SCHEMA_VERSION
	best_survival_seconds = 0.0
	win_count = 0
	total_runs = 0

func load_data() -> bool:
	if not FileAccess.file_exists(save_path):
		reset_to_defaults()
		return false

	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: Failed to open %s for reading, using defaults." % save_path)
		reset_to_defaults()
		return false

	var content: String = file.get_as_text()
	file.close()

	if content.strip_edges().is_empty():
		push_warning("SaveManager: Save file is empty, using defaults.")
		reset_to_defaults()
		return false

	var parsed: Variant = JSON.parse_string(content)
	if not (parsed is Dictionary):
		push_warning("SaveManager: Corrupted save data (not a JSON dictionary), falling back to defaults.")
		reset_to_defaults()
		return false

	var dict: Dictionary = parsed as Dictionary
	schema_version = int(dict.get("schema_version", CURRENT_SCHEMA_VERSION))
	var raw_best = dict.get("best_survival_seconds", 0.0)
	if raw_best is float or raw_best is int:
		best_survival_seconds = clampf(float(raw_best), 0.0, Config.RUN_SECONDS)
	else:
		best_survival_seconds = 0.0

	var raw_wins = dict.get("win_count", 0)
	if raw_wins is int or raw_wins is float:
		win_count = maxi(0, int(raw_wins))
	else:
		win_count = 0

	var raw_runs = dict.get("total_runs", 0)
	if raw_runs is int or raw_runs is float:
		total_runs = maxi(0, int(raw_runs))
	else:
		total_runs = 0

	return true

func save_data() -> bool:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: Failed to open %s for writing. Progress not saved." % save_path)
		return false

	var json_text: String = JSON.stringify(to_dict(), "\t")
	file.store_string(json_text)
	file.close()
	return true

func record_run(elapsed: float, won: bool) -> Dictionary:
	var valid_elapsed: float = clampf(elapsed, 0.0, Config.RUN_SECONDS)
	total_runs += 1
	if won:
		win_count += 1
	var is_new_best: bool = false
	if valid_elapsed > best_survival_seconds:
		best_survival_seconds = valid_elapsed
		is_new_best = true

	save_data()
	return {
		"is_new_best": is_new_best,
		"best_survival_seconds": best_survival_seconds,
		"win_count": win_count,
		"total_runs": total_runs
	}

static func format_seconds(seconds: float) -> String:
	var sec_int: int = int(seconds)
	return "%02d:%02d" % [int(sec_int / 60.0), sec_int % 60]
