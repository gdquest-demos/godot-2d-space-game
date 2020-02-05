extends Node2D


export var color := Color.beige

var _radius: float


func _ready() -> void:
	yield(owner, "ready")
	_radius = owner.collision_shape.shape.radius


func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, color)
