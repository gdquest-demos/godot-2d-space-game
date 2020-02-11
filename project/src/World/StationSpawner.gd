extends Node2D


signal station_spawned(station, player)


export var Station: PackedScene
export var Player: PackedScene
export var radius_player_near_station := 300.0

onready var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func spawn_station(world_size: Vector2, spawned_positions: Array) -> void:
	var shrunken_world_size := world_size/2 * 0.8
	var spawn_position: Vector2
	while true:
		var spawn_x := rng.randi_range(-1, 1)
		var spawn_y := rng.randi_range(-1, 1)
		if spawn_x == 0 and spawn_y == 0:
			continue
		spawn_position = Vector2(shrunken_world_size.x*spawn_x, shrunken_world_size.y*spawn_y)
		break
	var station := Station.instance()
	station.global_position = spawn_position
	var player := Player.instance()
	player.global_position = spawn_position + (
			Vector2.UP.rotated(rng.randf_range(-PI, PI)) * radius_player_near_station
	)
	add_child(player)
	add_child(station)
	emit_signal("station_spawned", station, player)
	spawned_positions.append(spawn_position)
