extends Node

## Pulse Clash - Global Game Manager (Autoload)
## Handles offline data persistence, global state, and mobile lifecycle.

signal score_changed(new_score: int)
signal high_score_updated(new_high_score: int)
signal game_state_changed(new_state: State)

enum State {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

const SAVE_FILE_PATH := "user://pulse_clash_save.json"

var current_state: State = State.MENU:
	set(value):
		current_state = value
		game_state_changed.emit(current_state)

var current_score: int = 0:
	set(value):
		current_score = value
		score_changed.emit(current_score)
		if current_score > high_score:
			high_score = current_score

var high_score: int = 0:
	set(value):
		high_score = value
		high_score_updated.emit(high_score)
		save_offline_data()

var sound_enabled: bool = true:
	set(value):
		sound_enabled = value
		save_offline_data()

var vibration_enabled: bool = true:
	set(value):
		vibration_enabled = value
		save_offline_data()


func toggle_sound() -> bool:
	sound_enabled = not sound_enabled
	return sound_enabled


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_offline_data()


func _notification(what: int) -> void:
	# Handle Android back button navigation
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_android_back_button()


func _handle_android_back_button() -> void:
	match current_state:
		State.PLAYING:
			current_state = State.PAUSED
		State.PAUSED:
			current_state = State.MENU
		State.MENU:
			get_tree().quit()
		State.GAME_OVER:
			current_state = State.MENU


func save_offline_data() -> void:
	var data := {
		"high_score": high_score,
		"sound_enabled": sound_enabled,
		"vibration_enabled": vibration_enabled,
		"version": "1.0"
	}
	var json_str := JSON.stringify(data, "\t")
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()


func load_offline_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		return
		
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(content)
	if error == OK and json.data is Dictionary:
		var dict: Dictionary = json.data
		high_score = dict.get("high_score", 0)
		sound_enabled = dict.get("sound_enabled", true)
		vibration_enabled = dict.get("vibration_enabled", true)
