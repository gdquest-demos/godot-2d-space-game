# Represents a Ship's stats, like its hull's health, its speed, etc. The stats are calculated from
# the base_* properties, with modifiers (upgrades) applied to them internally.
# To access the final stats, use the `get_*` functions, or call `get_stat()`
class_name StatsShip
extends Stats

signal health_depleted

export var _max_health := 100.0
export var _acceleration_max := 15.0
export var _linear_speed_max := 350.0
export var _angular_speed_max := 120.0
export var _angular_acceleration_max := 45.0

var health: float = _max_health setget set_health


func get_max_health() -> float:
	return get_stat("max_health")


func get_acceleration_max() -> float:
	return get_stat("acceleration_max")


func get_linear_speed_max() -> float:
	return get_stat("linear_speed_max")


func get_angular_speed_max() -> float:
	return get_stat("angular_speed_max")


func get_angular_acceleration_max() -> float:
	return get_stat("angular_acceleration_max")


func set_health(value: float) -> void:
	health = clamp(value, 0.0, _max_health)
	if is_equal_approx(health, 0.0):
		emit_signal("health_depleted")
	_update("health")
