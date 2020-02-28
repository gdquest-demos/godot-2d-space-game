# Spawns, positions and configures a Projectile instance in space and registers
# it into the global projectiles registry. Firing rate is controlled via a 
# cooldown timer.
class_name Gun
extends Node2D

export var Projectile: PackedScene

var damage_bonus := 0.0

onready var cooldown: Timer = $Cooldown


func _get_configuration_warning() -> String:
	return "Missing Projectile scene, the gun will not be able to fire" if not Projectile else ""


func fire(spawn_position: Vector2, spawn_orientation: float, projectile_mask: int) -> void:
	if not cooldown.is_stopped() or not Projectile:
		return

	var projectile: Projectile = Projectile.instance()
	projectile.global_position = spawn_position
	projectile.rotation = spawn_orientation
	projectile.collision_mask = projectile_mask
	projectile.shooter = owner
	projectile.damage += damage_bonus

	ObjectRegistry.register_projectile(projectile)
	cooldown.start()
