extends Gun


var projectile_mask: int = 0


func _get_configuration_warning() -> String:
	return "Missing Projectile scene, the gun will not be able to fire" if not Projectile else ""


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("fire"):
		fire(global_position, global_rotation, projectile_mask)
