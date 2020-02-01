extends Node2D


export var docking_distance := 200.0 setget _set_docking_distance
export var debug_draw_docking_radius := true setget _set_debug_draw_docking_radius
export var debug_docking_color_normal := Color(0, 1, 0, 0.05)
export var debug_docking_color_highlight := Color(0, 1, 0, 0.2)

var angle_proportion := 1.0
var player_inside := false
var radius: float

onready var docking_shape := $DockingArea/CollisionShape2D
onready var collision_shape := $KinematicBody2D/CollisionShape2D


func _ready() -> void:
	$DockingArea.connect("body_entered", self, "_on_DockingArea_body_entered")
	$DockingArea.connect("body_exited", self, "_on_DockingArea_body_exited")
	radius = collision_shape.shape.radius


func _draw() -> void:
	if debug_draw_docking_radius:
		var color := (
				debug_docking_color_normal if not player_inside else
				debug_docking_color_highlight
		)
		draw_circle(Vector2.ZERO, docking_distance, color)


func _set_debug_draw_docking_radius(value: bool) -> void:
	debug_draw_docking_radius = value
	update()


func _set_docking_distance(value: float) -> void:
	docking_distance = value
	collision_shape.shape.radius = value
	update()


func _on_DockingArea_body_entered(body: Node) -> void:
	player_inside = true
	body.can_dock = true
	update()


func _on_DockingArea_body_exited(body: Node) -> void:
	player_inside = false
	body.can_dock = false
	update()
