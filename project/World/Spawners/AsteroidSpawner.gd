# Dots a cluster of asteroids in the world, reporting the amount of iron added
# to the world via signals. The asteroids are spawned in groups at a random
# point inside of an asteroid belt that lies a minimum distance from the player
# station's spawn point. Most of the logic is just making sure that a cluster
# doesn't appear too close to another.
class_name AsteroidSpawner
extends Node2D

signal cluster_depleted(iron_left)

export var count_min := 1
export var count_max := 5

export var min_distance_from_station := 800.0
export var min_distance_between_clusters := 600.0

export var cluster_radius := 150.0
export var asteroid_radius := 75.0
export var randomize_rotation := true


# Spawns new asteroids until there's enough resources to mine in the world.
# The target amount of resources is `iron_amount_balance_level`.
func spawn_asteroid_clusters(
	rng: RandomNumberGenerator, target_iron_amount: float, world_radius: float
) -> float:
	var spawned_iron := 0.0
	while spawned_iron < target_iron_amount:
		var cluster := _spawn_asteroid_cluster(rng, world_radius)
		spawned_iron += cluster.iron_amount
	return spawned_iron


# Returns the remaining amount of resources to mine on the map.
func calculate_remaining_iron() -> float:
	var sum := 0.0
	for cluster in get_children():
		sum += cluster.iron_amount
	return sum


# Generates and randomly places a new asteroid cluster, then returns the newly created instance.
func _spawn_asteroid_cluster(rng: RandomNumberGenerator, world_radius: float) -> AsteroidCluster:
	var new_cluster: AsteroidCluster
	while not new_cluster:
		var spawn_position := (
			Vector2.UP.rotated(rng.randf_range(0, PI * 2))
			* rng.randf_range(min_distance_from_station, world_radius)
		)
		for cluster in get_children():
			if (
				spawn_position.distance_squared_to(cluster.position)
				< pow(min_distance_between_clusters, 2)
			):
				continue
		new_cluster = _create_cluster(rng, spawn_position)
		break
	return new_cluster


# Creates, initializes, and returns a new cluster with its asteroids pre-generated
func _create_cluster(rng: RandomNumberGenerator, spawn_position: Vector2) -> AsteroidCluster:
	var cluster := AsteroidCluster.new()
	add_child(cluster)
	cluster.global_position = spawn_position
	cluster.spawn_asteroids(rng, count_min, count_max, cluster_radius, asteroid_radius)
	return cluster


func _on_AsteroidCluster_depleted() -> void:
	emit_signal("cluster_depleted", calculate_remaining_iron())
