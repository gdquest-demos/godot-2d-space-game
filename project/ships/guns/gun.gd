# Spawns, positions and configures a Projectile instance in space and registers
# it into the global projectiles registry. Firing rate is controlled via a
# cooldown timer.
class_name Gun
extends Node2D

@export var projectile: PackedScene
@export var stats: Resource = preload("res://ships/player/player_gun_stats.tres")

@onready var cooldown: Timer = $Cooldown


func _ready() -> void:
	stats.initialize()
	cooldown.wait_time = stats.get_cooldown()


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray(["Missing Projectile scene, the gun will not be able to fire"]) if not Projectile else PackedStringArray([])


func fire(spawn_position: Vector2, spawn_orientation: float, projectile_mask: int) -> void:
	if not cooldown.is_stopped() or not Projectile:
		return

	var spread: float = stats.get_spread()

	var projectile_inst: Projectile = projectile.instantiate()
	projectile_inst.global_position = spawn_position
	projectile_inst.rotation = spawn_orientation + deg_to_rad(random_spread(spread))
	projectile_inst.speed *= 1.0 + random_spread(0.4)
	projectile_inst.collision_mask = projectile_mask
	projectile_inst.shooter = owner
	projectile_inst.damage += stats.get_damage()

	ObjectRegistry.register_projectile(projectile_inst)
	cooldown.wait_time = stats.get_cooldown() * (1.0 + random_spread(0.2))
	cooldown.start()


func _on_Stats_stat_changed(stat_name: String, _old_value: float, new_value: float) -> void:
	match stat_name:
		"cooldown":
			cooldown.wait_time = new_value


static func random_spread(value: float) -> float:
	var half_spread := value / 2.0
	return randf_range(-half_spread, half_spread)
