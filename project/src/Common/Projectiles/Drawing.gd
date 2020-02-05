extends Node2D


export var color := Color.red


func _draw() -> void:
	draw_circle(Vector2.ZERO, owner.get_node("CollisionShape2D").shape.radius, color)
