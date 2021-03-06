extends Node
class_name Bullets

var bulletObj: PackedScene = preload("res://Scenes/Bullet.tscn")
var bulletNum: int = 0
var bulletDamage: int = 25
var game: Node

func _ready():
	game = get_node("/root/Game")
	
func spawn_client(_pos, _rot):
	var _id: int = get_tree().get_network_unique_id()
	if (_id == 1):
		spawn(_pos, _rot, _id)
	else:
		rpc_id(1, "spawn", _pos, _rot, _id)

remote func spawn(_pos, _rot, _id):
	var bullet: Object = bulletObj.instance()
	bulletNum += 1
	
	bullet.set_name(str(bulletNum))
	add_child(bullet)
	bullet.translation = _pos
	bullet.rotation = _rot
	bullet.own = _id
	rpc("spawn_all", bulletNum)

remote func spawn_all(_num):
	var bullet: Node = bulletObj.instance()
	bullet.set_name(str(_num))
	add_child(bullet)

func hit(_other, _owner):
	var _otherid: int = int(_other.name)
	game.data["players"][_otherid]["health"] -= bulletDamage
	
	if (game.data["players"][_otherid]["health"] <= 0):
		game.data["players"][_owner]["kills"] += 1
		game.data["players"][_otherid]["deaths"] += 1
