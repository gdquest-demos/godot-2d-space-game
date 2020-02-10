extends Node


export var map_transition_time := 0.35

var _map_up := false

onready var player := $World/PlayerShip
onready var world_objects := get_tree().get_nodes_in_group("WorldObjects")


func _ready() -> void:
	get_tree().call_group_flags(2, "Enemies", "setup_world_objects", world_objects)
	get_tree().call_group_flags(
			2,
			"MappableObjects",
			"register_on_map",
			$MapViewport
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		_map_up = not _map_up
		get_tree().call_group("MapControls", "toggle_map", _map_up, map_transition_time)
