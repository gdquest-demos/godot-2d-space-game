extends Node


onready var player := $World/PlayerShip
onready var world_objects := get_tree().get_nodes_in_group("WorldObjects")


func _ready() -> void:
	get_tree().call_group_flags(2, "Enemies", "setup_target", player)
	get_tree().call_group_flags(2, "Enemies", "setup_world_objects", world_objects)
