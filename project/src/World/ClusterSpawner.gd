extends Node2D


signal object_spawned(object)


export var ObjectScene: PackedScene
export var count_min := 1
export var count_max := 5
export var spawn_radius := 150.0
export var object_radius := 75.0
export var randomize_rotation := true

onready var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func spawn_random_cluster(
			world_size: Vector2,
			existing_clusters: Array,
			radius_around_spawn_min: float
	) -> void:
	var immunity_radius := pow(radius_around_spawn_min,2)
	while true:
		var spawn_x := rng.randf_range(-world_size.x/2, world_size.x/2)
		var spawn_y := rng.randf_range(-world_size.y/2, world_size.y/2)
		var spawn_position := Vector2(spawn_x, spawn_y)
		var impedes_cluster := false
		for c in existing_clusters:
			if spawn_position.distance_squared_to(c) < immunity_radius:
				impedes_cluster = true
				break
		if not impedes_cluster:
			_spawn_object_cluster(spawn_position, existing_clusters)
			break


func _spawn_object_cluster(
			spawn_position: Vector2,
			existing_clusters: Array
	) -> void:
	var count = rng.randi_range(count_min, count_max)
	existing_clusters.append(spawn_position)
	var objects := []
	var immunity_radius := object_radius * object_radius
	for _i in range(count):
		while true:
			var angle := rng.randf()*2*PI
			var radius := spawn_radius * sqrt(rng.randf())
			var object_pos := Vector2(
					spawn_position.x + (radius * cos(angle)),
					spawn_position.y + (radius * sin(angle))
			)
			var valid := true
			for o in objects:
				if object_pos.distance_squared_to(o) < immunity_radius:
					valid = false
					break
			if valid:
				_spawn_object(object_pos)
				objects.append(object_pos)
				break


func _spawn_object(position: Vector2) -> void:
	var object = ObjectScene.instance()
	object.global_position = position
	if randomize_rotation:
		object.rotation = rng.randf_range(-PI, PI)
	add_child(object)
	emit_signal("object_spawned", object)
