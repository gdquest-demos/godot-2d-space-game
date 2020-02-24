extends Gun

var projectile_mask: int = 0

var _input_disabled := false

func _ready() -> void:
	Events.connect("upgrade_point_hit", self, "_on_Upgrade_Point_hit")
	Events.connect("upgrade_choice_made", self, "_on_Upgrade_choice_made")


func _get_configuration_warning() -> String:
	return "Missing Projectile scene, the gun will not be able to fire" if not Projectile else ""


func _physics_process(_delta: float) -> void:
	if not _input_disabled:
		if Input.is_action_pressed("fire"):
			fire(global_position, global_rotation, projectile_mask)


func _on_Upgrade_Point_hit() -> void:
	_input_disabled = true

func _on_Upgrade_choice_made(_choice: int) -> void:
	_input_disabled = false
