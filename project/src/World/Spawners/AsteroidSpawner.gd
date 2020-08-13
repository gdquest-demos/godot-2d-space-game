# Dots a cluster of asteroids in the world, reporting the amount of iron added
# to the world via signals. The asteroids are spawned in groups at a random
# point inside of an asteroid belt that lies a minimum distance from the player
# station's spawn point. Most of the logic is just making sure that a cluster
# doesn't appear too close to another.
class_name AsteroidSpawner
extends Node2D

export var AsteroidScene: PackedScene
export var count_min := 1
export var count_max := 5
export var spawn_radius := 150.0
export var asteroid_radius := 75.0
export var randomize_rotation := true

onready var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func spawn_random_cluster(
	world_radius: float,
	existing_clusters: Array,
	radius_from_spawn: float,
	radius_from_clusters: float,
	world: Node2D
) -> void:
	var immunity_radius := pow(radius_from_clusters, 2)

	while true:
		var spawn_position := (
			Vector2.UP.rotated(rng.randf_range(0, PI * 2))
			* rng.randf_range(radius_from_spawn, world_radius)
		)
		var impedes_cluster := false
		for c in existing_clusters:
			if spawn_position.distance_squared_to(c) < immunity_radius:
				impedes_cluster = true
				break
		if not impedes_cluster:
			_spawn_asteroid_cluster(spawn_position, existing_clusters, world)
			break


func _spawn_asteroid_cluster(spawn_position: Vector2, existing_clusters: Array, world: Node2D) -> void:
	var cluster := AsteroidCluster.new()
	cluster.spawn_asteroids(rng, count_min, count_max, spawn_radius, asteroid_radius)
