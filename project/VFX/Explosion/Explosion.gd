extends Node2D

var _audio_samples := [
	preload("Explosion_01.wav"),
	preload("Explosion_02.wav"),
	preload("Explosion_03.wav"),
	preload("Explosion_04.wav"),
]

export var Shockwave: PackedScene

onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	Events.emit_signal("explosion_occurred")
	
	audio.stream = _audio_samples[randi() % _audio_samples.size()]
	
	var shockwave := Shockwave.instance()
	ObjectRegistry.register_distortion_effect(shockwave)
	shockwave.global_position = global_position
	shockwave.emitting = true
	shockwave.get_node("LifeSpan").start()
