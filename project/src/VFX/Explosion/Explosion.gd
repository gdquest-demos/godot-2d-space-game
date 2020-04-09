extends Node2D

export var Shockwave: PackedScene

func _ready() -> void:
	var shockwave := Shockwave.instance()
	ObjectRegistry.register_distortion_effect(shockwave)
	shockwave.global_position = global_position
	shockwave.emitting = true
	shockwave.get_node("LifeSpan").start()
