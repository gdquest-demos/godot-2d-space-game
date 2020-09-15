# Code-based special effect that animates a set of lines extending out to
# represent a 'pop'. For full effect, make a popping noise with your mouth.
extends Node2D

export var color := Color.blue
export var radius := 200.0
export var lines := 12
export var length_max := 100.0
export var distance_start := 10.0
export var distance_max := 30.0
export var duration := 0.35

var current_length := 0.0
var current_distance := 10.0
var elapsed := 0.0


func _ready() -> void:
	set_as_toplevel(true)


func _draw() -> void:
	var angle_iteration := 360.0 / lines
	for i in range(lines):
		var angle := i * angle_iteration
		var direction := GSAIUtils.angle_to_vector2(deg2rad(angle))
		draw_line(
			direction * current_distance,
			(direction * current_distance) + direction * current_length,
			color
		)


func _process(delta: float) -> void:
	elapsed += delta
	var t := elapsed / duration
	current_distance = lerp(distance_start, distance_max, t)
	current_length = lerp(0, length_max, t)
	update()
	if t >= duration:
		queue_free()
