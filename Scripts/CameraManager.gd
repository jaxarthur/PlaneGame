extends Node

var camera: ARVROrigin;
var player: RigidBody;
var positionOffset: Vector3 = Vector3(0,1,1)
var rotationOffset: Quat = Quat(Vector3(0,1,0),PI) * Quat(Vector3(1,0,0), 0)
var positionSpeed: float = 1
var rotationSpeed: float = 1

var positionNew: Vector3;
var rotationNew: Vector3;

var playerBasis: Basis;
var playerPosition: Vector3;

func _ready():
	if is_network_master():
		camera = get_node(NodePath("./../../../Camera"))
		player = get_node(NodePath("./.."))

func _process(_delta):
	if is_network_master():
		playerBasis = player.transform.basis
		playerPosition = player.translation
		
		positionNew = playerPosition + (playerBasis.x * positionOffset.x + playerBasis.y * positionOffset.y + playerBasis.z * positionOffset.z)
		
		camera.translation = positionNew
		
		camera.transform.basis = Quat(player.transform.basis) * rotationOffset
