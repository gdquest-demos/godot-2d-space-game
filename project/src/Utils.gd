extends Node
class_name Utils


# Returns the radius of a circumcircle for a triangle.
# Adapted from algorithm by (mutoo)[https://gist.github.com/mutoo/5617691]
static func get_triangle_circumcircle_radius(points: PoolVector2Array) -> float:
	var a := points[0]
	var b := points[1]
	var c := points[2]
	
	var A := b.x - a.x
	var B := b.y - a.y
	var C := c.x - a.x
	var D := c.y - a.y
	var E := A * (a.x + b.x) + B * (a.y + b.y)
	var F := C * (a.x + c.x) + D * (a.y + c.y)
	var G := 2 * (A * (c.y - b.y) - B * (c.x - b.x))
	var dx: float
	var dy: float
	
	if abs(G) < 0.000001:
		dx = (max(a.x, max(b.x, c.x))) * 0.5
		dy = (max(a.y, max(b.y, c.y))) * 0.5
	else:
		dx = ((D*E - B*F) / G) - a.x
		dy = ((A*F - C*E) / G) - a.y
	
	return sqrt(dx * dx + dy * dy)
