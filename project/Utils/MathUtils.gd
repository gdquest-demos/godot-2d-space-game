# Helper global object that holds helpful mathematics functions that are not
# part of Godot.
class_name MathUtils
extends Node

# Returns the radius of a circumcircle for a triangle.
# The circumscribed circle or circumcircle of a polygon is a circle that passes
# through all the vertices of the polygon.
# Adapted from an algorithm by [mutoo](https://gist.github.com/mutoo/5617691)
static func get_triangle_circumcircle_radius(vertices: PoolVector2Array) -> float:
	assert(vertices.size() == 3)

	var a := vertices[0]
	var b := vertices[1]
	var c := vertices[2]

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
		dx = ((D * E - B * F) / G) - a.x
		dy = ((A * F - C * E) / G) - a.y

	return sqrt(dx * dx + dy * dy)
