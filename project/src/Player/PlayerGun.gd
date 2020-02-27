extends Gun

var projectile_mask: int = 0

var _input_disabled := false


func _ready() -> void:
	Events.connect("ui_interrupted", self, "_on_UI_Interrupted")
	Events.connect("ui_removed", self, "_on_UI_Removed")


func _get_configuration_warning() -> String:
	return "Missing Projectile scene, the gun will not be able to fire" if not Projectile else ""


func _physics_process(_delta: float) -> void:
	if not _input_disabled:
		if Input.is_action_pressed("fire"):
			fire(global_position, global_rotation, projectile_mask)


func _on_UI_Interrupted(_type: int) -> void:
	_input_disabled = true


func _on_UI_Removed() -> void:
	_input_disabled = false
