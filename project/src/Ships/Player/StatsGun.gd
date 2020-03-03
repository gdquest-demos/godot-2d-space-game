# Resource that defines the base stats for a gun.
class_name StatsGun
extends Stats

export var _damage := 4.0
export var _cooldown := 0.14
export var _spread := 30.0


func _init() -> void:
	_update_all()


func get_damage() -> float:
	return get_stat("damage")


func get_cooldown() -> float:
	return get_stat("cooldown")


func get_spread() -> float:
	return get_stat("spread")
