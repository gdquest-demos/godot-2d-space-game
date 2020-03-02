# Represents a Ship's stats, like its hull's health, its speed, etc. The stats are calculated from
# the base_* properties, with modifiers (upgrades) applied to them internally.
# To access the final stats, use the `get_*` functions, or call `get_stat()`
class_name StatsShip
extends Stats

export var _max_health := 100.0
export var _acceleration_max := 15.0
export var _linear_speed_max := 350.0
export var _angular_speed_max := 120.0
export var _angular_acceleration_max := 45.0


func _init() -> void:
	_update_all()


func get_max_health() -> float:
	return get_stat("_max_health")


func get_acceleration_max() -> float:
	return get_stat("_acceleration_max")


func get_linear_speed_max() -> float:
	return get_stat("_linear_speed_max")


func get_angular_speed_max() -> float:
	return get_stat("_angular_speed_max")


func get_angular_acceleration_max() -> float:
	return get_stat("_angular_acceleration_max")
