extends Node2D

var _audio_samples := [
	preload("explosion_01.wav"),
	preload("explosion_02.wav"),
	preload("explosion_03.wav"),
	preload("explosion_04.wav"),
]

@export var Shockwave: PackedScene

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Events.explosion_occurred.emit()
	
	audio.stream = _audio_samples[randi() % _audio_samples.size()]
	audio.play()
	var shockwave := Shockwave.instantiate()
	ObjectRegistry.register_distortion_effect(shockwave)
	shockwave.global_position = global_position
	shockwave.emitting = true
	shockwave.get_node("LifeSpan").autostart = true
	
	anim.play(&"Explode")
