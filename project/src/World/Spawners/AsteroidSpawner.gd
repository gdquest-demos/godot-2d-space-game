# Dots a cluster of asteroids in the world, reporting the amount of iron added
# to the world via signals. The asteroids are spawned in groups at a random
# point inside of an asteroid belt that lies a minimum distance from the player
# station's spawn point. Most of the logic is just making sure that a cluster
# doesn't appear too close to another.
class_name AsteroidSpawner
extends Node2D

export var count_min := 1
export var count_max := 5
export var spawn_radius := 150.0
export var asteroid_radius := 75.0
export var randomize_rotation := true


func spawn_random_cluster(
	rng: RandomNumberGenerator,
	world_radius: float,
	radius_from_spawn: float,
	radius_from_clusters: float
) -> void:
	var spawn_position := (
		Vector2.UP.rotated(rng.randf_range(0, PI * 2))
		* rng.randf_range(radius_from_spawn, world_radius)
	)
	for cluster in get_children():
		if spawn_position.distance_squared_to(cluster.position) < pow(radius_from_clusters, 2):
			return
	_spawn_asteroid_cluster(rng, spawn_position)


func _spawn_asteroid_cluster(rng: RandomNumberGenerator, spawn_position: Vector2) -> void:
	var cluster := AsteroidCluster.new()
	cluster.global_position = spawn_position
	cluster.spawn_asteroids(rng, count_min, count_max, spawn_radius, asteroid_radius)
	add_child(cluster)
