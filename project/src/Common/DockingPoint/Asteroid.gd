extends "res://src/Common/DockingPoint/DockingPoint.gd"

export var min_iron_amount := 5.0
export var max_iron_amount := 100.0

var iron_amount: float
var world: Node2D


func setup(rng: RandomNumberGenerator, _world: Node2D) -> void:
	world = _world
	iron_amount = rng.randf_range(min_iron_amount, max_iron_amount)
	scale *= iron_amount / max_iron_amount


func mine_amount(value: float) -> float:
	var mined := value
	if iron_amount - mined < 0:
		mined = iron_amount
	world.remove_iron(mined, self)
	iron_amount = iron_amount - mined
	if iron_amount == 0:
		emit_signal("died")
		queue_free()
	return mined
