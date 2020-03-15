# Dots a cluster of asteroids in the world, reporting the amount of iron added
# to the world via signals. The asteroids are spawned in groups at a random
# point inside of an asteroid belt that lies a minimum distance from the player
# station's spawn point. Most of the logic is just making sure that a cluster
# doesn't appear too close to another.
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
	var count = rng.randi_range(count_min, count_max)
	existing_clusters.append(spawn_position)
	var objects := []
	var spawned := []
	var immunity_radius := pow(asteroid_radius, 2)
	for _i in range(count):
		while true:
			var angle := rng.randf() * 2 * PI
			var radius := spawn_radius * sqrt(rng.randf())
			var asteroid_pos := Vector2(
				spawn_position.x + (radius * cos(angle)), spawn_position.y + (radius * sin(angle))
			)
			var valid := true
			for o in objects:
				if asteroid_pos.distance_squared_to(o) < immunity_radius:
					valid = false
					break
			if valid:
				var asteroid = _spawn_asteroid(asteroid_pos, world)
				spawned.append(asteroid)
				objects.append(asteroid_pos)
				break
	Events.emit_signal("asteroid_cluster_spawned", spawned)


func _spawn_asteroid(position: Vector2, world: Node2D) -> Node2D:
	var asteroid = AsteroidScene.instance()
	asteroid.setup(rng, world)
	asteroid.global_position = position
	if randomize_rotation:
		asteroid.rotation = rng.randf_range(0, PI * 2)
	add_child(asteroid)
	Events.emit_signal("asteroid_spawned", asteroid)
	return asteroid
