extends Control


onready var animator := $AnimationPlayer


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "intro":
		animator.play("idle")
