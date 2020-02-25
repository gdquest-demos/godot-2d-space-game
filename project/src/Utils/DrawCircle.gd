extends CollisionShape2D

export var color := Color.red


func _draw() -> void:
	draw_circle(Vector2.ZERO, shape.radius, color)
