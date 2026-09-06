extends RefCounted
## Manages user preferences (volume, fullscreen, reduced effects).
## Uses standard Godot ConfigFile at user://settings.cfg with fallback to safe defaults.

signal settings_changed

const DEFAULT_SETTINGS_PATH: String = "user://settings.cfg"
const SECTION: String = "preferences"

const DEFAULT_MASTER_VOLUME: float = 0.8
const DEFAULT_SFX_VOLUME: float = 0.8
const DEFAULT_FULLSCREEN: bool = false
const DEFAULT_REDUCED_EFFECTS: bool = false

var settings_path: String = DEFAULT_SETTINGS_PATH
var master_volume: float = DEFAULT_MASTER_VOLUME
var sfx_volume: float = DEFAULT_SFX_VOLUME
var fullscreen: bool = DEFAULT_FULLSCREEN
var reduced_effects: bool = DEFAULT_REDUCED_EFFECTS

func _init(custom_path: String = "") -> void:
	if not custom_path.is_empty():
		settings_path = custom_path

func reset_to_defaults() -> void:
	master_volume = DEFAULT_MASTER_VOLUME
	sfx_volume = DEFAULT_SFX_VOLUME
	fullscreen = DEFAULT_FULLSCREEN
	reduced_effects = DEFAULT_REDUCED_EFFECTS
	apply_all()
	save_settings()
	settings_changed.emit()

func load_settings() -> bool:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(settings_path)
	if err != OK:
		reset_to_defaults()
		return false

	master_volume = clampf(float(config.get_value(SECTION, "master_volume", DEFAULT_MASTER_VOLUME)), 0.0, 1.0)
	sfx_volume = clampf(float(config.get_value(SECTION, "sfx_volume", DEFAULT_SFX_VOLUME)), 0.0, 1.0)
	fullscreen = bool(config.get_value(SECTION, "fullscreen", DEFAULT_FULLSCREEN))
	reduced_effects = bool(config.get_value(SECTION, "reduced_effects", DEFAULT_REDUCED_EFFECTS))

	apply_all()
	settings_changed.emit()
	return true

func save_settings() -> bool:
	var config: ConfigFile = ConfigFile.new()
	config.set_value(SECTION, "master_volume", master_volume)
	config.set_value(SECTION, "sfx_volume", sfx_volume)
	config.set_value(SECTION, "fullscreen", fullscreen)
	config.set_value(SECTION, "reduced_effects", reduced_effects)
	var err: Error = config.save(settings_path)
	if err != OK:
		push_warning("SettingsManager: Failed to save settings to %s (Error %d)" % [settings_path, err])
		return false
	return true

func apply_all() -> void:
	apply_fullscreen()
	apply_audio()

func apply_fullscreen() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func apply_audio() -> void:
	var master_idx: int = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(master_volume))
		AudioServer.set_bus_mute(master_idx, master_volume <= 0.001)

	var sfx_idx: int = AudioServer.get_bus_index("SFX")
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx_volume))
		AudioServer.set_bus_mute(sfx_idx, sfx_volume <= 0.001)

func set_master_volume(val: float) -> void:
	master_volume = clampf(val, 0.0, 1.0)
	apply_audio()
	save_settings()
	settings_changed.emit()

func set_sfx_volume(val: float) -> void:
	sfx_volume = clampf(val, 0.0, 1.0)
	apply_audio()
	save_settings()
	settings_changed.emit()

func set_fullscreen(val: bool) -> void:
	fullscreen = val
	apply_fullscreen()
	save_settings()
	settings_changed.emit()

func set_reduced_effects(val: bool) -> void:
	reduced_effects = val
	save_settings()
	settings_changed.emit()
