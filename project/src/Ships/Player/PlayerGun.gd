# A gun that fires a projectile when user input is provided.
extends Gun

export var fire_action := "fire"

var collision_mask: int = 0

var _input_disabled := false


func _get_configuration_warning() -> String:
	return "Missing Projectile scene, the gun will not be able to fire" if not Projectile else ""


func _physics_process(_delta: float) -> void:
	if not _input_disabled:
		if Input.is_action_pressed(fire_action):
			fire(global_position, global_rotation, collision_mask)
