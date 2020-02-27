extends PanelContainer
class_name PauseMenu

var inGame: bool;
var fileName: String = "user://settings.save"

func _ready():
	_hide_all()
	_load_file()


func _process(_delta):
	pass


# Connections
func resume():
	_hide_all()


func open_settings():
	_hide_all()
	_show_settings()


func leave():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()


func exit():
	get_tree().quit(1)


func change_fullscreen(_bool):
	OS.window_fullscreen = _bool
	_save_file()


func change_bullet_volume(value: float):
	var _db: float = -pow(5 * (1-value), 2)
	AudioServer.set_bus_volume_db(1,_db)
	_save_file()


func change_plane_volume(value):
	var _db: float = -pow(5 * (1-value), 2)
	AudioServer.set_bus_volume_db(2,_db)
	_save_file()


func change_fov(value):
	var _camera: Camera = get_node("/root/Game/Camera")
	_camera.fov = value
	_save_file()


func set_defaults():
	_create_file()
	_load_file()


func back_to_main():
	_hide_all()
	_show_main(inGame)


# Pane Managment
func _hide_all():
	visible = false
	get_node("Main").visible = false
	get_node("Settings").visible = false

func _show_main(_inGame: bool):
	visible = true
	get_node("Main").visible = true
	get_node("Main/Leave").visible = _inGame

func _show_settings():
	visible = true
	get_node("Settings").visible = true

# External Control
func show_pause_menu(_inGame: bool):
	inGame = _inGame
	_hide_all()
	_show_main(_inGame)

func hide_pause_menu():
	_hide_all()

# Set Values
func _set_bullet_volume(_value):
	get_node("Settings/BulletSlider").value = _value

func _set_plane_volume(_value):
	get_node("Settings/PlaneSlider").value = _value

func _set_fov(_value):
	get_node("Settings/FovSlider").value = _value

func _set_fullscreen(_value):
	get_node("Settings/CheckButton").pressed = _value

# Get Values
func _get_bullet_volume():
	return get_node("Settings/BulletSlider").value

func _get_plane_volume():
	return get_node("Settings/PlaneSlider").value

func _get_fov():
	return get_node("Settings/FovSlider").value

func _get_fullscreen():
	return get_node("Settings/CheckButton").pressed

# Settings Saving
func _create_file():
	var _file: File = File.new()
	var _dir: Directory = Directory.new()
	var _dict: Dictionary = {"fov": 70, "bulletVolume": 1, "planeVolume": 1, "fullscreen": true}
	
	if (_file.file_exists(fileName)):
# warning-ignore:return_value_discarded
		_dir.remove(fileName)
# warning-ignore:return_value_discarded
	_file.open(fileName, File.WRITE)
	_file.store_line(to_json(_dict))
	_file.close()

func _load_file():
	var _file: File = File.new()
	var _dict: Dictionary
	var _data: JSONParseResult
	
	if (not _file.file_exists(fileName)):
		_create_file()
# warning-ignore:return_value_discarded
	_file.open(fileName, File.READ)
	_data = JSON.parse(_file.get_line())
	
	if (_data.error != OK or typeof(_data.result) != TYPE_DICTIONARY):
		_file.close()
		_create_file()
		_load_file()
	
	_dict = _data.result
	if (not _dict.has_all(["fov", "bulletVolume", "planeVolume", "fullscreen"])):
		_file.close()
		_create_file()
		_load_file()
	
	_set_bullet_volume(_dict["bulletVolume"])
	_set_plane_volume(_dict["planeVolume"])
	_set_fov(_dict["fov"])
	print(_dict["fullscreen"])
	_set_fullscreen(_dict["fullscreen"])
	_file.close()
	
func _save_file():
	var _file: File = File.new()
	var _dir: Directory = Directory.new()
	var _dict: Dictionary
	
	if (_file.file_exists(fileName)):
# warning-ignore:return_value_discarded
		_dir.remove(fileName)
	_dict["bulletVolume"] = _get_bullet_volume()
	_dict["planeVolume"] = _get_plane_volume()
	_dict["fov"] = _get_fov()
	_dict["fullscreen"] = _get_fullscreen()
# warning-ignore:return_value_discarded
	_file.open(fileName, File.WRITE)
	_file.store_line(to_json(_dict))
	_file.close()
