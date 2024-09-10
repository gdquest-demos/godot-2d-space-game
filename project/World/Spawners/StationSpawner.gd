# Spawns the player and the resource offloading station at the center of the
# world.
class_name StationSpawner
extends Node2D

@export var station: PackedScene
@export var radius_player_near_station := 300.0

@onready var player_ship: PlayerShip = $PlayerShip


func spawn_station(rng: RandomNumberGenerator) -> void:
	var station_inst := station.instantiate()
	add_child(station_inst)
	player_ship.global_position = (
		station_inst.global_position
		+ (Vector2.UP.rotated(rng.randf_range(0, PI * 2)) * radius_player_near_station)
	)
	Events.emit_signal("station_spawned", station_inst, player_ship)


func get_player() -> PlayerShip:
	return player_ship
