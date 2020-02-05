extends Node


onready var player: Node = get_tree().get_nodes_in_group("Player")[0]
onready var world_objects: = get_tree().get_nodes_in_group("WorldObjects")


func _ready() -> void:
	get_tree().call_group_flags(2, "Enemies", "setup_target", player)
	get_tree().call_group_flags(2, "Enemies", "setup_world_objects", world_objects)
	get_tree().call_group_flags(2, "Camera", "setup_player", player)
