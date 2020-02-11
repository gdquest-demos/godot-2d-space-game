extends Node


export var map_transition_time := 0.35
export var radius_around_clusters := 600.0
export var world_size := Vector2(4000, 2000)
export var pirate_clusters := 10
export var asteroid_clusters := 3

var _spawned_positions := []
var _world_objects := []
var player: KinematicBody2D
var _map_up := false

onready var pirate_spawner := $World/PirateSpawner
onready var station_spawner := $World/StationSpawner
onready var asteroid_spawner := $World/AsteroidSpawner
onready var map := $MapViewport
onready var camera := $World/Camera


func _ready() -> void:
	station_spawner.connect("station_spawned", self, "_on_Spawner_station_spawned")
	pirate_spawner.connect("object_spawned", self, "_on_Spawner_pirate_spawned")
	asteroid_spawner.connect("object_spawned", self, "_on_Spawner_asteroid_spawned")
	
	station_spawner.spawn_station(world_size, _spawned_positions)
	
	for _i in range(asteroid_clusters):
		asteroid_spawner.spawn_random_cluster(
				world_size,
				_spawned_positions,
				radius_around_clusters
		)
	
	for _i in range(pirate_clusters):
		pirate_spawner.spawn_random_cluster(
				world_size,
				_spawned_positions,
				radius_around_clusters
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		_map_up = not _map_up
		get_tree().call_group("MapControls", "toggle_map", _map_up, map_transition_time)


func _on_Spawner_pirate_spawned(pirate: Node) -> void:
	pirate.register_on_map(map)
	pirate.setup_world_objects(_world_objects)


func _on_Spawner_station_spawned(
			station: Node,
			player: KinematicBody2D
	) -> void:
	
	_world_objects.append(station)
	station.register_on_map(map)
	
	player.register_on_map(map)
	player.grab_camera(camera)
	self.player = player


func _on_Spawner_asteroid_spawned(asteroid: Node) -> void:
	asteroid.register_on_map(map)
	_world_objects.append(asteroid)
