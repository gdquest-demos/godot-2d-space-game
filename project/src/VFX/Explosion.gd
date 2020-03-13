extends Node2D

export var Shrapnel: PackedScene
export var Shockwave: PackedScene
export var shrapnel_count := 5


func _ready() -> void:
	$Flare.emitting = true
	$Smoke.emitting = true
	var shockwave := Shockwave.instance()

	ObjectRegistry.register_distortion_effect(shockwave)
	shockwave.global_position = shockwave.global_position
	shockwave.emitting = true
	shockwave.get_node("LifeSpan").start()

	if Shrapnel:
		for _i in range(shrapnel_count):
			var shrapnel := Shrapnel.instance()
			ObjectRegistry.register_effect(shrapnel)
			shrapnel.global_position = global_position

	$Blast/AnimationPlayer.play("blast")


func terminate() -> void:
	queue_free()
