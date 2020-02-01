extends Node2D


export var color := Color.white

onready var collision_shape: CollisionPolygon2D = owner.get_node("CollisionShape")


func _draw() -> void:
	var polygon := collision_shape.polygon
	draw_polygon(polygon, [color])
