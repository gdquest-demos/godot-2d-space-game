extends Node


onready var world: Node2D = $World
onready var player: Node = $World/PlayerShip
onready var pirate_objects := $World/Pirates
onready var camera := $World/Camera
onready var world_objects: = get_tree().get_nodes_in_group("WorldObjects")


func _ready() -> void:
	player.connect("player_dead", self, "_on_Player_dead")
	for po in pirate_objects.get_children():
		po.setup_target(player.agent)
		po.setup_world_objects(world_objects)
	camera.setup_player(player)


func _on_Player_dead() -> void:
	for po in pirate_objects.get_children():
		po.setup_target(null)
	camera.setup_player(null)
