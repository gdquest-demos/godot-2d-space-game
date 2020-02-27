extends TextureRect

onready var anim_player := $AnimationPlayer


# TODO: remove duration and move map toggle logic, see all instances of the function in the project
func _toggle_map(map_up: bool, duration: float) -> void:
	if map_up:
		anim_player.play("appear")
	else:
		anim_player.play("disappear")
