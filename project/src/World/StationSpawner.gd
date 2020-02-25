extends Node2D


export var Station: PackedScene
export var Player: PackedScene
export var radius_player_near_station := 300.0

onready var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func spawn_station() -> void:
	var station := Station.instance()
	var player := Player.instance()
	add_child(player)
	add_child(station)
	player.global_position = station.global_position + (
			Vector2.UP.rotated(rng.randf_range(0, PI*2)) * radius_player_near_station
	)
	Events.emit_signal("station_spawned", station, player)
