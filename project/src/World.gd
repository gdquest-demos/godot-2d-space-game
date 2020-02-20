extends Node2D

export var world_radius := 8000.0
export var asteroid_radius_from_spawn := 2000
export var radius_around_clusters := 600.0

export var iron_amount_balance_level := 100.0
export var refresh_threshold_range := 25.0

var iron_amount := 0.0
var _spawned_positions := []
var _world_objects := []

onready var asteroid_spawner := $AsteroidSpawner


func setup() -> void:
	_refresh_iron()


func remove_iron(amount: float) -> void:
	iron_amount = max(iron_amount - amount, 0)
	if iron_amount < refresh_threshold_range:
		_refresh_iron()


func _refresh_iron() -> void:
	asteroid_spawner.connect("cluster_spawned", self, "_on_Spawner_spawned_asteroid")
	while iron_amount < iron_amount_balance_level:
		asteroid_spawner.spawn_random_cluster(
			world_radius,
			_spawned_positions,
			asteroid_radius_from_spawn,
			radius_around_clusters,
			self
		)


func _on_Spawner_spawned_asteroid(asteroids: Array) -> void:
	for asteroid in asteroids:
		iron_amount += asteroid.iron_amount
