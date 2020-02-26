extends Node

export var map_transition_time := 0.35

var _spawned_positions := []
var _world_objects := []
var _map_up := false
var _map_disabled := false

onready var pirate_spawner := $World/PirateSpawner
onready var station_spawner := $World/StationSpawner
onready var asteroid_spawner := $World/AsteroidSpawner
onready var map := $ViewportContainer/MapViewport
onready var camera := $World/Camera
onready var world := $World
onready var quit_confirm := $UI/QuitConfirm


func _ready() -> void:
	# warning-ignore:return_value_discarded
	Events.connect("station_spawned", self, "_on_Spawner_station_spawned")
	# warning-ignore:return_value_discarded
	Events.connect("asteroid_spawned", self, "_on_Spawner_asteroid_spawned")
	# warning-ignore:return_value_discarded
	Events.connect("pirate_spawned", self, "_on_Spawner_pirate_spawned")
	
	camera.setup_camera_map(map)

	station_spawner.spawn_station()

	world.setup($UI/UpgradeUI)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map") and not _map_disabled:
		_map_up = not _map_up
		get_tree().call_group("MapControls", "_toggle_map", _map_up, map_transition_time)
	elif event.is_action_pressed("ui_cancel"):
		quit_confirm.visible = true
		quit_confirm.focus()
		Events.emit_signal("ui_interrupted", Events.UITypes.QUIT)


func _on_Spawner_pirate_spawned(pirate: Node) -> void:
	pirate.register_on_map(map)
	pirate.setup_world_objects(_world_objects)


func _on_Pirate_cluster_spawned(pirates: Array) -> void:
	var leader: KinematicBody2D = pirates[0]
	leader.is_squad_leader = true
	var nearest_asteroid: Vector2
	var min_distance := INF
	var cluster_position := leader.global_position
	for a in asteroid_spawner.get_children():
		var distance := cluster_position.distance_to(a.global_position)
		if distance < min_distance:
			nearest_asteroid = a.global_position
			min_distance = distance
	for p in pirates:
		p.setup_squad(p == leader, leader, nearest_asteroid, pirates)


func _on_Spawner_station_spawned(station: Node, _player: KinematicBody2D) -> void:
	_world_objects.append(weakref(station))
	station.register_on_map(map)
	Events.connect("ui_interrupted", world, "_on_UI_Interrupted")
	Events.connect("ui_interrupted", self, "_on_UI_Interrupted")
	Events.connect("ui_removed", self, "_on_UI_Removed")

	_player.register_on_map(map)
	_player.grab_camera(camera)


func _on_Spawner_asteroid_spawned(asteroid: Node) -> void:
	asteroid.register_on_map(map)
	_world_objects.append(weakref(asteroid))


func _on_UI_Removed() -> void:
	_map_disabled = false


func _on_UI_Interrupted(_type: int) -> void:
	_map_disabled = true
