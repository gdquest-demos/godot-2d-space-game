# Spawns the player and the resource offloading station at the center of the
# world.
class_name StationSpawner
extends Node2D

@export var station_scene: PackedScene = null
@export var radius_player_near_station := 300.0

@onready var player_ship: PlayerShip = $PlayerShip


func spawn_station(rng: RandomNumberGenerator) -> void:
	var station := station_scene.instantiate()
	add_child(station)
	player_ship.global_position = (
		station.global_position
		+ (Vector2.UP.rotated(rng.randf_range(0, PI * 2)) * radius_player_near_station)
	)
	Events.station_spawned.emit(station, player_ship)


func get_player() -> PlayerShip:
	return player_ship
