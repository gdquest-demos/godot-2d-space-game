extends CollisionPolygon2D


export var color := Color.white


func _draw() -> void:
	draw_colored_polygon(polygon, color)
