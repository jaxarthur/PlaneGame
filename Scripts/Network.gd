#New Code
extends Node
class_name Network

var code: String
var ip: String

var playerName: String = "bob"
var playerColor: Color = Color.red

var data: Dictionary = {"players": {}}
var dataPrintTimer: float = 0

var players: Players
var scoreBoard: ScoreBoard

var pauseMenu: PauseMenu
var pauseMenuActive: bool = false
var inGame: bool = false

const hex: Dictionary = {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "a": 10, "b": 11, "c": 12, "d": 13, "e": 14, "f": 15}


func _ready():
	var VR = ARVRServer.find_interface("OpenVR")
	if VR and VR.initialize():
		get_viewport().arvr = true
		get_viewport().hdr = false

		OS.vsync_enabled = false
		Engine.target_fps = 90
	
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connection_good")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connection_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_connection_lost")

	scoreBoard = get_node("/root/Game/UI/ScoreBoardPanel/ScoreBoard")
	players = get_node("/root/Game/Players")
	pauseMenu = get_node("/root/Game/PauseMenu")

func _process(delta):
	if (get_tree().network_peer != null):
		if (get_tree().is_network_server()):
			rpc_unreliable("_update_clients", data)
	
	if (Input.is_action_just_pressed("pause")):
		if (pauseMenuActive):
			pauseMenu.hide_pause_menu()
			pauseMenuActive = false
		else:
			pauseMenu.show_pause_menu(inGame)
			pauseMenuActive = true

#Peer Events
func _player_connected(_id):
	if (get_tree().is_network_server()):
		print("Adding {0}".format([_id]))
		rpc_id(_id, "_get_playerData")

func _player_disconnected(_id):
	if (get_tree().is_network_server()):
		print("Removing {0}".format([_id]))
		data["players"].erase(_id)
		

func _connection_good():
	pass

func _connection_fail():
	_display_menu(true)

func _connection_lost():
	_display_menu(true)

#Mode Calls
func host(_name, _color):
	playerName = _name
	playerColor = _color

	ip = _get_ip()
	code = _encode(ip)
	_set_code_display()
	inGame = true

	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(8008, 50)
	get_tree().set_network_peer(peer)
	_get_playerData()

func join(_code, _name, _color):
	playerName = _name
	playerColor = _color

	code = _code
	ip = _decode(code)
	_set_code_display()
	inGame = true

	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, 8008)
	get_tree().set_network_peer(peer)

remotesync func _get_playerData():
	var _id: int = get_tree().get_network_unique_id()
	
	if (get_tree().is_network_server()):
		_add_playerData(_id, playerName, playerColor)
	else:
		rpc_id(1, "_add_playerData", _id, playerName, playerColor)

remotesync func _add_playerData(_id: int, _name: String, _color: Color):
	if (get_tree().is_network_server()):
		data["players"][_id] = {"name": _name, "color": _color, "deaths": 0, "kills": 0, "health": 0}

#IP Functions
func _decode(_code: String):
	_code = _code.to_lower()
	var _ip = ""
	var _temp = 0
	for i in range(0, 8, 2):
		_temp = hex[_code[i]] * 16
		_temp = _temp + hex[_code[i+1]]
		if i != 6:
			_ip = _ip + str(_temp) + "."
		else:
			_ip = _ip + str(_temp)
	return _ip

func _encode(_ip: String):
	var _ipArray = _ip.split(".")
	var _code = ""
	var _temp = 0
	for i in _ipArray:
# warning-ignore:integer_division
		_temp = hex.keys()[int(i)/ 16]
		_temp = _temp + hex.keys()[int(i) % 16]
		_code = _code + _temp
	return _code

func _get_ip() -> String:
	var _ipArray: Array = IP.get_local_addresses()
	for i in _ipArray:
		if i != "127.0.0.1" and i.find(":") < 0:
			print_debug(i)
			return i
	return "0.0.0.0"

func _set_code_display():
	get_node("/root/Game/UI/CodeDisplay").text = "Code: {0}".format([code])

func _display_menu(_bool: bool):
	var _menu: Control = get_node("/root/Game/Menu")
	if _bool:
		_menu.show()
	else:
		_menu.hide()

remotesync func _update_clients(_data: Dictionary):
	scoreBoard.updateBoard(_data["players"])
	players.update_players(_data["players"])
