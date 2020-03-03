# Represents a Ship's stats, like its hull's health, its speed, etc. The stats are calculated from
# the base_* properties, with modifiers (upgrades) applied to them internally.
# To access the final stats, use the `get_*` functions, or call `get_stat()`
class_name StatsGun
extends Stats

export var _damage := 5.0
export var _cooldown := 0.4


func _init() -> void:
	_update_all()


func get_damage() -> float:
	return get_stat("damage")


func get_cooldown() -> float:
	return get_stat("cooldown")
